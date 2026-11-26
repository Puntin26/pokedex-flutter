import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graphql/client.dart';
import 'package:pokedex/app/api_outage_simulation.dart';
import 'package:pokedex/app/connection_status_provider.dart';
import 'package:pokedex/app/pokemon_dependencies.dart';
import 'package:pokedex/core/connectivity/connection_monitor.dart';
import 'package:pokedex/core/domain/sync_activity.dart';
import 'package:pokedex/core/domain/sync_failure.dart';
import 'package:pokedex/core/network/pokeapi_graphql_client.dart';
import 'package:pokedex/core/network/pokeapi_service_probe.dart';
import 'package:pokedex/features/pokemon/data/remote_pokemon_source.dart';
import 'package:pokedex/features/pokemon/domain/pokemon_sync.dart';
import 'package:pokedex/features/pokemon/presentation/pokemon_catalog_controller.dart';

import 'support/catalog_response.dart';

class CountingSync implements PokemonSync {
  int calls = 0;

  @override
  Future<void> synchronize({bool restart = false}) async => calls++;
  @override
  SyncActivity get activity => SyncActivity.idle;
  @override
  Stream<SyncActivity> watchActivity() => Stream.value(SyncActivity.idle);
}

void main() {
  group('Cliente GraphQL con simulacion de caida', () {
    late HttpServer server;
    late int requests;
    var simulate = false;
    late GraphQLClient client;

    setUp(() async {
      requests = 0;
      simulate = false;
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      server.listen((request) async {
        requests++;
        await utf8.decoder.bind(request).join();
        request.response.headers.contentType = ContentType.json;
        request.response.write(
          jsonEncode({
            'data': {
              ...catalogResponse([catalogRow(1)], total: 1),
              '__typename': 'query_root',
            },
          }),
        );
        await request.response.close();
      });
      client = createPokeApiClient(
        endpoint: 'http://127.0.0.1:${server.port}',
        simulateOutage: () => simulate,
      );
    });
    tearDown(() async {
      await client.link.dispose();
      await server.close(force: true);
    });

    test('Activa: falla como red caida sin llegar al servidor', () async {
      simulate = true;
      await expectLater(
        GraphqlPokemonSource(client).fetchPage(limit: 1, offset: 0),
        throwsA(
          isA<SyncFailure>().having(
            (failure) => failure.kind,
            'kind',
            SyncFailureKind.network,
          ),
        ),
      );
      expect(await PokeApiServiceProbe(client).isAvailable(), isFalse);
      expect(requests, 0);
    });

    test('Se puede desactivar en caliente y vuelve a responder', () async {
      simulate = true;
      expect(await PokeApiServiceProbe(client).isAvailable(), isFalse);
      simulate = false;
      expect(await PokeApiServiceProbe(client).isAvailable(), isTrue);
      final data = await GraphqlPokemonSource(client)
          .fetchPage(limit: 1, offset: 0);
      expect(data['pokemon'], hasLength(1));
      expect(requests, 2);
    });
  });

  test('toggle revisa la conexion y pide una actualizacion', () async {
    var probes = 0;
    final sync = CountingSync();
    final container = ProviderContainer(
      overrides: [
        pokemonSyncProvider.overrideWithValue(sync),
        connectionMonitorProvider.overrideWithValue(
          ConnectionMonitor(
            hasNetwork: () async => true,
            networkChanges: const Stream.empty(),
            isServiceAvailable: () async {
              probes++;
              return true;
            },
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    container.listen(connectionStatusProvider, (_, _) {});
    container.listen(catalogSyncControllerProvider, (_, _) {});
    await pumpEventQueue();
    final probesBefore = probes;
    final syncsBefore = sync.calls;

    container.read(apiOutageSimulationProvider.notifier).toggle();
    await pumpEventQueue();
    expect(container.read(apiOutageSimulationProvider), isTrue);
    expect(probes, probesBefore + 1);
    expect(sync.calls, syncsBefore + 1);

    container.read(apiOutageSimulationProvider.notifier).toggle();
    await pumpEventQueue();
    expect(container.read(apiOutageSimulationProvider), isFalse);
    // Al apagarla solo revisa; la sync la dispara el scheduler al ver la recuperacion.
    expect(probes, probesBefore + 2);
    expect(sync.calls, syncsBefore + 1);
  });
}
