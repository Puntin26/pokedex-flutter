import '../../../core/domain/sync_metadata.dart';
import 'pokemon.dart';

abstract interface class PokemonRepository {
  Stream<List<Pokemon>> watchCatalog();
  Stream<List<PokemonType>> watchTypes();
  Stream<SyncMetadata?> watchSyncMetadata(String resourceKey);
  Future<SyncMetadata?> readSyncMetadata(String resourceKey);

  Future<void> savePage(List<Pokemon> pokemon, SyncMetadata metadata);
  Future<void> updateSyncStatus(
    String resourceKey,
    SyncStatus status, {
    String? lastError,
  });
}
