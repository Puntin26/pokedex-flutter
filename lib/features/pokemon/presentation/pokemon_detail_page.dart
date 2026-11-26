import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/share_provider.dart';
import '../../../core/domain/sync_failure.dart';
import '../domain/pokemon.dart';
import '../domain/pokemon_detail.dart';
import 'detail_labels.dart';
import 'detail_sections.dart';
import 'pokemon_detail_providers.dart';

/// Acciones que compone quien abre el detalle (el corazon de favoritos): asi
/// la feature pokemon no depende de favorites.
typedef PokemonAction = Widget Function(Pokemon pokemon);

Route<void> pokemonDetailRoute(
  int pokemonId, {
  Object? heroTag,
  PokemonAction? action,
}) => MaterialPageRoute<void>(
  builder: (_) => PokemonDetailPage(
    pokemonId: pokemonId,
    heroTag: heroTag ?? 'detail-$pokemonId',
    action: action,
  ),
);

/// Detalle de un Pokemon. Muestra al instante lo que hay en SQLite y, si hay
/// servicio, descarga el detalle completo sin bloquear (OF-20, PA-02).
class PokemonDetailPage extends ConsumerStatefulWidget {
  const PokemonDetailPage({
    super.key,
    required this.pokemonId,
    required this.heroTag,
    this.action,
  });

  final int pokemonId;
  final Object heroTag;
  final PokemonAction? action;

  @override
  ConsumerState<PokemonDetailPage> createState() => _PokemonDetailPageState();
}

class _PokemonDetailPageState extends ConsumerState<PokemonDetailPage> {
  bool _showShiny = false;

  void _retry() => ref
      .read(detailSyncControllerProvider(widget.pokemonId).notifier)
      .synchronize();

  void _open(int pokemonId, {bool replace = false}) {
    final route = pokemonDetailRoute(pokemonId, action: widget.action);
    final navigator = Navigator.of(context);
    // Cambiar de forma reemplaza la pantalla; abrir una evolucion apila.
    replace ? navigator.pushReplacement(route) : navigator.push(route);
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(pokemonDetailProvider(widget.pokemonId));
    final sync = ref.watch(detailSyncControllerProvider(widget.pokemonId));
    final pokemon = detail.value?.pokemon;
    return Scaffold(
      appBar: AppBar(
        title: Text(pokemon == null ? 'Pokemon' : displayName(pokemon.name)),
        actions: [
          if (pokemon != null) ...[
            IconButton(
              tooltip: 'Compartir',
              icon: const Icon(Icons.share),
              onPressed: () => ref.read(shareTextProvider)(shareText(pokemon)),
            ),
            ?widget.action?.call(pokemon),
          ],
        ],
      ),
      body: SafeArea(
        child: switch (detail) {
          AsyncData(value: final PokemonDetail value) => _content(value, sync),
          AsyncData() => _notStored(sync),
          AsyncError() => _message(
            'No se pudo leer el detalle guardado.',
            onRetry: () =>
                ref.invalidate(pokemonDetailProvider(widget.pokemonId)),
          ),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }

  Widget _content(PokemonDetail detail, AsyncValue<void> sync) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: DetailHeader(
            detail: detail,
            heroTag: widget.heroTag,
            showShiny: _showShiny,
            onToggleShiny: () => setState(() => _showShiny = !_showShiny),
            onSelectForm: (form) => _open(form.id, replace: true),
          ),
        ),
        SliverToBoxAdapter(child: _syncNotice(detail, sync)),
        SliverToBoxAdapter(child: StatsSection(detail: detail)),
        SliverToBoxAdapter(
          child: AbilitiesSection(abilities: detail.abilities),
        ),
        SliverToBoxAdapter(child: MatchupsSection(pokemon: detail.pokemon)),
        SliverToBoxAdapter(
          child: EvolutionSection(detail: detail, onOpen: _open),
        ),
        SliverToBoxAdapter(child: MetadataSection(detail: detail)),
        MovesSliver(detail: detail),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  // Estado de la descarga sin tapar lo que ya se ve (IND-07).
  Widget _syncNotice(PokemonDetail detail, AsyncValue<void> sync) {
    if (sync.isLoading && !detail.hasFullDetail) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Row(
          children: [
            SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Expanded(child: Text('Descargando el detalle completo...')),
          ],
        ),
      );
    }
    if (!sync.hasError) return const SizedBox.shrink();
    final text = detail.hasFullDetail
        ? 'No se pudo actualizar; se muestran los datos guardados.'
        : 'Sin el detalle completo: ${_failureText(sync.error)} '
              'Se muestran los datos del catalogo.';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
          TextButton(onPressed: _retry, child: const Text('Reintentar')),
        ],
      ),
    );
  }

  // Ni siquiera el catalogo lo tiene (PA-02 sin conexion o con error).
  Widget _notStored(AsyncValue<void> sync) {
    if (sync.isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Descargando datos del Pokemon...'),
          ],
        ),
      );
    }
    return _message(
      'Este Pokemon aun no esta guardado. ${_failureText(sync.error)}',
      onRetry: _retry,
    );
  }

  Widget _message(String text, {required VoidCallback onRetry}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(text, textAlign: TextAlign.center),
            TextButton(onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }

  String _failureText(Object? error) => switch (error) {
    SyncFailure(kind: SyncFailureKind.network) =>
      'Conectate a Internet para descargarlo.',
    SyncFailure(:final message) => message,
    _ => 'No se pudo descargar.',
  };
}
