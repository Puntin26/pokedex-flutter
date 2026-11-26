import 'sync_metadata.dart';

/// Vigencia de los datos locales (PS-03): un recurso esta desactualizado si nunca
/// se completo o si su ultima sincronizacion completa supera [maxAge].
class FreshnessPolicy {
  const FreshnessPolicy({this.maxAge = const Duration(hours: 24)});

  final Duration maxAge;

  bool isStale(SyncMetadata? metadata, DateTime now) {
    final lastSuccessAt = metadata?.lastSuccessAt;
    if (metadata == null || !metadata.isComplete || lastSuccessAt == null) {
      return true;
    }
    return now.difference(lastSuccessAt) > maxAge;
  }
}
