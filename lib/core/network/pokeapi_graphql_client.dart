import 'dart:async';

import 'package:graphql/client.dart';

const pokeApiEndpoint = 'https://graphql.pokeapi.co/v1beta2';
const catalogRequestTimeout = Duration(seconds: 30);

GraphQLClient createPokeApiClient({
  String endpoint = pokeApiEndpoint,
  Duration timeout = catalogRequestTimeout,
  Link? transport,
}) {
  final timeoutLink = Link.function((request, [forward]) {
    // Cierra la espera al fallar para ignorar respuestas que lleguen tarde.
    return forward!(request).timeout(
      timeout,
      onTimeout: (sink) {
        sink.addError(TimeoutException('GraphQL excedio el tiempo de espera.'));
        sink.close();
      },
    );
  });
  return GraphQLClient(
    link: timeoutLink.concat(transport ?? HttpLink(endpoint)),
    cache: GraphQLCache(store: InMemoryStore()),
    queryRequestTimeout: null,
  );
}
