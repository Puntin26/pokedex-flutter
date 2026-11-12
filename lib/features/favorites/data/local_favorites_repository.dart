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
