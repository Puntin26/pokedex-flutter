import 'dart:math';

import 'json_fields.dart';
import '../domain/pokemon.dart';

class PokemonPageDto {
  PokemonPageDto._(this.pokemon, this.totalCount);

  final List<PokemonDto> pokemon;
  final int totalCount;

  factory PokemonPageDto.fromJson(
    Map<String, dynamic> data, {
    required int limit,
    required int offset,
  }) {
    final aggregate = jsonObject(
      jsonObject(data['pokemon_aggregate'])['aggregate'],
    );
    final total = aggregate['count'];
    if (total is! int || total < 0 || offset > total) _invalid();
    final rows = jsonList(data['pokemon']);
    // Un lote truncado sin errores tampoco puede avanzar el progreso.
    if (rows.length != min(limit, total - offset)) _invalid();
    final pokemon = rows
        .map((row) => PokemonDto.fromJson(jsonObject(row)))
        .toList();
    for (var index = 1; index < pokemon.length; index++) {
      if (pokemon[index].id <= pokemon[index - 1].id) _invalid();
    }
    return PokemonPageDto._(List.unmodifiable(pokemon), total);
  }

  List<Pokemon> toDomain(DateTime updatedAt) =>
      pokemon.map((item) => item.toDomain(updatedAt)).toList();
}

class PokemonDto {
  PokemonDto._({
    required this.id,
    required this.nationalNumber,
    required this.name,
    required this.imageUrl,
    required this.types,
    required this.species,
    required this.height,
    required this.weight,
    required this.baseStatTotal,
    required this.isDefault,
    required this.abilities,
  });

  final int id;
  final int nationalNumber;
  final String name;
  final String? imageUrl;
  final List<PokemonTypeSlot> types;
  final PokemonSpecies species;
  final int? height;
  final int? weight;
  final int? baseStatTotal;
  final bool isDefault;
  final List<PokemonAbility> abilities;

  factory PokemonDto.fromJson(Map<String, dynamic> row) {
    final id = positiveInt(row['id']);
    final nationalNumber = positiveInt(row['pokemon_species_id']);
    final name = trimmedName(row['name']);
    final typeRows = jsonList(row['pokemontypes']);
    if (typeRows.isEmpty || typeRows.length > 2) _invalid();
    final types = typeRows.map((value) {
      final entry = jsonObject(value);
      final type = jsonObject(entry['type']);
      return PokemonTypeSlot(
        type: PokemonType(
          id: positiveInt(type['id']),
          name: trimmedName(type['name']),
        ),
        slot: positiveInt(entry['slot']),
      );
    }).toList()..sort((a, b) => a.slot.compareTo(b.slot));
    if (types.first.slot != 1) _invalid();
    // Con dos tipos basta comparar sus posiciones e identidades.
    if (types.length == 2) {
      final first = types.first;
      final second = types.last;
      if (second.slot != 2 ||
          second.type.id == first.type.id ||
          second.type.name == first.type.name) {
        _invalid();
      }
    }
    final sprites = jsonList(row['pokemonsprites']);
    if (sprites.length > 1) _invalid();
    String? imageUrl;
    if (sprites.isNotEmpty) {
      final sprite = jsonObject(sprites.single);
      if (!sprite.containsKey('artwork') || !sprite.containsKey('front')) {
        _invalid();
      }
      final artwork = optionalHttpsUrl(sprite['artwork']);
      final front = optionalHttpsUrl(sprite['front']);
      imageUrl = artwork ?? front;
    }
    final species = _species(row['pokemonspecy']);
    // La especie anidada debe ser la misma que indica pokemon_species_id.
    if (species.id != nationalNumber) _invalid();
    final isDefault = row['is_default'];
    if (isDefault is! bool) _invalid();
    final statSum = jsonObject(
      jsonObject(jsonObject(row['pokemonstats_aggregate'])['aggregate'])['sum'],
    );
    return PokemonDto._(
      id: id,
      nationalNumber: nationalNumber,
      name: name,
      imageUrl: imageUrl,
      types: List.unmodifiable(types),
      species: species,
      height: optionalNonNegativeInt(row['height']),
      weight: optionalNonNegativeInt(row['weight']),
      // Nulo si PokeAPI no tiene stats para esa forma.
      baseStatTotal: optionalNonNegativeInt(statSum['base_stat']),
      isDefault: isDefault,
      abilities: _abilities(row['pokemonabilities']),
    );
  }

  Pokemon toDomain(DateTime updatedAt) => Pokemon(
    id: id,
    nationalNumber: nationalNumber,
    name: name,
    imageUrl: imageUrl,
    updatedAt: updatedAt.toUtc(),
    types: types,
    species: species,
    height: height,
    weight: weight,
    baseStatTotal: baseStatTotal,
    isDefault: isDefault,
    abilities: abilities,
  );
}

// Puede venir vacia (hay Pokemon sin habilidades); slots 1-3 sin repetir.
List<PokemonAbility> _abilities(Object? value) {
  final abilities = jsonList(value).map((entry) {
    final row = jsonObject(entry);
    final ability = jsonObject(row['ability']);
    final slot = positiveInt(row['slot']);
    final isHidden = row['is_hidden'];
    if (slot > 3 || isHidden is! bool) _invalid();
    return PokemonAbility(
      ability: Ability(
        id: positiveInt(ability['id']),
        name: trimmedName(ability['name']),
      ),
      slot: slot,
      isHidden: isHidden,
    );
  }).toList()..sort((a, b) => a.slot.compareTo(b.slot));
  final slots = abilities.map((entry) => entry.slot).toSet();
  final ids = abilities.map((entry) => entry.ability.id).toSet();
  if (slots.length != abilities.length || ids.length != abilities.length) {
    _invalid();
  }
  return List.unmodifiable(abilities);
}

PokemonSpecies _species(Object? value) {
  final species = jsonObject(value);
  final generationValue = species['generation'];
  Generation? generation;
  if (generationValue != null) {
    final row = jsonObject(generationValue);
    final region = row['region'];
    generation = Generation(
      id: positiveInt(row['id']),
      name: trimmedName(row['name']),
      regionName: region == null
          ? null
          : trimmedName(jsonObject(region)['name']),
    );
  }
  return PokemonSpecies(
    id: positiveInt(species['id']),
    name: trimmedName(species['name']),
    generation: generation,
  );
}

// El mensaje de siempre para el catalogo.
Never _invalid() => invalidResponse(
  'La pagina del catalogo esta incompleta o contiene datos invalidos.',
);
