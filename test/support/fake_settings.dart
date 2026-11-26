import 'package:pokedex/core/domain/settings_repository.dart';

// Preferencias en memoria: responde en microtareas, sirve con tiempo falso.
class FakeSettings implements SettingsRepository {
  FakeSettings([Map<String, String>? initial]) : values = {...?initial};

  final Map<String, String> values;
  int writes = 0;

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async {
    writes++;
    values[key] = value;
  }
}
