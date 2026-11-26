import 'dart:async';

import 'package:flutter/foundation.dart';

import '../connectivity/connection_monitor.dart';

typedef PeriodicTimerFactory = Timer Function(
  Duration period,
  void Function(Timer) callback,
);

/// Decide cuando sincronizar segun el estado del servicio (OF-11, OF-12, OF-20):
/// al recuperar el servicio y de forma periodica mientras esta Online.
/// La sync de arranque la hace el controlador del catalogo; aqui no se duplica.
class SyncScheduler {
  SyncScheduler({
    required this.synchronize,
    this.period = const Duration(minutes: 15),
    PeriodicTimerFactory? periodicTimer,
    void Function(String message)? log,
  }) : _periodicTimer = periodicTimer ?? Timer.periodic,
       _log = log ?? debugPrint;

  final Future<void> Function() synchronize;
  final Duration period;
  final PeriodicTimerFactory _periodicTimer;
  final void Function(String message) _log;

  // Ultimo estado firme; checking es transitorio y no cuenta.
  ConnectionStatus? _lastSettled;
  Timer? _timer;
  bool _disposed = false;

  void onStatus(ConnectionStatus status) {
    if (_disposed || status == ConnectionStatus.checking) return;
    final previous = _lastSettled;
    _lastSettled = status;
    if (status != ConnectionStatus.online) {
      _timer?.cancel();
      _timer = null;
      return;
    }
    _timer ??= _periodicTimer(period, (_) => _run('periodica'));
    final recovered =
        previous == ConnectionStatus.offline ||
        previous == ConnectionStatus.serviceUnavailable;
    if (recovered) _run('reconexion');
  }

  void _run(String reason) {
    _log('[sync] disparada por $reason');
    // No se espera: la sync corre en segundo plano sin bloquear la UI (OF-14).
    unawaited(
      synchronize().catchError((Object error) {
        // El fallo ya queda en la metadata y en SyncActivity; aqui solo se registra.
        _log('[sync] $reason fallo: $error');
      }),
    );
  }

  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _timer = null;
  }
}
