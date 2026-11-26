import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:graphql/client.dart';
import 'package:pokedex/core/domain/sync_failure.dart';
import 'package:pokedex/core/network/pokeapi_graphql_client.dart';
import 'package:pokedex/features/pokemon/data/remote_pokemon_source.dart';

import 'support/catalog_response.dart';

void main() {
  late HttpServer server;
  late GraphQLClient client;
  late GraphqlPokemonSource source;
  late List<Map<String, dynamic>> requests;
  late List<String> methods;
  Object? body;
  var status = 200;

  setUp(() async {
    requests = [];
    methods = [];
    body = {
      'data': catalogResponse([catalogRow(1)], total: 1),
    };
    status = 200;
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      methods.add(request.method);
      requests.add(
        jsonDecode(await utf8.decoder.bind(request).join())
            as Map<String, dynamic>,
      );
      request.response.statusCode = status;
      request.response.headers.contentType = ContentType.json;
      request.response.write(body is String ? body : jsonEncode(body));
      await request.response.close();
    });
    client = createPokeApiClient(endpoint: 'http://127.0.0.1:${server.port}');
    source = GraphqlPokemonSource(client);
  });

  tearDown(() async {
    await client.link.dispose();
    await server.close(force: true);
  });

  test('Hace POST con variables y vuelve a red sin cache GraphQL', () async {
    await source.fetchPage(limit: 2, offset: 0);
    body = {
      'data': catalogResponse([catalogRow(1, name: 'updated')], total: 1),
    };
    final response = await source.fetchPage(limit: 2, offset: 0);
    expect((response['pokemon'] as List).single['name'], 'updated');
    expect(requests, hasLength(2));
    expect(methods, ['POST', 'POST']);
    expect(requests.first['variables'], {'limit': 2, 'offset': 0});
    expect(requests.first['query'], contains('order_by: {id: asc}'));
    // 2.3: especie con generacion/region y total de stats agregado en el servidor.
    for (final field in [
      'is_default',
      'height',
      'weight',
      'pokemonspecy',
      'region',
      'pokemonstats_aggregate',
    ]) {
      expect(requests.first['query'], contains(field));
    }
    expect(requests.first['query'], contains('pokemon_species_id'));
    expect(
      requests.first['query'],
      contains('other.official-artwork.front_default'),
    );
    expect(client.cache.store.toMap(), isEmpty);
  });

  test(
    'Rechaza errores GraphQL aunque haya datos y respuestas sin datos',
    () async {
      for (final response in [
        {
          'data': catalogResponse([catalogRow(1)], total: 1),
          'errors': [
            {'message': 'partial'},
          ],
        },
        {
          'errors': [
            {'message': 'failure'},
          ],
        },
      ]) {
        body = response;
        await expectLater(
          source.fetchPage(limit: 2, offset: 0),
          throwsA(
            isA<SyncFailure>().having(
              (error) => error.kind,
              'kind',
              SyncFailureKind.graphql,
            ),
          ),
        );
      }
    },
  );

  test('Distingue HTTP 429 con JSON o HTML y servicio no disponible', () async {
    for (final response in [
      <String, dynamic>{
        'errors': [
          {'message': 'rate limit'},
        ],
      },
      '<html>rate limit</html>',
    ]) {
      status = 429;
      body = response;
      await expectLater(
        source.fetchPage(limit: 2, offset: 0),
        throwsA(
          isA<SyncFailure>().having(
            (error) => error.kind,
            'kind',
            SyncFailureKind.rateLimited,
          ),
        ),
      );
    }
    status = 503;
    await expectLater(
      source.fetchPage(limit: 2, offset: 0),
      throwsA(
        isA<SyncFailure>().having(
          (error) => error.kind,
          'kind',
          SyncFailureKind.serviceUnavailable,
        ),
      ),
    );
  });

  test('Rechaza una respuesta HTTP malformada', () async {
    body = 'not json';
    await expectLater(
      source.fetchPage(limit: 2, offset: 0),
      throwsA(
        isA<SyncFailure>().having(
          (error) => error.kind,
          'kind',
          SyncFailureKind.invalidResponse,
        ),
      ),
    );
  });

  test('Distingue timeout y perdida de conexion', () async {
    // Un stream que permanece abierto simula un servidor sin respuesta.
    final pending = StreamController<Response>();
    final waitingClient = createPokeApiClient(
      transport: Link.function((request, [forward]) => pending.stream),
      timeout: const Duration(milliseconds: 20),
    );
    await expectLater(
      GraphqlPokemonSource(waitingClient).fetchPage(limit: 2, offset: 0),
      throwsA(
        isA<SyncFailure>().having(
          (error) => error.kind,
          'kind',
          SyncFailureKind.timeout,
        ),
      ),
    );
    pending.add(
      Response(
        data: catalogResponse([catalogRow(1)], total: 1),
        response: const {},
      ),
    );
    await pending.close();
    await waitingClient.link.dispose();
    await server.close(force: true);
    await expectLater(
      source.fetchPage(limit: 2, offset: 0),
      throwsA(
        isA<SyncFailure>().having(
          (error) => error.kind,
          'kind',
          SyncFailureKind.network,
        ),
      ),
    );
  });
}
