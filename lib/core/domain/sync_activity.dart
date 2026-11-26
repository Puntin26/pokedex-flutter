/// Actividad de sincronizacion en memoria; independiente de ConnectionStatus (§7.4).
/// No se guarda en SQLite: la metadata persistida es la que permite reanudar.
enum SyncActivity { idle, syncing, waitingRetry, failed }
