import 'dart:async';

import 'package:graphql/client.dart';

const pokeApiEndpoint = String.fromEnvironment(
  'POKEAPI_ENDPOINT',
  defaultValue: 'https://graphql.pokeapi.co/v1beta2',
);
const catalogRequestTimeout = Duration(seconds: 30);
// Puerto cerrado en el propio dispositivo: falla al instante como API inaccesible (PA-08).
const unreachableEndpoint = 'https://127.0.0.1:1';

GraphQLClient createPokeApiClient({
  String endpoint = pokeApiEndpoint,
  Duration timeout = catalogRequestTimeout,
  Link? transport,
  bool Function()? simulateOutage,
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
    link: timeoutLink.concat(
      _withOutageSimulation(transport ?? HttpLink(endpoint), simulateOutage),
    ),
    cache: GraphQLCache(store: InMemoryStore()),
    queryRequestTimeout: null,
  );
}

// Se decide en cada peticion, asi el interruptor de depuracion actua sin reiniciar.
Link _withOutageSimulation(Link transport, bool Function()? simulateOutage) {
  if (simulateOutage == null) return transport;
  return Link.split(
    (_) => simulateOutage(),
    HttpLink(unreachableEndpoint),
    transport,
  );
}
