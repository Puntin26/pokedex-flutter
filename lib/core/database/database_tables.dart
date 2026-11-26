// Los check describen SQL para el generador; no ejecutan getters recursivos.
// ignore_for_file: recursive_getters

import 'package:drift/drift.dart';

@DataClassName('PokemonRow')
@TableIndex(name: 'pokemon_national_order', columns: {#nationalNumber, #id})
// Busqueda y orden por nombre, filtro por especie y orden por total (RNF-REN-02).
@TableIndex(name: 'pokemon_name', columns: {#name})
@TableIndex(name: 'pokemon_species_lookup', columns: {#speciesId})
@TableIndex(name: 'pokemon_stat_total_order', columns: {#baseStatTotal, #id})
class PokemonRecords extends Table {
  @override
  String get tableName => 'pokemon';

  IntColumn get id => integer().check(id.isBiggerThanValue(0))();
  IntColumn get nationalNumber =>
      integer().check(nationalNumber.isBiggerThanValue(0))();
  TextColumn get name => text().check(name.length.isBiggerThanValue(0))();
  TextColumn get imageUrl => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  // v2: nulos hasta que la sync los complete; las filas v1 migran sin inventar datos.
  IntColumn get speciesId =>
      integer().nullable().references(PokemonSpecies, #id)();
  // Unidades de PokeAPI: decimetros y hectogramos.
  IntColumn get height =>
      integer().nullable().check(height.isBiggerOrEqualValue(0))();
  IntColumn get weight =>
      integer().nullable().check(weight.isBiggerOrEqualValue(0))();
  IntColumn get baseStatTotal =>
      integer().nullable().check(baseStatTotal.isBiggerOrEqualValue(0))();
  // false en formas alternativas (Alola, Galar...) de la misma especie.
  BoolColumn get isDefault => boolean().withDefault(const Constant(true))();
  // v3: artwork shiny (o sprite shiny de respaldo); lo completa el detalle.
  TextColumn get shinyImageUrl => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('TypeRow')
class PokemonTypes extends Table {
  @override
  String get tableName => 'type';

  IntColumn get id => integer().check(id.isBiggerThanValue(0))();
  TextColumn get name =>
      text().unique().check(name.length.isBiggerThanValue(0))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('PokemonTypeRow')
@TableIndex(name: 'pokemon_type_by_type', columns: {#typeId, #pokemonId})
class PokemonTypeLinks extends Table {
  @override
  String get tableName => 'pokemon_type';

  IntColumn get pokemonId =>
      integer().references(PokemonRecords, #id, onDelete: KeyAction.cascade)();
  IntColumn get typeId => integer().references(PokemonTypes, #id)();
  IntColumn get slot => integer().check(slot.isBetweenValues(1, 2))();

  @override
  Set<Column> get primaryKey => {pokemonId, typeId};

  @override
  List<Set<Column>> get uniqueKeys => [
    {pokemonId, slot},
  ];
}

@DataClassName('FavoriteRow')
@TableIndex(name: 'favorite_creation_order', columns: {#createdAt, #pokemonId})
class Favorites extends Table {
  @override
  String get tableName => 'favorite';

  IntColumn get pokemonId => integer().references(PokemonRecords, #id)();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {pokemonId};
}

@DataClassName('SyncMetadataRow')
class SyncMetadataRecords extends Table {
  @override
  String get tableName => 'sync_metadata';

  TextColumn get resourceKey =>
      text().check(resourceKey.length.isBiggerThanValue(0))();
  IntColumn get nextOffset => integer()
      .withDefault(const Constant(0))
      .check(nextOffset.isBiggerOrEqualValue(0))();
  IntColumn get totalCount =>
      integer().nullable().check(totalCount.isBiggerOrEqualValue(0))();
  TextColumn get status => text()
      .withDefault(const Constant('idle'))
      .check(status.isIn(['idle', 'syncing', 'success', 'failed']))();
  DateTimeColumn get lastSuccessAt => dateTime().nullable()();
  TextColumn get lastError => text().nullable()();
  BoolColumn get isComplete => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {resourceKey};
}

// ---------------------------------------------------------------------------
// v2: catalogo ampliado (Diagrama 6.1 y 6.2). Todo se escribe solo desde la sync.

@DataClassName('GenerationRow')
class Generations extends Table {
  @override
  String get tableName => 'generation';

  IntColumn get id => integer().check(id.isBiggerThanValue(0))();
  TextColumn get name => text().check(name.length.isBiggerThanValue(0))();
  // Region principal de la generacion (filtro recomendado RF-FIL-02).
  TextColumn get regionName => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// Las evoluciones y los egg groups son de la especie; las formas son varios
// pokemon de la misma especie.
@DataClassName('SpeciesRow')
@TableIndex(name: 'species_generation', columns: {#generationId, #id})
class PokemonSpecies extends Table {
  @override
  String get tableName => 'species';

  IntColumn get id => integer().check(id.isBiggerThanValue(0))();
  TextColumn get name => text().check(name.length.isBiggerThanValue(0))();
  IntColumn get generationId =>
      integer().nullable().references(Generations, #id)();
  IntColumn get evolutionChainId =>
      integer().nullable().check(evolutionChainId.isBiggerThanValue(0))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('StatRow')
class Stats extends Table {
  @override
  String get tableName => 'stat';

  IntColumn get id => integer().check(id.isBiggerThanValue(0))();
  TextColumn get name =>
      text().unique().check(name.length.isBiggerThanValue(0))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('PokemonStatRow')
class PokemonStats extends Table {
  @override
  String get tableName => 'pokemon_stat';

  IntColumn get pokemonId =>
      integer().references(PokemonRecords, #id, onDelete: KeyAction.cascade)();
  IntColumn get statId => integer().references(Stats, #id)();
  IntColumn get baseValue =>
      integer().check(baseValue.isBiggerOrEqualValue(0))();

  @override
  Set<Column> get primaryKey => {pokemonId, statId};
}

@DataClassName('AbilityRow')
class Abilities extends Table {
  @override
  String get tableName => 'ability';

  IntColumn get id => integer().check(id.isBiggerThanValue(0))();
  TextColumn get name => text().check(name.length.isBiggerThanValue(0))();
  // Efecto corto; la UI lo recorta a 140-160 caracteres (RF-DET-03).
  TextColumn get effectSummary => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('PokemonAbilityRow')
@TableIndex(name: 'pokemon_ability_by_ability', columns: {#abilityId})
class PokemonAbilities extends Table {
  @override
  String get tableName => 'pokemon_ability';

  IntColumn get pokemonId =>
      integer().references(PokemonRecords, #id, onDelete: KeyAction.cascade)();
  IntColumn get abilityId => integer().references(Abilities, #id)();
  IntColumn get slot => integer().check(slot.isBetweenValues(1, 3))();
  BoolColumn get isHidden => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {pokemonId, abilityId};
}

@DataClassName('MoveRow')
class Moves extends Table {
  @override
  String get tableName => 'move';

  IntColumn get id => integer().check(id.isBiggerThanValue(0))();
  TextColumn get name => text().check(name.length.isBiggerThanValue(0))();
  IntColumn get typeId => integer().nullable().references(PokemonTypes, #id)();
  IntColumn get power =>
      integer().nullable().check(power.isBiggerOrEqualValue(0))();
  IntColumn get accuracy =>
      integer().nullable().check(accuracy.isBetweenValues(0, 100))();

  @override
  Set<Column> get primaryKey => {id};
}

// v3: juegos (red-blue, scarlet-violet...) con el orden cronologico de PokeAPI,
// para el selector de movimientos del detalle (RF-DET-05).
@DataClassName('VersionGroupRow')
class VersionGroups extends Table {
  @override
  String get tableName => 'version_group';

  IntColumn get id => integer().check(id.isBiggerThanValue(0))();
  TextColumn get name =>
      text().unique().check(name.length.isBiggerThanValue(0))();
  IntColumn get sortOrder =>
      integer().check(sortOrder.isBiggerOrEqualValue(0))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('PokemonMoveRow')
// Consulta por defecto del detalle: un version group y un metodo (RF-DET-05).
@TableIndex(
  name: 'pokemon_move_by_version',
  columns: {#pokemonId, #versionGroupId, #learnMethod},
)
class PokemonMoves extends Table {
  @override
  String get tableName => 'pokemon_move';

  IntColumn get pokemonId =>
      integer().references(PokemonRecords, #id, onDelete: KeyAction.cascade)();
  IntColumn get moveId => integer().references(Moves, #id)();
  IntColumn get versionGroupId => integer().references(VersionGroups, #id)();
  // level-up, machine, tutor, egg...
  TextColumn get learnMethod =>
      text().check(learnMethod.length.isBiggerThanValue(0))();
  IntColumn get levelLearned => integer()
      .withDefault(const Constant(0))
      .check(levelLearned.isBiggerOrEqualValue(0))();

  // El nivel es parte de la clave: PokeAPI registra algunos movimientos dos
  // veces en el mismo juego (vine-whip de bulbasaur en sun-moon: 7 y 9).
  @override
  Set<Column> get primaryKey => {
    pokemonId,
    moveId,
    versionGroupId,
    learnMethod,
    levelLearned,
  };
}

@DataClassName('EggGroupRow')
class EggGroups extends Table {
  @override
  String get tableName => 'egg_group';

  IntColumn get id => integer().check(id.isBiggerThanValue(0))();
  TextColumn get name =>
      text().unique().check(name.length.isBiggerThanValue(0))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SpeciesEggGroupRow')
class SpeciesEggGroups extends Table {
  @override
  String get tableName => 'species_egg_group';

  IntColumn get speciesId =>
      integer().references(PokemonSpecies, #id, onDelete: KeyAction.cascade)();
  IntColumn get eggGroupId => integer().references(EggGroups, #id)();

  @override
  Set<Column> get primaryKey => {speciesId, eggGroupId};
}

// Una fila por paso de la cadena; varias desde la misma especie = ramas (RF-DET-04).
@DataClassName('EvolutionRow')
@TableIndex(name: 'evolution_to_species', columns: {#toSpeciesId})
class Evolutions extends Table {
  @override
  String get tableName => 'evolution';

  IntColumn get fromSpeciesId =>
      integer().references(PokemonSpecies, #id, onDelete: KeyAction.cascade)();
  IntColumn get toSpeciesId =>
      integer().references(PokemonSpecies, #id, onDelete: KeyAction.cascade)();
  // Trigger principal: level-up, use-item, trade, shed...
  TextColumn get trigger => text().check(trigger.length.isBiggerThanValue(0))();
  IntColumn get minLevel =>
      integer().nullable().check(minLevel.isBiggerThanValue(0))();
  TextColumn get itemName => text().nullable()();
  IntColumn get minHappiness =>
      integer().nullable().check(minHappiness.isBiggerOrEqualValue(0))();
  TextColumn get timeOfDay => text().nullable()();

  @override
  Set<Column> get primaryKey => {fromSpeciesId, toSpeciesId};
}

// Multiplicador de dano de PokeAPI en porcentaje: 0, 50, 100 o 200 (RF-DET-06).
@DataClassName('TypeEfficacyRow')
class TypeEfficacies extends Table {
  @override
  String get tableName => 'type_efficacy';

  IntColumn get attackerTypeId => integer().references(PokemonTypes, #id)();
  IntColumn get defenderTypeId => integer().references(PokemonTypes, #id)();
  IntColumn get damageFactor =>
      integer().check(damageFactor.isIn([0, 50, 100, 200]))();

  @override
  Set<Column> get primaryKey => {attackerTypeId, defenderTypeId};
}

// ---------------------------------------------------------------------------
// v2: datos del usuario y locales (Diagrama 6.3). La sync del catalogo no los toca.

@DataClassName('TriviaResultRow')
// Ranking local: mejores puntajes primero (RF-TRV-03).
@TableIndex(name: 'trivia_result_ranking', columns: {#score, #playedAt})
class TriviaResults extends Table {
  @override
  String get tableName => 'trivia_result';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get score => integer().check(score.isBiggerOrEqualValue(0))();
  IntColumn get correctAnswers =>
      integer().check(correctAnswers.isBiggerOrEqualValue(0))();
  IntColumn get totalQuestions =>
      integer().check(totalQuestions.isBiggerThanValue(0))();
  DateTimeColumn get playedAt => dateTime()();
}

@DataClassName('TriviaAnswerRow')
@TableIndex(name: 'trivia_answer_by_result', columns: {#triviaResultId})
class TriviaAnswers extends Table {
  @override
  String get tableName => 'trivia_answer';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get triviaResultId =>
      integer().references(TriviaResults, #id, onDelete: KeyAction.cascade)();
  IntColumn get pokemonId => integer().references(PokemonRecords, #id)();
  BoolColumn get correct => boolean()();
  IntColumn get answeredInMs =>
      integer().nullable().check(answeredInMs.isBiggerOrEqualValue(0))();
}

// Los umbrales viven en el codigo y se documentan; aqui solo cuando se desbloqueo.
@DataClassName('AchievementRow')
class Achievements extends Table {
  @override
  String get tableName => 'achievement';

  TextColumn get key => text().check(key.length.isBiggerThanValue(0))();
  DateTimeColumn get unlockedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {key};
}

// Preferencias clave/valor: busqueda, filtros, orden, tema... (RF-FIL-04).
@DataClassName('AppSettingRow')
class AppSettings extends Table {
  @override
  String get tableName => 'app_setting';

  TextColumn get key => text().check(key.length.isBiggerThanValue(0))();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

// Imagenes guardadas en disco con limite y limpieza LRU (PS-08, Fase 5).
@DataClassName('ImageCacheRow')
@TableIndex(name: 'image_cache_lru', columns: {#lastAccessedAt})
class ImageCacheEntries extends Table {
  @override
  String get tableName => 'image_cache';

  TextColumn get url => text().check(url.length.isBiggerThanValue(0))();
  TextColumn get localPath =>
      text().unique().check(localPath.length.isBiggerThanValue(0))();
  IntColumn get sizeBytes =>
      integer().check(sizeBytes.isBiggerOrEqualValue(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get lastAccessedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {url};
}
