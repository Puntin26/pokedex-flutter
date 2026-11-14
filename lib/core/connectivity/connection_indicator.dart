import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/connection_status_provider.dart';
import 'connection_monitor.dart';

class ConnectionIndicator extends ConsumerWidget {
  const ConnectionIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(connectionStatusProvider);
    final (label, icon) = switch (status) {
      ConnectionStatus.checking => ('Comprobando conexion...', Icons.wifi_find),
      ConnectionStatus.online => ('Online', Icons.cloud_done_outlined),
      ConnectionStatus.offline => ('Offline', Icons.wifi_off),
      ConnectionStatus.serviceUnavailable => (
        'Servicio no disponible',
        Icons.cloud_off_outlined,
      ),
    };
    return Semantics(
      label: label,
      liveRegion: true,
      excludeSemantics: true,
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Flexible(child: Text(label)),
            ],
          ),
        ),
      ),
    );
  }
}
