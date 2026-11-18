import '../../../core/domain/sync_activity.dart';

abstract interface class PokemonSync {
  Future<void> synchronize({bool restart = false});

  SyncActivity get activity;

  /// Emite la actividad actual al suscribirse y luego cada cambio.
  Stream<SyncActivity> watchActivity();
}
