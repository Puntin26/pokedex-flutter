import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/pokemon_dependencies.dart';
import '../domain/catalog_query.dart';
import '../domain/pokemon.dart';

/// Espera tras la ultima tecla antes de consultar SQLite (RF-CAT-03: 300-500 ms).
const searchDebounce = Duration(milliseconds: 400);

/// Consulta activa del catalogo. La busqueda espera [searchDebounce]; tipo,
/// generacion y orden se aplican al instante.
class CatalogQueryController extends Notifier<CatalogQuery> {
  Timer? _searchTimer;

  @override
  CatalogQuery build() {
    ref.onDispose(() => _searchTimer?.cancel());
    return const CatalogQuery();
  }

  void updateSearch(String text) {
    _searchTimer?.cancel();
    _searchTimer = Timer(
      searchDebounce,
      () => state = state.copyWith(search: text),
    );
  }

  /// Borrar con la X no espera el debounce: el usuario ya decidio.
  void clearSearch() {
    _searchTimer?.cancel();
    state = state.copyWith(search: '');
  }

  void setType(int? typeId) => state = state.copyWith(typeId: typeId);

  void setGeneration(int? generationId) =>
      state = state.copyWith(generationId: generationId);

  void setSort(CatalogSort sort) => state = state.copyWith(sort: sort);

  void toggleDescending() =>
      state = state.copyWith(descending: !state.descending);

  /// Quita busqueda y filtros; el orden elegido se conserva.
  void clearFilters() {
    _searchTimer?.cancel();
    state = CatalogQuery(sort: state.sort, descending: state.descending);
  }
}

final catalogQueryProvider =
    NotifierProvider<CatalogQueryController, CatalogQuery>(
      CatalogQueryController.new,
    );

// Opciones de los menus; salen de SQLite, asi funcionan offline.
final catalogTypesProvider = StreamProvider<List<PokemonType>>(
  (ref) => ref.watch(pokemonRepositoryProvider).watchTypes(),
);

final catalogGenerationsProvider = StreamProvider<List<Generation>>(
  (ref) => ref.watch(pokemonRepositoryProvider).watchGenerations(),
);
