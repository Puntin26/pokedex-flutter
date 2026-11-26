import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/favorites/data/local_favorites_repository.dart';
import '../features/favorites/domain/favorites_repository.dart';
import 'pokemon_dependencies.dart';

final favoritesRepositoryProvider = Provider<FavoritesRepository>(
  (ref) => LocalFavoritesRepository(ref.watch(appDatabaseProvider)),
);
