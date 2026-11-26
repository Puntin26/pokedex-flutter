import 'package:graphql/client.dart';

import '../../../core/network/pokeapi_query.dart';

abstract interface class RemotePokemonSource {
  Future<Map<String, dynamic>> fetchPage({
    required int limit,
    required int offset,
  });
}

class GraphqlPokemonSource implements RemotePokemonSource {
  GraphqlPokemonSource(this.client);

  final GraphQLClient client;

  static const catalogQuery = r'''
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
        pokemonabilities(order_by: {slot: asc}) {
          slot
          is_hidden
          ability { id name }
        }
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
  ''';

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
    return queryPokeApi(
      client,
      catalogQuery,
      variables: {'limit': limit, 'offset': offset},
    );
  }
}
