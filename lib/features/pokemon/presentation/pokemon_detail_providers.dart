import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/connection_status_provider.dart';
import '../../../app/pokemon_dependencies.dart';
import '../../../core/connectivity/connection_monitor.dart';
import '../../../core/domain/sync_failure.dart';
import '../domain/move_query.dart';
import '../domain/pokemon_detail.dart';

/// Vista del detalle leida de SQLite; se actualiza sola al guardar.
final pokemonDetailProvider = StreamProvider.autoDispose
    .family<PokemonDetail?, int>(
      (ref, pokemonId) =>
          ref.watch(pokemonDetailRepositoryProvider).watchDetail(pokemonId),
      retry: (retryCount, error) => null,
    );

final pokemonMovesProvider = StreamProvider.autoDispose
    .family<List<PokemonMove>, MoveQuery>(
      (ref, query) =>
          ref.watch(pokemonDetailRepositoryProvider).watchMoves(query),
    );

final typeChartProvider = StreamProvider.autoDispose<TypeEfficacyDownload>(
  (ref) => ref.watch(pokemonDetailRepositoryProvider).watchTypeEfficacy(),
);

final detailSyncControllerProvider = NotifierProvider.autoDispose
    .family<DetailSyncController, AsyncValue<void>, int>(
      DetailSyncController.new,
    );

/// Descarga el detalle al abrirlo (OF-20) sin bloquear: la pantalla ya muestra
/// lo local. Si vuelve el servicio con la pantalla abierta, reintenta.
class DetailSyncController extends Notifier<AsyncValue<void>> {
  DetailSyncController(this.pokemonId);

  final int pokemonId;

  @override
  AsyncValue<void> build() {
    ref.listen(connectionStatusProvider, (previous, next) {
      final recovered =
          next == ConnectionStatus.online &&
          previous != ConnectionStatus.online;
      if (recovered && state.hasError) unawaited(synchronize());
    });
    unawaited(Future.microtask(synchronize));
    return const AsyncLoading();
  }

  Future<void> synchronize() async {
    if (!ref.mounted) return;
    // Sin red no se llama a la API: evita esperar todos los reintentos.
    if (ref.read(connectionStatusProvider) == ConnectionStatus.offline) {
      state = AsyncError(
        const SyncFailure(SyncFailureKind.network, 'Sin conexion.'),
        StackTrace.current,
      );
      return;
    }
    state = const AsyncLoading();
    try {
      await ref.read(pokemonDetailSyncProvider).synchronize(pokemonId);
      if (ref.mounted) state = const AsyncData(null);
    } catch (error, stackTrace) {
      if (ref.mounted) state = AsyncError(error, stackTrace);
    }
  }
}
