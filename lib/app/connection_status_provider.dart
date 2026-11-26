import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/connectivity/connection_monitor.dart';
import '../core/network/pokeapi_graphql_client.dart';
import '../core/network/pokeapi_service_probe.dart';
import 'api_outage_simulation.dart';

final connectionMonitorProvider = Provider<ConnectionMonitor>((ref) {
  final connectivity = Connectivity();
  final client = createPokeApiClient(
    timeout: const Duration(seconds: 5),
    simulateOutage: () => ref.read(apiOutageSimulationProvider),
  );
  ref.onDispose(client.link.dispose);
  final probe = PokeApiServiceProbe(client);
  bool hasNetwork(List<ConnectivityResult> results) =>
      results.any((result) => result != ConnectivityResult.none);

  return ConnectionMonitor(
    hasNetwork: () async => hasNetwork(await connectivity.checkConnectivity()),
    networkChanges: connectivity.onConnectivityChanged.map(hasNetwork),
    isServiceAvailable: probe.isAvailable,
  );
});

final connectionStatusProvider =
    NotifierProvider<ConnectionStatusController, ConnectionStatus>(
      ConnectionStatusController.new,
    );

class ConnectionStatusController extends Notifier<ConnectionStatus> {
  int _checkVersion = 0;

  @override
  ConnectionStatus build() {
    final monitor = ref.watch(connectionMonitorProvider);
    final subscription = monitor.networkChanges.listen(
      (available) => unawaited(check(networkAvailable: available)),
      onError: (Object error) {
        _checkVersion++;
        state = ConnectionStatus.serviceUnavailable;
      },
    );
    final lifecycle = AppLifecycleListener(onResume: () => unawaited(check()));
    // Revisa tambien una caida del servicio sin cambio de Wi-Fi.
    final timer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => unawaited(check()),
    );
    ref.onDispose(() {
      _checkVersion++;
      timer.cancel();
      lifecycle.dispose();
      unawaited(subscription.cancel());
    });
    unawaited(Future.microtask(check));
    return ConnectionStatus.checking;
  }

  Future<void> check({bool? networkAvailable}) async {
    if (!ref.mounted) return;
    final version = ++_checkVersion;
    if (networkAvailable == true) state = ConnectionStatus.checking;
    final result = await ref
        .read(connectionMonitorProvider)
        .check(networkAvailable: networkAvailable);
    // Un resultado viejo no reemplaza un cambio de red mas reciente.
    if (ref.mounted && version == _checkVersion) state = result;
  }
}
