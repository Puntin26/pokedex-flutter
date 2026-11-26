import 'package:drift/drift.dart';

import '../domain/sync_metadata.dart';
import 'app_database.dart';

/// Lectura y escritura de sync_metadata, comun a catalogo, detalle y tipos.
class SyncMetadataStore {
  SyncMetadataStore(this.database);

  final AppDatabase database;

  Selectable<SyncMetadataRow> _query(String resourceKey) =>
      database.select(database.syncMetadataRecords)
        ..where((row) => row.resourceKey.equals(resourceKey));

  static SyncMetadata _map(SyncMetadataRow row) => SyncMetadata(
    resourceKey: row.resourceKey,
    nextOffset: row.nextOffset,
    totalCount: row.totalCount,
    status: SyncStatus.values.byName(row.status),
    lastSuccessAt: row.lastSuccessAt?.toUtc(),
    lastError: row.lastError,
    isComplete: row.isComplete,
  );

  Stream<SyncMetadata?> watch(String resourceKey) =>
      _query(resourceKey)
          .watchSingleOrNull()
          .map((row) => row == null ? null : _map(row));

  Future<SyncMetadata?> read(String resourceKey) async {
    final row = await _query(resourceKey).getSingleOrNull();
    return row == null ? null : _map(row);
  }

  /// Se llama dentro de la misma transaccion que guarda los datos.
  Future<void> save(SyncMetadata metadata) => database
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

  // Un error no modifica el progreso confirmado ni la ultima fecha exitosa.
  Future<void> updateStatus(
    String resourceKey,
    SyncStatus status, {
    String? lastError,
  }) => database
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
