import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'database_tables.dart';
import 'schema_versions.dart';

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
    VersionGroups,
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
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    // Paso a paso con la copia del esquema de cada version (schema_versions.dart):
    // cada paso solo agrega o recrea tablas vacias; nunca se borran datos.
    onUpgrade: stepByStep(from1To2: _migrateToV2, from2To3: _migrateToV3),
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  // v1 -> v2: solo agrega; catalogo, tipos, favoritos y sync_metadata se conservan.
  static Future<void> _migrateToV2(Migrator m, Schema2 schema) async {
    // generation y species primero: pokemon.species_id las referencia.
    for (final table in <TableInfo>[
      schema.generation,
      schema.species,
      schema.stat,
      schema.pokemonStat,
      schema.ability,
      schema.pokemonAbility,
      schema.move,
      schema.pokemonMove,
      schema.eggGroup,
      schema.speciesEggGroup,
      schema.evolution,
      schema.typeEfficacy,
      schema.triviaResult,
      schema.triviaAnswer,
      schema.achievement,
      schema.appSetting,
      schema.imageCache,
    ]) {
      await m.createTable(table);
    }
    // Columnas nulas o con default: las filas existentes quedan validas.
    final pokemon = schema.pokemon;
    await m.addColumn(pokemon, pokemon.speciesId);
    await m.addColumn(pokemon, pokemon.height);
    await m.addColumn(pokemon, pokemon.weight);
    await m.addColumn(pokemon, pokemon.baseStatTotal);
    await m.addColumn(pokemon, pokemon.isDefault);
    for (final index in [
      schema.pokemonName,
      schema.pokemonSpeciesLookup,
      schema.pokemonStatTotalOrder,
      schema.pokemonTypeByType,
      schema.speciesGeneration,
      schema.pokemonAbilityByAbility,
      schema.pokemonMoveByVersion,
      schema.evolutionToSpecies,
      schema.triviaResultRanking,
      schema.triviaAnswerByResult,
      schema.imageCacheLru,
    ]) {
      await m.createIndex(index);
    }
  }

  // v2 -> v3: imagen shiny y version groups ordenados para los movimientos.
  static Future<void> _migrateToV3(Migrator m, Schema3 schema) async {
    await m.createTable(schema.versionGroup);
    // pokemon_move cambia su clave (version_group texto -> id). En v2 ninguna
    // instalacion escribe en ella, asi que recrearla no pierde datos.
    await m.deleteTable('pokemon_move');
    await m.createTable(schema.pokemonMove);
    await m.createIndex(schema.pokemonMoveByVersion);
    await m.addColumn(schema.pokemon, schema.pokemon.shinyImageUrl);
  }
}
