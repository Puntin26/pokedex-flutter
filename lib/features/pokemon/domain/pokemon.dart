class PokemonType {
  const PokemonType({required this.id, required this.name});

  final int id;
  final String name;
}

class PokemonTypeSlot {
  const PokemonTypeSlot({required this.type, required this.slot});

  final PokemonType type;
  final int slot;
}

class Pokemon {
  Pokemon({
    required this.id,
    required this.nationalNumber,
    required this.name,
    this.imageUrl,
    required this.updatedAt,
    required List<PokemonTypeSlot> types,
  }) : types = List.unmodifiable(types);

  final int id;
  final int nationalNumber;
  final String name;
  final String? imageUrl;
  final DateTime updatedAt;
  final List<PokemonTypeSlot> types;
}
