import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'catalog_filter_bar.dart';
import 'catalog_query_controller.dart';
import 'pokemon_catalog_controller.dart';
import 'pokemon_catalog_state.dart';
import 'pokemon_card.dart';

class PokemonPage extends ConsumerWidget {
  const PokemonPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(pokemonCatalogStateProvider);
    void retry() {
      ref.read(catalogSyncControllerProvider.notifier).retry();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Pokedex')),
      body: SafeArea(
        child: Column(
          children: [
            if (catalog.errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(catalog.errorMessage!, textAlign: TextAlign.center),
                    TextButton(
                      onPressed: catalog.isSyncing ? null : retry,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            const CatalogFilterBar(),
            if (catalog.isPartial)
              _PartialCatalogNotice(
                downloaded: catalog.partialDownloaded!,
                total: catalog.partialTotal!,
              ),
            if (catalog.isSyncing && catalog.pokemon.isNotEmpty)
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text('Actualizando catalogo...'),
              ),
            Expanded(
              child: _catalogBody(
                catalog,
                retry,
                () => ref.read(catalogQueryProvider.notifier).clearFilters(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _catalogBody(
    PokemonCatalogState catalog,
    VoidCallback retry,
    VoidCallback clearFilters,
  ) {
    switch (catalog.status) {
      case PokemonCatalogStatus.noResults:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Ningun Pokemon coincide con la busqueda o los filtros.',
                  textAlign: TextAlign.center,
                ),
                TextButton(
                  onPressed: clearFilters,
                  child: const Text('Limpiar filtros'),
                ),
              ],
            ),
          ),
        );
      case PokemonCatalogStatus.loading:
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Cargando catalogo...'),
            ],
          ),
        );
      case PokemonCatalogStatus.empty:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('No hay Pokemon guardados.'),
              TextButton(onPressed: retry, child: const Text('Reintentar')),
            ],
          ),
        );
      case PokemonCatalogStatus.error:
        return const Center(child: Text('No hay Pokemon guardados.'));
      case PokemonCatalogStatus.data:
        // Se construyen solo las tarjetas cercanas a la parte visible.
        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: catalog.pokemon.length,
          itemBuilder: (context, index) {
            final pokemon = catalog.pokemon[index];
            return PokemonCard(key: ValueKey(pokemon.id), pokemon: pokemon);
          },
        );
    }
  }
}

// Con el catalogo incompleto, buscar y filtrar puede no encontrar todo (RF-FIL-05).
class _PartialCatalogNotice extends StatelessWidget {
  const _PartialCatalogNotice({required this.downloaded, required this.total});

  final int downloaded;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Catalogo parcial: $downloaded de $total Pokemon descargados. '
              'La busqueda puede no mostrar todos.',
            ),
          ),
        ],
      ),
    );
  }
}
