import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'database_tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    PokemonRecords,
    PokemonTypes,
    PokemonTypeLinks,
    Favorites,
    SyncMetadataRecords,
    // v2
    Generations,
    PokemonSpecies,
    Stats,
    PokemonStats,
    Abilities,
    PokemonAbilities,
    Moves,
    PokemonMoves,
    EggGroups,
    SpeciesEggGroups,
    Evolutions,
    TypeEfficacies,
    TriviaResults,
    TriviaAnswers,
    Achievements,
    AppSettings,
    ImageCacheEntries,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'pokedex'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      // Cada version suma pasos que conservan los datos; nunca se borra la base.
      if (from < 2) await _migrateToV2(migrator);
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  // v1 -> v2: solo agrega; catalogo, tipos, favoritos y sync_metadata se conservan.
  Future<void> _migrateToV2(Migrator migrator) async {
    // generation y species primero: pokemon.species_id las referencia.
    for (final table in <TableInfo>[
      generations,
      pokemonSpecies,
      stats,
      pokemonStats,
      abilities,
      pokemonAbilities,
      moves,
      pokemonMoves,
      eggGroups,
      speciesEggGroups,
      evolutions,
      typeEfficacies,
      triviaResults,
      triviaAnswers,
      achievements,
      appSettings,
      imageCacheEntries,
    ]) {
      await migrator.createTable(table);
    }
    // Columnas nulas o con default: las filas existentes quedan validas.
    await migrator.addColumn(pokemonRecords, pokemonRecords.speciesId);
    await migrator.addColumn(pokemonRecords, pokemonRecords.height);
    await migrator.addColumn(pokemonRecords, pokemonRecords.weight);
    await migrator.addColumn(pokemonRecords, pokemonRecords.baseStatTotal);
    await migrator.addColumn(pokemonRecords, pokemonRecords.isDefault);
    // createTable no crea indices: se crean todos los que no existian en v1.
    const v1Indexes = {'pokemon_national_order', 'favorite_creation_order'};
    for (final index in allSchemaEntities.whereType<Index>()) {
      if (!v1Indexes.contains(index.entityName)) {
        await migrator.createIndex(index);
      }
    }
  }
}
