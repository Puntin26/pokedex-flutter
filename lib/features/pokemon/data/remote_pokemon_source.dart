import 'dart:async';

import 'package:graphql/client.dart';

import '../../../core/domain/sync_failure.dart';

abstract interface class RemotePokemonSource {
  Future<Map<String, dynamic>> fetchPage({
    required int limit,
    required int offset,
  });
}

class GraphqlPokemonSource implements RemotePokemonSource {
  GraphqlPokemonSource(this.client);

  final GraphQLClient client;

  static final catalogQuery = gql(r'''
    query PokemonCatalog($limit: Int!, $offset: Int!) {
      pokemon(limit: $limit, offset: $offset, order_by: {id: asc}) {
        id
        name
        height
        weight
        is_default
        pokemon_species_id
        pokemonspecy {
          id
          name
          generation { id name region { name } }
        }
        # Solo el total: el servidor suma y no se bajan las 6 stats por Pokemon.
        pokemonstats_aggregate { aggregate { sum { base_stat } } }
        pokemontypes(order_by: {slot: asc}) {
          slot
          type { id name }
        }
        pokemonsprites {
          artwork: sprites(path: "other.official-artwork.front_default")
          front: sprites(path: "front_default")
        }
      }
      pokemon_aggregate { aggregate { count } }
    }
  ''');

  @override
  Future<Map<String, dynamic>> fetchPage({
    required int limit,
    required int offset,
  }) async {
    if (limit < 1 || limit > 100 || offset < 0) {
      throw ArgumentError(
        'limit debe estar entre 1 y 100; offset debe ser no negativo.',
      );
    }
    final result = await client.query(
      QueryOptions(
        document: catalogQuery,
        variables: {'limit': limit, 'offset': offset},
        // SQLite es la unica fuente de datos persistidos del catalogo.
        fetchPolicy: FetchPolicy.noCache,
        errorPolicy: ErrorPolicy.all,
      ),
    );
    final exception = result.exception;
    if (exception != null) {
      final linkError = exception.linkException;
      final statusCode = switch (linkError) {
        HttpLinkServerException error => error.statusCode,
        HttpLinkParserException error => error.response.statusCode,
        _ => null,
      };
      if (statusCode == 429) {
        throw const SyncFailure(
          SyncFailureKind.rateLimited,
          'Limite de solicitudes de PokeAPI alcanzado.',
        );
      }
      if (linkError?.originalException is TimeoutException) {
        throw const SyncFailure(
          SyncFailureKind.timeout,
          'GraphQL excedio el tiempo de espera.',
        );
      }
      if (linkError is NetworkException ||
          (linkError is ServerException &&
              linkError.parsedResponse == null &&
              statusCode == null)) {
        throw const SyncFailure(
          SyncFailureKind.network,
          'No se pudo conectar con GraphQL.',
        );
      }
      if (statusCode != null && statusCode >= 300) {
        throw const SyncFailure(
          SyncFailureKind.serviceUnavailable,
          'El servicio GraphQL no esta disponible.',
        );
      }
      // Incluso con data, los errores GraphQL invalidan toda la pagina.
      if (exception.graphqlErrors.isNotEmpty) {
        throw const SyncFailure(
          SyncFailureKind.graphql,
          'GraphQL devolvio errores o datos parciales.',
        );
      }
      throw const SyncFailure(
        SyncFailureKind.invalidResponse,
        'La respuesta GraphQL no es valida.',
      );
    }
    final data = result.data;
    if (data == null) {
      throw const SyncFailure(
        SyncFailureKind.invalidResponse,
        'GraphQL no devolvio datos.',
      );
    }
    return data;
  }
}
