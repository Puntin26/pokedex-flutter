// Respuestas con la forma real de PokeAPI v1beta2 para el detalle, verificada
// contra la API (eevee 133, rattata-alola 10091, bulbasaur 1). Version reducida.

Map<String, dynamic> statRow(int id, String name, int value) => {
  'base_stat': value,
  'stat': <String, dynamic>{'id': id, 'name': name},
};

Map<String, dynamic> moveRow(
  int id,
  String name, {
  required String method,
  required int versionGroupId,
  required String versionGroup,
  required int order,
  int level = 0,
  int? power,
  int? accuracy,
  int typeId = 1,
  String typeName = 'normal',
}) => {
  'level': level,
  'movelearnmethod': <String, dynamic>{'name': method},
  'versiongroup': <String, dynamic>{
    'id': versionGroupId,
    'name': versionGroup,
    'order': order,
  },
  'move': <String, dynamic>{
    'id': id,
    'name': name,
    'power': power,
    'accuracy': accuracy,
    'type': <String, dynamic>{'id': typeId, 'name': typeName},
  },
};

Map<String, dynamic> evolutionRow({
  required String trigger,
  bool isDefault = true,
  int? minLevel,
  int? minHappiness,
  String timeOfDay = '',
  String? item,
}) => {
  'is_default': isDefault,
  'min_level': minLevel,
  'min_happiness': minHappiness,
  'time_of_day': timeOfDay,
  'evolutiontrigger': <String, dynamic>{'name': trigger},
  'item': item == null ? null : <String, dynamic>{'name': item},
};

Map<String, dynamic> chainSpecies(
  int id,
  String name, {
  int? from,
  List<Map<String, dynamic>> evolutions = const [],
}) => {
  'id': id,
  'name': name,
  'evolves_from_species_id': from,
  'pokemonevolutions': evolutions,
};

List<Map<String, dynamic>> eeveeStats() => [
  statRow(1, 'hp', 55),
  statRow(2, 'attack', 55),
  statRow(3, 'defense', 50),
  statRow(4, 'special-attack', 45),
  statRow(5, 'special-defense', 65),
  statRow(6, 'speed', 55),
];

List<Map<String, dynamic>> eeveeMoves() => [
  moveRow(
    33,
    'tackle',
    method: 'level-up',
    versionGroupId: 25,
    versionGroup: 'scarlet-violet',
    order: 27,
    level: 1,
    power: 40,
    accuracy: 100,
  ),
  // Mismo movimiento en dos niveles del mismo juego (dato real de PokeAPI).
  moveRow(
    129,
    'swift',
    method: 'level-up',
    versionGroupId: 25,
    versionGroup: 'scarlet-violet',
    order: 27,
    level: 10,
    power: 60,
  ),
  moveRow(
    129,
    'swift',
    method: 'level-up',
    versionGroupId: 25,
    versionGroup: 'scarlet-violet',
    order: 27,
    level: 20,
    power: 60,
  ),
  moveRow(
    273,
    'wish',
    method: 'egg',
    versionGroupId: 25,
    versionGroup: 'scarlet-violet',
    order: 27,
  ),
  moveRow(
    343,
    'covet',
    method: 'tutor',
    versionGroupId: 25,
    versionGroup: 'scarlet-violet',
    order: 27,
    power: 60,
    accuracy: 100,
  ),
  moveRow(
    34,
    'body-slam',
    method: 'machine',
    versionGroupId: 1,
    versionGroup: 'red-blue',
    order: 3,
    power: 85,
    accuracy: 100,
  ),
  moveRow(
    33,
    'tackle',
    method: 'level-up',
    versionGroupId: 1,
    versionGroup: 'red-blue',
    order: 3,
    level: 1,
    power: 35,
    accuracy: 95,
  ),
];

Map<String, dynamic> detailRow({
  int id = 133,
  String name = 'eevee',
  int speciesId = 133,
  bool isDefault = true,
  List<Map<String, dynamic>>? stats,
  List<Map<String, dynamic>>? moves,
  Map<String, dynamic>? evolutionChain,
  String? shinyArtwork = 'https://example.com/artwork/shiny/133.png',
  String? shinyFront = 'https://example.com/shiny/133.png',
}) => {
  'id': id,
  'name': name,
  'height': 3,
  'weight': 65,
  'is_default': isDefault,
  'pokemon_species_id': speciesId,
  'pokemonspecy': <String, dynamic>{
    'id': speciesId,
    'name': 'eevee',
    'evolution_chain_id': 67,
    'generation': <String, dynamic>{
      'id': 1,
      'name': 'generation-i',
      'region': <String, dynamic>{'name': 'kanto'},
    },
    'pokemonegggroups': [
      <String, dynamic>{
        'egggroup': <String, dynamic>{'id': 5, 'name': 'ground'},
      },
    ],
    'evolutionchain':
        evolutionChain ??
        <String, dynamic>{
          'pokemonspecies': [
            chainSpecies(133, 'eevee'),
            chainSpecies(
              134,
              'vaporeon',
              from: 133,
              evolutions: [
                evolutionRow(trigger: 'use-item', item: 'water-stone'),
              ],
            ),
            chainSpecies(
              196,
              'espeon',
              from: 133,
              evolutions: [
                evolutionRow(
                  trigger: 'level-up',
                  minHappiness: 160,
                  timeOfDay: 'day',
                ),
              ],
            ),
            // Varias filas y ninguna principal: se usa la primera.
            chainSpecies(
              470,
              'leafeon',
              from: 133,
              evolutions: [
                evolutionRow(trigger: 'level-up', isDefault: false),
                evolutionRow(
                  trigger: 'use-item',
                  isDefault: false,
                  item: 'leaf-stone',
                ),
              ],
            ),
          ],
        },
  },
  'pokemonstats_aggregate': <String, dynamic>{
    'aggregate': <String, dynamic>{
      'sum': <String, dynamic>{'base_stat': 325},
    },
  },
  'pokemonstats': stats ?? eeveeStats(),
  'pokemonabilities': [
    _ability(1, 50, 'run-away', 'Ensures success fleeing from wild battles.'),
    _ability(2, 91, 'adaptability', 'Increases the same-type attack bonus.'),
    _ability(3, 107, 'anticipation', null, hidden: true),
  ],
  'pokemontypes': [
    <String, dynamic>{
      'slot': 1,
      'type': <String, dynamic>{'id': 1, 'name': 'normal'},
    },
  ],
  'pokemonsprites': [
    <String, dynamic>{
      'artwork': 'https://example.com/artwork/$id.png',
      'front': 'https://example.com/$id.png',
      'shinyArtwork': shinyArtwork,
      'shinyFront': shinyFront,
    },
  ],
  'pokemonmoves': moves ?? eeveeMoves(),
};

Map<String, dynamic> _ability(
  int slot,
  int id,
  String name,
  String? effect, {
  bool hidden = false,
}) => {
  'slot': slot,
  'is_hidden': hidden,
  'ability': <String, dynamic>{
    'id': id,
    'name': name,
    'abilityeffecttexts': [
      if (effect != null) <String, dynamic>{'short_effect': effect},
    ],
  },
};

Map<String, dynamic> detailResponse(Map<String, dynamic> row) => {
  'pokemon': [row],
};

// Subconjunto real: normal recibe x2 de fighting y x0 de ghost.
Map<String, dynamic> typeEfficacyResponse() => {
  'typeefficacy': [
    _efficacy(1, 1, 100),
    _efficacy(1, 8, 0),
    _efficacy(2, 1, 200),
    _efficacy(2, 8, 0),
    _efficacy(8, 1, 0),
    _efficacy(8, 8, 200),
  ],
  'type': [
    <String, dynamic>{'id': 1, 'name': 'normal'},
    <String, dynamic>{'id': 2, 'name': 'fighting'},
    <String, dynamic>{'id': 8, 'name': 'ghost'},
    // Tipos sin tabla de efectividad: no deben guardarse.
    <String, dynamic>{'id': 19, 'name': 'stellar'},
    <String, dynamic>{'id': 10002, 'name': 'shadow'},
  ],
};

Map<String, dynamic> _efficacy(int attacker, int defender, int factor) => {
  'damage_type_id': attacker,
  'target_type_id': defender,
  'damage_factor': factor,
};
