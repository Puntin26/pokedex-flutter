import '../domain/settings_repository.dart';
import 'app_database.dart';

class LocalSettingsRepository implements SettingsRepository {
  LocalSettingsRepository(this.database);

  final AppDatabase database;

  @override
  Future<String?> read(String key) async {
    final row = await (database.select(
      database.appSettings,
    )..where((setting) => setting.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  // Upsert por clave: una sola fila por preferencia.
  @override
  Future<void> write(String key, String value) => database
      .into(database.appSettings)
      .insertOnConflictUpdate(
        AppSettingsCompanion.insert(key: key, value: value),
      );
}
