import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../domain/move_query.dart';
import '../domain/pokemon.dart';
import '../domain/pokemon_detail.dart';
import '../domain/type_matchups.dart';
import 'catalog_filter_bar.dart' show generationLabel;
import 'detail_labels.dart';
import 'pokemon_detail_providers.dart';

/// Bloque con titulo; el titulo es encabezado para lectores de pantalla.
class DetailSection extends StatelessWidget {
  const DetailSection({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

/// Identidad (RF-DET-01), formas (RF-DET-08), shiny (RF-DET-09) y region.
class DetailHeader extends StatelessWidget {
  const DetailHeader({
    super.key,
    required this.detail,
    required this.heroTag,
    required this.showShiny,
    required this.onToggleShiny,
    required this.onSelectForm,
  });

  final PokemonDetail detail;
  final Object heroTag;
  final bool showShiny;
  final VoidCallback onToggleShiny;
  final ValueChanged<Pokemon> onSelectForm;

  @override
  Widget build(BuildContext context) {
    final pokemon = detail.pokemon;
    final shiny = pokemon.shinyImageUrl;
    final url = showShiny && shiny != null ? shiny : pokemon.imageUrl;
    final generation = pokemon.species?.generation;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        children: [
          Hero(
            tag: heroTag,
            child: SizedBox(
              width: 220,
              height: 220,
              child: url == null
                  ? const Center(
                      child: Icon(Icons.image_not_supported_outlined, size: 48),
                    )
                  : Image.network(
                      url,
                      key: ValueKey(url),
                      fit: BoxFit.contain,
                      cacheWidth: 440,
                      semanticLabel: showShiny
                          ? 'Imagen shiny de ${displayName(pokemon.name)}'
                          : 'Imagen de ${displayName(pokemon.name)}',
                      errorBuilder: (_, _, _) => const Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          size: 48,
                        ),
                      ),
                    ),
            ),
          ),
          Text(
            '#${pokemon.nationalNumber} ${displayName(pokemon.name)}',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            alignment: WrapAlignment.center,
            children: [
              for (final slot in pokemon.types)
                Chip(label: Text(displayName(slot.type.name))),
              if (generation != null)
                Chip(
                  avatar: const Icon(Icons.public, size: 18),
                  label: Text(generationLabel(generation)),
                ),
            ],
          ),
          if (shiny != null)
            FilterChip(
              avatar: const Icon(Icons.auto_awesome, size: 18),
              label: const Text('Shiny'),
              tooltip: showShiny ? 'Ver version normal' : 'Ver version shiny',
              selected: showShiny,
              onSelected: (_) => onToggleShiny(),
            ),
          if (detail.forms.length > 1) ...[
            const SizedBox(height: 8),
            Text('Formas', style: Theme.of(context).textTheme.labelLarge),
            Wrap(
              spacing: 8,
              alignment: WrapAlignment.center,
              children: [
                for (final form in detail.forms)
                  ChoiceChip(
                    label: Text(displayName(form.name)),
                    selected: form.id == pokemon.id,
                    onSelected: form.id == pokemon.id
                        ? null
                        : (_) => onSelectForm(form),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Barras con valor y porcentaje, mas el total (RF-DET-02).
class StatsSection extends StatelessWidget {
  const StatsSection({super.key, required this.detail});

  final PokemonDetail detail;

  @override
  Widget build(BuildContext context) {
    if (detail.stats.isEmpty) {
      return const DetailSection(
        title: 'Estadisticas base',
        child: Text('Se muestran al descargar el detalle.'),
      );
    }
    final total = detail.stats.fold<int>(
      0,
      (sum, stat) => sum + stat.baseValue,
    );
    return DetailSection(
      title: 'Estadisticas base',
      child: Column(
        children: [
          for (final stat in detail.stats)
            Semantics(
              label:
                  '${statLabel(stat)}: ${stat.baseValue}, ${statPercent(stat)} por ciento',
              excludeSemantics: true,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(width: 88, child: Text(statLabel(stat))),
                    SizedBox(
                      width: 40,
                      child: Text(
                        '${stat.baseValue}',
                        textAlign: TextAlign.end,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: stat.baseValue / maxBaseStat,
                        minHeight: 8,
                      ),
                    ),
                    SizedBox(
                      width: 48,
                      child: Text(
                        '${statPercent(stat)}%',
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Total: $total',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        ],
      ),
    );
  }
}

/// Nombre, "Oculta" y efecto resumido (RF-DET-03).
class AbilitiesSection extends StatelessWidget {
  const AbilitiesSection({super.key, required this.abilities});

  final List<PokemonAbility> abilities;

  @override
  Widget build(BuildContext context) {
    return DetailSection(
      title: 'Habilidades',
      child: abilities.isEmpty
          ? const Text('Sin habilidades registradas.')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final entry in abilities)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              displayName(entry.ability.name),
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            if (entry.isHidden)
                              const Chip(
                                label: Text('Oculta'),
                                visualDensity: VisualDensity.compact,
                              ),
                          ],
                        ),
                        if (entry.ability.effectSummary != null)
                          Text(summarizeEffect(entry.ability.effectSummary!)),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}

/// Debilidades, resistencias e inmunidades (RF-DET-06).
class MatchupsSection extends ConsumerWidget {
  const MatchupsSection({super.key, required this.pokemon});

  final Pokemon pokemon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chart = ref.watch(typeChartProvider).value;
    final matchups = chart == null
        ? null
        : TypeMatchups.forDefender(
            [for (final slot in pokemon.types) slot.type],
            chart.rows,
            chart.types,
          );
    if (matchups == null || matchups.isEmpty) {
      return const DetailSection(
        title: 'Debilidades y resistencias',
        child: Text('Se muestran al descargar la tabla de tipos.'),
      );
    }
    return DetailSection(
      title: 'Debilidades y resistencias',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final multiplier in TypeMatchups.displayOrder)
            if (matchups.typesWith(multiplier).isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 56,
                      child: Text(
                        multiplierLabel(multiplier),
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    Expanded(
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          for (final type in matchups.typesWith(multiplier))
                            Chip(
                              label: Text(displayName(type.name)),
                              visualDensity: VisualDensity.compact,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

/// Linea o arbol con ramas y trigger principal (RF-DET-04).
class EvolutionSection extends StatelessWidget {
  const EvolutionSection({
    super.key,
    required this.detail,
    required this.onOpen,
  });

  final PokemonDetail detail;
  final ValueChanged<int> onOpen;

  @override
  Widget build(BuildContext context) {
    if (!detail.hasFullDetail && detail.evolutions.isEmpty) {
      return const DetailSection(
        title: 'Evoluciones',
        child: Text('Se muestran al descargar el detalle.'),
      );
    }
    if (detail.evolutions.isEmpty) {
      return const DetailSection(
        title: 'Evoluciones',
        child: Text('No evoluciona'),
      );
    }
    final members = {
      for (final member in detail.evolutionMembers) member.speciesId: member,
    };
    Widget memberChip(int speciesId) {
      final member = members[speciesId];
      final pokemonId = member?.pokemonId;
      final isCurrent = speciesId == detail.pokemon.species?.id;
      return ActionChip(
        label: Text(displayName(member?.name ?? '#$speciesId')),
        avatar: isCurrent ? const Icon(Icons.place, size: 18) : null,
        tooltip: pokemonId == null ? 'No esta guardado' : 'Abrir detalle',
        onPressed: pokemonId == null || isCurrent
            ? null
            : () => onOpen(pokemonId),
      );
    }

    return DetailSection(
      title: 'Evoluciones',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Una fila por paso: varias con el mismo origen son las ramas.
          for (final step in detail.evolutions)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Wrap(
                spacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  memberChip(step.fromSpeciesId),
                  const Icon(Icons.arrow_forward, size: 18),
                  memberChip(step.toSpeciesId),
                  Text(evolutionTrigger(step)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Peso, altura y egg groups (RF-DET-07).
class MetadataSection extends StatelessWidget {
  const MetadataSection({super.key, required this.detail});

  final PokemonDetail detail;

  @override
  Widget build(BuildContext context) {
    final pokemon = detail.pokemon;
    final eggGroups = detail.eggGroups.isEmpty
        ? (detail.hasFullDetail ? 'Ninguno' : '-')
        : detail.eggGroups.map((group) => displayName(group.name)).join(', ');
    return DetailSection(
      title: 'Datos',
      child: Wrap(
        spacing: 24,
        runSpacing: 8,
        children: [
          _Fact(label: 'Altura', value: formatHeight(pokemon.height)),
          _Fact(label: 'Peso', value: formatWeight(pokemon.weight)),
          _Fact(label: 'Egg groups', value: eggGroups),
          if (detail.versionGroups.isNotEmpty)
            _Fact(label: 'Juegos', value: '${detail.versionGroups.length}'),
        ],
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        Text(value, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}

const detailVersionMenuKey = Key('detail-version-menu');
const detailMoveSortKey = Key('detail-move-sort');

/// Movimientos filtrables y ordenables, en una lista perezosa (RF-DET-05).
/// Por defecto: el juego mas reciente y el metodo level-up.
class MovesSliver extends ConsumerStatefulWidget {
  const MovesSliver({super.key, required this.detail});

  final PokemonDetail detail;

  @override
  ConsumerState<MovesSliver> createState() => _MovesSliverState();
}

class _MovesSliverState extends ConsumerState<MovesSliver> {
  int? _versionGroupId;
  String? _method = 'level-up';
  MoveSort _sort = MoveSort.level;

  @override
  Widget build(BuildContext context) {
    final groups = widget.detail.versionGroups;
    if (groups.isEmpty) {
      return const SliverToBoxAdapter(
        child: DetailSection(
          title: 'Movimientos',
          child: Text('Se muestran al descargar el detalle.'),
        ),
      );
    }
    // Si el juego elegido ya no esta (otra forma), vuelve al mas reciente.
    final selected = groups.any((group) => group.id == _versionGroupId)
        ? _versionGroupId!
        : groups.last.id;
    final moves = ref.watch(
      pokemonMovesProvider(
        MoveQuery(
          pokemonId: widget.detail.pokemon.id,
          versionGroupId: selected,
          learnMethod: _method,
          sort: _sort,
        ),
      ),
    );
    final items = moves.value ?? const <PokemonMove>[];
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: DetailSection(
            title: 'Movimientos',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButton<int>(
                  key: detailVersionMenuKey,
                  isExpanded: true,
                  value: selected,
                  onChanged: (id) => setState(() => _versionGroupId = id),
                  items: [
                    for (final group in groups.reversed)
                      DropdownMenuItem(
                        value: group.id,
                        child: Text(
                          displayName(group.name),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    for (final entry in learnMethodLabels.entries)
                      ChoiceChip(
                        label: Text(entry.value),
                        selected: _method == entry.key,
                        onSelected: (_) => setState(() => _method = entry.key),
                      ),
                    ChoiceChip(
                      label: const Text('Todos'),
                      selected: _method == null,
                      onSelected: (_) => setState(() => _method = null),
                    ),
                    TextButton.icon(
                      key: detailMoveSortKey,
                      icon: const Icon(Icons.sort),
                      label: Text(
                        _sort == MoveSort.level
                            ? 'Orden: nivel'
                            : 'Orden: nombre',
                      ),
                      onPressed: () => setState(
                        () => _sort = _sort == MoveSort.level
                            ? MoveSort.name
                            : MoveSort.level,
                      ),
                    ),
                  ],
                ),
                if (moves.hasValue && items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('Sin movimientos para este filtro.'),
                  ),
              ],
            ),
          ),
        ),
        SliverList.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final move = items[index];
            final details = [
              if (move.learnMethod == 'level-up') 'Nivel ${move.level}',
              if (_method == null)
                learnMethodLabels[move.learnMethod] ??
                    displayName(move.learnMethod),
              if (move.type != null) displayName(move.type!.name),
              if (move.power != null) 'Poder ${move.power}',
              if (move.accuracy != null) 'Precision ${move.accuracy}',
            ];
            return ListTile(
              dense: true,
              title: Text(displayName(move.name)),
              subtitle: Text(details.join(' · ')),
            );
          },
        ),
      ],
    );
  }
}
