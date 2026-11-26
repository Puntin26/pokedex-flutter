import '../domain/pokemon.dart';
import '../domain/pokemon_detail.dart';
import 'json_fields.dart';
import 'pokemon_page_dto.dart';

/// Respuesta de la consulta de detalle (4.1). La identidad se valida con el
/// mismo DTO del catalogo; aqui se agregan stats, efectos, shiny, egg groups,
/// cadena evolutiva y movimientos.
class PokemonDetailDto {
  PokemonDetailDto._({
    required this.core,
    required this.effects,
    required this.shinyImageUrl,
    required this.stats,
    required this.eggGroups,
    required this.evolutionChainId,
    required this.chainSpecies,
    required this.evolutions,
    required this.versionGroups,
    required this.moves,
  });

  final PokemonDto core;
  final Map<int, String?> effects;
  final String? shinyImageUrl;
  final List<PokemonStat> stats;
  final List<EggGroup> eggGroups;
  final int? evolutionChainId;
  final List<PokemonSpecies> chainSpecies;
  final List<EvolutionStep> evolutions;
  final List<VersionGroup> versionGroups;
  final List<PokemonMove> moves;

  factory PokemonDetailDto.fromJson(
    Map<String, dynamic> data, {
    required int pokemonId,
  }) {
    final rows = jsonList(data['pokemon']);
    if (rows.length != 1) {
      invalidResponse('PokeAPI no tiene el Pokemon #$pokemonId.');
    }
    final row = jsonObject(rows.single);
    final core = PokemonDto.fromJson(row);
    if (core.id != pokemonId) invalidResponse();

    final species = jsonObject(row['pokemonspecy']);
    final (chainSpecies, evolutions) = _evolutionChain(
      species['evolutionchain'],
    );
    final moves = _moves(row['pokemonmoves']);
    final versionGroups = {
      for (final move in moves) move.$2.id: move.$2,
    }.values.toList()..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    return PokemonDetailDto._(
      core: core,
      effects: _effects(row['pokemonabilities']),
      shinyImageUrl: _shiny(row['pokemonsprites']),
      stats: _stats(row['pokemonstats']),
      eggGroups: _eggGroups(species['pokemonegggroups']),
      evolutionChainId: species['evolution_chain_id'] == null
          ? null
          : positiveInt(species['evolution_chain_id']),
      chainSpecies: chainSpecies,
      evolutions: evolutions,
      versionGroups: versionGroups,
      moves: [for (final move in moves) move.$1],
    );
  }

  PokemonDetailDownload toDomain(DateTime savedAt) {
    final base = core.toDomain(savedAt);
    return PokemonDetailDownload(
      pokemon: Pokemon(
        id: base.id,
        nationalNumber: base.nationalNumber,
        name: base.name,
        imageUrl: base.imageUrl,
        updatedAt: base.updatedAt,
        types: base.types,
        species: base.species,
        height: base.height,
        weight: base.weight,
        // El total sale de las stats descargadas, no del agregado.
        baseStatTotal: stats.fold<int>(0, (sum, stat) => sum + stat.baseValue),
        isDefault: base.isDefault,
        shinyImageUrl: shinyImageUrl,
        abilities: [
          for (final entry in base.abilities)
            PokemonAbility(
              ability: Ability(
                id: entry.ability.id,
                name: entry.ability.name,
                effectSummary: effects[entry.ability.id],
              ),
              slot: entry.slot,
              isHidden: entry.isHidden,
            ),
        ],
      ),
      stats: stats,
      eggGroups: eggGroups,
      evolutionChainId: evolutionChainId,
      chainSpecies: chainSpecies,
      evolutions: evolutions,
      versionGroups: versionGroups,
      moves: moves,
    );
  }
}

// Efecto corto en ingles por habilidad; puede faltar.
Map<int, String?> _effects(Object? value) => {
  for (final entry in jsonList(value))
    positiveInt(jsonObject(jsonObject(entry)['ability'])['id']): () {
      final texts = jsonList(
        jsonObject(jsonObject(entry)['ability'])['abilityeffecttexts'],
      );
      if (texts.isEmpty) return null;
      final text = jsonObject(texts.first)['short_effect'];
      return text is String && text.trim().isNotEmpty ? text.trim() : null;
    }(),
};

// Artwork shiny y, si falta, el sprite shiny (RF-DET-09).
String? _shiny(Object? value) {
  final sprites = jsonList(value);
  if (sprites.isEmpty) return null;
  if (sprites.length > 1) invalidResponse();
  final sprite = jsonObject(sprites.single);
  return optionalHttpsUrl(sprite['shinyArtwork']) ??
      optionalHttpsUrl(sprite['shinyFront']);
}

List<PokemonStat> _stats(Object? value) {
  final stats = [
    for (final entry in jsonList(value))
      () {
        final row = jsonObject(entry);
        final stat = jsonObject(row['stat']);
        return PokemonStat(
          id: positiveInt(stat['id']),
          name: trimmedName(stat['name']),
          baseValue: nonNegativeInt(row['base_stat']),
        );
      }(),
  ];
  if (stats.isEmpty ||
      stats.map((stat) => stat.id).toSet().length != stats.length) {
    invalidResponse();
  }
  return stats;
}

List<EggGroup> _eggGroups(Object? value) {
  final groups = [
    for (final entry in jsonList(value))
      () {
        final group = jsonObject(jsonObject(entry)['egggroup']);
        return EggGroup(
          id: positiveInt(group['id']),
          name: trimmedName(group['name']),
        );
      }(),
  ];
  if (groups.map((group) => group.id).toSet().length != groups.length) {
    invalidResponse();
  }
  return groups;
}

// Especies de la cadena y un paso por especie que evoluciona. Si hay varias
// filas de evolucion se usa la principal (is_default) o, si no hay, la primera.
(List<PokemonSpecies>, List<EvolutionStep>) _evolutionChain(Object? value) {
  if (value == null) return (const [], const []);
  final rows = [
    for (final entry in jsonList(jsonObject(value)['pokemonspecies']))
      jsonObject(entry),
  ];
  final species = [
    for (final row in rows)
      PokemonSpecies(
        id: positiveInt(row['id']),
        name: trimmedName(row['name']),
      ),
  ];
  final ids = {for (final item in species) item.id};
  if (ids.length != species.length) invalidResponse();

  final steps = <EvolutionStep>[];
  for (final row in rows) {
    final from = row['evolves_from_species_id'];
    if (from == null) continue;
    if (!ids.contains(positiveInt(from))) invalidResponse();
    final options = [
      for (final entry in jsonList(row['pokemonevolutions'])) jsonObject(entry),
    ];
    final main = options.where((option) => option['is_default'] == true);
    final chosen = main.isNotEmpty
        ? main.first
        : (options.isEmpty ? null : options.first);
    final timeOfDay = chosen?['time_of_day'];
    final item = chosen?['item'];
    steps.add(
      EvolutionStep(
        fromSpeciesId: from as int,
        toSpeciesId: positiveInt(row['id']),
        // Sin filas de evolucion PokeAPI no informa el metodo.
        trigger: chosen == null
            ? 'other'
            : trimmedName(jsonObject(chosen['evolutiontrigger'])['name']),
        minLevel: chosen?['min_level'] == null
            ? null
            : positiveInt(chosen!['min_level']),
        itemName: item == null ? null : trimmedName(jsonObject(item)['name']),
        minHappiness: optionalNonNegativeInt(chosen?['min_happiness']),
        // PokeAPI usa "" cuando no depende de la hora.
        timeOfDay: timeOfDay is String && timeOfDay.isNotEmpty
            ? timeOfDay
            : null,
      ),
    );
  }
  return (species, steps);
}

List<(PokemonMove, VersionGroup)> _moves(Object? value) {
  final moves = <(PokemonMove, VersionGroup)>[];
  final keys = <(int, int, String, int)>{};
  for (final entry in jsonList(value)) {
    final row = jsonObject(entry);
    final move = jsonObject(row['move']);
    final group = jsonObject(row['versiongroup']);
    final versionGroup = VersionGroup(
      id: positiveInt(group['id']),
      name: trimmedName(group['name']),
      sortOrder: nonNegativeInt(group['order']),
    );
    final type = move['type'] == null ? null : jsonObject(move['type']);
    final accuracy = optionalNonNegativeInt(move['accuracy']);
    if (accuracy != null && accuracy > 100) invalidResponse();
    final pokemonMove = PokemonMove(
      moveId: positiveInt(move['id']),
      name: trimmedName(move['name']),
      versionGroupId: versionGroup.id,
      learnMethod: trimmedName(jsonObject(row['movelearnmethod'])['name']),
      level: nonNegativeInt(row['level']),
      power: optionalNonNegativeInt(move['power']),
      accuracy: accuracy,
      type: type == null
          ? null
          : PokemonType(
              id: positiveInt(type['id']),
              name: trimmedName(type['name']),
            ),
    );
    // El mismo movimiento puede aparecer en dos niveles, pero no repetido igual.
    final key = (
      pokemonMove.moveId,
      pokemonMove.versionGroupId,
      pokemonMove.learnMethod,
      pokemonMove.level,
    );
    if (!keys.add(key)) invalidResponse();
    moves.add((pokemonMove, versionGroup));
  }
  return moves;
}

/// Tabla de efectividad de tipos (RF-DET-06). Solo se guardan los tipos que
/// aparecen en la tabla: stellar, unknown y shadow no tienen Pokemon.
class TypeEfficacyDto {
  TypeEfficacyDto._(this.types, this.rows);

  final List<PokemonType> types;
  final List<TypeEfficacy> rows;

  factory TypeEfficacyDto.fromJson(Map<String, dynamic> data) {
    final rows = [
      for (final entry in jsonList(data['typeefficacy']))
        () {
          final row = jsonObject(entry);
          final factor = row['damage_factor'];
          if (factor is! int || !const {0, 50, 100, 200}.contains(factor)) {
            invalidResponse();
          }
          return TypeEfficacy(
            attackerTypeId: positiveInt(row['damage_type_id']),
            defenderTypeId: positiveInt(row['target_type_id']),
            damageFactor: factor,
          );
        }(),
    ];
    final used = {
      for (final row in rows) ...[row.attackerTypeId, row.defenderTypeId],
    };
    final pairs = {
      for (final row in rows) (row.attackerTypeId, row.defenderTypeId),
    };
    if (rows.isEmpty || pairs.length != rows.length) invalidResponse();
    final types = [
      for (final entry in jsonList(data['type']))
        () {
          final type = jsonObject(entry);
          return PokemonType(
            id: positiveInt(type['id']),
            name: trimmedName(type['name']),
          );
        }(),
    ].where((type) => used.contains(type.id)).toList();
    if (types.length != used.length) invalidResponse();
    return TypeEfficacyDto._(types, rows);
  }

  TypeEfficacyDownload toDomain() =>
      TypeEfficacyDownload(types: types, rows: rows);
}
