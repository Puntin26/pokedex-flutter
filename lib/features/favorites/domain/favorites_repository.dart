import 'favorite.dart';

abstract interface class FavoritesRepository {
  Stream<List<Favorite>> watchFavorites();

  /// Solo los IDs: consulta liviana para pintar el corazon de cada tarjeta.
  Stream<Set<int>> watchFavoriteIds();
  Future<void> addFavorite(int pokemonId, DateTime createdAt);
  Future<void> removeFavorite(int pokemonId);

  /// Agrega o quita de forma atomica y devuelve si quedo como favorito.
  Future<bool> toggleFavorite(int pokemonId, DateTime createdAt);
}
