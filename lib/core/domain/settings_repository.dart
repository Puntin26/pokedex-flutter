/// Preferencias del usuario como clave/valor (tabla app_setting). La
/// sincronizacion del catalogo nunca las escribe (PS-11).
abstract interface class SettingsRepository {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
}
