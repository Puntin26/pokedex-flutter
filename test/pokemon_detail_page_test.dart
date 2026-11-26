import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pokedex/app/share_provider.dart';
import 'package:pokedex/core/domain/sync_failure.dart';
import 'package:pokedex/features/favorites/presentation/favorite_button.dart';
import 'package:pokedex/features/pokemon/data/local_pokemon_detail_repository.dart';
import 'package:pokedex/features/pokemon/data/pokemon_detail_sync_coordinator.dart';
import 'package:pokedex/features/pokemon/domain/pokemon.dart';
import 'package:pokedex/features/pokemon/presentation/detail_sections.dart';
import 'package:pokedex/features/pokemon/presentation/pokemon_detail_page.dart';

import 'support/app_harness.dart';
import 'support/detail_response.dart';
import 'support/fake_detail_source.dart';

const gen1 = Generation(id: 1, name: 'generation-i', regionName: 'kanto');

Pokemon catalogEntry(
  int id,
  String name, {
  int? speciesId,
  bool isDefault = true,
}) => Pokemon(
  id: id,
  nationalNumber: speciesId ?? id,
  name: name,
  imageUrl: 'https://example.com/artwork/$id.png',
  updatedAt: DateTime.utc(2026),
  types: const [
    PokemonTypeSlot(type: PokemonType(id: 1, name: 'normal'), slot: 1),
  ],
  species: PokemonSpecies(id: speciesId ?? id, name: name, generation: gen1),
  isDefault: isDefault,
);

void main() {
  late AppHarness app;
  late FakeDetailSource remote;
  late List<String> shared;

  setUp(() {
    app = AppHarness();
    remote = FakeDetailSource();
    shared = [];
    // Solo eevee existe en la API falsa; otros IDs fallan como sin red.
    remote.detail = (id) async => id == 133
        ? detailResponse(detailRow())
        : throw const SyncFailure(SyncFailureKind.network, 'Sin conexion.');
  });
  tearDown(() => app.database.close());

  Future<void> mount(
    WidgetTester tester, {
    bool online = true,
    double width = 800,
    double textScale = 1,
  }) => app.mount(
    tester,
    online: online,
    width: width,
    height: 3200,
    textScale: textScale,
    detailSync: PokemonDetailSyncCoordinator(
      remote: remote,
      local: LocalPokemonDetailRepository(app.database),
      log: (_) {},
    ),
    overrides: [
      shareTextProvider.overrideWithValue((text) async => shared.add(text)),
    ],
  );

  // La transicion de ruta dura 300 ms; settle deja terminar SQLite.
  Future<void> navigate(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await app.settle(tester);
    await tester.pump(const Duration(milliseconds: 400));
    await app.settle(tester);
  }

  Future<void> openFromCatalog(WidgetTester tester, String name) async {
    await tester.tap(find.text(name));
    await navigate(tester);
  }

  Future<void> push(WidgetTester tester, int pokemonId) async {
    tester
        .state<NavigatorState>(find.byType(Navigator))
        .push(pokemonDetailRoute(pokemonId));
    await navigate(tester);
  }

  Finder inDetail(Finder finder) =>
      find.descendant(of: find.byType(PokemonDetailPage), matching: finder);

  testWidgets(
    'Tocar la tarjeta abre el detalle con Hero y lo completa (OF-20)',
    (tester) async {
      await app.seed(tester, [catalogEntry(133, 'eevee')]);
      await mount(tester);
      await openFromCatalog(tester, 'eevee');

      expect(inDetail(find.text('#133 Eevee')), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Hero && widget.tag == 'catalog-133',
        ),
        findsOneWidget,
      );
      expect(inDetail(find.text('Gen I · Kanto')), findsOneWidget);
      // RF-DET-02: valor, porcentaje y total.
      expect(inDetail(find.text('PS')), findsOneWidget);
      expect(inDetail(find.text('22%')), findsNWidgets(3));
      expect(inDetail(find.text('Total: 325')), findsOneWidget);
      expect(find.bySemanticsLabel('PS: 55, 22 por ciento'), findsOneWidget);
      expect(remote.detailCalls, [133]);
    },
  );

  testWidgets('Habilidades con "Oculta" y efecto; datos y egg groups', (
    tester,
  ) async {
    await app.seed(tester, [catalogEntry(133, 'eevee')]);
    await mount(tester);
    await openFromCatalog(tester, 'eevee');

    expect(inDetail(find.text('Anticipation')), findsOneWidget);
    expect(inDetail(find.text('Oculta')), findsOneWidget);
    expect(
      inDetail(find.text('Ensures success fleeing from wild battles.')),
      findsOneWidget,
    );
    expect(inDetail(find.text('0.3 m')), findsOneWidget);
    expect(inDetail(find.text('6.5 kg')), findsOneWidget);
    expect(inDetail(find.text('Ground')), findsOneWidget);
  });

  testWidgets(
    'Matchups: normal es debil a lucha e inmune a fantasma (RF-DET-06)',
    (tester) async {
      await app.seed(tester, [catalogEntry(133, 'eevee')]);
      await mount(tester);
      await openFromCatalog(tester, 'eevee');

      final section = find.ancestor(
        of: find.text('Debilidades y resistencias'),
        matching: find.byType(DetailSection),
      );
      expect(
        find.descendant(of: section, matching: find.text('x2')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: section, matching: find.text('Fighting')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: section, matching: find.text('x0')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: section, matching: find.text('Ghost')),
        findsOneWidget,
      );
    },
  );

  testWidgets('Evoluciones con ramas y trigger; abre la evolucion guardada', (
    tester,
  ) async {
    await app.seed(tester, [
      catalogEntry(133, 'eevee'),
      catalogEntry(134, 'vaporeon'),
    ]);
    await mount(tester);
    await openFromCatalog(tester, 'eevee');

    expect(inDetail(find.text('Usar Water stone')), findsOneWidget);
    expect(inDetail(find.text('Amistad 160 de dia')), findsOneWidget);
    expect(inDetail(find.text('Subir de nivel')), findsOneWidget);

    await tester.tap(inDetail(find.widgetWithText(ActionChip, 'Vaporeon')));
    await navigate(tester);
    expect(find.widgetWithText(AppBar, 'Vaporeon'), findsOneWidget);
  });

  testWidgets('Sin cadena evolutiva muestra "No evoluciona"', (tester) async {
    remote.detail = (_) async => detailResponse(
      detailRow(
        evolutionChain: {
          'pokemonspecies': [chainSpecies(133, 'eevee')],
        },
      ),
    );
    await app.seed(tester, [catalogEntry(133, 'eevee')]);
    await mount(tester);
    await openFromCatalog(tester, 'eevee');
    expect(inDetail(find.text('No evoluciona')), findsOneWidget);
  });

  testWidgets(
    'Movimientos: juego reciente y nivel por defecto; filtros y orden',
    (tester) async {
      await app.seed(tester, [catalogEntry(133, 'eevee')]);
      await mount(tester);
      await openFromCatalog(tester, 'eevee');

      List<String> moveNames() => [
        for (final tile in tester.widgetList<ListTile>(
          inDetail(find.byType(ListTile)),
        ))
          (tile.title! as Text).data!,
      ];
      expect(inDetail(find.text('Scarlet violet')), findsOneWidget);
      expect(moveNames(), ['Tackle', 'Swift', 'Swift']);

      await tester.tap(inDetail(find.widgetWithText(ChoiceChip, 'Huevo')));
      await app.settle(tester);
      expect(moveNames(), ['Wish']);

      await tester.tap(inDetail(find.widgetWithText(ChoiceChip, 'Todos')));
      await tester.tap(find.byKey(detailMoveSortKey));
      await app.settle(tester);
      expect(moveNames(), ['Covet', 'Swift', 'Swift', 'Tackle', 'Wish']);

      await tester.tap(find.byKey(detailVersionMenuKey));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Red blue').last);
      await tester.pumpAndSettle();
      await app.settle(tester);
      expect(moveNames(), ['Body slam', 'Tackle']);
    },
  );

  testWidgets('Shiny alterna la imagen (RF-DET-09)', (tester) async {
    await app.seed(tester, [catalogEntry(133, 'eevee')]);
    await mount(tester);
    await openFromCatalog(tester, 'eevee');

    // cacheWidth envuelve la imagen de red en un ResizeImage.
    String detailImage() =>
        ((tester.widget<Image>(inDetail(find.byType(Image))).image
                        as ResizeImage)
                    .imageProvider
                as NetworkImage)
            .url;
    expect(detailImage(), 'https://example.com/artwork/133.png');
    await tester.tap(inDetail(find.widgetWithText(FilterChip, 'Shiny')));
    await tester.pump();
    expect(detailImage(), 'https://example.com/artwork/shiny/133.png');
    expect(find.bySemanticsLabel('Imagen shiny de Eevee'), findsOneWidget);
  });

  testWidgets('Selector de formas cambia a la otra forma (RF-DET-08)', (
    tester,
  ) async {
    await app.seed(tester, [
      catalogEntry(133, 'eevee'),
      catalogEntry(10159, 'eevee-starter', speciesId: 133, isDefault: false),
    ]);
    await mount(tester);
    await openFromCatalog(tester, 'eevee');

    expect(inDetail(find.text('Formas')), findsOneWidget);
    await tester.tap(
      inDetail(find.widgetWithText(ChoiceChip, 'Eevee starter')),
    );
    await navigate(tester);
    expect(find.widgetWithText(AppBar, 'Eevee starter'), findsOneWidget);
    // Reemplaza la pantalla: atras vuelve al catalogo, no a la otra forma.
    await tester.pageBack();
    await navigate(tester);
    expect(find.byType(PokemonDetailPage), findsNothing);
  });

  testWidgets(
    'PA-02: con servicio, un Pokemon no guardado se descarga y se ve',
    (tester) async {
      await mount(tester);
      await push(tester, 133);
      expect(inDetail(find.text('#133 Eevee')), findsOneWidget);
      expect(inDetail(find.text('Total: 325')), findsOneWidget);
    },
  );

  testWidgets('Sin conexion y sin guardar: mensaje util y Reintentar', (
    tester,
  ) async {
    await mount(tester, online: false);
    await push(tester, 25);
    expect(
      inDetail(find.textContaining('Este Pokemon aun no esta guardado')),
      findsOneWidget,
    );
    expect(
      inDetail(find.textContaining('Conectate a Internet')),
      findsOneWidget,
    );
    expect(inDetail(find.text('Reintentar')), findsOneWidget);
    // Sin red no se llama a la API (no espera los reintentos).
    expect(remote.detailCalls, isEmpty);
  });

  testWidgets('Sin conexion con datos del catalogo: muestra lo local y avisa', (
    tester,
  ) async {
    await app.seed(tester, [catalogEntry(133, 'eevee')]);
    await mount(tester, online: false);
    await openFromCatalog(tester, 'eevee');
    expect(inDetail(find.text('#133 Eevee')), findsOneWidget);
    expect(
      inDetail(find.textContaining('Se muestran los datos del catalogo')),
      findsOneWidget,
    );
    expect(
      inDetail(find.text('Se muestran al descargar el detalle.')),
      findsWidgets,
    );
  });

  testWidgets('Compartir y favorito desde el detalle (RF-DET-10)', (
    tester,
  ) async {
    await app.seed(tester, [catalogEntry(133, 'eevee')]);
    await mount(tester);
    await openFromCatalog(tester, 'eevee');

    await tester.tap(find.byTooltip('Compartir'));
    await tester.pump();
    expect(shared.single, contains('#133 Eevee'));
    expect(shared.single, contains('Tipo: Normal'));
    expect(shared.single, contains('Total base: 325'));

    await tester.tap(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.byType(FavoriteButton),
      ),
    );
    await tester.pumpAndSettle();
    await app.settle(tester);
    await tester.pageBack();
    await navigate(tester);
    // El catalogo refleja el favorito sin recargar (RF-FAV-04).
    expect(find.bySemanticsLabel('Quitar eevee de favoritos'), findsOneWidget);
  });

  testWidgets('Texto al 200 % en pantalla estrecha no desborda', (
    tester,
  ) async {
    await app.seed(tester, [catalogEntry(133, 'eevee')]);
    await mount(tester, width: 360, textScale: 2);
    await openFromCatalog(tester, 'eevee');
    expect(tester.takeException(), isNull);
    expect(inDetail(find.text('Total: 325')), findsOneWidget);
  });
}
