import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pokedex/app/app.dart';
import 'package:pokedex/app/connection_status_provider.dart';
import 'package:pokedex/app/pokemon_dependencies.dart';
import 'package:pokedex/core/connectivity/connection_monitor.dart';
import 'package:pokedex/core/database/app_database.dart';
import 'package:pokedex/core/domain/sync_activity.dart';
import 'package:pokedex/core/domain/sync_metadata.dart';
import 'package:pokedex/features/pokemon/data/local_pokemon_repository.dart';
import 'package:pokedex/features/pokemon/domain/pokemon.dart';
import 'package:pokedex/features/pokemon/domain/pokemon_sync.dart';

class IdleSync implements PokemonSync {
  @override
  Future<void> synchronize({bool restart = false}) async {}
  @override
  SyncActivity get activity => SyncActivity.idle;
  @override
  Stream<SyncActivity> watchActivity() => Stream.value(SyncActivity.idle);
}

Pokemon samplePokemon(int id, String name) => Pokemon(
  id: id,
  nationalNumber: id,
  name: name,
  updatedAt: DateTime.utc(2026),
  types: const [
    PokemonTypeSlot(type: PokemonType(id: 12, name: 'grass'), slot: 1),
  ],
);

/// App completa sobre SQLite en memoria, sin red (modo avion) y sin sync real.
class AppHarness {
  AppHarness() : database = AppDatabase(NativeDatabase.memory());

  final AppDatabase database;
  late final LocalPokemonRepository pokemon = LocalPokemonRepository(database);
  ProviderContainer? container;

  Future<void> seed(WidgetTester tester, List<Pokemon> items) =>
      tester.runAsync(
        () => pokemon.savePage(
          items,
          SyncMetadata(
            resourceKey: 'pokemon_catalog',
            nextOffset: items.length,
            totalCount: items.length,
            status: SyncStatus.success,
            lastSuccessAt: DateTime.utc(2026),
            isComplete: true,
          ),
        ),
      );

  // pump(Duration.zero) ejecuta los Timer.run con que Drift cierra streams.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 10; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await tester.pump(Duration.zero);
    }
  }

  Future<void> mount(
    WidgetTester tester, {
    List<Override> overrides = const [],
    double width = 800,
    double textScale = 1,
  }) async {
    tester.view.physicalSize = Size(width, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    addTearDown(dispose);
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        pokemonRepositoryProvider.overrideWithValue(pokemon),
        pokemonSyncProvider.overrideWithValue(IdleSync()),
        connectionMonitorProvider.overrideWithValue(
          ConnectionMonitor(
            hasNetwork: () async => false,
            networkChanges: const Stream.empty(),
            isServiceAvailable: () async => false,
          ),
        ),
        ...overrides,
      ],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container!,
        // Sin envoltorio con escala 1: la app toma MediaQuery de la vista real,
        // incluidas las opciones de accesibilidad que cambie el test.
        child: textScale == 1
            ? const PokedexApp()
            : MediaQuery(
                data: MediaQueryData.fromView(tester.view)
                    .copyWith(textScaler: TextScaler.linear(textScale)),
                child: const PokedexApp(),
              ),
      ),
    );
    await settle(tester);
  }

  /// Simula cerrar la app: se descarta el alcance, la base sigue.
  void dispose() {
    container?.dispose();
    container = null;
  }
}
