import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/domain/sync_metadata.dart';
import '../domain/catalog_query.dart';
import '../domain/pokemon.dart';
import '../domain/pokemon_repository.dart';
import 'pokemon_row_mapper.dart';

class LocalPokemonRepository implements PokemonRepository {
  LocalPokemonRepository(this.database);

  final AppDatabase database;

  @override
  Stream<List<Pokemon>> watchCatalog([
    CatalogQuery query = const CatalogQuery(),
  ]) {
    final pokemon = database.pokemonRecords;
    final links = database.pokemonTypeLinks;
    final types = database.pokemonTypes;
    final species = database.pokemonSpecies;
    final generations = database.generations;
    final select = database.select(pokemon).join([
      leftOuterJoin(links, links.pokemonId.equalsExp(pokemon.id)),
      leftOuterJoin(types, types.id.equalsExp(links.typeId)),
      leftOuterJoin(species, species.id.equalsExp(pokemon.speciesId)),
      leftOuterJoin(
        generations,
        generations.id.equalsExp(species.generationId),
      ),
    ]);

    // Todo el filtrado y el orden ocurre en SQLite, no en Dart (RNF-REN-02).
    final search = query.normalizedSearch;
    if (search.isNotEmpty) {
      select.where(
        pokemon.name.like('%${_escapeLike(search)}%', escapeChar: r'\'),
      );
    }
    final typeId = query.typeId;
    if (typeId != null) {
      // EXISTS y no un where sobre el join: asi el Pokemon conserva sus dos tipos.
      final filter = database.alias(links, 'type_filter');
      select.where(
        existsQuery(
          database.select(filter)..where(
            (row) =>
                row.pokemonId.equalsExp(pokemon.id) & row.typeId.equals(typeId),
          ),
        ),
      );
    }
    final generationId = query.generationId;
    if (generationId != null) {
      select.where(species.generationId.equals(generationId));
    }

    OrderingTerm by(Expression expression, {NullsOrder? nulls}) =>
        query.descending
        ? OrderingTerm.desc(expression, nulls: nulls)
        : OrderingTerm.asc(expression, nulls: nulls);
    select.orderBy([
      switch (query.sort) {
        CatalogSort.number => by(pokemon.nationalNumber),
        CatalogSort.name => by(pokemon.name),
        // Sin total (fila aun no sincronizada) siempre al final.
        CatalogSort.baseStatTotal => by(
          pokemon.baseStatTotal,
          nulls: NullsOrder.last,
        ),
      },
      // Desempate estable; slot mantiene el orden de tipos para el mapper.
      OrderingTerm.asc(pokemon.nationalNumber),
      OrderingTerm.asc(pokemon.id),
      OrderingTerm.asc(links.slot),
    ]);
    return select.watch().map((rows) => mapPokemonRows(rows, database));
  }

  @override
  Stream<List<Generation>> watchGenerations() {
    final query = database.select(database.generations)
      ..orderBy([(table) => OrderingTerm.asc(table.id)]);
    return query.watch().map(
      (rows) => rows
          .map(
            (row) => Generation(
              id: row.id,
              name: row.name,
              regionName: row.regionName,
            ),
          )
          .toList(),
    );
  }

  @override
  Stream<List<PokemonType>> watchTypes() {
    final query = database.select(database.pokemonTypes)
      ..orderBy([(table) => OrderingTerm.asc(table.name)]);
    return query.watch().map(
      (rows) =>
          rows.map((row) => PokemonType(id: row.id, name: row.name)).toList(),
    );
  }

  Selectable<SyncMetadataRow> _metadataQuery(String resourceKey) {
    return database.select(database.syncMetadataRecords)
      ..where((row) => row.resourceKey.equals(resourceKey));
  }

  SyncMetadata _mapMetadata(SyncMetadataRow row) => SyncMetadata(
    resourceKey: row.resourceKey,
    nextOffset: row.nextOffset,
    totalCount: row.totalCount,
    status: SyncStatus.values.byName(row.status),
    lastSuccessAt: row.lastSuccessAt?.toUtc(),
    lastError: row.lastError,
    isComplete: row.isComplete,
  );

  @override
  Stream<SyncMetadata?> watchSyncMetadata(String resourceKey) =>
      _metadataQuery(resourceKey)
          .watchSingleOrNull()
          .map((row) => row == null ? null : _mapMetadata(row));

  @override
  Future<SyncMetadata?> readSyncMetadata(String resourceKey) async {
    final row = await _metadataQuery(resourceKey).getSingleOrNull();
    return row == null ? null : _mapMetadata(row);
  }

  @override
  Future<void> savePage(List<Pokemon> pokemon, SyncMetadata metadata) {
    return database.transaction(() async {
      for (final item in pokemon) {
        final species = item.species;
        if (species != null) await _saveSpecies(species);
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
              ),
            );
        await (database.delete(
          database.pokemonTypeLinks,
        )..where((row) => row.pokemonId.equals(item.id))).go();
        for (final entry in item.types) {
          await database
              .into(database.pokemonTypes)
              .insertOnConflictUpdate(
                PokemonTypesCompanion.insert(
                  id: Value(entry.type.id),
                  name: entry.type.name,
                ),
              );
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
      // El offset solo cambia si se confirma la pagina completa.
      await database
          .into(database.syncMetadataRecords)
          .insertOnConflictUpdate(
            SyncMetadataRecordsCompanion.insert(
              resourceKey: metadata.resourceKey,
              nextOffset: Value(metadata.nextOffset),
              totalCount: Value(metadata.totalCount),
              status: Value(metadata.status.name),
              lastSuccessAt: Value(metadata.lastSuccessAt),
              lastError: Value(metadata.lastError),
              isComplete: Value(metadata.isComplete),
            ),
          );
    });
  }

  // Solo escribe las columnas que trae el catalogo: lo que complete la sync del
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

  @override
  Future<void> updateSyncStatus(
    String resourceKey,
    SyncStatus status, {
    String? lastError,
  }) async {
    // Un error de red no modifica el progreso confirmado ni borra el catalogo.
    await database
        .into(database.syncMetadataRecords)
        .insert(
          SyncMetadataRecordsCompanion.insert(
            resourceKey: resourceKey,
            status: Value(status.name),
            lastError: Value(lastError),
          ),
          onConflict: DoUpdate(
            (_) => SyncMetadataRecordsCompanion(
              status: Value(status.name),
              lastError: Value(lastError),
            ),
          ),
        );
  }
}

// El texto del usuario se busca literal: %, _ y \ no actuan como comodines.
String _escapeLike(String value) =>
    value.replaceAllMapped(RegExp(r'[\\%_]'), (match) => '\\${match[0]}');
