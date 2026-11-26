import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../core/connectivity/connection_indicator.dart';
import '../features/pokemon/presentation/pokemon_page.dart';
import 'sync_scheduler_provider.dart';

class PokedexApp extends ConsumerWidget {
  const PokedexApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mantiene activa la sync automatica (reconexion y periodica) en toda la app.
    ref.watch(syncSchedulerProvider);
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
