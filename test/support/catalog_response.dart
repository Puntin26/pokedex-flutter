Map<String, dynamic> catalogRow(int id, {int? nationalNumber, String? name}) =>
    {
      'id': id,
      'name': name ?? 'pokemon-$id',
      'pokemon_species_id': nationalNumber ?? id,
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

Map<String, dynamic> catalogResponse(
  List<Map<String, dynamic>> rows, {
  required int total,
}) => {
  'pokemon': rows,
  'pokemon_aggregate': {
    'aggregate': {'count': total},
  },
};
