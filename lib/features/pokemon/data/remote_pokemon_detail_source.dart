import 'package:graphql/client.dart';

import '../../../core/network/pokeapi_query.dart';

abstract interface class RemotePokemonDetailSource {
  Future<Map<String, dynamic>> fetchDetail(int pokemonId);
  Future<Map<String, dynamic>> fetchTypeEfficacy();
}

class GraphqlPokemonDetailSource implements RemotePokemonDetailSource {
  GraphqlPokemonDetailSource(this.client);

  final GraphQLClient client;

  // Campos verificados contra PokeAPI v1beta2. Incluye los del catalogo para
  // validar la identidad con el mismo DTO (PA-02: puede no estar guardado).
  static const detailQuery = r'''
    query PokemonDetail($id: Int!) {
      pokemon(where: {id: {_eq: $id}}) {
        id
        name
        height
        weight
        is_default
        pokemon_species_id
        pokemonspecy {
          id
          name
          evolution_chain_id
          generation { id name region { name } }
          pokemonegggroups { egggroup { id name } }
          evolutionchain {
            pokemonspecies(order_by: {id: asc}) {
              id
              name
              evolves_from_species_id
              pokemonevolutions(order_by: {id: asc}) {
                is_default
                min_level
                min_happiness
                time_of_day
                evolutiontrigger { name }
                item { name }
              }
            }
          }
        }
        pokemonstats_aggregate { aggregate { sum { base_stat } } }
        pokemonstats(order_by: {stat_id: asc}) { base_stat stat { id name } }
        pokemonabilities(order_by: {slot: asc}) {
          slot
          is_hidden
          ability {
            id
            name
            abilityeffecttexts(where: {language_id: {_eq: 9}}) { short_effect }
          }
        }
        pokemontypes(order_by: {slot: asc}) { slot type { id name } }
        pokemonsprites {
          artwork: sprites(path: "other.official-artwork.front_default")
          front: sprites(path: "front_default")
          shinyArtwork: sprites(path: "other.official-artwork.front_shiny")
          shinyFront: sprites(path: "front_shiny")
        }
        pokemonmoves {
          level
          movelearnmethod { name }
          versiongroup { id name order }
          move { id name power accuracy type { id name } }
        }
      }
    }
  ''';

  static const typeEfficacyQuery = r'''
    query TypeEfficacy {
      typeefficacy(order_by: [{damage_type_id: asc}, {target_type_id: asc}]) {
        damage_type_id
        target_type_id
        damage_factor
      }
      type(order_by: {id: asc}) { id name }
    }
  ''';

  @override
  Future<Map<String, dynamic>> fetchDetail(int pokemonId) {
    if (pokemonId <= 0) throw ArgumentError.value(pokemonId, 'pokemonId');
    return queryPokeApi(client, detailQuery, variables: {'id': pokemonId});
  }

  @override
  Future<Map<String, dynamic>> fetchTypeEfficacy() =>
      queryPokeApi(client, typeEfficacyQuery);
}
