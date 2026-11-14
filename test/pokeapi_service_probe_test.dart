import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:graphql/client.dart';
import 'package:pokedex/core/network/pokeapi_graphql_client.dart';
import 'package:pokedex/core/network/pokeapi_service_probe.dart';

void main() {
  test('La comprobacion consulta el servicio cada vez sin cache', () async {
    var calls = 0;
    final client = createPokeApiClient(
      transport: Link.function((request, [forward]) {
        calls++;
        expect(
          request.operation.document,
          equals(gql('query ServiceHealth { __typename }')),
        );
        return Stream.value(
          Response(
            data: const {'__typename': 'query_root'},
            response: const {},
          ),
        );
      }),
    );
    addTearDown(client.link.dispose);
    final probe = PokeApiServiceProbe(client);
    expect(await probe.isAvailable(), isTrue);
    expect(await probe.isAvailable(), isTrue);
    expect(calls, 2);
    expect(client.cache.store.toMap(), isEmpty);
  });

  test('Rechaza errores GraphQL y respuestas invalidas', () async {
    for (final response in [
      Response(data: const {}, response: const {}),
      Response(data: const {'__typename': ''}, response: const {}),
      Response(
        data: const {'__typename': 'query_root'},
        errors: [const GraphQLError(message: 'Fallo parcial')],
        response: const {},
      ),
    ]) {
      final client = createPokeApiClient(
        transport: Link.function(
          (request, [forward]) => Stream.value(response),
        ),
      );
      expect(await PokeApiServiceProbe(client).isAvailable(), isFalse);
      await client.link.dispose();
    }
  });

  test('Un servicio sin respuesta termina por timeout', () async {
    final pending = StreamController<Response>();
    final client = createPokeApiClient(
      timeout: const Duration(milliseconds: 20),
      transport: Link.function((request, [forward]) => pending.stream),
    );
    expect(await PokeApiServiceProbe(client).isAvailable(), isFalse);
    await pending.close();
    await client.link.dispose();
  });
}
