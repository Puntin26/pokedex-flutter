import 'pokemon.dart';

class PokemonStat {
  const PokemonStat({
    required this.id,
    required this.name,
    required this.baseValue,
  });

  final int id;
  final String name;
  final int baseValue;
}

class EggGroup {
  const EggGroup({required this.id, required this.name});

  final int id;
  final String name;
}

/// Juego (red-blue, scarlet-violet...); [sortOrder] es el orden cronologico.
class VersionGroup {
  const VersionGroup({
    required this.id,
    required this.name,
    required this.sortOrder,
  });

  final int id;
  final String name;
  final int sortOrder;
}

/// Un paso de la cadena: varias filas con el mismo origen son ramas.
class EvolutionStep {
  const EvolutionStep({
    required this.fromSpeciesId,
    required this.toSpeciesId,
    required this.trigger,
    this.minLevel,
    this.itemName,
    this.minHappiness,
    this.timeOfDay,
  });

  final int fromSpeciesId;
  final int toSpeciesId;
  // level-up, use-item, trade...
  final String trigger;
  final int? minLevel;
  final String? itemName;
  final int? minHappiness;
  final String? timeOfDay;
}

class PokemonMove {
  const PokemonMove({
    required this.moveId,
    required this.name,
    required this.versionGroupId,
    required this.learnMethod,
    required this.level,
    this.power,
    this.accuracy,
    this.type,
  });

  final int moveId;
  final String name;
  final int versionGroupId;
  // level-up, machine, tutor, egg...
  final String learnMethod;
  final int level;
  final int? power;
  final int? accuracy;
  final PokemonType? type;
}

/// Multiplicador de dano en porcentaje: 0, 50, 100 o 200.
class TypeEfficacy {
  const TypeEfficacy({
    required this.attackerTypeId,
    required this.defenderTypeId,
    required this.damageFactor,
  });

  final int attackerTypeId;
  final int defenderTypeId;
  final int damageFactor;
}

/// Lo que trae la consulta de detalle para guardarlo en una transaccion.
class PokemonDetailDownload {
  PokemonDetailDownload({
    required this.pokemon,
    required List<PokemonStat> stats,
    required List<EggGroup> eggGroups,
    required this.evolutionChainId,
    required List<PokemonSpecies> chainSpecies,
    required List<EvolutionStep> evolutions,
    required List<VersionGroup> versionGroups,
    required List<PokemonMove> moves,
  }) : stats = List.unmodifiable(stats),
       eggGroups = List.unmodifiable(eggGroups),
       chainSpecies = List.unmodifiable(chainSpecies),
       evolutions = List.unmodifiable(evolutions),
       versionGroups = List.unmodifiable(versionGroups),
       moves = List.unmodifiable(moves);

  final Pokemon pokemon;
  final List<PokemonStat> stats;
  final List<EggGroup> eggGroups;
  final int? evolutionChainId;
  final List<PokemonSpecies> chainSpecies;
  final List<EvolutionStep> evolutions;
  final List<VersionGroup> versionGroups;
  final List<PokemonMove> moves;

  String? get shinyImageUrl => pokemon.shinyImageUrl;
}

class TypeEfficacyDownload {
  TypeEfficacyDownload({
    required List<PokemonType> types,
    required List<TypeEfficacy> rows,
  }) : types = List.unmodifiable(types),
       rows = List.unmodifiable(rows);

  final List<PokemonType> types;
  final List<TypeEfficacy> rows;
}

/// Especie de la cadena con su Pokemon por defecto si esta guardado.
class EvolutionMember {
  const EvolutionMember({
    required this.speciesId,
    required this.name,
    this.pokemonId,
    this.imageUrl,
  });

  final int speciesId;
  final String name;
  final int? pokemonId;
  final String? imageUrl;
}

/// Vista del detalle leida de SQLite. Los movimientos se consultan aparte
/// (MoveQuery) porque pueden ser cientos.
class PokemonDetail {
  PokemonDetail({
    required this.pokemon,
    required List<PokemonAbility> abilities,
    required List<PokemonStat> stats,
    required List<EggGroup> eggGroups,
    required List<EvolutionMember> evolutionMembers,
    required List<EvolutionStep> evolutions,
    required List<Pokemon> forms,
    required List<VersionGroup> versionGroups,
    this.updatedAt,
  }) : abilities = List.unmodifiable(abilities),
       stats = List.unmodifiable(stats),
       eggGroups = List.unmodifiable(eggGroups),
       evolutionMembers = List.unmodifiable(evolutionMembers),
       evolutions = List.unmodifiable(evolutions),
       forms = List.unmodifiable(forms),
       versionGroups = List.unmodifiable(versionGroups);

  final Pokemon pokemon;
  final List<PokemonAbility> abilities;
  final List<PokemonStat> stats;
  final List<EggGroup> eggGroups;
  final List<EvolutionMember> evolutionMembers;
  final List<EvolutionStep> evolutions;
  // Formas de la misma especie (Alola, Galar...), incluida esta.
  final List<Pokemon> forms;
  final List<VersionGroup> versionGroups;
  // Ultima descarga del detalle; null si solo hay datos del catalogo.
  final DateTime? updatedAt;

  bool get hasFullDetail => updatedAt != null;
}
