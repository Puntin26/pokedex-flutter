import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pokedex/app/connection_indicator.dart';
import 'package:pokedex/app/favorites_dependencies.dart';
import 'package:pokedex/app/home_shell.dart';
import 'package:pokedex/core/database/app_database.dart';
import 'package:pokedex/features/favorites/data/local_favorites_repository.dart';
import 'package:pokedex/features/favorites/domain/favorite.dart';
import 'package:pokedex/features/favorites/presentation/favorite_button.dart';
import 'package:pokedex/features/favorites/presentation/favorites_page.dart';
import 'package:pokedex/features/pokemon/data/local_pokemon_repository.dart';
import 'package:pokedex/core/domain/sync_metadata.dart';

import 'support/app_harness.dart';

class FailingFavorites extends LocalFavoritesRepository {
  FailingFavorites(super.database);
  bool fail = true;

  @override
  Stream<List<Favorite>> watchFavorites() => fail
      ? Stream.error(StateError('lectura fallida'))
      : super.watchFavorites();
}

void main() {
  group('Repositorio de favoritos (3.2)', () {
    late AppDatabase database;
    late LocalFavoritesRepository favorites;

    setUp(() async {
      database = AppDatabase(NativeDatabase.memory());
      favorites = LocalFavoritesRepository(database);
      await LocalPokemonRepository(database).savePage(
        [samplePokemon(1, 'bulbasaur'), samplePokemon(4, 'charmander')],
        const SyncMetadata(
          resourceKey: 'pokemon_catalog',
          nextOffset: 2,
          totalCount: 2,
          isComplete: true,
        ),
      );
    });
    tearDown(() => database.close());

    test('toggle agrega y quita; dos toques seguidos se anulan', () async {
      expect(await favorites.toggleFavorite(1, DateTime.utc(2026)), isTrue);
      expect(await favorites.watchFavoriteIds().first, {1});
      expect(await favorites.toggleFavorite(1, DateTime.utc(2026)), isFalse);
      expect(await favorites.watchFavoriteIds().first, isEmpty);

      // Simultaneos: la transaccion los serializa, no quedan inconsistentes.
      final results = await Future.wait([
        favorites.toggleFavorite(4, DateTime.utc(2026)),
        favorites.toggleFavorite(4, DateTime.utc(2026)),
      ]);
      expect(results, [true, false]);
      expect(await favorites.watchFavoriteIds().first, isEmpty);
    });

    test('Guardar un favorito tarda menos de 150 ms (RF-FAV-04)', () async {
      // Calienta la conexion: la primera consulta abre la base.
      await favorites.watchFavoriteIds().first;
      final stopwatch = Stopwatch()..start();
      await favorites.toggleFavorite(1, DateTime.utc(2026));
      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(150));
    });
  });

  group('Navegacion y favoritos en la app (3.1-3.4)', () {
    late AppHarness app;

    setUp(() => app = AppHarness());
    tearDown(() => app.database.close());

    Future<void> openTab(WidgetTester tester, String label) async {
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text(label),
        ),
      );
      await tester.pumpAndSettle();
      await app.settle(tester);
    }

    Finder heartOf(String name) => find.descendant(
      of: find.ancestor(of: find.text(name), matching: find.byType(Card)),
      matching: find.byType(FavoriteButton),
    );

    testWidgets('Barra inferior con 3 pestanas e indicador siempre visible', (
      tester,
    ) async {
      await app.seed(tester, [samplePokemon(1, 'bulbasaur')]);
      await app.mount(tester);
      for (final label in ['Catalogo', 'Favoritos', 'Trivia']) {
        expect(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.text(label),
          ),
          findsOneWidget,
        );
        await openTab(tester, label);
        expect(find.byType(ConnectionIndicator), findsOneWidget);
      }
    });

    testWidgets('Atras desde otra pestana vuelve al catalogo', (tester) async {
      await app.mount(tester);
      await openTab(tester, 'Favoritos');
      expect(app.container!.read(homeTabProvider), HomeTab.favorites);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(app.container!.read(homeTabProvider), HomeTab.catalog);
    });

    testWidgets(
      'Favorito offline: corazon en el catalogo y pantalla dedicada',
      (tester) async {
        await app.seed(tester, [
          samplePokemon(1, 'bulbasaur'),
          samplePokemon(4, 'charmander'),
        ]);
        await app.mount(tester);
        expect(
          find.bySemanticsLabel('Agregar bulbasaur a favoritos'),
          findsOneWidget,
        );

        await tester.tap(heartOf('bulbasaur'));
        await tester.pumpAndSettle();
        await app.settle(tester);
        expect(
          find.bySemanticsLabel('Quitar bulbasaur de favoritos'),
          findsOneWidget,
        );
        expect(find.byIcon(Icons.favorite), findsOneWidget);

        await openTab(tester, 'Favoritos');
        expect(find.text('bulbasaur'), findsWidgets);
        expect(
          find.descendant(
            of: find.byType(FavoritesPageBody),
            matching: find.text('charmander'),
          ),
          findsNothing,
        );
      },
    );

    testWidgets(
      'Quitar desde Favoritos actualiza el catalogo y se puede deshacer',
      (tester) async {
        await app.seed(tester, [samplePokemon(1, 'bulbasaur')]);
        await tester.runAsync(
          () =>
              LocalFavoritesRepository(app.database)
                  .addFavorite(1, DateTime.utc(2026, 11, 20)),
        );
        await app.mount(tester);
        await openTab(tester, 'Favoritos');

        await tester.tap(
          find.descendant(
            of: find.byType(FavoritesPageBody),
            matching: find.byType(FavoriteButton),
          ),
        );
        await tester.pumpAndSettle();
        await app.settle(tester);
        expect(find.text('Aun no tienes favoritos.'), findsOneWidget);
        expect(find.text('bulbasaur quitado de favoritos'), findsOneWidget);

        await tester.tap(find.text('Deshacer'));
        await tester.pumpAndSettle();
        await app.settle(tester);
        final restored = await tester.runAsync(
          () => LocalFavoritesRepository(app.database).watchFavorites().first,
        );
        expect(restored!.single.createdAt, DateTime.utc(2026, 11, 20));

        // El catalogo refleja el estado sin recargar (RF-FAV-04).
        await openTab(tester, 'Catalogo');
        expect(
          find.bySemanticsLabel('Quitar bulbasaur de favoritos'),
          findsOneWidget,
        );
      },
    );

    testWidgets('Sin favoritos: estado vacio que lleva al catalogo (PA-15)', (
      tester,
    ) async {
      await app.mount(tester);
      await openTab(tester, 'Favoritos');
      expect(find.text('Aun no tienes favoritos.'), findsOneWidget);
      await tester.tap(find.text('Ir al catalogo'));
      await tester.pumpAndSettle();
      expect(app.container!.read(homeTabProvider), HomeTab.catalog);
    });

    testWidgets('Error al leer favoritos ofrece Reintentar', (tester) async {
      final failing = FailingFavorites(app.database);
      await app.mount(
        tester,
        overrides: [favoritesRepositoryProvider.overrideWithValue(failing)],
      );
      await openTab(tester, 'Favoritos');
      expect(find.text('No se pudieron leer los favoritos.'), findsOneWidget);
      failing.fail = false;
      await tester.tap(find.text('Reintentar'));
      await tester.pumpAndSettle();
      await app.settle(tester);
      expect(find.text('Aun no tienes favoritos.'), findsOneWidget);
    });

    testWidgets('Los favoritos sobreviven a cerrar y abrir la app', (
      tester,
    ) async {
      await app.seed(tester, [samplePokemon(1, 'bulbasaur')]);
      await app.mount(tester);
      await tester.tap(heartOf('bulbasaur'));
      await tester.pumpAndSettle();
      await app.settle(tester);
      await tester.pumpWidget(const SizedBox());
      app.dispose();

      await app.mount(tester);
      await openTab(tester, 'Favoritos');
      expect(
        find.descendant(
          of: find.byType(FavoritesPageBody),
          matching: find.text('bulbasaur'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('Texto al 200 % en pantalla estrecha no desborda', (
      tester,
    ) async {
      await app.seed(tester, [samplePokemon(1, 'bulbasaur')]);
      await app.mount(tester, width: 360, textScale: 2);
      expect(tester.takeException(), isNull);
      await openTab(tester, 'Favoritos');
      expect(tester.takeException(), isNull);
    });

    // Durante la transicion del AnimatedSwitcher conviven el icono viejo y el nuevo.
    Finder heartIcons() =>
        find.descendant(of: heartOf('bulbasaur'), matching: find.byType(Icon));

    testWidgets('El corazon anima el cambio (RF-COM-03)', (tester) async {
      await app.seed(tester, [samplePokemon(1, 'bulbasaur')]);
      await app.mount(tester);
      await tester.tap(heartOf('bulbasaur'));
      await app.settle(tester);
      await tester.pump(const Duration(milliseconds: 100));
      expect(heartIcons(), findsNWidgets(2));
      await tester.pumpAndSettle();
      expect(heartIcons(), findsOneWidget);
    });

    testWidgets('Con animaciones reducidas el corazon cambia sin animar', (
      tester,
    ) async {
      await app.seed(tester, [samplePokemon(1, 'bulbasaur')]);
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await app.mount(tester);
      await tester.tap(heartOf('bulbasaur'));
      await app.settle(tester);
      await tester.pump(const Duration(milliseconds: 100));
      expect(heartIcons(), findsOneWidget);
      expect(
        find.descendant(
          of: heartOf('bulbasaur'),
          matching: find.byIcon(Icons.favorite),
        ),
        findsOneWidget,
      );
    });
  });
}
