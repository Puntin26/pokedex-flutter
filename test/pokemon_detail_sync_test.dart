import 'dart:async';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/core/database/app_database.dart';
import 'package:pokedex/core/domain/sync_failure.dart';
import 'package:pokedex/core/domain/sync_metadata.dart';
import 'package:pokedex/core/sync/retry_policy.dart';
import 'package:pokedex/features/favorites/data/local_favorites_repository.dart';
import 'package:pokedex/features/pokemon/data/local_pokemon_detail_repository.dart';
import 'package:pokedex/features/pokemon/data/local_pokemon_repository.dart';
import 'package:pokedex/features/pokemon/data/pokemon_detail_sync_coordinator.dart';
import 'package:pokedex/features/pokemon/data/remote_pokemon_detail_source.dart';
import 'package:pokedex/features/pokemon/domain/move_query.dart';

import 'support/detail_response.dart';

class FakeDetailSource implements RemotePokemonDetailSource {
  Future<Map<String, dynamic>> Function(int id) detail = (id) async =>
      detailResponse(detailRow());
  Future<Map<String, dynamic>> Function() efficacy = () async =>
      typeEfficacyResponse();
  final detailCalls = <int>[];
  int efficacyCalls = 0;

  @override
  Future<Map<String, dynamic>> fetchDetail(int pokemonId) {
    detailCalls.add(pokemonId);
    return detail(pokemonId);
  }

  @override
  Future<Map<String, dynamic>> fetchTypeEfficacy() {
    efficacyCalls++;
    return efficacy();
  }
}

void main() {
  late AppDatabase database;
  late LocalPokemonDetailRepository repository;
  late FakeDetailSource remote;
  late PokemonDetailSyncCoordinator sync;
  late List<String> logs;
  var now = DateTime.utc(2026, 11, 26, 12);

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = LocalPokemonDetailRepository(database);
    remote = FakeDetailSource();
    logs = [];
    now = DateTime.utc(2026, 11, 26, 12);
    sync = PokemonDetailSyncCoordinator(
      remote: remote,
      local: repository,
      clock: () => now,
      log: logs.add,
    );
  });
  tearDown(() => database.close());

  group('Sincronizacion del detalle (4.2)', () {
    test(
      'PA-02: un Pokemon no guardado se descarga, persiste y se lee',
      () async {
        expect(await repository.watchDetail(133).first, isNull);

        await sync.synchronize(133);

        final detail = (await repository.watchDetail(133).first)!;
        expect(detail.pokemon.name, 'eevee');
        expect(detail.stats, hasLength(6));
        expect(detail.pokemon.baseStatTotal, 325);
        expect(
          detail.abilities.first.ability.effectSummary,
          startsWith('Ensures'),
        );
        expect(detail.pokemon.shinyImageUrl, endsWith('shiny/133.png'));
        expect(detail.eggGroups.single.name, 'ground');
        expect(detail.evolutionMembers.map((member) => member.name), [
          'eevee',
          'vaporeon',
          'espeon',
          'leafeon',
        ]);
        expect(detail.evolutions, hasLength(3));
        expect(detail.versionGroups.map((group) => group.name), [
          'red-blue',
          'scarlet-violet',
        ]);
        expect(detail.updatedAt, now);
        // Tambien aparece en el catalogo, con su especie y generacion.
        final catalog = await LocalPokemonRepository(database)
            .watchCatalog()
            .first;
        expect(catalog.single.species!.generation!.regionName, 'kanto');
        // Registro de la consulta GraphQL en consola (verificacion de PA-02).
        expect(logs, contains(contains('[graphql] PokemonDetail #133')));
      },
    );

    test(
      'Movimientos por juego, metodo y orden, todo en SQL (RF-DET-05)',
      () async {
        await sync.synchronize(133);
        Future<List<String>> moves(MoveQuery query) async =>
            (await repository.watchMoves(query).first)
                .map((move) => '${move.name}@${move.level}')
                .toList();

        expect(
          await moves(const MoveQuery(pokemonId: 133, versionGroupId: 25)),
          ['tackle@1', 'swift@10', 'swift@20'],
        );
        expect(
          await moves(
            const MoveQuery(
              pokemonId: 133,
              versionGroupId: 25,
              learnMethod: 'egg',
            ),
          ),
          ['wish@0'],
        );
        expect(
          await moves(
            const MoveQuery(
              pokemonId: 133,
              versionGroupId: 25,
              learnMethod: null,
              sort: MoveSort.name,
            ),
          ),
          ['covet@0', 'swift@10', 'swift@20', 'tackle@1', 'wish@0'],
        );
        expect(
          await moves(const MoveQuery(pokemonId: 133, versionGroupId: 1)),
          ['tackle@1'],
        );
      },
    );

    test(
      'PA-16: abrir el detalle restaura datos alterados y no toca favoritos',
      () async {
        await sync.synchronize(133);
        await LocalFavoritesRepository(database).addFavorite(133, now);
        await (database.update(database.pokemonRecords)
              ..where((row) => row.id.equals(133)))
            .write(const PokemonRecordsCompanion(name: Value('alterado')));
        await database.delete(database.pokemonStats).go();
        await database.delete(database.pokemonMoves).go();

        await sync.synchronize(133);

        final detail = (await repository.watchDetail(133).first)!;
        expect(detail.pokemon.name, 'eevee');
        expect(detail.stats, hasLength(6));
        expect(
          await repository
              .watchMoves(const MoveQuery(pokemonId: 133, versionGroupId: 25))
              .first,
          hasLength(3),
        );
        expect(
          await LocalFavoritesRepository(database).watchFavoriteIds().first,
          {133},
        );
      },
    );

    test(
      'El detalle no borra la generacion de otras especies de la cadena',
      () async {
        await (database.into(database.generations)).insert(
          GenerationsCompanion.insert(
            id: const Value(2),
            name: 'generation-ii',
          ),
        );
        await database
            .into(database.pokemonSpecies)
            .insert(
              PokemonSpeciesCompanion.insert(
                id: const Value(196),
                name: 'espeon',
                generationId: const Value(2),
              ),
            );
        await sync.synchronize(133);
        final espeon = await (database.select(
          database.pokemonSpecies,
        )..where((row) => row.id.equals(196))).getSingle();
        expect(espeon.generationId, 2);
        expect(espeon.evolutionChainId, 67);
      },
    );

    test(
      'Abrir el mismo detalle dos veces a la vez hace una sola descarga',
      () async {
        final response = Completer<Map<String, dynamic>>();
        remote.detail = (_) => response.future;
        final first = sync.synchronize(133);
        final second = sync.synchronize(133);
        response.complete(detailResponse(detailRow()));
        await Future.wait([first, second]);
        expect(remote.detailCalls, [133]);
      },
    );

    test(
      'Un fallo conserva lo guardado y marca el recurso como fallido',
      () async {
        await sync.synchronize(133);
        remote.detail = (_) async =>
            throw const SyncFailure(SyncFailureKind.network, 'sin red');

        await expectLater(sync.synchronize(133), throwsA(isA<SyncFailure>()));

        final detail = (await repository.watchDetail(133).first)!;
        expect(detail.stats, hasLength(6));
        final metadata = (await repository.readSyncMetadata(
          PokemonDetailSyncCoordinator.resourceKey(133),
        ))!;
        expect(metadata.status, SyncStatus.failed);
        expect(metadata.lastSuccessAt, now);
        expect(metadata.lastError, contains('network'));
        // Se puede volver a intentar: el bloqueo se libero.
        remote.detail = (_) async => detailResponse(detailRow());
        await sync.synchronize(133);
      },
    );

    test(
      'Reintenta los fallos temporales con la politica de backoff',
      () async {
        var failures = 1;
        remote.detail = (_) async {
          if (failures-- > 0) {
            throw const SyncFailure(SyncFailureKind.timeout, 'lento');
          }
          return detailResponse(detailRow());
        };
        sync = PokemonDetailSyncCoordinator(
          remote: remote,
          local: repository,
          clock: () => now,
          log: logs.add,
          retryPolicy: RetryPolicy(wait: (_) async {}, log: logs.add),
        );
        await sync.synchronize(133);
        expect(remote.detailCalls, [133, 133]);
      },
    );
  });

  group('Efectividad de tipos (4.4)', () {
    test(
      'Se baja con el primer detalle y no se repite mientras esta vigente',
      () async {
        await sync.synchronize(133);
        await sync.synchronize(133);
        expect(remote.efficacyCalls, 1);
        final rows = await repository.watchTypeEfficacy().first;
        expect(rows, hasLength(6));
        // Los tipos sin tabla (stellar, shadow) no quedan en el catalogo.
        final types = await LocalPokemonRepository(database).watchTypes().first;
        expect(types.map((type) => type.name), isNot(contains('stellar')));

        now = now.add(const Duration(hours: 25));
        await sync.synchronize(133);
        expect(remote.efficacyCalls, 2);
      },
    );

    test('Si falla la tabla de tipos, el detalle igual se guarda', () async {
      remote.efficacy = () async =>
          throw const SyncFailure(SyncFailureKind.serviceUnavailable, '503');
      await sync.synchronize(133);
      expect((await repository.watchDetail(133).first)!.stats, hasLength(6));
      expect(logs, contains(contains('efectividad de tipos')));
    });
  });
}
