import 'favorite.dart';

abstract interface class FavoritesRepository {
  Stream<List<Favorite>> watchFavorites();
  Future<void> addFavorite(int pokemonId, DateTime createdAt);
  Future<void> removeFavorite(int pokemonId);
}
