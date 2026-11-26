// Fila con la forma real de PokeAPI v1beta2 (verificada contra la API).
Map<String, dynamic> catalogRow(
  int id, {
  int? nationalNumber,
  String? name,
  bool isDefault = true,
  int baseStatTotal = 318,
}) {
  final speciesId = nationalNumber ?? id;
  return {
    'id': id,
    'name': name ?? 'pokemon-$id',
    'height': 7,
    'weight': 69,
    'is_default': isDefault,
    'pokemon_species_id': speciesId,
    // Tipado como jsonDecode para que los tests puedan poner nulos.
    'pokemonspecy': <String, dynamic>{
      'id': speciesId,
      'name': 'species-$speciesId',
      'generation': <String, dynamic>{
        'id': 1,
        'name': 'generation-i',
        'region': {'name': 'kanto'},
      },
    },
    'pokemonstats_aggregate': <String, dynamic>{
      'aggregate': <String, dynamic>{
        'sum': <String, dynamic>{'base_stat': baseStatTotal},
      },
    },
    'pokemontypes': [
      {
        'slot': 1,
        'type': {'id': 12, 'name': 'grass'},
      },
      {
        'slot': 2,
        'type': {'id': 4, 'name': 'poison'},
      },
    ],
    'pokemonsprites': [
      {
        'artwork': 'https://example.com/artwork/$id.png',
        'front': 'https://example.com/$id.png',
      },
    ],
  };
}

Map<String, dynamic> catalogResponse(
  List<Map<String, dynamic>> rows, {
  required int total,
}) => {
  'pokemon': rows,
  'pokemon_aggregate': {
    'aggregate': {'count': total},
  },
};
