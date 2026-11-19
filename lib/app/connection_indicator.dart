import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../core/connectivity/connection_monitor.dart';
import '../core/domain/sync_activity.dart';
import 'api_outage_simulation.dart';
import 'clock_provider.dart';
import 'connection_indicator_state.dart';

class ConnectionIndicator extends ConsumerWidget {
  const ConnectionIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(connectionIndicatorStateProvider);
    final now = ref.watch(clockProvider)();
    final (label, icon) = switch (state.status) {
      ConnectionStatus.checking => ('Comprobando conexion...', Icons.wifi_find),
      ConnectionStatus.online => ('Online', Icons.cloud_done_outlined),
      ConnectionStatus.offline => ('Offline', Icons.wifi_off),
      ConnectionStatus.serviceUnavailable => (
        'Servicio no disponible',
        Icons.cloud_off_outlined,
      ),
    };
    final activity = switch (state.activity) {
      SyncActivity.syncing => ('Sincronizando', Icons.sync),
      SyncActivity.waitingRetry => ('Reintentando', Icons.schedule),
      SyncActivity.idle || SyncActivity.failed => null,
    };
    final updatedAt = state.updatedAt;
    final detail = updatedAt == null
        ? 'Sin datos guardados'
        : '${state.origin == DataOrigin.remote ? 'Datos remotos' : 'Datos locales'}'
              ' · actualizado ${formatUpdatedAt(updatedAt, now)}'
              '${state.isStale ? ' · desactualizado' : ''}';
    final simulatingOutage = ref.watch(apiOutageSimulationProvider);
    const simulationLabel = 'Simulacion: API caida';
    final theme = Theme.of(context);
    final indicator = Semantics(
      label: [
        label,
        ?activity?.$1,
        detail,
        if (simulatingOutage) simulationLabel,
      ].join('. '),
      liveRegion: true,
      excludeSemantics: true,
      child: Material(
        color: theme.colorScheme.surfaceContainerHighest,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Wrap: con texto grande la actividad baja de linea sin desbordar.
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: [
                  Icon(icon, size: 20),
                  Text(label),
                  if (activity != null) ...[
                    Icon(activity.$2, size: 18),
                    Text(activity.$1),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                detail,
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              if (simulatingOutage)
                Text(
                  simulationLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    // PA-08 sin reinstalar: solo existe en debug, nunca en la app entregada.
    if (!kDebugMode) return indicator;
    return GestureDetector(
      onLongPress: () =>
          ref.read(apiOutageSimulationProvider.notifier).toggle(),
      child: indicator,
    );
  }
}
