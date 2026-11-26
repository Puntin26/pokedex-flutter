import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/connectivity/connection_monitor.dart';
import '../core/domain/freshness_policy.dart';
import '../core/domain/sync_activity.dart';
import '../features/pokemon/presentation/pokemon_catalog_controller.dart';
import 'clock_provider.dart';
import 'connection_status_provider.dart';
import 'pokemon_dependencies.dart';

enum DataOrigin { local, remote }

/// Lo que muestra el indicador global: conexion, actividad de sync y
/// procedencia/vigencia de los datos, como dimensiones separadas (§7.4, IND-04).
class ConnectionIndicatorState {
  const ConnectionIndicatorState({
    required this.status,
    required this.activity,
    this.origin,
    this.updatedAt,
    this.isStale = false,
  });

  final ConnectionStatus status;
  final SyncActivity activity;
  // Null si todavia no hay catalogo guardado.
  final DataOrigin? origin;
  final DateTime? updatedAt;
  final bool isStale;
}

/// Estado de conexion con antiparpadeo (IND-06): un cambio entre estados firmes
/// se muestra solo si dura [delay]; "comprobando" no reemplaza al ultimo conocido.
class DisplayedConnectionStatus extends Notifier<ConnectionStatus> {
  static const delay = Duration(milliseconds: 1500);
  Timer? _pending;

  @override
  ConnectionStatus build() {
    ref.onDispose(() => _pending?.cancel());
    ref.listen(connectionStatusProvider, (_, next) => _onStatus(next));
    return ref.read(connectionStatusProvider);
  }

  void _onStatus(ConnectionStatus next) {
    _pending?.cancel();
    _pending = null;
    if (next == state || next == ConnectionStatus.checking) return;
    // El primer resultado al arrancar no espera.
    if (state == ConnectionStatus.checking) {
      state = next;
      return;
    }
    _pending = Timer(delay, () => state = next);
  }
}

final displayedConnectionStatusProvider =
    NotifierProvider<DisplayedConnectionStatus, ConnectionStatus>(
      DisplayedConnectionStatus.new,
    );

final connectionIndicatorStateProvider = Provider<ConnectionIndicatorState>((
  ref,
) {
  final status = ref.watch(displayedConnectionStatusProvider);
  final activity =
      ref.watch(catalogSyncActivityProvider).value ?? SyncActivity.idle;
  final metadata = ref.watch(catalogMetadataProvider).value;
  final updatedAt = metadata?.lastSuccessAt;
  if (updatedAt == null) {
    return ConnectionIndicatorState(status: status, activity: activity);
  }
  final isStale = const FreshnessPolicy().isStale(
    metadata,
    ref.watch(clockProvider)(),
  );
  // Todo se lee de SQLite; es "remoto" si refleja a PokeAPI: online y vigente.
  final origin = status == ConnectionStatus.online && !isStale
      ? DataOrigin.remote
      : DataOrigin.local;
  return ConnectionIndicatorState(
    status: status,
    activity: activity,
    origin: origin,
    updatedAt: updatedAt,
    isStale: isStale,
  );
});

/// "HH:mm" si es hoy; "dd/MM HH:mm" si es otro dia. Siempre en hora local.
String formatUpdatedAt(DateTime at, DateTime now) {
  final local = at.toLocal();
  final today = now.toLocal();
  String two(int value) => value.toString().padLeft(2, '0');
  final time = '${two(local.hour)}:${two(local.minute)}';
  final sameDay =
      local.year == today.year &&
      local.month == today.month &&
      local.day == today.day;
  return sameDay ? time : '${two(local.day)}/${two(local.month)} $time';
}
