enum SyncStatus { idle, syncing, success, failed }

class SyncMetadata {
  const SyncMetadata({
    required this.resourceKey,
    this.nextOffset = 0,
    this.totalCount,
    this.status = SyncStatus.idle,
    this.lastSuccessAt,
    this.lastError,
    this.isComplete = false,
  });

  final String resourceKey;
  final int nextOffset;
  final int? totalCount;
  final SyncStatus status;
  final DateTime? lastSuccessAt;
  final String? lastError;
  final bool isComplete;
}
