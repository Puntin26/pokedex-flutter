enum ConnectionStatus { checking, online, offline, serviceUnavailable }

class ConnectionMonitor {
  const ConnectionMonitor({
    required this.hasNetwork,
    required this.networkChanges,
    required this.isServiceAvailable,
  });

  final Future<bool> Function() hasNetwork;
  final Stream<bool> networkChanges;
  final Future<bool> Function() isServiceAvailable;

  Future<ConnectionStatus> check({bool? networkAvailable}) async {
    try {
      if (!(networkAvailable ?? await hasNetwork())) {
        return ConnectionStatus.offline;
      }
      // La presencia de red no confirma que GraphQL este accesible.
      return await isServiceAvailable()
          ? ConnectionStatus.online
          : ConnectionStatus.serviceUnavailable;
    } catch (_) {
      return ConnectionStatus.serviceUnavailable;
    }
  }
}
