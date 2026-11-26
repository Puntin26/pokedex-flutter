import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../pokemon/data/pokemon_row_mapper.dart';
import '../domain/favorite.dart';
import '../domain/favorites_repository.dart';

class LocalFavoritesRepository implements FavoritesRepository {
  LocalFavoritesRepository(this.database);

  final AppDatabase database;

  @override
  Stream<List<Favorite>> watchFavorites() {
    final favorites = database.favorites;
    final pokemon = database.pokemonRecords;
    final links = database.pokemonTypeLinks;
    final types = database.pokemonTypes;
    final query =
        database.select(favorites).join([
          innerJoin(pokemon, pokemon.id.equalsExp(favorites.pokemonId)),
          leftOuterJoin(links, links.pokemonId.equalsExp(pokemon.id)),
          leftOuterJoin(types, types.id.equalsExp(links.typeId)),
        ])..orderBy([
          OrderingTerm.desc(favorites.createdAt),
          OrderingTerm.desc(favorites.pokemonId),
          OrderingTerm.asc(links.slot),
        ]);

    return query.watch().map((rows) {
      final dates = <int, DateTime>{};
      for (final row in rows) {
        final favorite = row.readTable(favorites);
        dates[favorite.pokemonId] = favorite.createdAt.toUtc();
      }
      return mapPokemonRows(rows, database)
          .map(
            (pokemon) =>
                Favorite(pokemon: pokemon, createdAt: dates[pokemon.id]!),
          )
          .toList();
    });
  }

  @override
  Stream<Set<int>> watchFavoriteIds() {
    final query = database.selectOnly(database.favorites)
      ..addColumns([database.favorites.pokemonId]);
    return query.watch().map(
      (rows) => {
        for (final row in rows) row.read(database.favorites.pokemonId)!,
      },
    );
  }

  // En una transaccion: dos toques seguidos se serializan (agrega y luego quita)
  // en lugar de leer ambos el mismo estado viejo.
  @override
  Future<bool> toggleFavorite(int pokemonId, DateTime createdAt) {
    return database.transaction(() async {
      final removed = await (database.delete(
        database.favorites,
      )..where((row) => row.pokemonId.equals(pokemonId))).go();
      if (removed > 0) return false;
      await addFavorite(pokemonId, createdAt);
      return true;
    });
  }

  @override
  Future<void> addFavorite(int pokemonId, DateTime createdAt) async {
    await database
        .into(database.favorites)
        .insert(
          FavoritesCompanion.insert(
            pokemonId: Value(pokemonId),
            createdAt: createdAt,
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  @override
  Future<void> removeFavorite(int pokemonId) async {
    await (database.delete(
      database.favorites,
    )..where((row) => row.pokemonId.equals(pokemonId))).go();
  }
}
