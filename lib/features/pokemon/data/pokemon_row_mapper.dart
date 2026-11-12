import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/pokemon.dart';

// Agrupa las filas del join sin repetir Pokemon y conserva el orden de tipos.
List<Pokemon> mapPokemonRows(List<TypedResult> rows, AppDatabase database) {
  final records = <int, PokemonRow>{};
  final types = <int, List<PokemonTypeSlot>>{};

  for (final row in rows) {
    final pokemon = row.readTable(database.pokemonRecords);
    records[pokemon.id] = pokemon;
    final slots = types.putIfAbsent(pokemon.id, () => []);
    final type = row.readTableOrNull(database.pokemonTypes);
    final link = row.readTableOrNull(database.pokemonTypeLinks);
    if (type != null && link != null) {
      slots.add(
        PokemonTypeSlot(
          type: PokemonType(id: type.id, name: type.name),
          slot: link.slot,
        ),
      );
    }
  }

  return records.values.map((row) {
    return Pokemon(
      id: row.id,
      nationalNumber: row.nationalNumber,
      name: row.name,
      imageUrl: row.imageUrl,
      updatedAt: row.updatedAt.toUtc(),
      types: types[row.id]!,
    );
  }).toList();
}
