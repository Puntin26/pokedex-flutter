import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/database/local_settings_repository.dart';
import '../core/domain/settings_repository.dart';
import 'pokemon_dependencies.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => LocalSettingsRepository(ref.watch(appDatabaseProvider)),
);
