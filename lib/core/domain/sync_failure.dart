enum SyncFailureKind {
  timeout,
  network,
  serviceUnavailable,
  rateLimited,
  graphql,
  invalidResponse,
  storage,
}

class SyncFailure implements Exception {
  const SyncFailure(this.kind, this.message);

  final SyncFailureKind kind;
  final String message;

  @override
  String toString() => '${kind.name}: $message';
}
