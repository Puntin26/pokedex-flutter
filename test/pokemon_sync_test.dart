import 'dart:async';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/core/database/app_database.dart';
import 'package:pokedex/core/domain/sync_failure.dart';
import 'package:pokedex/core/domain/sync_metadata.dart';
import 'package:pokedex/features/favorites/data/local_favorites_repository.dart';
import 'package:pokedex/features/pokemon/data/local_pokemon_repository.dart';
import 'package:pokedex/features/pokemon/data/pokemon_sync_coordinator.dart';
import 'package:pokedex/features/pokemon/data/remote_pokemon_source.dart';
import 'package:pokedex/features/pokemon/domain/pokemon.dart';

import 'support/catalog_response.dart';

class FakeRemote implements RemotePokemonSource {
  FakeRemote(this.respond);

  Future<Map<String, dynamic>> Function(int limit, int offset) respond;
  final offsets = <int>[];

  @override
  Future<Map<String, dynamic>> fetchPage({
    required int limit,
    required int offset,
  }) {
    offsets.add(offset);
    return respond(limit, offset);
  }
}

class FailingLocal extends LocalPokemonRepository {
  FailingLocal(super.database);
  bool failSave = true;
  bool failStatus = false;

  @override
  Future<void> savePage(List<Pokemon> pokemon, SyncMetadata metadata) {
    if (failSave) throw StateError('disk unavailable');
    return super.savePage(pokemon, metadata);
  }

  @override
  Future<void> updateSyncStatus(
    String resourceKey,
    SyncStatus status, {
    String? lastError,
  }) {
    if (failStatus) throw StateError('status unavailable');
    return super.updateSyncStatus(resourceKey, status, lastError: lastError);
  }
}

const resource = PokemonSyncCoordinator.resourceKey;

void main() {
  late AppDatabase database;
  late LocalPokemonRepository local;
  late FakeRemote remote;
  late PokemonSyncCoordinator sync;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    local = LocalPokemonRepository(database);
    remote = FakeRemote(
      (limit, offset) async => catalogResponse(
        List.generate(
          (5 - offset).clamp(0, limit),
          (index) => catalogRow(offset + index + 1),
        ),
        total: 5,
      ),
    );
    sync = PokemonSyncCoordinator(remote: remote, local: local, pageSize: 2);
  });
  tearDown(() => database.close());

  test(
    'Multiples paginas emiten datos locales y metadata confirmada',
    () async {
      final firstPage = Completer<void>();
      final release = Completer<void>();
      final original = remote.respond;
      remote.respond = (limit, offset) async {
        if (offset == 2) {
          firstPage.complete();
          await release.future;
        }
        return original(limit, offset);
      };
      final catalogEvents = <List<Pokemon>>[];
      final subscription = local.watchCatalog().listen(catalogEvents.add);
      addTearDown(subscription.cancel);
      final running = sync.synchronize();
      await firstPage.future;
      final progress = await local.readSyncMetadata(resource);
      expect(progress!.nextOffset, 2);
      expect(progress.status, SyncStatus.syncing);
      expect(progress.totalCount, 5);
      expect(progress.isComplete, isFalse);
      expect(await local.watchCatalog().first, hasLength(2));
      release.complete();
      await running;
      expect(remote.offsets, [0, 2, 4]);
      expect((await local.watchCatalog().first).map((item) => item.id), [
        1,
        2,
        3,
        4,
        5,
      ]);
      expect(catalogEvents.any((items) => items.length == 2), isTrue);
      final metadata = (await local.readSyncMetadata(resource))!;
      expect(metadata.nextOffset, 5);
      expect(metadata.totalCount, 5);
      expect(metadata.status, SyncStatus.success);
      expect(metadata.isComplete, isTrue);
      expect(metadata.lastError, isNull);
      expect(metadata.lastSuccessAt, isNotNull);
    },
  );

  test(
    'Termina sin pagina extra si el total es multiplo del limite o cero',
    () async {
      for (final total in [4, 0]) {
        remote.offsets.clear();
        remote.respond = (limit, offset) async => catalogResponse(
          List.generate(
            (total - offset).clamp(0, limit),
            (index) => catalogRow(offset + index + 1),
          ),
          total: total,
        );
        await sync.synchronize(restart: true);
        expect(remote.offsets, total == 0 ? [0] : [0, 2]);
        final metadata = (await local.readSyncMetadata(resource))!;
        expect(metadata.nextOffset, total);
        expect(metadata.isComplete, isTrue);
      }
      // Una respuesta vacia valida nunca borra el catalogo previo.
      expect(await local.watchCatalog().first, hasLength(4));
    },
  );

  test('Tres sincronizaciones completas actualizan sin duplicar ni tocar favoritos', () async {
    final favorites = LocalFavoritesRepository(database);
    await sync.synchronize();
    final favoriteAt = DateTime.utc(2026, 11, 15);
    await favorites.addFavorite(1, favoriteAt);
    remote.respond = (limit, offset) async => catalogResponse(
      List.generate(
        (5 - offset).clamp(0, limit),
        (index) => catalogRow(
          offset + index + 1,
          name: 'updated-${offset + index + 1}',
        ),
      ),
      total: 5,
    );
    await sync.synchronize();
    await sync.synchronize();
    expect(remote.offsets, [0, 2, 4, 0, 2, 4, 0, 2, 4]);
    expect(await local.watchCatalog().first, hasLength(5));
    expect(await local.watchTypes().first, hasLength(2));
    final favorite = (await favorites.watchFavorites().first).single;
    expect(favorite.pokemon.name, 'updated-1');
    expect(favorite.createdAt, favoriteAt);
    final links = await database.select(database.pokemonTypeLinks).get();
    expect(links, hasLength(10));
  });

  test(
    'Fallo remoto conserva progreso y reanuda incluso con otro coordinador',
    () async {
      final original = remote.respond;
      remote.respond = (limit, offset) {
        if (offset == 2) {
          throw const SyncFailure(SyncFailureKind.network, 'offline');
        }
        return original(limit, offset);
      };
      await expectLater(sync.synchronize(), throwsA(isA<SyncFailure>()));
      final failed = (await local.readSyncMetadata(resource))!;
      expect(failed.nextOffset, 2);
      expect(failed.status, SyncStatus.failed);
      expect(failed.lastError, contains('network'));
      expect(failed.lastSuccessAt, isNotNull);
      expect(await local.watchCatalog().first, hasLength(2));
      remote.respond = original;
      await PokemonSyncCoordinator(
        remote: remote,
        local: local,
        pageSize: 2,
      ).synchronize();
      expect(remote.offsets, [0, 2, 2, 4]);
      expect((await local.readSyncMetadata(resource))!.lastError, isNull);
    },
  );

  test('Reinicio explicito comienza en cero tras una interrupcion', () async {
    await local.savePage(
      [],
      const SyncMetadata(
        resourceKey: resource,
        nextOffset: 2,
        totalCount: 5,
        status: SyncStatus.syncing,
      ),
    );
    await sync.synchronize(restart: true);
    expect(remote.offsets, [0, 2, 4]);
  });

  test(
    'Respuesta invalida no sobrescribe catalogo, favoritos ni fecha correcta',
    () async {
      await sync.synchronize();
      final previous = (await local.readSyncMetadata(resource))!;
      final favorites = LocalFavoritesRepository(database);
      await favorites.addFavorite(1, DateTime.utc(2026));
      remote.respond = (limit, offset) async => catalogResponse([
        catalogRow(1, name: 'should-not-save'),
        catalogRow(2)..remove('pokemontypes'),
      ], total: 5);
      await expectLater(sync.synchronize(), throwsA(isA<SyncFailure>()));
      final result = await local.watchCatalog().first;
      expect(result.first.name, 'pokemon-1');
      expect(result, hasLength(5));
      final metadata = (await local.readSyncMetadata(resource))!;
      expect(metadata.nextOffset, previous.nextOffset);
      expect(metadata.lastSuccessAt, previous.lastSuccessAt);
      expect(metadata.isComplete, isTrue);
      expect(metadata.status, SyncStatus.failed);
      expect(await favorites.watchFavorites().first, hasLength(1));
    },
  );

  test(
    'Cambio de total requiere reinicio y no avanza la pagina afectada',
    () async {
      final original = remote.respond;
      remote.respond = (limit, offset) async {
        final data = await original(limit, offset);
        if (offset == 2) {
          data['pokemon_aggregate'] = {
            'aggregate': {'count': 6},
          };
        }
        return data;
      };
      await expectLater(sync.synchronize(), throwsA(isA<SyncFailure>()));
      expect((await local.readSyncMetadata(resource))!.nextOffset, 2);
      expect(await local.watchCatalog().first, hasLength(2));
      remote.respond = original;
      await sync.synchronize(restart: true);
      expect(await local.watchCatalog().first, hasLength(5));
    },
  );

  test(
    'IDs repetidos entre paginas fallan sin avanzar ni generar un ciclo',
    () async {
      remote.respond = (limit, offset) async => catalogResponse(
        offset == 0
            ? [catalogRow(1), catalogRow(2)]
            : [catalogRow(2), catalogRow(3)],
        total: 5,
      );
      await expectLater(sync.synchronize(), throwsA(isA<SyncFailure>()));
      expect(remote.offsets, [0, 2]);
      expect((await local.readSyncMetadata(resource))!.nextOffset, 2);
    },
  );

  test(
    'Una transaccion fallida revierte datos y offset y permite reintentar',
    () async {
      await database.customStatement('''
      CREATE TRIGGER fail_second BEFORE INSERT ON pokemon
      WHEN NEW.id = 2 BEGIN SELECT RAISE(ABORT, 'test failure'); END;
    ''');
      await expectLater(
        sync.synchronize(),
        throwsA(
          isA<SyncFailure>().having(
            (error) => error.kind,
            'kind',
            SyncFailureKind.storage,
          ),
        ),
      );
      expect(await local.watchCatalog().first, isEmpty);
      expect((await local.readSyncMetadata(resource))!.nextOffset, 0);
      await database.customStatement('DROP TRIGGER fail_second');
      await sync.synchronize();
      expect(remote.offsets, [0, 0, 2, 4]);
      expect(await local.watchCatalog().first, hasLength(5));
    },
  );

  test('Libera bloqueo aun si falla guardar y registrar el error', () async {
    final failing = FailingLocal(database)..failStatus = true;
    final coordinator = PokemonSyncCoordinator(
      remote: remote,
      local: failing,
      pageSize: 2,
    );
    await expectLater(coordinator.synchronize(), throwsA(isA<SyncFailure>()));
    failing.failStatus = false;
    await expectLater(coordinator.synchronize(), throwsA(isA<SyncFailure>()));
    failing.failSave = false;
    await coordinator.synchronize();
    expect(await local.watchCatalog().first, hasLength(5));
  });

  test(
    'Llamadas simultaneas comparten intento y resultado tambien tras error',
    () async {
      final pending = Completer<Map<String, dynamic>>();
      remote.respond = (limit, offset) => pending.future;
      final first = sync.synchronize();
      final second = sync.synchronize(restart: true);
      expect(identical(first, second), isTrue);
      final assertion = expectLater(first, throwsA(isA<SyncFailure>()));
      await Future<void>.delayed(Duration.zero);
      pending.completeError(
        const SyncFailure(SyncFailureKind.timeout, 'test timeout'),
      );
      await assertion;
      expect(remote.offsets, [0]);
      remote.respond = (limit, offset) async => catalogResponse([], total: 0);
      final retry = sync.synchronize();
      expect(identical(retry, first), isFalse);
      await retry;
      expect(remote.offsets, [0, 0]);
    },
  );

  test(
    'Reabre SQLite en disco y reanuda desde la ultima pagina confirmada',
    () async {
      await database.close();
      final directory = await Directory.systemTemp.createTemp('pokedex_sync_');
      final file = File('${directory.path}/catalog.sqlite');
      var disk = AppDatabase(NativeDatabase(file));
      try {
        var repository = LocalPokemonRepository(disk);
        final original = remote.respond;
        remote.respond = (limit, offset) {
          if (offset == 2) {
            throw const SyncFailure(SyncFailureKind.network, 'offline');
          }
          return original(limit, offset);
        };
        await expectLater(
          PokemonSyncCoordinator(
            remote: remote,
            local: repository,
            pageSize: 2,
          ).synchronize(),
          throwsA(isA<SyncFailure>()),
        );
        await LocalFavoritesRepository(disk).addFavorite(1, DateTime.utc(2026));
        await disk.close();
        disk = AppDatabase(NativeDatabase(file));
        repository = LocalPokemonRepository(disk);
        expect((await repository.readSyncMetadata(resource))!.nextOffset, 2);
        remote.respond = original;
        await PokemonSyncCoordinator(
          remote: remote,
          local: repository,
          pageSize: 2,
        ).synchronize();
        expect(remote.offsets, [0, 2, 2, 4]);
        expect(await repository.watchCatalog().first, hasLength(5));
        expect(
          await LocalFavoritesRepository(disk).watchFavorites().first,
          hasLength(1),
        );
      } finally {
        await disk.close();
        await directory.delete(recursive: true);
      }
    },
  );
}
