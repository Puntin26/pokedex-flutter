import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/connectivity/connection_monitor.dart';
import '../core/sync/sync_scheduler.dart';
import '../features/pokemon/presentation/pokemon_catalog_controller.dart';
import 'connection_status_provider.dart';

// Conecta el estado del servicio con la sync del catalogo; vive mientras la app.
final syncSchedulerProvider = Provider<SyncScheduler>((ref) {
  final scheduler = SyncScheduler(
    // Pasa por el controlador para que la UI refleje la sync y sus errores.
    synchronize: () =>
        ref.read(catalogSyncControllerProvider.notifier).synchronize(),
  );
  ref.onDispose(scheduler.dispose);
  ref.listen<ConnectionStatus>(
    connectionStatusProvider,
    (_, status) => scheduler.onStatus(status),
    fireImmediately: true,
  );
  return scheduler;
});
