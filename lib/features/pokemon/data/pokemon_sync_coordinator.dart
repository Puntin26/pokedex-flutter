import '../../../core/domain/sync_failure.dart';
import '../../../core/domain/sync_metadata.dart';
import '../domain/pokemon_repository.dart';
import '../domain/pokemon_sync.dart';
import 'pokemon_page_dto.dart';
import 'remote_pokemon_source.dart';

class PokemonSyncCoordinator implements PokemonSync {
  PokemonSyncCoordinator({
    required this.remote,
    required this.local,
    this.pageSize = 100,
  }) {
    if (pageSize < 1 || pageSize > 100) {
      throw ArgumentError.value(
        pageSize,
        'pageSize',
        'Debe estar entre 1 y 100.',
      );
    }
  }

  static const resourceKey = 'pokemon_catalog';
  final RemotePokemonSource remote;
  final PokemonRepository local;
  final int pageSize;
  Future<void>? _activeSync;

  @override
  Future<void> synchronize({bool restart = false}) {
    // Los eventos simultaneos comparten el mismo intento y resultado.
    return _activeSync ??= _synchronize(restart: restart);
  }

  Future<void> _synchronize({required bool restart}) async {
    try {
      final previous = await local.readSyncMetadata(resourceKey);
      final resume = !restart && previous != null && !previous.isComplete;
      var offset = resume ? previous.nextOffset : 0;
      int? expectedTotal = resume ? previous.totalCount : null;
      var previousId = 0;
      await local.updateSyncStatus(resourceKey, SyncStatus.syncing);

      while (true) {
        final data = await remote.fetchPage(limit: pageSize, offset: offset);
        final page = PokemonPageDto.fromJson(
          data,
          limit: pageSize,
          offset: offset,
        );
        if ((expectedTotal != null && page.totalCount != expectedTotal) ||
            (page.pokemon.isNotEmpty && page.pokemon.first.id <= previousId)) {
          throw const SyncFailure(
            SyncFailureKind.invalidResponse,
            'El catalogo remoto cambio durante la paginacion. Reinicie la sincronizacion.',
          );
        }
        final savedAt = DateTime.now().toUtc();
        final pokemon = page.toDomain(savedAt);
        final nextOffset = offset + pokemon.length;
        final complete = nextOffset == page.totalCount;

        // Este es el punto fetch -> mapper -> transaccion/upsert local.
        await local.savePage(
          pokemon,
          SyncMetadata(
            resourceKey: resourceKey,
            nextOffset: nextOffset,
            totalCount: page.totalCount,
            status: complete ? SyncStatus.success : SyncStatus.syncing,
            lastSuccessAt: savedAt,
            isComplete: complete,
          ),
        );
        if (complete) return;
        offset = nextOffset;
        expectedTotal = page.totalCount;
        previousId = pokemon.last.id;
      }
    } catch (error, stackTrace) {
      final failure = error is SyncFailure
          ? error
          : const SyncFailure(
              SyncFailureKind.storage,
              'No se pudo leer o guardar el catalogo local.',
            );
      try {
        await local.updateSyncStatus(
          resourceKey,
          SyncStatus.failed,
          lastError: failure.toString(),
        );
      } catch (_) {
        // Si SQLite tambien falla al registrar el error, conserva el fallo original.
      }
      Error.throwWithStackTrace(failure, stackTrace);
    } finally {
      _activeSync = null;
    }
  }
}
