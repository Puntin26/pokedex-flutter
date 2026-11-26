import 'dart:async';

import '../../../core/domain/sync_activity.dart';
import '../../../core/domain/sync_failure.dart';
import '../../../core/domain/sync_metadata.dart';
import '../../../core/sync/retry_policy.dart';
import '../domain/pokemon_repository.dart';
import '../domain/pokemon_sync.dart';
import 'pokemon_page_dto.dart';
import 'remote_pokemon_source.dart';

class PokemonSyncCoordinator implements PokemonSync {
  PokemonSyncCoordinator({
    required this.remote,
    required this.local,
    this.pageSize = 100,
    RetryPolicy? retryPolicy,
  }) : retryPolicy = retryPolicy ?? RetryPolicy.none() {
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
  final RetryPolicy retryPolicy;
  Future<void>? _activeSync;
  SyncActivity _activity = SyncActivity.idle;
  final _activityChanges = StreamController<SyncActivity>.broadcast(sync: true);

  @override
  SyncActivity get activity => _activity;

  @override
  Stream<SyncActivity> watchActivity() {
    // Stream.multi se suscribe de forma sincrona: no se pierde un cambio entre
    // el valor inicial y la suscripcion.
    return Stream.multi((listener) {
      listener.add(_activity);
      final subscription = _activityChanges.stream.listen(listener.add);
      listener.onCancel = subscription.cancel;
    });
  }

  Future<void> dispose() => _activityChanges.close();

  void _setActivity(SyncActivity activity) {
    if (activity == _activity || _activityChanges.isClosed) return;
    _activity = activity;
    _activityChanges.add(activity);
  }

  @override
  Future<void> synchronize({bool restart = false}) {
    // Los eventos simultaneos comparten el mismo intento y resultado.
    return _activeSync ??= _synchronize(restart: restart);
  }

  Future<void> _synchronize({required bool restart}) async {
    _setActivity(SyncActivity.syncing);
    try {
      final previous = await local.readSyncMetadata(resourceKey);
      final resume = !restart && previous != null && !previous.isComplete;
      var offset = resume ? previous.nextOffset : 0;
      int? expectedTotal = resume ? previous.totalCount : null;
      var previousId = 0;
      await local.updateSyncStatus(resourceKey, SyncStatus.syncing);

      while (true) {
        // Se reintenta solo la pagina actual: las ya guardadas no se repiten.
        final pageOffset = offset;
        final data = await retryPolicy.run(
          () {
            _setActivity(SyncActivity.syncing);
            return remote.fetchPage(limit: pageSize, offset: pageOffset);
          },
          label: 'catalogo offset $pageOffset',
          onRetry: (_) => _setActivity(SyncActivity.waitingRetry),
        );
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
        if (complete) {
          _setActivity(SyncActivity.idle);
          return;
        }
        offset = nextOffset;
        expectedTotal = page.totalCount;
        previousId = pokemon.last.id;
      }
    } catch (error, stackTrace) {
      _setActivity(SyncActivity.failed);
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
