import 'pokemon.dart';
import 'pokemon_detail.dart';

/// Multiplicadores de dano que recibe un Pokemon segun sus tipos (RF-DET-06).
/// Con dos tipos se multiplican: x2 * x2 = x4, x2 * x0.5 = x1, cualquier x0 = x0.
class TypeMatchups {
  TypeMatchups._(this._multipliers, this._types);

  /// Grupos que muestra la pantalla; x1 (dano normal) no se lista.
  static const displayOrder = <double>[4, 2, 0.5, 0.25, 0];

  final Map<int, double> _multipliers;
  final List<PokemonType> _types;

  factory TypeMatchups.forDefender(
    List<PokemonType> defenderTypes,
    List<TypeEfficacy> table,
    List<PokemonType> allTypes,
  ) {
    final factors = {
      for (final row in table)
        (row.attackerTypeId, row.defenderTypeId): row.damageFactor / 100,
    };
    final multipliers = <int, double>{};
    if (table.isNotEmpty) {
      for (final attacker in allTypes) {
        var multiplier = 1.0;
        for (final defender in defenderTypes) {
          // Sin fila en la tabla, PokeAPI considera dano normal (x1).
          multiplier *= factors[(attacker.id, defender.id)] ?? 1;
        }
        multipliers[attacker.id] = multiplier;
      }
    }
    final sorted = [...allTypes]..sort((a, b) => a.name.compareTo(b.name));
    return TypeMatchups._(multipliers, sorted);
  }

  bool get isEmpty => _multipliers.isEmpty;

  double multiplierFor(PokemonType attacker) => _multipliers[attacker.id] ?? 1;

  List<PokemonType> typesWith(double multiplier) => [
    for (final type in _types)
      if (_multipliers[type.id] == multiplier) type,
  ];
}

/// Efecto de habilidad para la tarjeta: espacios normalizados y, si es largo,
/// cortado en una palabra entre 140 y 160 caracteres con "…" (RF-DET-03).
String summarizeEffect(String text, {int max = 160, int min = 140}) {
  final clean = text.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (clean.length <= max) return clean;
  final limit = max - 1; // deja lugar para "…"
  final cut = clean.lastIndexOf(' ', limit);
  final end = cut >= min ? cut : limit;
  return '${clean.substring(0, end).trimRight()}…';
}
