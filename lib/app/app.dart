import 'package:material_ui/material_ui.dart';

import '../features/pokemon/presentation/pokemon_page.dart';

class PokedexApp extends StatelessWidget {
  const PokedexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Pokedex',
      debugShowCheckedModeBanner: false,
      home: PokemonPage(),
    );
  }
}
