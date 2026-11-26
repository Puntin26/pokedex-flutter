import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/core/database/app_database.dart';
import 'package:pokedex/core/domain/sync_metadata.dart';
import 'package:pokedex/core/network/pokeapi_graphql_client.dart';
import 'package:pokedex/features/favorites/data/local_favorites_repository.dart';
import 'package:pokedex/features/pokemon/data/local_pokemon_detail_repository.dart';
import 'package:pokedex/features/pokemon/data/local_pokemon_repository.dart';
import 'package:pokedex/features/pokemon/data/pokemon_detail_sync_coordinator.dart';
import 'package:pokedex/features/pokemon/data/pokemon_page_dto.dart';
import 'package:pokedex/features/pokemon/data/remote_pokemon_detail_source.dart';
import 'package:pokedex/features/pokemon/data/pokemon_sync_coordinator.dart';
import 'package:pokedex/features/pokemon/data/remote_pokemon_source.dart';
import 'package:pokedex/features/pokemon/domain/catalog_query.dart';
import 'package:pokedex/features/pokemon/domain/move_query.dart';

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
    // 2.9: habilidades reales; los 4 primeros: 3 con overgrow, charmander no.
    final abilities = await local.watchAbilities().first;
    final overgrow = abilities.firstWhere((item) => item.name == 'overgrow');
    expect(abilities.map((item) => item.name), contains('chlorophyll'));
    final withOvergrow = await local
        .watchCatalog(CatalogQuery(abilityId: overgrow.id))
        .first;
    expect(withOvergrow.map((item) => item.id), [1, 2, 3]);
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

  test(
    'PokeAPI real: detalle de eevee y bulbasaur se valida y se guarda',
    () async {
      final client = createPokeApiClient();
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      addTearDown(client.link.dispose);
      final repository = LocalPokemonDetailRepository(database);
      final sync = PokemonDetailSyncCoordinator(
        remote: GraphqlPokemonDetailSource(client),
        local: repository,
      );

      await sync.synchronize(133);
      final eevee = (await repository.watchDetail(133).first)!;
      expect(eevee.pokemon.name, 'eevee');
      expect(eevee.stats, hasLength(6));
      expect(eevee.pokemon.shinyImageUrl, contains('shiny'));
      expect(eevee.evolutions.length, greaterThanOrEqualTo(8));
      expect(eevee.abilities.where((entry) => entry.isHidden), isNotEmpty);
      expect(eevee.versionGroups, isNotEmpty);
      expect(await repository.watchTypeEfficacy().first, hasLength(324));

      // Bulbasaur tiene vine-whip dos veces en sun-moon (niveles 7 y 9).
      await sync.synchronize(1);
      final bulbasaur = (await repository.watchDetail(1).first)!;
      final sunMoon = bulbasaur.versionGroups.firstWhere(
        (group) => group.name == 'sun-moon',
      );
      final moves = await repository
          .watchMoves(MoveQuery(pokemonId: 1, versionGroupId: sunMoon.id))
          .first;
      expect(
        moves
            .where((move) => move.name == 'vine-whip')
            .map((move) => move.level),
        [7, 9],
      );
    },
  );
}
