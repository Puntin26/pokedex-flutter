import 'package:graphql/client.dart';

class PokeApiServiceProbe {
  PokeApiServiceProbe(this.client);

  final GraphQLClient client;

  static final _query = gql('query ServiceHealth { __typename }');

  Future<bool> isAvailable() async {
    // El monitor maneja los errores de esta consulta.
    final result = await client.query(
      QueryOptions(document: _query, fetchPolicy: FetchPolicy.noCache),
    );
    final typeName = result.data?['__typename'];
    return !result.hasException && typeName is String && typeName.isNotEmpty;
  }
}
