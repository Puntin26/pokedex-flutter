import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/core/database/app_database.dart';
import 'package:pokedex/core/domain/sync_metadata.dart';
import 'package:pokedex/features/favorites/data/local_favorites_repository.dart';
import 'package:pokedex/features/pokemon/data/local_pokemon_repository.dart';
import 'package:pokedex/features/pokemon/domain/pokemon.dart';

final savedAt = DateTime.utc(2026, 11, 15, 12);
const grass = PokemonType(id: 12, name: 'grass');
const poison = PokemonType(id: 4, name: 'poison');
const resource = 'pokemon_catalog';

const kanto = Generation(id: 1, name: 'generation-i', regionName: 'kanto');

Pokemon samplePokemon({
  int id = 1,
  int nationalNumber = 1,
  String name = 'bulbasaur',
  String? imageUrl = 'https://example.com/1.png',
  List<PokemonTypeSlot> types = const [
    PokemonTypeSlot(type: poison, slot: 2),
    PokemonTypeSlot(type: grass, slot: 1),
  ],
  PokemonSpecies? species,
  int? baseStatTotal,
  bool isDefault = true,
}) => Pokemon(
  id: id,
  nationalNumber: nationalNumber,
  name: name,
  imageUrl: imageUrl,
  updatedAt: savedAt,
  types: types,
  species: species,
  baseStatTotal: baseStatTotal,
  isDefault: isDefault,
);

SyncMetadata pageMetadata({int offset = 1, bool complete = false}) =>
    SyncMetadata(
      resourceKey: resource,
      nextOffset: offset,
      totalCount: 2,
      status: SyncStatus.success,
      lastSuccessAt: savedAt,
      isComplete: complete,
    );

Future<T> nextValue<T>(StreamIterator<T> iterator) async {
  expect(await iterator.moveNext().timeout(const Duration(seconds: 5)), isTrue);
  return iterator.current;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('SQLite en memoria', () {
    late AppDatabase database;
    late LocalPokemonRepository pokemon;
    late LocalFavoritesRepository favorites;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      pokemon = LocalPokemonRepository(database);
      favorites = LocalFavoritesRepository(database);
    });

    tearDown(() => database.close());

    test(
      'La base nueva esta vacia, con version, indices y claves foraneas',
      () async {
        expect(await pokemon.watchCatalog().first, isEmpty);
        expect(await pokemon.watchTypes().first, isEmpty);
        expect(await favorites.watchFavorites().first, isEmpty);
        expect(await pokemon.watchSyncMetadata(resource).first, isNull);
        expect(await pokemon.readSyncMetadata(resource), isNull);
        final version = await database
            .customSelect('PRAGMA user_version')
            .getSingle();
        expect(version.read<int>('user_version'), 2);
        final keys = await database
            .customSelect('PRAGMA foreign_keys')
            .getSingle();
        expect(keys.read<int>('foreign_keys'), 1);
        final indices = await database
            .customSelect("SELECT name FROM sqlite_master WHERE type = 'index'")
            .get();
        expect(
          indices.map((row) => row.read<String>('name')),
          containsAll([
            'pokemon_national_order',
            'favorite_creation_order',
            // v2: busqueda, filtros y orden del catalogo (RNF-REN-02).
            'pokemon_name',
            'pokemon_stat_total_order',
            'pokemon_type_by_type',
            'species_generation',
          ]),
        );
      },
    );

    test(
      'El catalogo y los tipos emiten cambios ordenados tras el commit',
      () async {
        final catalog = StreamIterator(pokemon.watchCatalog());
        final types = StreamIterator(pokemon.watchTypes());
        final metadata = StreamIterator(pokemon.watchSyncMetadata(resource));
        addTearDown(catalog.cancel);
        addTearDown(types.cancel);
        addTearDown(metadata.cancel);
        expect(await nextValue(catalog), isEmpty);
        expect(await nextValue(types), isEmpty);
        expect(await nextValue(metadata), isNull);

        await pokemon.savePage([
          samplePokemon(id: 2, nationalNumber: 2, name: 'ivysaur'),
          samplePokemon(),
        ], pageMetadata(offset: 2, complete: true));

        final result = await nextValue(catalog);
        expect(result.map((item) => item.id), [1, 2]);
        expect(result.first.name, 'bulbasaur');
        expect(result.first.imageUrl, 'https://example.com/1.png');
        expect(result.first.updatedAt, savedAt);
        expect(result.first.types.map((entry) => entry.type.name), [
          'grass',
          'poison',
        ]);
        expect(result.first.types.map((entry) => entry.slot), [1, 2]);
        expect((await nextValue(types)).map((type) => type.name), [
          'grass',
          'poison',
        ]);
        final progress = (await nextValue(metadata))!;
        expect(progress.nextOffset, 2);
        expect(progress.totalCount, 2);
        expect(progress.status, SyncStatus.success);
        expect(progress.lastSuccessAt, savedAt);
        expect(progress.isComplete, isTrue);
      },
    );

    test(
      'Repetir una pagina no duplica entidades y conserva el favorito',
      () async {
        await pokemon.savePage([samplePokemon()], pageMetadata());
        await favorites.addFavorite(1, savedAt);
        for (var repetition = 0; repetition < 3; repetition++) {
          await pokemon.savePage([samplePokemon()], pageMetadata());
        }
        expect(
          await database.select(database.pokemonRecords).get(),
          hasLength(1),
        );
        expect(
          await database.select(database.pokemonTypes).get(),
          hasLength(2),
        );
        expect(
          await database.select(database.pokemonTypeLinks).get(),
          hasLength(2),
        );
        expect(
          await database.select(database.syncMetadataRecords).get(),
          hasLength(1),
        );
        final result = await favorites.watchFavorites().first;
        expect(result, hasLength(1));
        expect(result.single.createdAt, savedAt);
      },
    );

    test(
      'El upsert actualiza campos y reemplaza tipos sin perder favoritos',
      () async {
        await pokemon.savePage([samplePokemon()], pageMetadata());
        await favorites.addFavorite(1, savedAt);
        final favoriteStream = StreamIterator(favorites.watchFavorites());
        addTearDown(favoriteStream.cancel);
        await nextValue(favoriteStream);
        await pokemon.savePage([
          samplePokemon(
            name: 'updated-name',
            imageUrl: null,
            types: const [PokemonTypeSlot(type: poison, slot: 1)],
          ),
        ], pageMetadata());
        final updated = (await nextValue(favoriteStream)).single;
        expect(updated.pokemon.name, 'updated-name');
        expect(updated.pokemon.imageUrl, isNull);
        expect(updated.pokemon.types.single.type.name, 'poison');
        expect(updated.pokemon.types.single.slot, 1);
        expect(updated.createdAt, savedAt);
        expect(
          await database.select(database.pokemonTypeLinks).get(),
          hasLength(1),
        );
      },
    );

    test(
      'Los favoritos son reactivos, idempotentes y se ordenan por fecha',
      () async {
        await pokemon.savePage([
          samplePokemon(),
          samplePokemon(id: 2, nationalNumber: 2, name: 'ivysaur'),
        ], pageMetadata(offset: 2));
        final stream = StreamIterator(favorites.watchFavorites());
        addTearDown(stream.cancel);
        expect(await nextValue(stream), isEmpty);
        await favorites.addFavorite(1, savedAt);
        expect((await nextValue(stream)).single.pokemon.id, 1);
        final later = savedAt.add(const Duration(minutes: 1));
        await favorites.addFavorite(2, later);
        expect((await nextValue(stream)).map((item) => item.pokemon.id), [
          2,
          1,
        ]);
        await favorites.addFavorite(1, later);
        final result = await favorites.watchFavorites().first;
        expect(result, hasLength(2));
        expect(result.last.createdAt, savedAt);
        await favorites.removeFavorite(1);
        // Un insert ignorado puede invalidar el stream; leer hasta observar la baja.
        final removed = await favorites.watchFavorites().first;
        expect(removed.single.pokemon.id, 2);
        await favorites.removeFavorite(1);
        expect(await favorites.watchFavorites().first, hasLength(1));
      },
    );

    test(
      'La identidad remota permite formas con el mismo numero nacional',
      () async {
        await pokemon.savePage([
          samplePokemon(id: 10001, name: 'alternate-form'),
          samplePokemon(),
        ], pageMetadata(offset: 2));
        final result = await pokemon.watchCatalog().first;
        expect(result.map((item) => item.id), [1, 10001]);
        expect(result.map((item) => item.nationalNumber), [1, 1]);
      },
    );

    test('Las claves foraneas impiden referencias huerfanas', () async {
      await expectLater(favorites.addFavorite(999, savedAt), throwsException);
      await pokemon.savePage([samplePokemon()], pageMetadata());
      await expectLater(
        database
            .into(database.pokemonTypeLinks)
            .insert(
              PokemonTypeLinksCompanion.insert(
                pokemonId: 999,
                typeId: 12,
                slot: 1,
              ),
            ),
        throwsException,
      );
      await expectLater(
        database
            .into(database.pokemonTypeLinks)
            .insert(
              PokemonTypeLinksCompanion.insert(
                pokemonId: 1,
                typeId: 999,
                slot: 1,
              ),
            ),
        throwsException,
      );
      await favorites.addFavorite(1, savedAt);
      await expectLater(
        (database.delete(
          database.pokemonRecords,
        )..where((row) => row.id.equals(1))).go(),
        throwsException,
      );
      expect(
        await database.customSelect('PRAGMA foreign_key_check').get(),
        isEmpty,
      );
    });

    test('SQLite rechaza claves, tipos y posiciones duplicados', () async {
      await pokemon.savePage([samplePokemon()], pageMetadata());
      for (final statement in [
        "INSERT INTO pokemon VALUES (1, 1, 'duplicate', NULL, 0)",
        "INSERT INTO type VALUES (12, 'duplicate')",
        "INSERT INTO type VALUES (999, 'grass')",
        'INSERT INTO pokemon_type VALUES (1, 12, 2)',
        'INSERT INTO pokemon_type VALUES (1, 4, 1)',
      ]) {
        await expectLater(database.customStatement(statement), throwsException);
      }
      // Un tipo nuevo tampoco puede ocupar una posicion ya utilizada.
      await database.customStatement("INSERT INTO type VALUES (10, 'fire')");
      await expectLater(
        database.customStatement('INSERT INTO pokemon_type VALUES (1, 10, 1)'),
        throwsException,
      );
    });

    test(
      'SQLite valida valores y estados incluso ante escrituras directas',
      () async {
        await pokemon.savePage([samplePokemon()], pageMetadata());
        for (final statement in [
          "UPDATE pokemon SET id = 0 WHERE id = 1",
          'UPDATE pokemon SET national_number = 0',
          "UPDATE pokemon SET name = ''",
          "UPDATE type SET name = '' WHERE id = 12",
          'UPDATE pokemon_type SET slot = 0',
          'UPDATE pokemon_type SET slot = 3',
          'UPDATE sync_metadata SET next_offset = -1',
          'UPDATE sync_metadata SET total_count = -1',
          "UPDATE sync_metadata SET status = 'unknown'",
          "UPDATE sync_metadata SET resource_key = ''",
        ]) {
          await expectLater(
            database.customStatement(statement),
            throwsException,
          );
        }
      },
    );

    test(
      'Un fallo intermedio revierte catalogo, tipos y progreso de la pagina',
      () async {
        await pokemon.savePage([samplePokemon()], pageMetadata());
        await favorites.addFavorite(1, savedAt);
        final invalid = samplePokemon(
          id: 3,
          nationalNumber: 3,
          name: 'invalid',
          types: const [
            PokemonTypeSlot(type: PokemonType(id: 10, name: 'fire'), slot: 1),
            PokemonTypeSlot(type: poison, slot: 1),
          ],
        );
        await expectLater(
          pokemon.savePage([
            samplePokemon(name: 'should-rollback', types: const []),
            samplePokemon(id: 2, nationalNumber: 2, name: 'ivysaur'),
            invalid,
          ], pageMetadata(offset: 3)),
          throwsException,
        );
        final result = await pokemon.watchCatalog().first;
        expect(result.single.name, 'bulbasaur');
        expect(result.single.types, hasLength(2));
        expect(
          await database.select(database.pokemonTypes).get(),
          hasLength(2),
        );
        expect((await pokemon.readSyncMetadata(resource))!.nextOffset, 1);
        expect(
          (await favorites.watchFavorites().first).single.createdAt,
          savedAt,
        );
      },
    );

    test(
      'Un fallo al guardar metadata tambien revierte todos los datos',
      () async {
        await expectLater(
          pokemon.savePage([
            samplePokemon(),
          ], const SyncMetadata(resourceKey: resource, nextOffset: -1)),
          throwsException,
        );
        expect(await pokemon.watchCatalog().first, isEmpty);
        expect(await pokemon.watchTypes().first, isEmpty);
        expect(await pokemon.readSyncMetadata(resource), isNull);
      },
    );

    test('Un fallo sincrono no publica filas parciales en el stream', () async {
      final catalog = StreamIterator(pokemon.watchCatalog());
      addTearDown(catalog.cancel);
      expect(await nextValue(catalog), isEmpty);
      await expectLater(
        pokemon.savePage([
          samplePokemon(),
        ], const SyncMetadata(resourceKey: resource, nextOffset: -1)),
        throwsException,
      );
      await pokemon.savePage([
        samplePokemon(id: 2, nationalNumber: 2, name: 'ivysaur'),
      ], pageMetadata(offset: 2));
      final result = await nextValue(catalog);
      expect(result.single.id, 2);
    });

    test(
      'El estado de sincronizacion conserva progreso y datos por recurso',
      () async {
        await pokemon.updateSyncStatus(resource, SyncStatus.syncing);
        final initial = (await pokemon.readSyncMetadata(resource))!;
        expect(initial.nextOffset, 0);
        expect(initial.totalCount, isNull);
        expect(initial.lastSuccessAt, isNull);
        expect(initial.isComplete, isFalse);
        await pokemon.savePage([samplePokemon()], pageMetadata());
        await pokemon.updateSyncStatus(
          resource,
          SyncStatus.failed,
          lastError: 'timeout',
        );
        await pokemon.updateSyncStatus('other_resource', SyncStatus.syncing);
        final failed = (await pokemon.readSyncMetadata(resource))!;
        expect(failed.status, SyncStatus.failed);
        expect(failed.lastError, 'timeout');
        expect(failed.nextOffset, 1);
        expect(failed.totalCount, 2);
        expect(failed.lastSuccessAt, savedAt);
        expect(await pokemon.watchCatalog().first, hasLength(1));
        expect(
          (await pokemon.readSyncMetadata('other_resource'))!.nextOffset,
          0,
        );
        await pokemon.updateSyncStatus(resource, SyncStatus.syncing);
        expect((await pokemon.readSyncMetadata(resource))!.lastError, isNull);
        await pokemon.savePage([], pageMetadata(offset: 1, complete: true));
        expect((await pokemon.readSyncMetadata(resource))!.isComplete, isTrue);
        expect(await pokemon.watchCatalog().first, hasLength(1));
      },
    );
  });

  test(
    'Catalogo, favoritos y metadata sobreviven al cierre y reapertura en disco',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'pokedex_database_test_',
      );
      final file = File('${directory.path}/pokedex.sqlite');
      const pathChannel = MethodChannel('plugins.flutter.io/path_provider');
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(pathChannel, (call) async {
        if (call.method == 'getApplicationDocumentsDirectory' ||
            call.method == 'getTemporaryDirectory') {
          return directory.path;
        }
        throw UnsupportedError('Metodo de ruta no esperado: ${call.method}');
      });
      AppDatabase? diskDatabase;
      try {
        // Usa la apertura real de drift_flutter, con directorios temporales.
        diskDatabase = AppDatabase();
        var diskPokemon = LocalPokemonRepository(diskDatabase);
        var diskFavorites = LocalFavoritesRepository(diskDatabase);
        await diskPokemon.savePage([
          samplePokemon(),
        ], pageMetadata(complete: true));
        await diskFavorites.addFavorite(1, savedAt);
        await diskPokemon.updateSyncStatus(
          resource,
          SyncStatus.failed,
          lastError: 'offline',
        );
        await diskDatabase.close();
        diskDatabase = null;

        expect(await file.length(), greaterThan(0));
        diskDatabase = AppDatabase();
        diskPokemon = LocalPokemonRepository(diskDatabase);
        diskFavorites = LocalFavoritesRepository(diskDatabase);
        final stored = (await diskPokemon.watchCatalog().first).single;
        expect(stored.name, 'bulbasaur');
        expect(stored.types.map((entry) => entry.type.name), [
          'grass',
          'poison',
        ]);
        expect(
          (await diskFavorites.watchFavorites().first).single.createdAt,
          savedAt,
        );
        final progress = (await diskPokemon.readSyncMetadata(resource))!;
        expect(progress.nextOffset, 1);
        expect(progress.totalCount, 2);
        expect(progress.isComplete, isTrue);
        expect(progress.lastSuccessAt, savedAt);
        expect(progress.status, SyncStatus.failed);
        expect(progress.lastError, 'offline');
        expect(
          await diskDatabase.customSelect('PRAGMA foreign_key_check').get(),
          isEmpty,
        );
      } finally {
        await diskDatabase?.close();
        messenger.setMockMethodCallHandler(pathChannel, null);
        // Solo se elimina el directorio temporal creado por esta prueba.
        await directory.delete(recursive: true);
      }
    },
  );

  group('Catalogo v2: especie, generacion y medidas (2.3)', () {
    late AppDatabase database;
    late LocalPokemonRepository pokemon;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      pokemon = LocalPokemonRepository(database);
    });
    tearDown(() => database.close());

    test('Guarda y devuelve especie, generacion, total y forma', () async {
      await pokemon.savePage([
        samplePokemon(
          species: const PokemonSpecies(
            id: 1,
            name: 'bulbasaur',
            generation: kanto,
          ),
          baseStatTotal: 318,
        ),
        samplePokemon(
          id: 10091,
          nationalNumber: 19,
          name: 'rattata-alola',
          species: const PokemonSpecies(
            id: 19,
            name: 'rattata',
            generation: kanto,
          ),
          baseStatTotal: 253,
          isDefault: false,
        ),
      ], pageMetadata(offset: 2, complete: true));

      final catalog = await pokemon.watchCatalog().first;
      expect(catalog.map((item) => item.id), [1, 10091]);
      final alola = catalog.last;
      expect(alola.isDefault, isFalse);
      expect(alola.baseStatTotal, 253);
      expect(alola.species!.id, 19);
      expect(alola.species!.name, 'rattata');
      expect(alola.species!.generation!.regionName, 'kanto');
      expect(await database.select(database.generations).get(), hasLength(1));
      expect(
        await database.select(database.pokemonSpecies).get(),
        hasLength(2),
      );
    });

    test('El catalogo no borra lo que guardo la sync del detalle', () async {
      const species = PokemonSpecies(
        id: 1,
        name: 'bulbasaur',
        generation: kanto,
      );
      await pokemon.savePage([samplePokemon(species: species)], pageMetadata());
      // Simula la sync del detalle (Fase 4) completando campos propios.
      await (database.update(database.pokemonSpecies)
            ..where((row) => row.id.equals(1)))
          .write(const PokemonSpeciesCompanion(evolutionChainId: Value(1)));

      await pokemon.savePage([samplePokemon(species: species)], pageMetadata());

      final row = await database.select(database.pokemonSpecies).getSingle();
      expect(row.evolutionChainId, 1);
    });

    test('Sin especie (fila migrada de v1) se lee con campos nulos', () async {
      await pokemon.savePage([samplePokemon()], pageMetadata());
      final item = (await pokemon.watchCatalog().first).single;
      expect(item.species, isNull);
      expect(item.baseStatTotal, isNull);
      expect(item.isDefault, isTrue);
    });
  });
}
