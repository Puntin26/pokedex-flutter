import '../../../core/domain/sync_metadata.dart';
import 'move_query.dart';
import 'pokemon_detail.dart';

abstract interface class PokemonDetailRepository {
  /// null si el Pokemon no esta guardado todavia.
  Stream<PokemonDetail?> watchDetail(int pokemonId);
  Stream<List<PokemonMove>> watchMoves(MoveQuery query);

  /// Tabla de efectividad con los tipos que participan (para los matchups).
  Stream<TypeEfficacyDownload> watchTypeEfficacy();

  Future<void> saveDetail(PokemonDetailDownload detail, SyncMetadata metadata);
  Future<void> saveTypeEfficacy(
    TypeEfficacyDownload efficacy,
    SyncMetadata metadata,
  );
  Future<SyncMetadata?> readSyncMetadata(String resourceKey);
  Future<void> updateSyncStatus(
    String resourceKey,
    SyncStatus status, {
    String? lastError,
  });
}
