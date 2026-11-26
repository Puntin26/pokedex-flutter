import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/database/app_database.dart';
import '../core/domain/sync_activity.dart';
import '../core/network/pokeapi_graphql_client.dart';
import '../core/sync/retry_policy.dart';
import '../features/pokemon/data/local_pokemon_detail_repository.dart';
import '../features/pokemon/data/local_pokemon_repository.dart';
import '../features/pokemon/data/pokemon_detail_sync_coordinator.dart';
import '../features/pokemon/data/remote_pokemon_detail_source.dart';
import '../features/pokemon/data/pokemon_sync_coordinator.dart';
import '../features/pokemon/data/remote_pokemon_source.dart';
import '../features/pokemon/domain/pokemon_detail_repository.dart';
import '../features/pokemon/domain/pokemon_detail_sync.dart';
import '../features/pokemon/domain/pokemon_repository.dart';
import '../features/pokemon/domain/pokemon_sync.dart';
import 'api_outage_simulation.dart';

// Estas instancias viven en el ProviderScope, no en cada widget.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(() => unawaited(database.close()));
  return database;
});

final pokeApiClientProvider = Provider((ref) {
  final client = createPokeApiClient(
    simulateOutage: () => ref.read(apiOutageSimulationProvider),
  );
  ref.onDispose(client.link.dispose);
  return client;
});

final pokemonRepositoryProvider = Provider<PokemonRepository>((ref) {
  return LocalPokemonRepository(ref.watch(appDatabaseProvider));
});

final pokemonSyncProvider = Provider<PokemonSync>((ref) {
  final coordinator = PokemonSyncCoordinator(
    remote: GraphqlPokemonSource(ref.watch(pokeApiClientProvider)),
    local: ref.watch(pokemonRepositoryProvider),
    retryPolicy: RetryPolicy(),
  );
  ref.onDispose(() => unawaited(coordinator.dispose()));
  return coordinator;
});

// Actividad de sync del catalogo; la consume el indicador global (tarea 1.5).
final catalogSyncActivityProvider = StreamProvider<SyncActivity>(
  (ref) => ref.watch(pokemonSyncProvider).watchActivity(),
);

final pokemonDetailRepositoryProvider = Provider<PokemonDetailRepository>(
  (ref) => LocalPokemonDetailRepository(ref.watch(appDatabaseProvider)),
);

// Mismo cliente que el catalogo: el interruptor de PA-08 tambien lo afecta.
final pokemonDetailSyncProvider = Provider<PokemonDetailSync>(
  (ref) => PokemonDetailSyncCoordinator(
    remote: GraphqlPokemonDetailSource(ref.watch(pokeApiClientProvider)),
    local: ref.watch(pokemonDetailRepositoryProvider),
    retryPolicy: RetryPolicy(),
  ),
);
