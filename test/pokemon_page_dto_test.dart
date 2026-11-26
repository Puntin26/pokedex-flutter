import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/core/domain/sync_failure.dart';
import 'package:pokedex/features/pokemon/data/pokemon_page_dto.dart';

import 'support/catalog_response.dart';

void main() {
  test('Distingue forma y numero nacional, ordena tipos y usa UTC', () {
    final row = catalogRow(10001, nationalNumber: 386, name: 'deoxys-attack');
    (row['pokemontypes'] as List).setAll(
      0,
      (row['pokemontypes'] as List).reversed.toList(),
    );
    final page = PokemonPageDto.fromJson(
      catalogResponse([row], total: 1),
      limit: 100,
      offset: 0,
    );
    final result = page
        .toDomain(DateTime.parse('2026-11-15T12:00:00-04:00'))
        .single;
    expect(result.id, 10001);
    expect(result.nationalNumber, 386);
    expect(result.name, 'deoxys-attack');
    expect(result.types.map((entry) => entry.slot), [1, 2]);
    expect(result.types.map((entry) => entry.type.name), ['grass', 'poison']);
    expect(result.imageUrl, 'https://example.com/artwork/10001.png');
    expect(result.updatedAt, DateTime.utc(2026, 11, 15, 16));
    expect(result.updatedAt.isUtc, isTrue);
  });

  test('Mapea especie, generacion, region, medidas y total de stats (2.3)', () {
    final row = catalogRow(
      10091,
      nationalNumber: 19,
      name: 'rattata-alola',
      isDefault: false,
      baseStatTotal: 253,
    );
    final result = PokemonPageDto.fromJson(
      catalogResponse([row], total: 1),
      limit: 2,
      offset: 0,
    ).toDomain(DateTime.utc(2026)).single;
    expect(result.isDefault, isFalse);
    expect(result.height, 7);
    expect(result.weight, 69);
    expect(result.baseStatTotal, 253);
    expect(result.species!.id, 19);
    expect(result.species!.name, 'species-19');
    expect(result.species!.generation!.id, 1);
    expect(result.species!.generation!.name, 'generation-i');
    expect(result.species!.generation!.regionName, 'kanto');
  });

  test('Acepta nulos donde el esquema los permite', () {
    final row = catalogRow(1)
      ..['height'] = null
      ..['weight'] = null;
    (row['pokemonspecy'] as Map)['generation'] = null;
    ((row['pokemonstats_aggregate'] as Map)['aggregate'] as Map)['sum'] = {
      'base_stat': null,
    };
    final result = PokemonPageDto.fromJson(
      catalogResponse([row], total: 1),
      limit: 2,
      offset: 0,
    ).toDomain(DateTime.utc(2026)).single;
    expect(result.height, isNull);
    expect(result.weight, isNull);
    expect(result.baseStatTotal, isNull);
    expect(result.species!.generation, isNull);

    final noRegion = catalogRow(2);
    ((noRegion['pokemonspecy'] as Map)['generation'] as Map)['region'] = null;
    final generation = PokemonPageDto.fromJson(
      catalogResponse([noRegion], total: 1),
      limit: 2,
      offset: 0,
    ).toDomain(DateTime.utc(2026)).single.species!.generation!;
    expect(generation.regionName, isNull);
  });

  test('Usa sprite si falta artwork y admite ausencia real de imagen', () {
    for (final sprites in [
      [
        {'artwork': null, 'front': 'https://example.com/front.png'},
      ],
      [
        {'artwork': null, 'front': null},
      ],
      [],
    ]) {
      final row = catalogRow(1)..['pokemonsprites'] = sprites;
      final result = PokemonPageDto.fromJson(
        catalogResponse([row], total: 1),
        limit: 2,
        offset: 0,
      ).toDomain(DateTime.utc(2026)).single;
      expect(
        result.imageUrl,
        sprites.isNotEmpty && sprites.first['front'] != null
            ? 'https://example.com/front.png'
            : null,
      );
    }
  });

  final invalidRows = <String, void Function(Map<String, dynamic>)>{
    'ID ausente': (row) => row.remove('id'),
    'ID no entero': (row) => row['id'] = '1',
    'numero invalido': (row) => row['pokemon_species_id'] = 0,
    'nombre vacio': (row) => row['name'] = ' ',
    'tipos ausentes': (row) => row.remove('pokemontypes'),
    'tipo vacio': (row) => row['pokemontypes'] = [],
    'tipo parcial': (row) => (row['pokemontypes'] as List).first.remove('type'),
    'slot repetido': (row) => (row['pokemontypes'] as List).last['slot'] = 1,
    'tipo repetido': (row) => (row['pokemontypes'] as List).last['type'] = {
      'id': 12,
      'name': 'grass',
    },
    'sprites ausentes': (row) => row.remove('pokemonsprites'),
    'sprite parcial': (row) =>
        (row['pokemonsprites'] as List).first.remove('artwork'),
    'imagen invalida': (row) =>
        (row['pokemonsprites'] as List).first['front'] = 'invalid',
    'especie ausente': (row) => row.remove('pokemonspecy'),
    'especie distinta al numero': (row) =>
        (row['pokemonspecy'] as Map)['id'] = 99,
    'especie sin nombre': (row) => (row['pokemonspecy'] as Map)['name'] = '',
    'generacion parcial': (row) =>
        ((row['pokemonspecy'] as Map)['generation'] as Map).remove('name'),
    'is_default no booleano': (row) => row['is_default'] = 1,
    'altura negativa': (row) => row['height'] = -1,
    'peso no entero': (row) => row['weight'] = 6.9,
    'stats sin agregado': (row) => row.remove('pokemonstats_aggregate'),
    'total negativo': (row) =>
        ((row['pokemonstats_aggregate'] as Map)['aggregate'] as Map)['sum'] = {
          'base_stat': -5,
        },
  };
  for (final entry in invalidRows.entries) {
    test('Rechaza ${entry.key}', () {
      final row = catalogRow(1);
      entry.value(row);
      expect(
        () => PokemonPageDto.fromJson(
          catalogResponse([row], total: 1),
          limit: 2,
          offset: 0,
        ),
        throwsA(
          isA<SyncFailure>().having(
            (error) => error.kind,
            'kind',
            SyncFailureKind.invalidResponse,
          ),
        ),
      );
    });
  }

  test(
    'Rechaza paginas truncadas, duplicadas, desordenadas y total invalido',
    () {
      final responses = [
        catalogResponse([catalogRow(1)], total: 3),
        catalogResponse([catalogRow(1), catalogRow(1)], total: 2),
        catalogResponse([catalogRow(2), catalogRow(1)], total: 2),
        catalogResponse([catalogRow(1)], total: -1),
        <String, dynamic>{
          'pokemon': [catalogRow(1)],
        },
        catalogResponse([
          catalogRow(1),
          catalogRow(2),
          catalogRow(3),
        ], total: 3),
      ];
      for (final response in responses) {
        expect(
          () => PokemonPageDto.fromJson(response, limit: 2, offset: 0),
          throwsA(isA<SyncFailure>()),
        );
      }
    },
  );
}
