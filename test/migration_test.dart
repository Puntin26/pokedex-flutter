import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/core/database/app_database.dart';

import 'generated_migrations/schema.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test('v1 -> v2 produce exactamente el esquema v2', () async {
    final schema = await verifier.schemaAt(1);
    final database = AppDatabase(schema.newConnection());
    addTearDown(database.close);
    await verifier.migrateAndValidate(database, 2);
  });

  test('v1 -> v2 conserva catalogo, tipos, favoritos y progreso de sync', () async {
    final schema = await verifier.schemaAt(1);
    final v1 = schema.rawDatabase;
    // Fechas como segundos Unix: el formato que usa Drift en v1.
    v1.execute('''
      INSERT INTO pokemon (id, national_number, name, image_url, updated_at)
        VALUES (1, 1, 'bulbasaur', 'https://img/1.png', 1764000000),
               (25, 25, 'pikachu', NULL, 1764000000);
      INSERT INTO type (id, name) VALUES (12, 'grass'), (13, 'electric');
      INSERT INTO pokemon_type (pokemon_id, type_id, slot)
        VALUES (1, 12, 1), (25, 13, 1);
      INSERT INTO favorite (pokemon_id, created_at) VALUES (25, 1764100000);
      INSERT INTO sync_metadata
        (resource_key, next_offset, total_count, status, last_success_at,
         last_error, is_complete)
        VALUES ('pokemon_catalog', 2, 2, 'success', 1764000000, NULL, 1);
    ''');

    final database = AppDatabase(schema.newConnection());
    addTearDown(database.close);
    await verifier.migrateAndValidate(database, 2);

    final pokemon = await (database.select(
      database.pokemonRecords,
    )..orderBy([(row) => OrderingTerm.asc(row.id)])).get();
    expect(pokemon.map((row) => (row.id, row.name, row.imageUrl)), [
      (1, 'bulbasaur', 'https://img/1.png'),
      (25, 'pikachu', null),
    ]);
    // Las columnas nuevas no inventan datos: quedan nulas hasta la sync.
    expect(pokemon.first.speciesId, isNull);
    expect(pokemon.first.baseStatTotal, isNull);
    expect(pokemon.first.isDefault, isTrue);

    expect(
      await database.select(database.pokemonTypeLinks).get(),
      hasLength(2),
    );
    final favorite = await database.select(database.favorites).getSingle();
    expect(favorite.pokemonId, 25);
    expect(
      favorite.createdAt.toUtc(),
      DateTime.fromMillisecondsSinceEpoch(1764100000 * 1000, isUtc: true),
    );
    final metadata = await database
        .select(database.syncMetadataRecords)
        .getSingle();
    expect(metadata.isComplete, isTrue);
    expect(metadata.nextOffset, 2);

    // Las tablas nuevas existen, vacias, y aceptan datos con sus restricciones.
    expect(await database.select(database.appSettings).get(), isEmpty);
    await database
        .into(database.appSettings)
        .insert(AppSettingsCompanion.insert(key: 'catalog.query', value: '{}'));
    expect(await database.select(database.appSettings).get(), hasLength(1));
  });

  test('v2 hace cumplir las llaves foraneas de las tablas nuevas', () async {
    final schema = await verifier.schemaAt(1);
    final database = AppDatabase(schema.newConnection());
    addTearDown(database.close);
    await verifier.migrateAndValidate(database, 2);

    await expectLater(
      database
          .into(database.pokemonStats)
          .insert(
            PokemonStatsCompanion.insert(
              pokemonId: 999,
              statId: 1,
              baseValue: 45,
            ),
          ),
      throwsA(isA<Exception>()),
    );
  });
}
