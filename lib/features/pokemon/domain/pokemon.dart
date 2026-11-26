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

class Ability {
  const Ability({required this.id, required this.name, this.effectSummary});

  final int id;
  final String name;
  // Efecto corto en ingles; lo trae el detalle (RF-DET-03).
  final String? effectSummary;
}

class PokemonAbility {
  const PokemonAbility({
    required this.ability,
    required this.slot,
    required this.isHidden,
  });

  final Ability ability;
  final int slot;
  final bool isHidden;
}

class Generation {
  const Generation({required this.id, required this.name, this.regionName});

  final int id;
  final String name;
  final String? regionName;
}

class PokemonSpecies {
  const PokemonSpecies({required this.id, required this.name, this.generation});

  final int id;
  final String name;
  final Generation? generation;
}

class Pokemon {
  Pokemon({
    required this.id,
    required this.nationalNumber,
    required this.name,
    this.imageUrl,
    required this.updatedAt,
    required List<PokemonTypeSlot> types,
    this.species,
    this.height,
    this.weight,
    this.baseStatTotal,
    this.isDefault = true,
    this.shinyImageUrl,
    List<PokemonAbility> abilities = const [],
  }) : types = List.unmodifiable(types),
       abilities = List.unmodifiable(abilities);

  final int id;
  final int nationalNumber;
  final String name;
  final String? imageUrl;
  final DateTime updatedAt;
  final List<PokemonTypeSlot> types;
  // Nulos en filas migradas de v1 hasta la siguiente sincronizacion.
  final PokemonSpecies? species;
  // Unidades de PokeAPI: decimetros y hectogramos.
  final int? height;
  final int? weight;
  final int? baseStatTotal;
  // false en formas alternativas (Alola, Galar...).
  final bool isDefault;
  // Artwork shiny (o sprite shiny); lo completa el detalle (RF-DET-09).
  final String? shinyImageUrl;
  // Se llena al descargar y se guarda para el filtro (RF-FIL-02); la lista del
  // catalogo no lo lee para no multiplicar filas del join (lo leera el detalle).
  final List<PokemonAbility> abilities;
}
