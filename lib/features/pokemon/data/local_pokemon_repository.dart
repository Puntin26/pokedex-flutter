import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/domain/sync_metadata.dart';
import '../domain/pokemon.dart';
import '../domain/pokemon_repository.dart';
import 'pokemon_row_mapper.dart';

class LocalPokemonRepository implements PokemonRepository {
  LocalPokemonRepository(this.database);

  final AppDatabase database;

  @override
  Stream<List<Pokemon>> watchCatalog() {
    final pokemon = database.pokemonRecords;
    final links = database.pokemonTypeLinks;
    final types = database.pokemonTypes;
    final query =
        database.select(pokemon).join([
          leftOuterJoin(links, links.pokemonId.equalsExp(pokemon.id)),
          leftOuterJoin(types, types.id.equalsExp(links.typeId)),
        ])..orderBy([
          OrderingTerm.asc(pokemon.nationalNumber),
          OrderingTerm.asc(pokemon.id),
          OrderingTerm.asc(links.slot),
        ]);
    return query.watch().map((rows) => mapPokemonRows(rows, database));
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
