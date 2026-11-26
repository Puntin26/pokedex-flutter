import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/sync_metadata_store.dart';
import '../../../core/domain/sync_metadata.dart';
import '../domain/catalog_query.dart';
import '../domain/pokemon.dart';
import '../domain/pokemon_repository.dart';
import 'pokemon_row_mapper.dart';
import 'pokemon_writer.dart';

class LocalPokemonRepository implements PokemonRepository {
  LocalPokemonRepository(this.database)
    : _writer = PokemonWriter(database),
      _metadata = SyncMetadataStore(database);

  final AppDatabase database;
  final PokemonWriter _writer;
  final SyncMetadataStore _metadata;

  @override
  Stream<List<Pokemon>> watchCatalog([
    CatalogQuery query = const CatalogQuery(),
  ]) {
    final pokemon = database.pokemonRecords;
    final links = database.pokemonTypeLinks;
    final types = database.pokemonTypes;
    final species = database.pokemonSpecies;
    final generations = database.generations;
    final select = database.select(pokemon).join([
      leftOuterJoin(links, links.pokemonId.equalsExp(pokemon.id)),
      leftOuterJoin(types, types.id.equalsExp(links.typeId)),
      leftOuterJoin(species, species.id.equalsExp(pokemon.speciesId)),
      leftOuterJoin(
        generations,
        generations.id.equalsExp(species.generationId),
      ),
    ]);

    // Todo el filtrado y el orden ocurre en SQLite, no en Dart (RNF-REN-02).
    final search = query.normalizedSearch;
    if (search.isNotEmpty) {
      select.where(
        pokemon.name.like('%${_escapeLike(search)}%', escapeChar: r'\'),
      );
    }
    final typeId = query.typeId;
    if (typeId != null) {
      // EXISTS y no un where sobre el join: asi el Pokemon conserva sus dos tipos.
      final filter = database.alias(links, 'type_filter');
      select.where(
        existsQuery(
          database.select(filter)..where(
            (row) =>
                row.pokemonId.equalsExp(pokemon.id) & row.typeId.equals(typeId),
          ),
        ),
      );
    }
    final abilityId = query.abilityId;
    if (abilityId != null) {
      final filter = database.alias(
        database.pokemonAbilities,
        'ability_filter',
      );
      select.where(
        existsQuery(
          database.select(filter)..where(
            (row) =>
                row.pokemonId.equalsExp(pokemon.id) &
                row.abilityId.equals(abilityId),
          ),
        ),
      );
    }
    final generationId = query.generationId;
    if (generationId != null) {
      select.where(species.generationId.equals(generationId));
    }

    OrderingTerm by(Expression expression, {NullsOrder? nulls}) =>
        query.descending
        ? OrderingTerm.desc(expression, nulls: nulls)
        : OrderingTerm.asc(expression, nulls: nulls);
    select.orderBy([
      switch (query.sort) {
        CatalogSort.number => by(pokemon.nationalNumber),
        CatalogSort.name => by(pokemon.name),
        // Sin total (fila aun no sincronizada) siempre al final.
        CatalogSort.baseStatTotal => by(
          pokemon.baseStatTotal,
          nulls: NullsOrder.last,
        ),
      },
      // Desempate estable; slot mantiene el orden de tipos para el mapper.
      OrderingTerm.asc(pokemon.nationalNumber),
      OrderingTerm.asc(pokemon.id),
      OrderingTerm.asc(links.slot),
    ]);
    return select.watch().map((rows) => mapPokemonRows(rows, database));
  }

  // Solo las habilidades que tiene algun Pokemon guardado, por nombre.
  @override
  Stream<List<Ability>> watchAbilities() {
    final abilities = database.abilities;
    final links = database.pokemonAbilities;
    final query = database.selectOnly(abilities, distinct: true)
      ..addColumns([abilities.id, abilities.name])
      ..join([innerJoin(links, links.abilityId.equalsExp(abilities.id))])
      ..orderBy([OrderingTerm.asc(abilities.name)]);
    return query.watch().map(
      (rows) => rows
          .map(
            (row) => Ability(
              id: row.read(abilities.id)!,
              name: row.read(abilities.name)!,
            ),
          )
          .toList(),
    );
  }

  @override
  Stream<List<Generation>> watchGenerations() {
    final query = database.select(database.generations)
      ..orderBy([(table) => OrderingTerm.asc(table.id)]);
    return query.watch().map(
      (rows) => rows
          .map(
            (row) => Generation(
              id: row.id,
              name: row.name,
              regionName: row.regionName,
            ),
          )
          .toList(),
    );
  }

  // Solo tipos que tiene algun Pokemon: los de movimientos (shadow) no filtran.
  @override
  Stream<List<PokemonType>> watchTypes() {
    final types = database.pokemonTypes;
    final links = database.pokemonTypeLinks;
    final query = database.selectOnly(types, distinct: true)
      ..addColumns([types.id, types.name])
      ..join([innerJoin(links, links.typeId.equalsExp(types.id))])
      ..orderBy([OrderingTerm.asc(types.name)]);
    return query.watch().map(
      (rows) => rows
          .map(
            (row) => PokemonType(
              id: row.read(types.id)!,
              name: row.read(types.name)!,
            ),
          )
          .toList(),
    );
  }

  @override
  Stream<SyncMetadata?> watchSyncMetadata(String resourceKey) =>
      _metadata.watch(resourceKey);

  @override
  Future<SyncMetadata?> readSyncMetadata(String resourceKey) =>
      _metadata.read(resourceKey);

  @override
  Future<void> savePage(List<Pokemon> pokemon, SyncMetadata metadata) {
    return database.transaction(() async {
      for (final item in pokemon) {
        await _writer.upsertPokemon(item);
      }
      // El offset solo cambia si se confirma la pagina completa.
      await _metadata.save(metadata);
    });
  }

  @override
  Future<void> updateSyncStatus(
    String resourceKey,
    SyncStatus status, {
    String? lastError,
  }) => _metadata.updateStatus(resourceKey, status, lastError: lastError);
}

// El texto del usuario se busca literal: %, _ y \ no actuan como comodines.
String _escapeLike(String value) =>
    value.replaceAllMapped(RegExp(r'[\\%_]'), (match) => '\\${match[0]}');
