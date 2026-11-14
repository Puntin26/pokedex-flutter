import 'package:material_ui/material_ui.dart';

import '../core/connectivity/connection_indicator.dart';
import '../features/pokemon/presentation/pokemon_page.dart';

class PokedexApp extends StatelessWidget {
  const PokedexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokedex',
      debugShowCheckedModeBanner: false,
      // El indicador queda fuera de las rutas para seguir visible al navegar.
      builder: (context, child) => SafeArea(
        child: Column(
          children: [
            Expanded(child: child!),
            const ConnectionIndicator(),
          ],
        ),
      ),
      home: const PokemonPage(),
    );
  }
}
