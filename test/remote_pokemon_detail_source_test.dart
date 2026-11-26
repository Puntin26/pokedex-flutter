import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:graphql/client.dart';
import 'package:pokedex/core/domain/sync_failure.dart';
import 'package:pokedex/core/network/pokeapi_graphql_client.dart';
import 'package:pokedex/features/pokemon/data/pokemon_detail_dto.dart';
import 'package:pokedex/features/pokemon/data/remote_pokemon_detail_source.dart';

import 'support/detail_response.dart';

void main() {
  late HttpServer server;
  late GraphQLClient client;
  late GraphqlPokemonDetailSource source;
  late List<Map<String, dynamic>> requests;
  var status = 200;
  Object body = {};

  setUp(() async {
    requests = [];
    status = 200;
    body = {'data': detailResponse(detailRow())};
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      requests.add(
        jsonDecode(await utf8.decoder.bind(request).join())
            as Map<String, dynamic>,
      );
      request.response.statusCode = status;
      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode(body));
      await request.response.close();
    });
    client = createPokeApiClient(endpoint: 'http://127.0.0.1:${server.port}');
    source = GraphqlPokemonDetailSource(client);
  });
  tearDown(() async {
    await client.link.dispose();
    await server.close(force: true);
  });

  test('Pide el detalle por ID con los campos verificados', () async {
    final data = await source.fetchDetail(133);
    expect(requests.single['variables'], {'id': 133});
    final query = requests.single['query'] as String;
    for (final field in [
      'pokemonstats',
      'abilityeffecttexts',
      'front_shiny',
      'pokemonegggroups',
      'evolutionchain',
      'pokemonevolutions',
      'movelearnmethod',
      'versiongroup',
      // Campos del catalogo: PA-02 abre Pokemon no guardados.
      'pokemonstats_aggregate',
      'pokemontypes',
    ]) {
      expect(query, contains(field));
    }
    expect(
      PokemonDetailDto.fromJson(
        data,
        pokemonId: 133,
      ).toDomain(DateTime.utc(2026)).moves,
      hasLength(7),
    );
  });

  test('Traduce los errores igual que el catalogo', () async {
    status = 503;
    await expectLater(
      source.fetchDetail(133),
      throwsA(
        isA<SyncFailure>().having(
          (failure) => failure.kind,
          'kind',
          SyncFailureKind.serviceUnavailable,
        ),
      ),
    );
    status = 429;
    await expectLater(
      source.fetchTypeEfficacy(),
      throwsA(
        isA<SyncFailure>().having(
          (failure) => failure.kind,
          'kind',
          SyncFailureKind.rateLimited,
        ),
      ),
    );
  });

  test('Rechaza un ID invalido sin llamar a la red', () {
    expect(() => source.fetchDetail(0), throwsArgumentError);
    expect(requests, isEmpty);
  });
}
