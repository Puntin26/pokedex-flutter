import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'pokemon_catalog_controller.dart';
import 'pokemon_catalog_state.dart';

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
            if (catalog.isSyncing && catalog.pokemon.isNotEmpty)
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text('Actualizando catalogo...'),
              ),
            Expanded(child: _catalogBody(catalog, retry)),
          ],
        ),
      ),
    );
  }

  Widget _catalogBody(PokemonCatalogState catalog, VoidCallback retry) {
    switch (catalog.status) {
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
            return ListTile(
              key: ValueKey(pokemon.id),
              title: Text(pokemon.name),
              subtitle: Text('#${pokemon.nationalNumber}'),
            );
          },
        );
    }
  }
}
