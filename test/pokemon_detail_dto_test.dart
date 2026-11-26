import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/core/domain/sync_failure.dart';
import 'package:pokedex/features/pokemon/data/pokemon_detail_dto.dart';
import 'package:pokedex/features/pokemon/domain/pokemon_detail.dart';

import 'support/detail_response.dart';

void main() {
  final savedAt = DateTime.utc(2026, 11, 26);

  PokemonDetailDownload parse(Map<String, dynamic> row) =>
      PokemonDetailDto.fromJson(
        detailResponse(row),
        pokemonId: row['id'] as int,
      ).toDomain(savedAt);

  test('Mapea identidad, stats, habilidades con efecto y shiny (4.1)', () {
    final detail = parse(detailRow());
    expect(detail.pokemon.id, 133);
    expect(detail.pokemon.name, 'eevee');
    expect(detail.pokemon.types.single.type.name, 'normal');
    expect(detail.pokemon.baseStatTotal, 325);
    expect(detail.stats.map((stat) => stat.name), [
      'hp',
      'attack',
      'defense',
      'special-attack',
      'special-defense',
      'speed',
    ]);
    expect(detail.stats.first.baseValue, 55);
    final abilities = detail.pokemon.abilities;
    expect(abilities.map((entry) => entry.ability.effectSummary), [
      'Ensures success fleeing from wild battles.',
      'Increases the same-type attack bonus.',
      null,
    ]);
    expect(abilities.last.isHidden, isTrue);
    expect(detail.shinyImageUrl, 'https://example.com/artwork/shiny/133.png');
    expect(detail.eggGroups.single.name, 'ground');
    expect(detail.evolutionChainId, 67);
  });

  test('Shiny usa el sprite si falta el artwork, o nada si no hay', () {
    expect(
      parse(detailRow(shinyArtwork: null)).shinyImageUrl,
      'https://example.com/shiny/133.png',
    );
    expect(
      parse(detailRow(shinyArtwork: null, shinyFront: null)).shinyImageUrl,
      isNull,
    );
  });

  test('Evoluciones: ramas, trigger principal y hora vacia como nulo', () {
    final detail = parse(detailRow());
    expect(detail.chainSpecies.map((species) => species.id), [
      133,
      134,
      196,
      470,
    ]);
    final steps = {
      for (final step in detail.evolutions) step.toSpeciesId: step,
    };
    expect(steps.keys, [134, 196, 470]);
    expect(steps[134]!.fromSpeciesId, 133);
    expect(steps[134]!.trigger, 'use-item');
    expect(steps[134]!.itemName, 'water-stone');
    expect(steps[134]!.timeOfDay, isNull);
    expect(steps[196]!.minHappiness, 160);
    expect(steps[196]!.timeOfDay, 'day');
    // Ninguna fila principal: se usa la primera.
    expect(steps[470]!.trigger, 'level-up');
    expect(steps[470]!.itemName, isNull);
  });

  test('Sin cadena evolutiva no hay pasos ("No evoluciona")', () {
    final detail = parse(
      detailRow(
        evolutionChain: {
          'pokemonspecies': [chainSpecies(133, 'eevee')],
        },
      ),
    );
    expect(detail.evolutions, isEmpty);
  });

  test('Movimientos por juego y metodo; mismo movimiento en dos niveles', () {
    final detail = parse(detailRow());
    expect(
      detail.versionGroups.map(
        (group) => (group.id, group.name, group.sortOrder),
      ),
      [(1, 'red-blue', 3), (25, 'scarlet-violet', 27)],
    );
    expect(detail.moves, hasLength(7));
    final swift = detail.moves.where((move) => move.name == 'swift');
    expect(swift.map((move) => move.level), [10, 20]);
    final bodySlam = detail.moves.firstWhere(
      (move) => move.name == 'body-slam',
    );
    expect(bodySlam.learnMethod, 'machine');
    expect(bodySlam.versionGroupId, 1);
    expect(bodySlam.power, 85);
    expect(bodySlam.type!.name, 'normal');
  });

  final invalid = <String, void Function(Map<String, dynamic>)>{
    'stats ausentes': (row) => row.remove('pokemonstats'),
    'stat negativa': (row) =>
        (row['pokemonstats'] as List).first['base_stat'] = -1,
    'stat repetida': (row) =>
        (row['pokemonstats'] as List).last['stat'] = {'id': 1, 'name': 'hp'},
    'movimiento sin juego': (row) =>
        (row['pokemonmoves'] as List).first.remove('versiongroup'),
    'movimiento duplicado exacto': (row) =>
        (row['pokemonmoves'] as List).add((row['pokemonmoves'] as List).first),
    'nivel negativo': (row) =>
        (row['pokemonmoves'] as List).first['level'] = -1,
    'precision fuera de rango': (row) =>
        ((row['pokemonmoves'] as List).first['move'] as Map)['accuracy'] = 101,
    'evolucion sin trigger': (row) {
      final chain =
          ((row['pokemonspecy'] as Map)['evolutionchain']
                  as Map)['pokemonspecies']
              as List;
      (chain[1]['pokemonevolutions'] as List).first['evolutiontrigger'] = null;
    },
    'evoluciona de una especie fuera de la cadena': (row) {
      final chain =
          ((row['pokemonspecy'] as Map)['evolutionchain']
                  as Map)['pokemonspecies']
              as List;
      chain[1]['evolves_from_species_id'] = 999;
    },
    'egg group sin nombre': (row) =>
        (((row['pokemonspecy'] as Map)['pokemonegggroups'] as List)
                    .first['egggroup']
                as Map)
            .remove('name'),
  };
  for (final entry in invalid.entries) {
    test('Rechaza ${entry.key}', () {
      final row = detailRow();
      entry.value(row);
      expect(
        () => PokemonDetailDto.fromJson(detailResponse(row), pokemonId: 133),
        throwsA(
          isA<SyncFailure>().having(
            (failure) => failure.kind,
            'kind',
            SyncFailureKind.invalidResponse,
          ),
        ),
      );
    });
  }

  test('Un ID que PokeAPI no tiene se informa como respuesta invalida', () {
    expect(
      () => PokemonDetailDto.fromJson({'pokemon': []}, pokemonId: 99999),
      throwsA(isA<SyncFailure>()),
    );
    expect(
      () =>
          PokemonDetailDto.fromJson(detailResponse(detailRow()), pokemonId: 25),
      throwsA(isA<SyncFailure>()),
    );
  });

  group('TypeEfficacyDto', () {
    test('Guarda solo los tipos usados y los multiplicadores validos', () {
      final efficacy = TypeEfficacyDto.fromJson(typeEfficacyResponse());
      expect(efficacy.types.map((type) => type.name), [
        'normal',
        'fighting',
        'ghost',
      ]);
      expect(efficacy.rows, hasLength(6));
      expect(
        efficacy.rows
            .firstWhere(
              (row) => row.attackerTypeId == 2 && row.defenderTypeId == 1,
            )
            .damageFactor,
        200,
      );
    });

    test(
      'Rechaza multiplicadores fuera de 0/50/100/200 o tipos desconocidos',
      () {
        final badFactor = typeEfficacyResponse();
        (badFactor['typeefficacy'] as List).first['damage_factor'] = 150;
        final unknownType = typeEfficacyResponse();
        (unknownType['typeefficacy'] as List).first['target_type_id'] = 77;
        for (final response in [badFactor, unknownType, <String, dynamic>{}]) {
          expect(
            () => TypeEfficacyDto.fromJson(response),
            throwsA(isA<SyncFailure>()),
          );
        }
      },
    );
  });
}
