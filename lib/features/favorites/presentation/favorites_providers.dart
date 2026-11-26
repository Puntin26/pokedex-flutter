import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/clock_provider.dart';
import '../../../app/favorites_dependencies.dart';
import '../domain/favorite.dart';

final favoritesProvider = StreamProvider<List<Favorite>>(
  (ref) => ref.watch(favoritesRepositoryProvider).watchFavorites(),
  retry: (retryCount, error) => null,
);

final favoriteIdsProvider = StreamProvider<Set<int>>(
  (ref) => ref.watch(favoritesRepositoryProvider).watchFavoriteIds(),
);

/// Reactivo por Pokemon: catalogo, favoritos y detalle se actualizan solos
/// cuando cambia SQLite (RF-FAV-04).
final isFavoriteProvider = Provider.family<bool, int>(
  (ref, pokemonId) =>
      ref.watch(favoriteIdsProvider).value?.contains(pokemonId) ?? false,
);

final favoritesControllerProvider = Provider<FavoritesController>(
  FavoritesController.new,
);

class FavoritesController {
  FavoritesController(this._ref);

  final Ref _ref;

  /// Devuelve si quedo como favorito. Mide cuanto tarda en persistir: en el
  /// dispositivo de demo debe ser menos de 150 ms (RF-FAV-04).
  Future<bool> toggle(int pokemonId) async {
    final stopwatch = Stopwatch()..start();
    final isFavorite = await _ref
        .read(favoritesRepositoryProvider)
        .toggleFavorite(pokemonId, _ref.read(clockProvider)().toUtc());
    debugPrint(
      '[favoritos] #$pokemonId ${isFavorite ? 'agregado' : 'quitado'} '
      'en ${stopwatch.elapsedMilliseconds} ms',
    );
    return isFavorite;
  }

  /// Deshacer: vuelve a agregarlo con su fecha original para conservar el orden.
  Future<void> restore(Favorite favorite) => _ref
      .read(favoritesRepositoryProvider)
      .addFavorite(favorite.pokemon.id, favorite.createdAt);
}
