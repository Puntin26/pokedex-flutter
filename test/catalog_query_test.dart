import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/core/database/app_database.dart';
import 'package:pokedex/core/domain/sync_metadata.dart';
import 'package:pokedex/features/pokemon/data/local_pokemon_repository.dart';
import 'package:pokedex/features/pokemon/domain/catalog_query.dart';
import 'package:pokedex/features/pokemon/domain/pokemon.dart';

const grass = PokemonType(id: 12, name: 'grass');
const poison = PokemonType(id: 4, name: 'poison');
const fire = PokemonType(id: 10, name: 'fire');
const electric = PokemonType(id: 13, name: 'electric');
const psychic = PokemonType(id: 14, name: 'psychic');
const fairy = PokemonType(id: 18, name: 'fairy');
const dark = PokemonType(id: 17, name: 'dark');
const normal = PokemonType(id: 1, name: 'normal');
const gen1 = Generation(id: 1, name: 'generation-i', regionName: 'kanto');
const gen2 = Generation(id: 2, name: 'generation-ii', regionName: 'johto');

Pokemon entry(
  int id,
  String name, {
  required List<PokemonType> types,
  int? nationalNumber,
  Generation? generation,
  int? total,
  bool hasSpecies = true,
}) {
  final number = nationalNumber ?? id;
  return Pokemon(
    id: id,
    nationalNumber: number,
    name: name,
    updatedAt: DateTime.utc(2026),
    types: [
      for (var i = 0; i < types.length; i++)
        PokemonTypeSlot(type: types[i], slot: i + 1),
    ],
    species: hasSpecies
        ? PokemonSpecies(id: number, name: name, generation: generation)
        : null,
    baseStatTotal: total,
  );
}

final catalog = [
  entry(1, 'bulbasaur', types: [grass, poison], generation: gen1, total: 318),
  entry(4, 'charmander', types: [fire], generation: gen1, total: 309),
  entry(25, 'pikachu', types: [electric], generation: gen1, total: 320),
  entry(122, 'mr-mime', types: [psychic, fairy], generation: gen1, total: 460),
  entry(152, 'chikorita', types: [grass], generation: gen2, total: 318),
  entry(
    10091,
    'rattata-alola',
    nationalNumber: 19,
    types: [dark, normal],
    generation: gen1,
    total: 253,
  ),
  // Fila migrada de v1: sin especie ni total hasta la proxima sync.
  entry(9999, 'legacy', types: [normal], hasSpecies: false),
];

void main() {
  late AppDatabase database;
  late LocalPokemonRepository repository;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    repository = LocalPokemonRepository(database);
    await repository.savePage(
      catalog,
      SyncMetadata(
        resourceKey: 'pokemon_catalog',
        nextOffset: catalog.length,
        totalCount: catalog.length,
        status: SyncStatus.success,
        isComplete: true,
      ),
    );
  });
  tearDown(() => database.close());

  Future<List<String>> names(CatalogQuery query) async =>
      (await repository.watchCatalog(query).first)
          .map((pokemon) => pokemon.name)
          .toList();

  group('CatalogQuery (dominio)', () {
    test('Normaliza la busqueda: minusculas, sin bordes, espacios a guion', () {
      expect(
        const CatalogQuery(search: '  Mr  Mime ').normalizedSearch,
        'mr-mime',
      );
      expect(const CatalogQuery().normalizedSearch, '');
    });

    test('Igualdad por valor y copyWith que puede limpiar filtros', () {
      const query = CatalogQuery(search: 'pika', typeId: 13, generationId: 1);
      expect(
        query,
        const CatalogQuery(search: 'pika', typeId: 13, generationId: 1),
      );
      expect(
        query.hashCode,
        const CatalogQuery(
          search: 'pika',
          typeId: 13,
          generationId: 1,
        ).hashCode,
      );
      final cleared = query.copyWith(typeId: null, sort: CatalogSort.name);
      expect(cleared.typeId, isNull);
      expect(cleared.generationId, 1);
      expect(cleared.search, 'pika');
      expect(cleared.sort, CatalogSort.name);
      expect(query.copyWith(), query);
    });
  });

  group('watchCatalog(CatalogQuery) en SQL (2.5)', () {
    test('Sin filtros ordena por numero nacional e incluye formas', () async {
      expect(await names(const CatalogQuery()), [
        'bulbasaur',
        'charmander',
        'rattata-alola',
        'pikachu',
        'mr-mime',
        'chikorita',
        'legacy',
      ]);
    });

    test('Busca por parte del nombre sin distinguir mayusculas', () async {
      expect(await names(const CatalogQuery(search: 'SAUR')), ['bulbasaur']);
      expect(await names(const CatalogQuery(search: 'cha')), ['charmander']);
      expect(await names(const CatalogQuery(search: 'mr mime')), ['mr-mime']);
      expect(await names(const CatalogQuery(search: 'zzz')), isEmpty);
    });

    test('Los comodines de LIKE se buscan como texto literal', () async {
      expect(await names(const CatalogQuery(search: '%')), isEmpty);
      expect(await names(const CatalogQuery(search: '_')), isEmpty);
      expect(await names(const CatalogQuery(search: r'\')), isEmpty);
    });

    test('Filtra por tipo y conserva todos los tipos del Pokemon', () async {
      final result = await repository
          .watchCatalog(CatalogQuery(typeId: poison.id))
          .first;
      expect(result.map((pokemon) => pokemon.name), ['bulbasaur']);
      expect(result.single.types.map((slot) => slot.type.name), [
        'grass',
        'poison',
      ]);
      expect(await names(CatalogQuery(typeId: grass.id)), [
        'bulbasaur',
        'chikorita',
      ]);
    });

    test('Filtra por generacion y excluye filas sin especie', () async {
      expect(await names(const CatalogQuery(generationId: 2)), ['chikorita']);
      expect(
        await names(const CatalogQuery(generationId: 1)),
        isNot(contains('legacy')),
      );
    });

    test('Combina busqueda, tipo y generacion', () async {
      expect(
        await names(
          CatalogQuery(search: 'i', typeId: grass.id, generationId: 2),
        ),
        ['chikorita'],
      );
    });

    test('Ordena por nombre en ambos sentidos', () async {
      expect(await names(const CatalogQuery(sort: CatalogSort.name)), [
        'bulbasaur',
        'charmander',
        'chikorita',
        'legacy',
        'mr-mime',
        'pikachu',
        'rattata-alola',
      ]);
      expect(
        (await names(
          const CatalogQuery(sort: CatalogSort.name, descending: true),
        )).first,
        'rattata-alola',
      );
    });

    test('Ordena por total con empates por numero y nulos al final', () async {
      expect(
        await names(
          const CatalogQuery(sort: CatalogSort.baseStatTotal, descending: true),
        ),
        [
          'mr-mime',
          'pikachu',
          'bulbasaur',
          'chikorita',
          'charmander',
          'rattata-alola',
          'legacy',
        ],
      );
      expect(await names(const CatalogQuery(sort: CatalogSort.baseStatTotal)), [
        'rattata-alola',
        'charmander',
        'bulbasaur',
        'chikorita',
        'pikachu',
        'mr-mime',
        'legacy',
      ]);
    });

    test('El resultado filtrado se actualiza al guardar una pagina', () async {
      final events = StreamIterator(
        repository.watchCatalog(CatalogQuery(typeId: fire.id)),
      );
      addTearDown(events.cancel);
      expect(await events.moveNext(), isTrue);
      expect(events.current.map((pokemon) => pokemon.name), ['charmander']);

      await repository.savePage(
        [
          entry(5, 'charmeleon', types: [fire], generation: gen1, total: 405),
        ],
        SyncMetadata(
          resourceKey: 'pokemon_catalog',
          nextOffset: 8,
          totalCount: 8,
          status: SyncStatus.success,
          isComplete: true,
        ),
      );
      expect(await events.moveNext(), isTrue);
      expect(events.current.map((pokemon) => pokemon.name), [
        'charmander',
        'charmeleon',
      ]);
    });

    test('watchGenerations lista las generaciones ordenadas', () async {
      final generations = await repository.watchGenerations().first;
      expect(generations.map((generation) => generation.id), [1, 2]);
      expect(generations.last.regionName, 'johto');
    });
  });
}
