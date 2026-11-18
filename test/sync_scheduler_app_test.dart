import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/app/app.dart';
import 'package:pokedex/app/connection_status_provider.dart';
import 'package:pokedex/app/pokemon_dependencies.dart';
import 'package:pokedex/core/connectivity/connection_monitor.dart';
import 'package:pokedex/core/database/app_database.dart';
import 'package:pokedex/features/pokemon/data/local_pokemon_repository.dart';
import 'package:pokedex/features/pokemon/data/pokemon_sync_coordinator.dart';
import 'package:pokedex/features/pokemon/data/remote_pokemon_source.dart';

import 'support/catalog_response.dart';

class CountingRemote implements RemotePokemonSource {
  final offsets = <int>[];

  @override
  Future<Map<String, dynamic>> fetchPage({
    required int limit,
    required int offset,
  }) async {
    offsets.add(offset);
    return catalogResponse([catalogRow(1), catalogRow(2)], total: 2);
  }
}

void main() {
  testWidgets('Al recuperar la conexion sincroniza sola una vez (PA-07)', (
    tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    final changes = StreamController<bool>.broadcast();
    final remote = CountingRemote();
    var network = false;
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        pokemonSyncProvider.overrideWithValue(
          PokemonSyncCoordinator(
            remote: remote,
            local: LocalPokemonRepository(database),
          ),
        ),
        connectionMonitorProvider.overrideWithValue(
          ConnectionMonitor(
            hasNetwork: () async => network,
            networkChanges: changes.stream,
            isServiceAvailable: () async => true,
          ),
        ),
      ],
    );
    addTearDown(() async {
      container.dispose();
      await changes.close();
      await database.close();
    });

    Future<void> settle() async {
      for (var i = 0; i < 20; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 10)),
        );
        await tester.pump();
      }
    }

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const PokedexApp(),
      ),
    );
    await settle();
    expect(container.read(connectionStatusProvider), ConnectionStatus.offline);
    // Solo la sync de arranque del catalogo.
    expect(remote.offsets, [0]);

    network = true;
    changes.add(true);
    await settle();
    expect(container.read(connectionStatusProvider), ConnectionStatus.online);
    expect(remote.offsets, [0, 0]);

    // Otro evento con red sin haber caido no vuelve a descargar.
    changes.add(true);
    await settle();
    expect(remote.offsets, [0, 0]);
  });
}
