import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/core/database/app_database.dart';

import 'generated_migrations/schema.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  // Cada version inicial migra a un esquema identico al de una instalacion nueva.
  for (final from in [1, 2]) {
    test('v$from -> v3 produce exactamente el esquema actual', () async {
      final schema = await verifier.schemaAt(from);
      final database = AppDatabase(schema.newConnection());
      addTearDown(database.close);
      await verifier.migrateAndValidate(database, 3);
    });
  }

  test('v1 -> v3 conserva catalogo, tipos, favoritos y progreso de sync', () async {
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
    await verifier.migrateAndValidate(database, 3);

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

  test('v3 hace cumplir las llaves foraneas de las tablas nuevas', () async {
    final schema = await verifier.schemaAt(1);
    final database = AppDatabase(schema.newConnection());
    addTearDown(database.close);
    await verifier.migrateAndValidate(database, 3);

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

  test('v2 -> v3 conserva datos v2 y agrega shiny y version groups', () async {
    final schema = await verifier.schemaAt(2);
    schema.rawDatabase.execute('''
      INSERT INTO generation (id, name, region_name)
        VALUES (1, 'generation-i', 'kanto');
      INSERT INTO species (id, name, generation_id) VALUES (1, 'bulbasaur', 1);
      INSERT INTO pokemon (id, national_number, name, image_url, updated_at,
          species_id, height, weight, base_stat_total, is_default)
        VALUES (1, 1, 'bulbasaur', 'https://img/1.png', 1764000000,
          1, 7, 69, 318, 1);
      INSERT INTO ability (id, name, effect_summary)
        VALUES (65, 'overgrow', NULL);
      INSERT INTO pokemon_ability (pokemon_id, ability_id, slot, is_hidden)
        VALUES (1, 65, 1, 0);
      INSERT INTO favorite (pokemon_id, created_at) VALUES (1, 1764100000);
      INSERT INTO app_setting (key, value) VALUES ('catalog.query', '{"typeId":12}');
    ''');

    final database = AppDatabase(schema.newConnection());
    addTearDown(database.close);
    await verifier.migrateAndValidate(database, 3);

    final pokemon = await database.select(database.pokemonRecords).getSingle();
    expect(pokemon.baseStatTotal, 318);
    expect(pokemon.speciesId, 1);
    expect(pokemon.shinyImageUrl, isNull);
    expect(
      await database.select(database.pokemonAbilities).get(),
      hasLength(1),
    );
    expect(await database.select(database.favorites).get(), hasLength(1));
    final setting = await database.select(database.appSettings).getSingle();
    expect(setting.value, '{"typeId":12}');
    // pokemon_move se recreo con version_group_id (estaba vacia en v2).
    await database
        .into(database.versionGroups)
        .insert(
          VersionGroupsCompanion.insert(
            id: const Value(25),
            name: 'scarlet-violet',
            sortOrder: 28,
          ),
        );
    await database
        .into(database.moves)
        .insert(MovesCompanion.insert(id: const Value(33), name: 'tackle'));
    await database
        .into(database.pokemonMoves)
        .insert(
          PokemonMovesCompanion.insert(
            pokemonId: 1,
            moveId: 33,
            versionGroupId: 25,
            learnMethod: 'level-up',
            levelLearned: const Value(1),
          ),
        );
    expect(await database.select(database.pokemonMoves).get(), hasLength(1));
  });
}
