import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pokedex/app/app.dart';
import 'package:pokedex/app/connection_status_provider.dart';
import 'package:pokedex/app/pokemon_dependencies.dart';
import 'package:pokedex/app/settings_provider.dart';
import 'package:pokedex/core/connectivity/connection_monitor.dart';
import 'package:pokedex/core/database/app_database.dart';
import 'package:pokedex/core/database/local_settings_repository.dart';
import 'package:pokedex/core/domain/sync_activity.dart';
import 'package:pokedex/core/domain/sync_metadata.dart';
import 'package:pokedex/features/pokemon/data/local_pokemon_repository.dart';
import 'package:pokedex/features/pokemon/domain/catalog_query.dart';
import 'package:pokedex/features/pokemon/domain/pokemon.dart';
import 'package:pokedex/features/pokemon/domain/pokemon_sync.dart';
import 'package:pokedex/features/pokemon/presentation/catalog_filter_bar.dart';
import 'package:pokedex/features/pokemon/presentation/catalog_query_controller.dart';

import 'support/fake_settings.dart';

class IdleSync implements PokemonSync {
  @override
  Future<void> synchronize({bool restart = false}) async {}
  @override
  SyncActivity get activity => SyncActivity.idle;
  @override
  Stream<SyncActivity> watchActivity() => Stream.value(SyncActivity.idle);
}

const grass = PokemonType(id: 12, name: 'grass');
const fire = PokemonType(id: 10, name: 'fire');
const electric = PokemonType(id: 13, name: 'electric');
const gen1 = Generation(id: 1, name: 'generation-i', regionName: 'kanto');
const gen2 = Generation(id: 2, name: 'generation-ii', regionName: 'johto');

const overgrow = Ability(id: 65, name: 'overgrow');
const blaze = Ability(id: 66, name: 'blaze');
const staticAbility = Ability(id: 9, name: 'static');

Pokemon entry(
  int id,
  String name,
  PokemonType type,
  Generation generation,
  int total,
  Ability ability,
) => Pokemon(
  id: id,
  nationalNumber: id,
  name: name,
  updatedAt: DateTime.utc(2026),
  types: [PokemonTypeSlot(type: type, slot: 1)],
  species: PokemonSpecies(id: id, name: name, generation: generation),
  baseStatTotal: total,
  abilities: [PokemonAbility(ability: ability, slot: 1, isHidden: false)],
);

final sample = [
  entry(1, 'bulbasaur', grass, gen1, 318, overgrow),
  entry(4, 'charmander', fire, gen1, 309, blaze),
  entry(25, 'pikachu', electric, gen1, 320, staticAbility),
  entry(152, 'chikorita', grass, gen2, 318, overgrow),
];

void main() {
  // Debounce del buscador con tiempo falso (RF-CAT-03).
  group('CatalogQueryController', () {
    Future<ProviderContainer> ready() async {
      final container = ProviderContainer(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(FakeSettings()),
        ],
      );
      addTearDown(container.dispose);
      await container.read(catalogQueryProvider.future);
      return container;
    }

    testWidgets('Aplica la busqueda 400 ms despues de la ultima tecla', (
      tester,
    ) async {
      final container = await ready();
      final changes = <String>[];
      container.listen(
        catalogQueryProvider,
        (_, next) => changes.add(next.requireValue.search),
      );
      final controller = container.read(catalogQueryProvider.notifier);

      controller.updateSearch('p');
      await tester.pump(const Duration(milliseconds: 200));
      controller.updateSearch('pi');
      await tester.pump(const Duration(milliseconds: 200));
      controller.updateSearch('pik');
      await tester.pump(const Duration(milliseconds: 399));
      expect(changes, isEmpty);
      await tester.pump(const Duration(milliseconds: 1));
      expect(changes, ['pik']);
      expect(searchDebounce, const Duration(milliseconds: 400));
    });

    testWidgets('Tipo, generacion y orden se aplican al instante', (
      tester,
    ) async {
      final container = await ready();
      final controller = container.read(catalogQueryProvider.notifier);
      controller.setType(12);
      controller.setGeneration(2);
      controller.setSort(CatalogSort.name);
      controller.toggleDescending();
      expect(
        container.read(catalogQueryProvider).requireValue,
        const CatalogQuery(
          typeId: 12,
          generationId: 2,
          sort: CatalogSort.name,
          descending: true,
        ),
      );
    });

    testWidgets('clear quita busqueda y filtros pero conserva el orden', (
      tester,
    ) async {
      final container = await ready();
      final controller = container.read(catalogQueryProvider.notifier);
      controller.setType(12);
      controller.setSort(CatalogSort.baseStatTotal);
      controller.updateSearch('pika');
      controller.clearFilters();
      await tester.pump(const Duration(seconds: 1));
      expect(
        container.read(catalogQueryProvider).requireValue,
        const CatalogQuery(sort: CatalogSort.baseStatTotal),
      );
    });
  });

  group('Pantalla del catalogo con filtros (2.6)', () {
    late AppDatabase database;
    late LocalPokemonRepository repository;
    ProviderContainer? container;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      repository = LocalPokemonRepository(database);
    });
    tearDown(() async {
      container?.dispose();
      container = null;
      await database.close();
    });

    // pump() sin duracion no avanza el reloj falso; Duration.zero si ejecuta el
    // Timer.run con que Drift cierra el stream de la consulta anterior.
    Future<void> settle(WidgetTester tester) async {
      for (var i = 0; i < 10; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 10)),
        );
        await tester.pump(Duration.zero);
      }
    }

    Future<void> seed(
      WidgetTester tester, {
      int? downloaded,
      int total = 4,
    }) async {
      await tester.runAsync(
        () => repository.savePage(
          sample,
          SyncMetadata(
            resourceKey: 'pokemon_catalog',
            nextOffset: downloaded ?? sample.length,
            totalCount: total,
            status: SyncStatus.success,
            lastSuccessAt: DateTime.utc(2026),
            isComplete: downloaded == null,
          ),
        ),
      );
    }

    Future<void> mount(
      WidgetTester tester, {
      double textScale = 1,
      double width = 800,
    }) async {
      tester.view.physicalSize = Size(width, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      // Se libera antes de que flutter_test revise timers pendientes.
      addTearDown(() {
        container?.dispose();
        container = null;
      });
      container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          pokemonRepositoryProvider.overrideWithValue(repository),
          pokemonSyncProvider.overrideWithValue(IdleSync()),
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
          child: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
            child: const PokedexApp(),
          ),
        ),
      );
      await settle(tester);
    }

    List<String> visibleNames(WidgetTester tester) => [
      for (final name in ['bulbasaur', 'charmander', 'pikachu', 'chikorita'])
        if (find.text(name).evaluate().isNotEmpty) name,
    ];

    Future<void> choose(WidgetTester tester, Key menu, String option) async {
      await tester.tap(find.byKey(menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text(option).last);
      await tester.pumpAndSettle();
      await settle(tester);
    }

    testWidgets('El buscador filtra la lista tras el debounce', (tester) async {
      await seed(tester);
      await mount(tester);
      expect(visibleNames(tester), hasLength(4));

      await tester.enterText(find.byKey(catalogSearchFieldKey), 'chi');
      await tester.pump(const Duration(milliseconds: 100));
      await settle(tester);
      expect(visibleNames(tester), hasLength(4));

      await tester.pump(searchDebounce);
      await settle(tester);
      expect(visibleNames(tester), ['chikorita']);

      await tester.tap(find.byTooltip('Borrar busqueda'));
      await tester.pump();
      await settle(tester);
      expect(visibleNames(tester), hasLength(4));
    });

    testWidgets('Filtra por tipo y por generacion desde los menus', (
      tester,
    ) async {
      await seed(tester);
      await mount(tester);

      await choose(tester, catalogTypeMenuKey, 'Grass');
      expect(visibleNames(tester), ['bulbasaur', 'chikorita']);

      await choose(tester, catalogGenerationMenuKey, 'Gen II · Johto');
      expect(visibleNames(tester), ['chikorita']);

      await choose(tester, catalogTypeMenuKey, 'Todos los tipos');
      await choose(tester, catalogGenerationMenuKey, 'Todas las generaciones');
      expect(visibleNames(tester), hasLength(4));
    });

    testWidgets('Ordena por total y alterna el sentido', (tester) async {
      await seed(tester);
      await mount(tester);
      await choose(tester, catalogSortMenuKey, 'Total base');

      double top(String name) => tester.getTopLeft(find.text(name)).dy;
      expect(top('charmander'), lessThan(top('pikachu')));

      await tester.tap(find.byKey(catalogDirectionButtonKey));
      await tester.pump();
      await settle(tester);
      expect(top('pikachu'), lessThan(top('charmander')));
      expect(
        find.bySemanticsLabel(RegExp('Orden descendente')),
        findsOneWidget,
      );
    });

    testWidgets('Sin resultados ofrece limpiar los filtros', (tester) async {
      await seed(tester);
      await mount(tester);
      await tester.enterText(find.byKey(catalogSearchFieldKey), 'zzz');
      await tester.pump(searchDebounce);
      await settle(tester);
      expect(
        find.text('Ningun Pokemon coincide con la busqueda o los filtros.'),
        findsOneWidget,
      );
      expect(find.text('No hay Pokemon guardados.'), findsNothing);

      await tester.tap(find.text('Limpiar filtros'));
      await tester.pump();
      await settle(tester);
      expect(visibleNames(tester), hasLength(4));
      expect(
        tester
            .widget<TextField>(find.byKey(catalogSearchFieldKey))
            .controller!
            .text,
        isEmpty,
      );
    });

    testWidgets('Avisa cuando el catalogo local es parcial (RF-FIL-05)', (
      tester,
    ) async {
      await seed(tester, downloaded: 4, total: 1302);
      await mount(tester);
      expect(
        find.textContaining('Catalogo parcial: 4 de 1302'),
        findsOneWidget,
      );
    });

    testWidgets('No muestra el aviso con el catalogo completo', (tester) async {
      await seed(tester);
      await mount(tester);
      expect(find.textContaining('Catalogo parcial'), findsNothing);
    });

    testWidgets('Texto al 200 % en pantalla estrecha no desborda', (
      tester,
    ) async {
      await seed(tester, downloaded: 4, total: 1302);
      await mount(tester, textScale: 2, width: 360);
      expect(tester.takeException(), isNull);
      expect(find.byKey(catalogSearchFieldKey), findsOneWidget);
    });

    testWidgets('Al abrir la app restaura busqueda, filtros y orden', (
      tester,
    ) async {
      await seed(tester);
      await tester.runAsync(
        () => LocalSettingsRepository(database).write(
          catalogQuerySettingKey,
          const CatalogQuery(
            search: 'i',
            typeId: 12,
            sort: CatalogSort.name,
            descending: true,
          ).encode(),
        ),
      );
      await mount(tester);

      // Ya filtrado desde el primer cuadro: grass con "i", nombre descendente.
      expect(visibleNames(tester), ['chikorita']);
      expect(
        tester
            .widget<TextField>(find.byKey(catalogSearchFieldKey))
            .controller!
            .text,
        'i',
      );
      expect(find.text('Grass'), findsOneWidget);
      expect(find.text('Nombre'), findsOneWidget);
      expect(
        find.bySemanticsLabel(RegExp('Orden descendente')),
        findsOneWidget,
      );
    });

    testWidgets('Cambiar un filtro en pantalla queda guardado en app_setting', (
      tester,
    ) async {
      await seed(tester);
      await mount(tester);
      await choose(tester, catalogTypeMenuKey, 'Fire');
      final saved = await tester.runAsync(
        () => LocalSettingsRepository(database).read(catalogQuerySettingKey),
      );
      expect(CatalogQuery.decode(saved), CatalogQuery(typeId: fire.id));
    });

    testWidgets('Filtra por habilidad con autocompletado y chip (2.9)', (
      tester,
    ) async {
      await seed(tester);
      await mount(tester);

      await tester.enterText(find.byKey(catalogAbilityFieldKey), 'over');
      await tester.pump();
      await tester.tap(find.text('Overgrow').last);
      await tester.pump();
      await settle(tester);
      expect(visibleNames(tester), ['bulbasaur', 'chikorita']);
      expect(find.text('Habilidad: Overgrow'), findsOneWidget);
      final saved = await tester.runAsync(
        () => LocalSettingsRepository(database).read(catalogQuerySettingKey),
      );
      expect(CatalogQuery.decode(saved).abilityId, overgrow.id);

      await tester.tap(find.byTooltip('Quitar filtro de habilidad'));
      await tester.pump();
      await settle(tester);
      expect(visibleNames(tester), hasLength(4));
      expect(find.byKey(catalogAbilityFieldKey), findsOneWidget);
    });
  });
}
