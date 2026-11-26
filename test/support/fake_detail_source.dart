import 'package:pokedex/core/domain/sync_failure.dart';
import 'package:pokedex/features/pokemon/data/remote_pokemon_detail_source.dart';
import 'package:pokedex/features/pokemon/domain/pokemon_detail_sync.dart';

import 'detail_response.dart';

class FakeDetailSource implements RemotePokemonDetailSource {
  Future<Map<String, dynamic>> Function(int id) detail = (id) async =>
      detailResponse(detailRow());
  Future<Map<String, dynamic>> Function() efficacy = () async =>
      typeEfficacyResponse();
  final detailCalls = <int>[];
  int efficacyCalls = 0;

  @override
  Future<Map<String, dynamic>> fetchDetail(int pokemonId) {
    detailCalls.add(pokemonId);
    return detail(pokemonId);
  }

  @override
  Future<Map<String, dynamic>> fetchTypeEfficacy() {
    efficacyCalls++;
    return efficacy();
  }
}

/// Por defecto en el arnes: ninguna prueba toca la red real por descuido.
class NoNetworkDetailSync implements PokemonDetailSync {
  @override
  Future<void> synchronize(int pokemonId) async =>
      throw const SyncFailure(SyncFailureKind.network, 'Sin conexion.');
}
