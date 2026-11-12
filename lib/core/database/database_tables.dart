// Los check describen SQL para el generador; no ejecutan getters recursivos.
// ignore_for_file: recursive_getters

import 'package:drift/drift.dart';

@DataClassName('PokemonRow')
@TableIndex(name: 'pokemon_national_order', columns: {#nationalNumber, #id})
class PokemonRecords extends Table {
  @override
  String get tableName => 'pokemon';

  IntColumn get id => integer().check(id.isBiggerThanValue(0))();
  IntColumn get nationalNumber =>
      integer().check(nationalNumber.isBiggerThanValue(0))();
  TextColumn get name => text().check(name.length.isBiggerThanValue(0))();
  TextColumn get imageUrl => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

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
