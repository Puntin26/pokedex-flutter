import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/home_shell.dart';
import '../../pokemon/presentation/pokemon_card.dart';
import '../domain/favorite.dart';
import 'favorite_button.dart';
import 'favorites_providers.dart';

/// Pantalla dedicada de favoritos (RF-FAV-02); todo sale de SQLite (RF-FAV-03).
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favoritos')),
      body: const SafeArea(child: FavoritesPageBody()),
    );
  }
}

class FavoritesPageBody extends ConsumerWidget {
  const FavoritesPageBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (ref.watch(favoritesProvider)) {
      AsyncData(:final value) when value.isEmpty => const _EmptyFavorites(),
      AsyncData(:final value) => ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: value.length,
        itemBuilder: (_, index) {
          final favorite = value[index];
          return PokemonCard(
            key: ValueKey(favorite.pokemon.id),
            pokemon: favorite.pokemon,
            trailing: FavoriteButton(
              pokemon: favorite.pokemon,
              onRemoved: () => _offerUndo(context, ref, favorite),
            ),
          );
        },
      ),
      AsyncError() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('No se pudieron leer los favoritos.'),
            TextButton(
              onPressed: () => ref.invalidate(favoritesProvider),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
      _ => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando favoritos...'),
          ],
        ),
      ),
    };
  }

  // La tarjeta desaparece al quitarla; "Deshacer" evita perderla por un toque.
  void _offerUndo(BuildContext context, WidgetRef ref, Favorite favorite) {
    final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text('${favorite.pokemon.name} quitado de favoritos'),
        action: SnackBarAction(
          label: 'Deshacer',
          onPressed: () =>
              ref.read(favoritesControllerProvider).restore(favorite),
        ),
      ),
    );
  }
}

class _EmptyFavorites extends ConsumerWidget {
  const _EmptyFavorites();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.favorite_border, size: 48),
            const SizedBox(height: 12),
            const Text('Aun no tienes favoritos.', textAlign: TextAlign.center),
            const Text(
              'Toca el corazon de un Pokemon en el catalogo para guardarlo aqui.',
              textAlign: TextAlign.center,
            ),
            TextButton(
              onPressed: () =>
                  ref.read(homeTabProvider.notifier).select(HomeTab.catalog),
              child: const Text('Ir al catalogo'),
            ),
          ],
        ),
      ),
    );
  }
}
