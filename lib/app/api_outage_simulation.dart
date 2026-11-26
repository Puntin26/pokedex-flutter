import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/pokemon/presentation/pokemon_catalog_controller.dart';
import 'connection_status_provider.dart';

/// Interruptor de depuracion para PA-08: con red activa, envia las peticiones
/// GraphQL a un endpoint inalcanzable. Se activa con pulsacion larga en el
/// indicador, solo en modo debug.
class ApiOutageSimulation extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() {
    state = !state;
    debugPrint(
      '[debug] Simulacion de API caida ${state ? 'activada' : 'desactivada'}',
    );
    // Actualiza el indicador sin esperar al chequeo periodico de 30 s.
    unawaited(ref.read(connectionStatusProvider.notifier).check());
    // Al activarla pide una actualizacion para ver el backoff en consola.
    // Al apagarla, el scheduler sincroniza solo al detectar la recuperacion.
    if (state) {
      unawaited(ref.read(catalogSyncControllerProvider.notifier).synchronize());
    }
  }
}

final apiOutageSimulationProvider = NotifierProvider<ApiOutageSimulation, bool>(
  ApiOutageSimulation.new,
);
