import 'dart:math';

import '../../../core/domain/sync_failure.dart';
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
    final aggregate = _object(_object(data['pokemon_aggregate'])['aggregate']);
    final total = aggregate['count'];
    if (total is! int || total < 0 || offset > total) _invalid();
    final rows = _list(data['pokemon']);
    // Un lote truncado sin errores tampoco puede avanzar el progreso.
    if (rows.length != min(limit, total - offset)) _invalid();
    final pokemon = rows
        .map((row) => PokemonDto.fromJson(_object(row)))
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
  PokemonDto._(
    this.id,
    this.nationalNumber,
    this.name,
    this.imageUrl,
    this.types,
  );

  final int id;
  final int nationalNumber;
  final String name;
  final String? imageUrl;
  final List<PokemonTypeSlot> types;

  factory PokemonDto.fromJson(Map<String, dynamic> row) {
    final id = _positiveInt(row['id']);
    final nationalNumber = _positiveInt(row['pokemon_species_id']);
    final name = _name(row['name']);
    final typeRows = _list(row['pokemontypes']);
    if (typeRows.isEmpty || typeRows.length > 2) _invalid();
    final types = typeRows.map((value) {
      final entry = _object(value);
      final type = _object(entry['type']);
      return PokemonTypeSlot(
        type: PokemonType(
          id: _positiveInt(type['id']),
          name: _name(type['name']),
        ),
        slot: _positiveInt(entry['slot']),
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
    final sprites = _list(row['pokemonsprites']);
    if (sprites.length > 1) _invalid();
    String? imageUrl;
    if (sprites.isNotEmpty) {
      final sprite = _object(sprites.single);
      if (!sprite.containsKey('artwork') || !sprite.containsKey('front')) {
        _invalid();
      }
      final artwork = _imageUrl(sprite['artwork']);
      final front = _imageUrl(sprite['front']);
      imageUrl = artwork ?? front;
    }
    return PokemonDto._(
      id,
      nationalNumber,
      name,
      imageUrl,
      List.unmodifiable(types),
    );
  }

  Pokemon toDomain(DateTime updatedAt) => Pokemon(
    id: id,
    nationalNumber: nationalNumber,
    name: name,
    imageUrl: imageUrl,
    updatedAt: updatedAt.toUtc(),
    types: types,
  );
}

Map<String, dynamic> _object(Object? value) {
  if (value is! Map<String, dynamic>) _invalid();
  return value;
}

List<dynamic> _list(Object? value) {
  if (value is! List) _invalid();
  return value;
}

int _positiveInt(Object? value) {
  if (value is! int || value <= 0) _invalid();
  return value;
}

String _name(Object? value) {
  if (value is! String || value.trim().isEmpty || value != value.trim()) {
    _invalid();
  }
  return value;
}

String? _imageUrl(Object? value) {
  if (value == null) return null;
  if (value is! String) _invalid();
  final uri = Uri.tryParse(value);
  if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) _invalid();
  return value;
}

Never _invalid() => throw const SyncFailure(
  SyncFailureKind.invalidResponse,
  'La pagina del catalogo esta incompleta o contiene datos invalidos.',
);
