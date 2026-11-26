import '../domain/pokemon.dart';
import '../domain/pokemon_detail.dart';

// Textos visibles del detalle. Pasaran a los .arb con i18n (Fase 6).

/// "rattata-alola" -> "Rattata alola".
String displayName(String name) {
  final words = name.replaceAll('-', ' ');
  return words.isEmpty ? words : words[0].toUpperCase() + words.substring(1);
}

const _statLabels = {
  'hp': 'PS',
  'attack': 'Ataque',
  'defense': 'Defensa',
  'special-attack': 'At. esp.',
  'special-defense': 'Def. esp.',
  'speed': 'Velocidad',
};

String statLabel(PokemonStat stat) =>
    _statLabels[stat.name] ?? displayName(stat.name);

/// La base mas alta posible en los juegos; el porcentaje se calcula sobre ella.
const maxBaseStat = 255;

int statPercent(PokemonStat stat) =>
    (stat.baseValue * 100 / maxBaseStat).round();

/// Filtros de movimientos de RF-DET-05, en el orden de los chips.
const learnMethodLabels = {
  'level-up': 'Nivel',
  'machine': 'MT',
  'tutor': 'Tutor',
  'egg': 'Huevo',
};

/// Trigger principal legible (RF-DET-04): nivel, objeto, intercambio, amistad, hora.
String evolutionTrigger(EvolutionStep step) {
  final parts = <String>[];
  switch (step.trigger) {
    case 'level-up':
      if (step.minLevel != null) {
        parts.add('Nivel ${step.minLevel}');
      } else if (step.minHappiness != null) {
        parts.add('Amistad ${step.minHappiness}');
      } else {
        parts.add('Subir de nivel');
      }
    case 'use-item':
      parts.add('Usar ${displayName(step.itemName ?? 'objeto')}');
    case 'trade':
      parts.add(
        step.itemName == null
            ? 'Intercambio'
            : 'Intercambio con ${displayName(step.itemName!)}',
      );
    default:
      parts.add(displayName(step.trigger));
  }
  switch (step.timeOfDay) {
    case 'day':
      parts.add('de dia');
    case 'night':
      parts.add('de noche');
    case final String other:
      parts.add(other);
    case null:
      break;
  }
  return parts.join(' ');
}

/// Altura en decimetros y peso en hectogramos (unidades de PokeAPI).
String formatHeight(int? decimeters) =>
    decimeters == null ? '-' : '${(decimeters / 10).toStringAsFixed(1)} m';

String formatWeight(int? hectograms) =>
    hectograms == null ? '-' : '${(hectograms / 10).toStringAsFixed(1)} kg';

String multiplierLabel(double multiplier) => switch (multiplier) {
  4 => 'x4',
  2 => 'x2',
  0.5 => 'x0.5',
  0.25 => 'x0.25',
  _ => 'x0',
};

String typesLabel(Pokemon pokemon) =>
    pokemon.types.map((slot) => displayName(slot.type.name)).join(' / ');

/// Texto para compartir (RF-DET-10).
String shareText(Pokemon pokemon) => [
  '#${pokemon.nationalNumber} ${displayName(pokemon.name)}',
  'Tipo: ${typesLabel(pokemon)}',
  if (pokemon.baseStatTotal != null) 'Total base: ${pokemon.baseStatTotal}',
  'Datos de PokeAPI (pokeapi.co)',
].join('\n');
