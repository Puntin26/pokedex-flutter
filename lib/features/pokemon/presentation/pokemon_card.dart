import 'package:material_ui/material_ui.dart';

import '../domain/pokemon.dart';

class PokemonCard extends StatelessWidget {
  const PokemonCard({super.key, required this.pokemon, this.trailing});

  final Pokemon pokemon;
  // Accion al final de la tarjeta (el corazon); la compone quien la usa.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            SizedBox(width: 88, height: 88, child: _image()),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('#${pokemon.nationalNumber}'),
                  Text(
                    pokemon.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Wrap(
                    spacing: 6,
                    children: [
                      for (final type in pokemon.types)
                        Chip(label: Text(type.type.name)),
                    ],
                  ),
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }

  Widget _image() {
    final url = pokemon.imageUrl;
    if (url == null || url.isEmpty) return _missingImage();
    return Image.network(
      url,
      fit: BoxFit.contain,
      cacheWidth: 176,
      semanticLabel: 'Imagen de ${pokemon.name}',
      // El espacio se mantiene estable durante la carga y ante fallos offline.
      frameBuilder: (context, child, frame, loaded) => frame != null || loaded
          ? child
          : const Center(
              child: Icon(
                Icons.image_outlined,
                size: 32,
                semanticLabel: 'Cargando imagen',
              ),
            ),
      errorBuilder: (context, error, stackTrace) => _missingImage(),
    );
  }

  Widget _missingImage() {
    return const Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.image_not_supported_outlined, size: 32),
            Text('Sin imagen'),
          ],
        ),
      ),
    );
  }
}
