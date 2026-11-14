import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pokedex/app/app.dart';
import 'package:pokedex/app/connection_status_provider.dart';
import 'package:pokedex/app/pokemon_dependencies.dart';
import 'package:pokedex/core/database/app_database.dart';
import 'package:pokedex/core/connectivity/connection_monitor.dart';
import 'package:pokedex/core/domain/sync_failure.dart';
import 'package:pokedex/core/domain/sync_metadata.dart';
import 'package:pokedex/features/pokemon/data/local_pokemon_repository.dart';
import 'package:pokedex/features/pokemon/data/pokemon_page_dto.dart';
import 'package:pokedex/features/pokemon/data/pokemon_sync_coordinator.dart';
import 'package:pokedex/features/pokemon/data/remote_pokemon_source.dart';
import 'package:pokedex/features/pokemon/domain/pokemon.dart';
import 'package:pokedex/features/pokemon/presentation/pokemon_catalog_controller.dart';
import 'package:pokedex/features/pokemon/presentation/pokemon_catalog_state.dart';

import 'support/catalog_response.dart';

class ControlledRemote implements RemotePokemonSource {
  Future<Map<String, dynamic>> Function(int limit, int offset) respond = (
    limit,
    offset,
  ) async => catalogResponse([], total: 0);
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

class FailingRepository extends LocalPokemonRepository {
  FailingRepository(super.database);
  bool failRead = false;
  bool failStatus = false;

  @override
  Stream<List<Pokemon>> watchCatalog() {
    return failRead
        ? Stream.error(StateError('Fallo de lectura local'))
        : super.watchCatalog();
  }

  @override
  Future<void> updateSyncStatus(
    String resourceKey,
    SyncStatus status, {
    String? lastError,
  }) async {
    if (failStatus) throw StateError('Fallo de escritura local');
    await super.updateSyncStatus(resourceKey, status, lastError: lastError);
  }
}

// Deja avanzar SQLite en tiempo real sin esperar una descarga pendiente.
Future<void> pumpUntil(WidgetTester tester, bool Function() ready) async {
  for (var attempt = 0; attempt < 100; attempt++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await tester.pump(const Duration(milliseconds: 16));
    if (ready()) return;
  }
  fail('La pantalla no alcanzo el estado esperado.');
}

void main() {
  late AppDatabase database;
  late FailingRepository local;
  late ControlledRemote remote;
  ProviderContainer? container;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    local = FailingRepository(database);
    remote = ControlledRemote();
  });
  tearDown(() async {
    container?.dispose();
    container = null;
    await database.close();
  });

  Future<void> mount(WidgetTester tester, {int pageSize = 2}) async {
    addTearDown(() {
      container?.dispose();
      container = null;
    });
    final sync = PokemonSyncCoordinator(
      remote: remote,
      local: local,
      pageSize: pageSize,
    );
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        pokemonRepositoryProvider.overrideWithValue(local),
        pokemonSyncProvider.overrideWithValue(sync),
        connectionMonitorProvider.overrideWithValue(
          ConnectionMonitor(
            hasNetwork: () async => false,
            networkChanges: const Stream.empty(),
            isServiceAvailable: () async => false,
          ),
        ),
      ],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container!,
        child: const PokedexApp(),
      ),
    );
  }

  Future<void> savePokemon(WidgetTester tester, List<int> ids) async {
    await tester.runAsync(() async {
      final page = PokemonPageDto.fromJson(
        catalogResponse(ids.map(catalogRow).toList(), total: ids.length),
        limit: ids.length,
        offset: 0,
      );
      await local.savePage(
        page.toDomain(DateTime.utc(2026, 11, 15)),
        SyncMetadata(
          resourceKey: catalogResourceKey,
          nextOffset: ids.length,
          totalCount: ids.length,
          status: SyncStatus.success,
          isComplete: true,
        ),
      );
    });
  }

  testWidgets('La pantalla aparece antes de que responda la descarga', (
    tester,
  ) async {
    final response = Completer<Map<String, dynamic>>();
    remote.respond = (limit, offset) => response.future;
    await mount(tester);
    expect(find.text('Pokedex'), findsOneWidget);
    expect(find.text('Cargando catalogo...'), findsOneWidget);
    await pumpUntil(tester, () => remote.offsets.isNotEmpty);
    expect(
      container!.read(pokemonCatalogStateProvider).status,
      PokemonCatalogStatus.loading,
    );
    response.complete(catalogResponse([], total: 0));
    await pumpUntil(
      tester,
      () => find.text('No hay Pokemon guardados.').evaluate().isNotEmpty,
    );
    expect(
      container!.read(pokemonCatalogStateProvider).status,
      PokemonCatalogStatus.empty,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Muestra datos guardados mientras la red sigue pendiente y si falla',
    (tester) async {
      await savePokemon(tester, [1, 2]);
      final response = Completer<Map<String, dynamic>>();
      remote.respond = (limit, offset) => response.future;
      await mount(tester);
      await pumpUntil(
        tester,
        () => find.text('pokemon-1').evaluate().isNotEmpty,
      );
      expect(find.text('#1'), findsOneWidget);
      expect(find.text('Actualizando catalogo...'), findsOneWidget);
      expect(
        container!.read(pokemonCatalogStateProvider).status,
        PokemonCatalogStatus.data,
      );
      response.completeError(
        const SyncFailure(SyncFailureKind.network, 'Sin conexion.'),
      );
      await pumpUntil(
        tester,
        () => find.text('Sin conexion.').evaluate().isNotEmpty,
      );
      expect(find.text('pokemon-1'), findsOneWidget);
      expect(find.text('pokemon-2'), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Una pagina llega por SQLite y permite scroll y navegar durante la siguiente',
    (tester) async {
      final secondPage = Completer<Map<String, dynamic>>();
      remote.respond = (limit, offset) async {
        if (offset == 30) return secondPage.future;
        return catalogResponse(
          List.generate(30, (index) => catalogRow(index + 1)),
          total: 31,
        );
      };
      await mount(tester, pageSize: 30);
      await pumpUntil(
        tester,
        () =>
            remote.offsets.length == 2 &&
            find.text('pokemon-1').evaluate().isNotEmpty,
      );
      expect(container!.read(localCatalogProvider).value, hasLength(30));
      expect(container!.read(catalogMetadataProvider).value!.nextOffset, 30);
      expect(find.text('Actualizando catalogo...'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('pokemon-30'), 400);
      expect(find.text('pokemon-30'), findsOneWidget);

      // Esta ruta comprueba el Navigator sin agregar otra pantalla al producto.
      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      unawaited(
        navigator.push(
          MaterialPageRoute<void>(
            builder: (_) => const Scaffold(body: Text('Ruta de prueba')),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Ruta de prueba'), findsOneWidget);
      expect(find.text('Offline'), findsOneWidget);
      navigator.pop();
      await tester.pumpAndSettle();
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container!,
          child: const PokedexApp(),
        ),
      );
      expect(remote.offsets, [0, 30]);
      secondPage.complete(catalogResponse([catalogRow(31)], total: 31));
      await pumpUntil(
        tester,
        () =>
            container!.read(localCatalogProvider).value?.length == 31 &&
            !container!.read(pokemonCatalogStateProvider).isSyncing,
      );
      expect(remote.offsets, [0, 30]);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Error sin datos y reintento que muestra datos locales', (
    tester,
  ) async {
    remote.respond = (limit, offset) async => throw const SyncFailure(
      SyncFailureKind.timeout,
      'Tiempo de espera agotado.',
    );
    await mount(tester);
    await pumpUntil(
      tester,
      () => find.text('Tiempo de espera agotado.').evaluate().isNotEmpty,
    );
    expect(
      container!.read(pokemonCatalogStateProvider).status,
      PokemonCatalogStatus.error,
    );
    final response = Completer<Map<String, dynamic>>();
    remote.respond = (limit, offset) => response.future;
    await tester.tap(find.text('Reintentar'));
    await pumpUntil(tester, () => remote.offsets.length == 2);
    expect(find.text('Cargando catalogo...'), findsOneWidget);
    response.complete(catalogResponse([catalogRow(1)], total: 1));
    await pumpUntil(
      tester,
      () =>
          find.text('pokemon-1').evaluate().isNotEmpty &&
          find.text('Reintentar').evaluate().isEmpty,
    );
    expect(remote.offsets, [0, 0]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Reintentar reanuda y no duplica llamadas simultaneas', (
    tester,
  ) async {
    remote.respond = (limit, offset) async {
      if (offset == 2) {
        throw const SyncFailure(SyncFailureKind.network, 'Sin conexion.');
      }
      return catalogResponse([catalogRow(1), catalogRow(2)], total: 3);
    };
    await mount(tester);
    await pumpUntil(
      tester,
      () => find.text('Sin conexion.').evaluate().isNotEmpty,
    );
    final response = Completer<Map<String, dynamic>>();
    remote.respond = (limit, offset) => response.future;
    await tester.tap(find.text('Reintentar'));
    unawaited(container!.read(catalogSyncControllerProvider.notifier).retry());
    await pumpUntil(tester, () => remote.offsets.length == 3);
    expect(remote.offsets, [0, 2, 2]);
    expect(find.text('pokemon-1'), findsOneWidget);
    response.complete(catalogResponse([catalogRow(3)], total: 3));
    await pumpUntil(
      tester,
      () =>
          find.text('pokemon-3').evaluate().isNotEmpty &&
          !container!.read(pokemonCatalogStateProvider).isSyncing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Un catalogo remoto que cambia permite reiniciar con Reintentar',
    (tester) async {
      remote.respond = (limit, offset) async => catalogResponse([
        catalogRow(offset + 1),
        catalogRow(offset + 2),
      ], total: offset == 0 ? 3 : 4);
      await mount(tester);
      await pumpUntil(
        tester,
        () => find.text('Reintentar').evaluate().isNotEmpty,
      );
      remote.respond = (limit, offset) async => catalogResponse([
        catalogRow(offset + 1),
        catalogRow(offset + 2),
      ], total: 4);
      await tester.tap(find.text('Reintentar'));
      await pumpUntil(
        tester,
        () =>
            find.text('pokemon-4').evaluate().isNotEmpty &&
            !container!.read(pokemonCatalogStateProvider).isSyncing,
      );
      expect(remote.offsets, [0, 2, 0, 2]);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Recibe cambios locales de datos y metadata sin otra llamada remota',
    (tester) async {
      await mount(tester);
      await pumpUntil(
        tester,
        () =>
            container!.read(pokemonCatalogStateProvider).status ==
            PokemonCatalogStatus.empty,
      );
      await savePokemon(tester, [7]);
      await pumpUntil(
        tester,
        () => find.text('pokemon-7').evaluate().isNotEmpty,
      );
      await tester.runAsync(
        () => local.updateSyncStatus(
          catalogResourceKey,
          SyncStatus.failed,
          lastError: 'Fallo remoto previo',
        ),
      );
      await pumpUntil(
        tester,
        () => find.text('Reintentar').evaluate().isNotEmpty,
      );
      expect(find.text('pokemon-7'), findsOneWidget);
      expect(remote.offsets, [0]);
    },
  );

  testWidgets('El reintento se suscribe de nuevo despues de un fallo local', (
    tester,
  ) async {
    local.failRead = true;
    await mount(tester);
    await pumpUntil(
      tester,
      () =>
          find
              .text('No se pudo leer el catalogo local.')
              .evaluate()
              .isNotEmpty &&
          !container!.read(pokemonCatalogStateProvider).isSyncing,
    );
    local.failRead = false;
    await tester.tap(find.text('Reintentar'));
    await pumpUntil(
      tester,
      () =>
          container!.read(pokemonCatalogStateProvider).status ==
          PokemonCatalogStatus.empty,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Un fallo al guardar metadata tambien tiene mensaje y reintento',
    (tester) async {
      local.failStatus = true;
      await mount(tester);
      await pumpUntil(
        tester,
        () => find
            .text('No se pudo leer o guardar el catalogo local.')
            .evaluate()
            .isNotEmpty,
      );
      expect(find.text('Reintentar'), findsOneWidget);
      local.failStatus = false;
      await tester.tap(find.text('Reintentar'));
      await pumpUntil(
        tester,
        () =>
            container!.read(pokemonCatalogStateProvider).status ==
            PokemonCatalogStatus.empty,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Descartar el alcance durante una descarga atiende el error tardio',
    (tester) async {
      final response = Completer<Map<String, dynamic>>();
      remote.respond = (limit, offset) => response.future;
      await mount(tester);
      await pumpUntil(tester, () => remote.offsets.isNotEmpty);
      await tester.pumpWidget(const SizedBox());
      await tester.runAsync(() async {
        container!.dispose();
        container = null;
        response.completeError(
          const SyncFailure(SyncFailureKind.network, 'Sin conexion.'),
        );
        await local
            .watchSyncMetadata(catalogResourceKey)
            .firstWhere((metadata) => metadata?.status == SyncStatus.failed);
      });
      await tester.pump();
      expect(tester.takeException(), isNull);
    },
  );
}
