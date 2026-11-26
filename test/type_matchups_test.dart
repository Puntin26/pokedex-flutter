import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/features/pokemon/domain/pokemon.dart';
import 'package:pokedex/features/pokemon/domain/pokemon_detail.dart';
import 'package:pokedex/features/pokemon/domain/type_matchups.dart';

const normal = PokemonType(id: 1, name: 'normal');
const fighting = PokemonType(id: 2, name: 'fighting');
const flying = PokemonType(id: 3, name: 'flying');
const ground = PokemonType(id: 5, name: 'ground');
const rock = PokemonType(id: 6, name: 'rock');
const ghost = PokemonType(id: 8, name: 'ghost');
const grass = PokemonType(id: 12, name: 'grass');
const electric = PokemonType(id: 13, name: 'electric');
const ice = PokemonType(id: 15, name: 'ice');

TypeEfficacy row(PokemonType attacker, PokemonType defender, int factor) =>
    TypeEfficacy(
      attackerTypeId: attacker.id,
      defenderTypeId: defender.id,
      damageFactor: factor,
    );

// Subconjunto real de la tabla de PokeAPI.
final table = [
  row(fighting, normal, 200),
  row(ghost, normal, 0),
  row(ice, grass, 200),
  row(ice, flying, 200),
  row(electric, flying, 200),
  row(electric, grass, 50),
  row(ground, flying, 0),
  row(ground, grass, 50),
  row(grass, grass, 50),
  row(grass, flying, 50),
  row(rock, flying, 200),
  row(fighting, flying, 50),
];
final types = [
  normal,
  fighting,
  flying,
  ground,
  rock,
  ghost,
  grass,
  electric,
  ice,
];

void main() {
  test('Un tipo: debilidad x2 e inmunidad x0 (eevee, normal)', () {
    final matchups = TypeMatchups.forDefender([normal], table, types);
    expect(matchups.typesWith(2).map((type) => type.name), ['fighting']);
    expect(matchups.typesWith(0).map((type) => type.name), ['ghost']);
    expect(matchups.typesWith(4), isEmpty);
  });

  test('Dos tipos multiplican: x4, x0.25 y el x0 manda (grass/flying)', () {
    final matchups = TypeMatchups.forDefender([grass, flying], table, types);
    expect(matchups.typesWith(4).map((type) => type.name), ['ice']);
    expect(matchups.typesWith(2).map((type) => type.name), ['rock']);
    // electric: x2 por flying y x0.5 por grass = x1 (no aparece).
    expect(matchups.multiplierFor(electric), 1);
    expect(matchups.typesWith(0.25).map((type) => type.name), ['grass']);
    // fighting: x0.5 solo por flying.
    expect(matchups.typesWith(0.5).map((type) => type.name), ['fighting']);
    // ground: x0 por flying anula el x0.5 de grass.
    expect(matchups.typesWith(0).map((type) => type.name), ['ground']);
  });

  test('Sin tabla descargada no hay matchups', () {
    expect(TypeMatchups.forDefender([normal], const [], types).isEmpty, isTrue);
  });

  test('Los grupos salen en orden x4, x2, x0.5, x0.25, x0', () {
    expect(TypeMatchups.displayOrder, [4, 2, 0.5, 0.25, 0]);
  });

  group('summarizeEffect (RF-DET-03)', () {
    test('Un texto corto queda igual', () {
      expect(
        summarizeEffect('Ensures success fleeing.'),
        'Ensures success fleeing.',
      );
    });

    test('Un texto largo se corta en una palabra, maximo 160 con "…"', () {
      final long = List.filled(40, 'palabra').join(' ');
      final summary = summarizeEffect(long);
      expect(summary.length, lessThanOrEqualTo(160));
      expect(summary.length, greaterThanOrEqualTo(140));
      expect(summary, endsWith('…'));
      expect(summary, isNot(contains('palabr…')));
    });

    test('Normaliza espacios y saltos de linea de PokeAPI', () {
      expect(
        summarizeEffect('Raises\nSpeed  by one\fstage.'),
        'Raises Speed by one stage.',
      );
    });
  });
}
