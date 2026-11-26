import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../features/favorites/presentation/favorite_button.dart';
import '../features/favorites/presentation/favorites_page.dart';
import '../features/pokemon/presentation/pokemon_page.dart';
import '../features/trivia/presentation/trivia_page.dart';

enum HomeTab { catalog, favorites, trivia }

class HomeTabController extends Notifier<HomeTab> {
  @override
  HomeTab build() => HomeTab.catalog;

  void select(HomeTab tab) => state = tab;
}

final homeTabProvider = NotifierProvider<HomeTabController, HomeTab>(
  HomeTabController.new,
);

/// Pantallas principales con barra inferior. IndexedStack conserva el estado
/// de cada pestana (scroll, busqueda) al cambiar. El indicador de conexion
/// vive fuera, en PokedexApp, y se ve en todas (IND-01).
class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(homeTabProvider);
    final tabs = ref.read(homeTabProvider.notifier);
    return PopScope(
      // "Atras" desde Favoritos o Trivia vuelve al catalogo antes de salir.
      canPop: tab == HomeTab.catalog,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) tabs.select(HomeTab.catalog);
      },
      child: Scaffold(
        body: IndexedStack(
          index: tab.index,
          children: [
            // Aqui se compone el corazon en el catalogo: asi la feature pokemon
            // no depende de favorites (que ya depende de pokemon).
            PokemonPage(
              cardTrailing: (pokemon) => FavoriteButton(pokemon: pokemon),
            ),
            const FavoritesPage(),
            const TriviaPage(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: tab.index,
          onDestinationSelected: (index) => tabs.select(HomeTab.values[index]),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.catching_pokemon_outlined),
              selectedIcon: Icon(Icons.catching_pokemon),
              label: 'Catalogo',
            ),
            NavigationDestination(
              icon: Icon(Icons.favorite_border),
              selectedIcon: Icon(Icons.favorite),
              label: 'Favoritos',
            ),
            NavigationDestination(
              icon: Icon(Icons.quiz_outlined),
              selectedIcon: Icon(Icons.quiz),
              label: 'Trivia',
            ),
          ],
        ),
      ),
    );
  }
}
