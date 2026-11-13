import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/pokemon_dependencies.dart';
import '../../../core/domain/sync_failure.dart';
import '../../../core/domain/sync_metadata.dart';
import '../domain/pokemon.dart';
import 'pokemon_catalog_state.dart';

const catalogResourceKey = 'pokemon_catalog';

final localCatalogProvider = StreamProvider<List<Pokemon>>(
  (ref) => ref.watch(pokemonRepositoryProvider).watchCatalog(),
  retry: (retryCount, error) => null,
);

final catalogMetadataProvider = StreamProvider<SyncMetadata?>(
  (ref) => ref
      .watch(pokemonRepositoryProvider)
      .watchSyncMetadata(catalogResourceKey),
  retry: (retryCount, error) => null,
);

final catalogSyncControllerProvider =
    NotifierProvider<CatalogSyncController, AsyncValue<void>>(
      CatalogSyncController.new,
    );

class CatalogSyncController extends Notifier<AsyncValue<void>> {
  bool _restartOnRetry = false;

  @override
  AsyncValue<void> build() {
    ref.watch(pokemonSyncProvider);
    // Arranca una vez por alcance sin esperar la descarga para pintar la UI.
    unawaited(Future.microtask(synchronize));
    return const AsyncLoading();
  }

  Future<void> synchronize() async {
    if (!ref.mounted) return;
    state = const AsyncLoading();
    try {
      // El coordinador comparte el mismo intento si recibe varias llamadas.
      await ref.read(pokemonSyncProvider).synchronize(restart: _restartOnRetry);
      _restartOnRetry = false;
      if (ref.mounted) state = const AsyncData(null);
    } catch (error, stackTrace) {
      // Tambien atiende el fallo si SQLite no pudo guardar la metadata de error.
      _restartOnRetry =
          error is SyncFailure && error.kind == SyncFailureKind.invalidResponse;
      if (ref.mounted) state = AsyncError(error, stackTrace);
    }
  }

  Future<void> retry() {
    if (ref.read(localCatalogProvider).hasError) {
      ref.invalidate(localCatalogProvider);
    }
    if (ref.read(catalogMetadataProvider).hasError) {
      ref.invalidate(catalogMetadataProvider);
    }
    return synchronize();
  }
}

// La lista y la metadata se leen solo del repositorio local.
final pokemonCatalogStateProvider = Provider<PokemonCatalogState>((ref) {
  final catalog = ref.watch(localCatalogProvider);
  final metadata = ref.watch(catalogMetadataProvider);
  final sync = ref.watch(catalogSyncControllerProvider);
  final pokemon = catalog.value ?? const <Pokemon>[];
  String? errorMessage;
  if (catalog.hasError || metadata.hasError) {
    errorMessage = 'No se pudo leer el catalogo local.';
  } else if (sync.hasError) {
    final error = sync.error;
    errorMessage = error is SyncFailure
        ? error.message
        : 'No se pudo actualizar el catalogo.';
  } else if (!sync.isLoading && metadata.value?.status == SyncStatus.failed) {
    errorMessage = 'No se pudo actualizar el catalogo.';
  }
  final isSyncing =
      sync.isLoading ||
      (!sync.hasError && metadata.value?.status == SyncStatus.syncing);
  final PokemonCatalogStatus status;
  if (pokemon.isNotEmpty) {
    status = PokemonCatalogStatus.data;
  } else if (errorMessage != null) {
    status = PokemonCatalogStatus.error;
  } else if (catalog.isLoading || isSyncing) {
    status = PokemonCatalogStatus.loading;
  } else {
    status = PokemonCatalogStatus.empty;
  }
  return PokemonCatalogState(
    status: status,
    pokemon: pokemon,
    isSyncing: isSyncing,
    errorMessage: errorMessage,
  );
});
