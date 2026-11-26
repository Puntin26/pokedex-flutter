import 'package:flutter/foundation.dart';

import '../../../core/domain/freshness_policy.dart';
import '../../../core/domain/sync_failure.dart';
import '../../../core/domain/sync_metadata.dart';
import '../../../core/sync/retry_policy.dart';
import '../domain/pokemon_detail_repository.dart';
import '../domain/pokemon_detail_sync.dart';
import 'pokemon_detail_dto.dart';
import 'remote_pokemon_detail_source.dart';

/// Al abrir un detalle: descarga, valida y guarda en una transaccion (OF-20,
/// PA-02). La UI ya mostro lo local; recibe lo nuevo por SQLite. Sobrescribir
/// en cada apertura restaura datos alterados localmente (OF-19, PA-16).
class PokemonDetailSyncCoordinator implements PokemonDetailSync {
  PokemonDetailSyncCoordinator({
    required this.remote,
    required this.local,
    RetryPolicy? retryPolicy,
    DateTime Function()? clock,
    void Function(String message)? log,
    this.typeEfficacyFreshness = const FreshnessPolicy(),
  }) : retryPolicy = retryPolicy ?? RetryPolicy.none(),
       _clock = clock ?? DateTime.now,
       _log = log ?? debugPrint;

  static String resourceKey(int pokemonId) => 'pokemon_detail:$pokemonId';
  static const typeEfficacyKey = 'type_efficacy';

  final RemotePokemonDetailSource remote;
  final PokemonDetailRepository local;
  final RetryPolicy retryPolicy;
  final FreshnessPolicy typeEfficacyFreshness;
  final DateTime Function() _clock;
  final void Function(String message) _log;
  // Un intento en curso por Pokemon; distintos Pokemon van en paralelo.
  final _active = <int, Future<void>>{};

  @override
  Future<void> synchronize(int pokemonId) =>
      _active[pokemonId] ??= _synchronize(pokemonId).whenComplete(() {
        // Bloque sin valor: si devolviera el Future quitado (este mismo),
        // whenComplete lo esperaria y quedaria bloqueado para siempre.
        _active.remove(pokemonId);
      });

  Future<void> _synchronize(int pokemonId) async {
    final key = resourceKey(pokemonId);
    try {
      await local.updateSyncStatus(key, SyncStatus.syncing);
      _log('[graphql] PokemonDetail #$pokemonId');
      final data = await retryPolicy.run(
        () => remote.fetchDetail(pokemonId),
        label: 'detalle #$pokemonId',
      );
      final savedAt = _clock().toUtc();
      final detail = PokemonDetailDto.fromJson(
        data,
        pokemonId: pokemonId,
      ).toDomain(savedAt);
      await local.saveDetail(
        detail,
        SyncMetadata(
          resourceKey: key,
          nextOffset: 1,
          totalCount: 1,
          status: SyncStatus.success,
          lastSuccessAt: savedAt,
          isComplete: true,
        ),
      );
      _log(
        '[sync] detalle #$pokemonId guardado: ${detail.moves.length} '
        'movimientos en ${detail.versionGroups.length} juegos',
      );
    } catch (error, stackTrace) {
      final failure = error is SyncFailure
          ? error
          : const SyncFailure(
              SyncFailureKind.storage,
              'No se pudo guardar el detalle en la base local.',
            );
      try {
        await local.updateSyncStatus(
          key,
          SyncStatus.failed,
          lastError: failure.toString(),
        );
      } catch (_) {
        // Si SQLite tambien falla al registrar el error, conserva el fallo original.
      }
      Error.throwWithStackTrace(failure, stackTrace);
    }
    await _refreshTypeEfficacyIfStale();
  }

  // La tabla de tipos es igual para todos: se baja una vez y se renueva tras
  // 24 h. Si falla, el detalle ya quedo guardado; solo faltan los matchups.
  Future<void> _refreshTypeEfficacyIfStale() async {
    final now = _clock().toUtc();
    final metadata = await local.readSyncMetadata(typeEfficacyKey);
    if (!typeEfficacyFreshness.isStale(metadata, now)) return;
    try {
      final data = await retryPolicy.run(
        remote.fetchTypeEfficacy,
        label: 'efectividad de tipos',
      );
      await local.saveTypeEfficacy(
        TypeEfficacyDto.fromJson(data).toDomain(),
        SyncMetadata(
          resourceKey: typeEfficacyKey,
          nextOffset: 1,
          totalCount: 1,
          status: SyncStatus.success,
          lastSuccessAt: now,
          isComplete: true,
        ),
      );
    } catch (error) {
      _log('[sync] No se pudo actualizar la efectividad de tipos: $error');
      await local.updateSyncStatus(
        typeEfficacyKey,
        SyncStatus.failed,
        lastError: error.toString(),
      );
    }
  }
}
