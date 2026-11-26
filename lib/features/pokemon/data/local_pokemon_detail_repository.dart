import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/sync_metadata_store.dart';
import '../../../core/domain/sync_metadata.dart';
import '../domain/move_query.dart';
import '../domain/pokemon.dart';
import '../domain/pokemon_detail.dart';
import '../domain/pokemon_detail_repository.dart';
import 'pokemon_detail_sync_coordinator.dart';
import 'pokemon_row_mapper.dart';
import 'pokemon_writer.dart';

class LocalPokemonDetailRepository implements PokemonDetailRepository {
  LocalPokemonDetailRepository(this.database)
    : _writer = PokemonWriter(database),
      _metadata = SyncMetadataStore(database);

  final AppDatabase database;
  final PokemonWriter _writer;
  final SyncMetadataStore _metadata;

  // Tablas que forman la vista del detalle: si cambia cualquiera tras un
  // commit, se vuelve a leer (la UI recibe lo nuevo sin recargar).
  late final Set<ResultSetImplementation> _detailTables = {
    database.pokemonRecords,
    database.pokemonTypeLinks,
    database.pokemonTypes,
    database.pokemonSpecies,
    database.generations,
    database.pokemonStats,
    database.stats,
    database.pokemonAbilities,
    database.abilities,
    database.speciesEggGroups,
    database.eggGroups,
    database.evolutions,
    database.pokemonMoves,
    database.versionGroups,
    database.syncMetadataRecords,
  };

  @override
  Stream<PokemonDetail?> watchDetail(int pokemonId) {
    final changes = Stream<void>.multi((listener) {
      listener.add(null);
      final subscription = database
          .tableUpdates(TableUpdateQuery.onAllTables(_detailTables))
          .listen((_) => listener.add(null));
      listener.onCancel = subscription.cancel;
    });
    // asyncMap procesa en orden: una lectura vieja no pisa una nueva.
    return changes.asyncMap((_) => _loadDetail(pokemonId));
  }

  Future<PokemonDetail?> _loadDetail(int pokemonId) async {
    final pokemon = await _loadPokemon((row) => row.id.equals(pokemonId))
        .then((items) => items.isEmpty ? null : items.single);
    if (pokemon == null) return null;

    final abilities = database.abilities;
    final links = database.pokemonAbilities;
    final abilityRows =
        await (database.select(links).join([
                innerJoin(abilities, abilities.id.equalsExp(links.abilityId)),
              ])
              ..where(links.pokemonId.equals(pokemonId))
              ..orderBy([OrderingTerm.asc(links.slot)]))
            .get();

    final stats = database.stats;
    final pokemonStats = database.pokemonStats;
    final statRows =
        await (database.select(pokemonStats).join([
                innerJoin(stats, stats.id.equalsExp(pokemonStats.statId)),
              ])
              ..where(pokemonStats.pokemonId.equals(pokemonId))
              ..orderBy([OrderingTerm.asc(pokemonStats.statId)]))
            .get();

    final speciesId = pokemon.species?.id;
    var eggGroups = <EggGroup>[];
    var members = <EvolutionMember>[];
    var steps = <EvolutionStep>[];
    var forms = <Pokemon>[pokemon];
    if (speciesId != null) {
      eggGroups = await _loadEggGroups(speciesId);
      forms = await _loadPokemon(
        (row) => row.speciesId.equals(speciesId),
        orderBy: [
          OrderingTerm.desc(database.pokemonRecords.isDefault),
          OrderingTerm.asc(database.pokemonRecords.id),
        ],
      );
      final species = await (database.select(
        database.pokemonSpecies,
      )..where((row) => row.id.equals(speciesId))).getSingleOrNull();
      final chainId = species?.evolutionChainId;
      if (chainId != null) (members, steps) = await _loadChain(chainId);
    }

    final groups = database.versionGroups;
    final moves = database.pokemonMoves;
    final groupRows =
        await (database.selectOnly(groups, distinct: true)
              ..addColumns([groups.id, groups.name, groups.sortOrder])
              ..join([
                innerJoin(moves, moves.versionGroupId.equalsExp(groups.id)),
              ])
              ..where(moves.pokemonId.equals(pokemonId))
              ..orderBy([OrderingTerm.asc(groups.sortOrder)]))
            .get();

    final metadata = await _metadata.read(
      PokemonDetailSyncCoordinator.resourceKey(pokemonId),
    );
    return PokemonDetail(
      pokemon: pokemon,
      abilities: [
        for (final row in abilityRows)
          PokemonAbility(
            ability: Ability(
              id: row.readTable(abilities).id,
              name: row.readTable(abilities).name,
              effectSummary: row.readTable(abilities).effectSummary,
            ),
            slot: row.readTable(links).slot,
            isHidden: row.readTable(links).isHidden,
          ),
      ],
      stats: [
        for (final row in statRows)
          PokemonStat(
            id: row.readTable(stats).id,
            name: row.readTable(stats).name,
            baseValue: row.readTable(pokemonStats).baseValue,
          ),
      ],
      eggGroups: eggGroups,
      evolutionMembers: members,
      evolutions: steps,
      forms: forms,
      versionGroups: [
        for (final row in groupRows)
          VersionGroup(
            id: row.read(groups.id)!,
            name: row.read(groups.name)!,
            sortOrder: row.read(groups.sortOrder)!,
          ),
      ],
      updatedAt: metadata?.lastSuccessAt,
    );
  }

  // Mismo join que el catalogo (tipos, especie, generacion) con otro filtro.
  Future<List<Pokemon>> _loadPokemon(
    Expression<bool> Function($PokemonRecordsTable row) filter, {
    List<OrderingTerm> orderBy = const [],
  }) async {
    final pokemon = database.pokemonRecords;
    final links = database.pokemonTypeLinks;
    final types = database.pokemonTypes;
    final species = database.pokemonSpecies;
    final generations = database.generations;
    final rows =
        await (database.select(pokemon).join([
                leftOuterJoin(links, links.pokemonId.equalsExp(pokemon.id)),
                leftOuterJoin(types, types.id.equalsExp(links.typeId)),
                leftOuterJoin(species, species.id.equalsExp(pokemon.speciesId)),
                leftOuterJoin(
                  generations,
                  generations.id.equalsExp(species.generationId),
                ),
              ])
              ..where(filter(pokemon))
              ..orderBy([...orderBy, OrderingTerm.asc(links.slot)]))
            .get();
    return mapPokemonRows(rows, database);
  }

  Future<List<EggGroup>> _loadEggGroups(int speciesId) async {
    final groups = database.eggGroups;
    final links = database.speciesEggGroups;
    final rows =
        await (database.select(links).join([
                innerJoin(groups, groups.id.equalsExp(links.eggGroupId)),
              ])
              ..where(links.speciesId.equals(speciesId))
              ..orderBy([OrderingTerm.asc(groups.name)]))
            .get();
    return [
      for (final row in rows)
        EggGroup(
          id: row.readTable(groups).id,
          name: row.readTable(groups).name,
        ),
    ];
  }

  Future<(List<EvolutionMember>, List<EvolutionStep>)> _loadChain(
    int chainId,
  ) async {
    final speciesRows =
        await (database.select(database.pokemonSpecies)
              ..where((row) => row.evolutionChainId.equals(chainId))
              ..orderBy([(row) => OrderingTerm.asc(row.id)]))
            .get();
    final ids = [for (final row in speciesRows) row.id];
    // Imagen e ID del Pokemon por defecto de cada especie, si esta guardado.
    final defaults = {
      for (final row
          in await (database.select(database.pokemonRecords)..where(
                (row) => row.speciesId.isIn(ids) & row.isDefault.equals(true),
              ))
              .get())
        row.speciesId!: row,
    };
    final stepRows =
        await (database.select(database.evolutions)
              ..where((row) => row.toSpeciesId.isIn(ids))
              ..orderBy([(row) => OrderingTerm.asc(row.toSpeciesId)]))
            .get();
    return (
      [
        for (final row in speciesRows)
          EvolutionMember(
            speciesId: row.id,
            name: row.name,
            pokemonId: defaults[row.id]?.id,
            imageUrl: defaults[row.id]?.imageUrl,
          ),
      ],
      [
        for (final row in stepRows)
          EvolutionStep(
            fromSpeciesId: row.fromSpeciesId,
            toSpeciesId: row.toSpeciesId,
            trigger: row.trigger,
            minLevel: row.minLevel,
            itemName: row.itemName,
            minHappiness: row.minHappiness,
            timeOfDay: row.timeOfDay,
          ),
      ],
    );
  }

  @override
  Stream<List<PokemonMove>> watchMoves(MoveQuery query) {
    final links = database.pokemonMoves;
    final moves = database.moves;
    final types = database.pokemonTypes;
    final method = query.learnMethod;
    final select =
        database.select(links).join([
          innerJoin(moves, moves.id.equalsExp(links.moveId)),
          leftOuterJoin(types, types.id.equalsExp(moves.typeId)),
        ])..where(
          links.pokemonId.equals(query.pokemonId) &
              links.versionGroupId.equals(query.versionGroupId),
        );
    if (method != null) select.where(links.learnMethod.equals(method));
    select.orderBy(switch (query.sort) {
      MoveSort.level => [
        OrderingTerm.asc(links.levelLearned),
        OrderingTerm.asc(moves.name),
      ],
      MoveSort.name => [
        OrderingTerm.asc(moves.name),
        OrderingTerm.asc(links.levelLearned),
      ],
    });
    return select.watch().map(
      (rows) => [
        for (final row in rows)
          () {
            final link = row.readTable(links);
            final move = row.readTable(moves);
            final type = row.readTableOrNull(types);
            return PokemonMove(
              moveId: move.id,
              name: move.name,
              versionGroupId: link.versionGroupId,
              learnMethod: link.learnMethod,
              level: link.levelLearned,
              power: move.power,
              accuracy: move.accuracy,
              type: type == null
                  ? null
                  : PokemonType(id: type.id, name: type.name),
            );
          }(),
      ],
    );
  }

  @override
  Stream<List<TypeEfficacy>> watchTypeEfficacy() => database
      .select(database.typeEfficacies)
      .watch()
      .map(
        (rows) => [
          for (final row in rows)
            TypeEfficacy(
              attackerTypeId: row.attackerTypeId,
              defenderTypeId: row.defenderTypeId,
              damageFactor: row.damageFactor,
            ),
        ],
      );

  // Todo o nada (OF-04): si algo falla, no queda un detalle a medias.
  @override
  Future<void> saveDetail(PokemonDetailDownload detail, SyncMetadata metadata) {
    return database.transaction(() async {
      final pokemonId = detail.pokemon.id;
      await _writer.upsertPokemon(detail.pokemon);

      for (final stat in detail.stats) {
        await database
            .into(database.stats)
            .insertOnConflictUpdate(
              StatsCompanion.insert(id: Value(stat.id), name: stat.name),
            );
      }
      await (database.delete(
        database.pokemonStats,
      )..where((row) => row.pokemonId.equals(pokemonId))).go();
      await database.batch(
        (batch) => batch.insertAll(database.pokemonStats, [
          for (final stat in detail.stats)
            PokemonStatsCompanion.insert(
              pokemonId: pokemonId,
              statId: stat.id,
              baseValue: stat.baseValue,
            ),
        ]),
      );

      final speciesId = detail.pokemon.species?.id;
      if (speciesId != null) {
        await (database.delete(
          database.speciesEggGroups,
        )..where((row) => row.speciesId.equals(speciesId))).go();
        for (final group in detail.eggGroups) {
          await database
              .into(database.eggGroups)
              .insertOnConflictUpdate(
                EggGroupsCompanion.insert(
                  id: Value(group.id),
                  name: group.name,
                ),
              );
          await database
              .into(database.speciesEggGroups)
              .insert(
                SpeciesEggGroupsCompanion.insert(
                  speciesId: speciesId,
                  eggGroupId: group.id,
                ),
              );
        }
      }
      await _saveEvolutionChain(detail);

      for (final group in detail.versionGroups) {
        await database
            .into(database.versionGroups)
            .insertOnConflictUpdate(
              VersionGroupsCompanion.insert(
                id: Value(group.id),
                name: group.name,
                sortOrder: group.sortOrder,
              ),
            );
      }
      final moveTypes = {
        for (final move in detail.moves)
          if (move.type != null) move.type!.id: move.type!,
      };
      for (final type in moveTypes.values) {
        await _writer.upsertType(type);
      }
      final moves = {for (final move in detail.moves) move.moveId: move};
      await database.batch((batch) {
        batch.insertAllOnConflictUpdate(database.moves, [
          for (final move in moves.values)
            MovesCompanion.insert(
              id: Value(move.moveId),
              name: move.name,
              typeId: Value(move.type?.id),
              power: Value(move.power),
              accuracy: Value(move.accuracy),
            ),
        ]);
      });
      await (database.delete(
        database.pokemonMoves,
      )..where((row) => row.pokemonId.equals(pokemonId))).go();
      await database.batch(
        (batch) => batch.insertAll(database.pokemonMoves, [
          for (final move in detail.moves)
            PokemonMovesCompanion.insert(
              pokemonId: pokemonId,
              moveId: move.moveId,
              versionGroupId: move.versionGroupId,
              learnMethod: move.learnMethod,
              levelLearned: Value(move.level),
            ),
        ]),
      );
      await _metadata.save(metadata);
    });
  }

  // Las especies de la cadena solo actualizan nombre y cadena: su generacion
  // la escribe el catalogo y aqui no se conoce.
  Future<void> _saveEvolutionChain(PokemonDetailDownload detail) async {
    final chainId = detail.evolutionChainId;
    for (final species in detail.chainSpecies) {
      await database
          .into(database.pokemonSpecies)
          .insert(
            PokemonSpeciesCompanion.insert(
              id: Value(species.id),
              name: species.name,
              evolutionChainId: Value(chainId),
            ),
            onConflict: DoUpdate(
              (_) => PokemonSpeciesCompanion(
                name: Value(species.name),
                evolutionChainId: Value(chainId),
              ),
            ),
          );
    }
    final ids = [for (final species in detail.chainSpecies) species.id];
    if (ids.isEmpty) return;
    await (database.delete(database.evolutions)..where(
          (row) => row.toSpeciesId.isIn(ids) | row.fromSpeciesId.isIn(ids),
        ))
        .go();
    await database.batch(
      (batch) => batch.insertAll(database.evolutions, [
        for (final step in detail.evolutions)
          EvolutionsCompanion.insert(
            fromSpeciesId: step.fromSpeciesId,
            toSpeciesId: step.toSpeciesId,
            trigger: step.trigger,
            minLevel: Value(step.minLevel),
            itemName: Value(step.itemName),
            minHappiness: Value(step.minHappiness),
            timeOfDay: Value(step.timeOfDay),
          ),
      ]),
    );
  }

  @override
  Future<void> saveTypeEfficacy(
    TypeEfficacyDownload efficacy,
    SyncMetadata metadata,
  ) {
    return database.transaction(() async {
      for (final type in efficacy.types) {
        await _writer.upsertType(type);
      }
      await database.delete(database.typeEfficacies).go();
      await database.batch(
        (batch) => batch.insertAll(database.typeEfficacies, [
          for (final row in efficacy.rows)
            TypeEfficaciesCompanion.insert(
              attackerTypeId: row.attackerTypeId,
              defenderTypeId: row.defenderTypeId,
              damageFactor: row.damageFactor,
            ),
        ]),
      );
      await _metadata.save(metadata);
    });
  }

  @override
  Future<SyncMetadata?> readSyncMetadata(String resourceKey) =>
      _metadata.read(resourceKey);

  @override
  Future<void> updateSyncStatus(
    String resourceKey,
    SyncStatus status, {
    String? lastError,
  }) => _metadata.updateStatus(resourceKey, status, lastError: lastError);
}
