import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../pokemon/domain/pokemon.dart';
import 'favorites_providers.dart';

/// Corazon animado para agregar o quitar un favorito (RF-COM-03, RF-FAV-01).
/// El estado sale de SQLite, asi se ve igual en catalogo, favoritos y detalle.
class FavoriteButton extends ConsumerWidget {
  const FavoriteButton({super.key, required this.pokemon, this.onRemoved});

  final Pokemon pokemon;

  /// Se llama cuando el toque lo quita (p. ej. para ofrecer "Deshacer").
  final VoidCallback? onRemoved;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(isFavoriteProvider(pokemon.id));
    // Respeta "reducir animaciones" del sistema.
    final animate = !MediaQuery.disableAnimationsOf(context);
    final label = isFavorite
        ? 'Quitar ${pokemon.name} de favoritos'
        : 'Agregar ${pokemon.name} a favoritos';
    return IconButton(
      tooltip: label,
      onPressed: () async {
        final added = await ref
            .read(favoritesControllerProvider)
            .toggle(pokemon.id);
        if (!added && context.mounted) onRemoved?.call();
      },
      icon: AnimatedSwitcher(
        duration: animate ? const Duration(milliseconds: 250) : Duration.zero,
        transitionBuilder: (child, animation) => ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: child,
        ),
        // Forma distinta (lleno/contorno) ademas del color: no depende solo del color.
        child: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          key: ValueKey(isFavorite),
          color: isFavorite ? Colors.red.shade700 : null,
          semanticLabel: label,
        ),
      ),
    );
  }
}
