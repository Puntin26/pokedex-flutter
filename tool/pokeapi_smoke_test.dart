import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/core/database/app_database.dart';
import 'package:pokedex/core/domain/sync_metadata.dart';
import 'package:pokedex/core/network/pokeapi_graphql_client.dart';
import 'package:pokedex/features/favorites/data/local_favorites_repository.dart';
import 'package:pokedex/features/pokemon/data/local_pokemon_repository.dart';
import 'package:pokedex/features/pokemon/data/pokemon_page_dto.dart';
import 'package:pokedex/features/pokemon/data/pokemon_sync_coordinator.dart';
import 'package:pokedex/features/pokemon/data/remote_pokemon_source.dart';

// Comprobacion manual: no forma parte de la suite automatizada sin Internet.
void main() {
  test('PokeAPI real: dos paginas pequenas se mapean y guardan en SQLite', () async {
    final client = createPokeApiClient();
    final database = AppDatabase(NativeDatabase.memory());
    final local = LocalPokemonRepository(database);
    final favorites = LocalFavoritesRepository(database);
    final remote = GraphqlPokemonSource(client);
    const resource = PokemonSyncCoordinator.resourceKey;
    addTearDown(database.close);
    addTearDown(client.link.dispose);

    var offset = 0;
    int? total;
    PokemonPageDto? firstPage;
    for (var pageNumber = 0; pageNumber < 2; pageNumber++) {
      final data = await remote.fetchPage(limit: 2, offset: offset);
      final page = PokemonPageDto.fromJson(data, limit: 2, offset: offset);
      firstPage ??= page;
      expect(total == null || page.totalCount == total, isTrue);
      total = page.totalCount;
      offset += page.pokemon.length;
      await local.savePage(
        page.toDomain(DateTime.now().toUtc()),
        SyncMetadata(
          resourceKey: resource,
          nextOffset: offset,
          totalCount: total,
          status: SyncStatus.idle,
          lastSuccessAt: DateTime.now().toUtc(),
          isComplete: offset == total,
        ),
      );
    }
    final catalog = await local.watchCatalog().first;
    expect(catalog, hasLength(4));
    expect(catalog.map((item) => item.id).toSet(), hasLength(4));
    expect(catalog.first.name, 'bulbasaur');
    expect(catalog.first.nationalNumber, 1);
    expect(catalog.first.types.map((entry) => entry.type.name), [
      'grass',
      'poison',
    ]);
    expect(catalog.first.imageUrl, startsWith('https://'));
    // 2.3: especie, generacion/region y total de stats llegan de la API real.
    expect(catalog.first.baseStatTotal, 318);
    expect(catalog.first.isDefault, isTrue);
    expect(catalog.first.height, 7);
    expect(catalog.first.species!.id, 1);
    expect(catalog.first.species!.generation!.id, 1);
    expect(catalog.first.species!.generation!.regionName, 'kanto');
    await favorites.addFavorite(catalog.first.id, DateTime.utc(2026));
    final metadata = (await local.readSyncMetadata(resource))!;
    await local.savePage(firstPage!.toDomain(DateTime.now().toUtc()), metadata);
    expect(await local.watchCatalog().first, hasLength(4));
    expect(await favorites.watchFavorites().first, hasLength(1));
    expect(metadata.nextOffset, 4);
    expect(metadata.isComplete, isFalse);
    // ignore: avoid_print
    print(
      'PokeAPI: 2 solicitudes, 4 Pokemon en SQLite, total $total, offset $offset, favorito conservado.',
    );
  }, timeout: const Timeout(Duration(seconds: 90)));
}
