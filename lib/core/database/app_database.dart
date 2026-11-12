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
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'pokedex'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      // Cada nueva version debera tener una migracion que conserve los datos.
      throw UnsupportedError('Migracion no definida: $from -> $to');
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
