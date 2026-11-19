import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../core/connectivity/connection_monitor.dart';
import '../core/domain/sync_activity.dart';
import 'clock_provider.dart';
import 'connection_indicator_state.dart';

class ConnectionIndicator extends ConsumerWidget {
  const ConnectionIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final indicator = ref.watch(connectionIndicatorStateProvider);
    final now = ref.watch(clockProvider)();
    final (label, icon) = switch (indicator.status) {
      ConnectionStatus.checking => ('Comprobando conexion...', Icons.wifi_find),
      ConnectionStatus.online => ('Online', Icons.cloud_done_outlined),
      ConnectionStatus.offline => ('Offline', Icons.wifi_off),
      ConnectionStatus.serviceUnavailable => (
        'Servicio no disponible',
        Icons.cloud_off_outlined,
      ),
    };
    final activity = switch (indicator.activity) {
      SyncActivity.syncing => ('Sincronizando', Icons.sync),
      SyncActivity.waitingRetry => ('Reintentando', Icons.schedule),
      SyncActivity.idle || SyncActivity.failed => null,
    };
    final updatedAt = indicator.updatedAt;
    final detail = updatedAt == null
        ? 'Sin datos guardados'
        : '${indicator.origin == DataOrigin.remote ? 'Datos remotos' : 'Datos locales'}'
              ' · actualizado ${formatUpdatedAt(updatedAt, now)}'
              '${indicator.isStale ? ' · desactualizado' : ''}';
    final theme = Theme.of(context);
    return Semantics(
      label: [label, ?activity?.$1, detail].join('. '),
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
            ],
          ),
        ),
      ),
    );
  }
}
