import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/pokemon.dart';

/// Guarda un Pokemon con su especie, habilidades y tipos. Lo usan el catalogo
/// y el detalle, siempre dentro de la transaccion de quien llama.
/// Regla: lo que no viene en la descarga no se pisa (upsert parcial).
class PokemonWriter {
  PokemonWriter(this.database);

  final AppDatabase database;

  Future<void> upsertPokemon(Pokemon item) async {
    final species = item.species;
    if (species != null) await _saveSpecies(species);
    final shiny = item.shinyImageUrl;
    // Actualiza por ID sin borrar la fila referenciada por favoritos.
    await database
        .into(database.pokemonRecords)
        .insertOnConflictUpdate(
          PokemonRecordsCompanion.insert(
            id: Value(item.id),
            nationalNumber: item.nationalNumber,
            name: item.name,
            imageUrl: Value(item.imageUrl),
            updatedAt: item.updatedAt,
            speciesId: Value(species?.id),
            height: Value(item.height),
            weight: Value(item.weight),
            baseStatTotal: Value(item.baseStatTotal),
            isDefault: Value(item.isDefault),
            // El catalogo no trae shiny: no borra el que guardo el detalle.
            shinyImageUrl: shiny == null ? const Value.absent() : Value(shiny),
          ),
        );
    await _replaceAbilities(item);
    await (database.delete(
      database.pokemonTypeLinks,
    )..where((row) => row.pokemonId.equals(item.id))).go();
    for (final entry in item.types) {
      await upsertType(entry.type);
      await database
          .into(database.pokemonTypeLinks)
          .insert(
            PokemonTypeLinksCompanion.insert(
              pokemonId: item.id,
              typeId: entry.type.id,
              slot: entry.slot,
            ),
          );
    }
  }

  Future<void> upsertType(PokemonType type) => database
      .into(database.pokemonTypes)
      .insertOnConflictUpdate(
        PokemonTypesCompanion.insert(id: Value(type.id), name: type.name),
      );

  // Reemplaza los enlaces (restaura alteraciones, OF-19). El efecto solo se
  // escribe cuando viene: el catalogo no lo trae, el detalle si.
  Future<void> _replaceAbilities(Pokemon item) async {
    await (database.delete(
      database.pokemonAbilities,
    )..where((row) => row.pokemonId.equals(item.id))).go();
    for (final entry in item.abilities) {
      final effect = entry.ability.effectSummary;
      final effectValue = effect == null
          ? const Value<String?>.absent()
          : Value<String?>(effect);
      await database
          .into(database.abilities)
          .insert(
            AbilitiesCompanion.insert(
              id: Value(entry.ability.id),
              name: entry.ability.name,
              effectSummary: effectValue,
            ),
            onConflict: DoUpdate(
              (_) => AbilitiesCompanion(
                name: Value(entry.ability.name),
                effectSummary: effectValue,
              ),
            ),
          );
      await database
          .into(database.pokemonAbilities)
          .insert(
            PokemonAbilitiesCompanion.insert(
              pokemonId: item.id,
              abilityId: entry.ability.id,
              slot: entry.slot,
              isHidden: Value(entry.isHidden),
            ),
          );
    }
  }

  // Solo escribe las columnas que trae la descarga: lo que complete la sync del
  // detalle (evolution_chain_id...) no se pisa con un upsert parcial.
  Future<void> _saveSpecies(PokemonSpecies species) async {
    final generation = species.generation;
    if (generation != null) {
      await database
          .into(database.generations)
          .insertOnConflictUpdate(
            GenerationsCompanion.insert(
              id: Value(generation.id),
              name: generation.name,
              regionName: Value(generation.regionName),
            ),
          );
    }
    await database
        .into(database.pokemonSpecies)
        .insertOnConflictUpdate(
          PokemonSpeciesCompanion.insert(
            id: Value(species.id),
            name: species.name,
            generationId: Value(generation?.id),
          ),
        );
  }
}
