import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/pokemon_dependencies.dart';
import '../../../app/settings_provider.dart';
import '../domain/catalog_query.dart';
import '../domain/pokemon.dart';

/// Espera tras la ultima tecla antes de consultar SQLite (RF-CAT-03: 300-500 ms).
const searchDebounce = Duration(milliseconds: 400);
const catalogQuerySettingKey = 'catalog.query';

/// Consulta activa del catalogo, guardada entre sesiones (RF-FIL-04).
/// Se restaura antes de mostrar la lista para no saltar de "todo" a "filtrado".
/// La busqueda espera [searchDebounce]; tipo, generacion y orden van al instante.
class CatalogQueryController extends AsyncNotifier<CatalogQuery> {
  Timer? _searchTimer;

  @override
  Future<CatalogQuery> build() async {
    ref.onDispose(() => _searchTimer?.cancel());
    try {
      return CatalogQuery.decode(
        await ref.read(settingsRepositoryProvider).read(catalogQuerySettingKey),
      );
    } catch (error) {
      // Una preferencia ilegible no debe impedir ver el catalogo.
      debugPrint('[ajustes] No se pudo leer la consulta guardada: $error');
      return const CatalogQuery();
    }
  }

  void updateSearch(String text) {
    _searchTimer?.cancel();
    _searchTimer = Timer(
      searchDebounce,
      () => _update((query) => query.copyWith(search: text)),
    );
  }

  /// Borrar con la X no espera el debounce: el usuario ya decidio.
  void clearSearch() {
    _searchTimer?.cancel();
    _update((query) => query.copyWith(search: ''));
  }

  void setType(int? typeId) =>
      _update((query) => query.copyWith(typeId: typeId));

  void setGeneration(int? generationId) =>
      _update((query) => query.copyWith(generationId: generationId));

  void setAbility(int? abilityId) =>
      _update((query) => query.copyWith(abilityId: abilityId));

  void setSort(CatalogSort sort) =>
      _update((query) => query.copyWith(sort: sort));

  void toggleDescending() =>
      _update((query) => query.copyWith(descending: !query.descending));

  /// Quita busqueda y filtros; el orden elegido se conserva.
  void clearFilters() {
    _searchTimer?.cancel();
    _update(
      (query) => CatalogQuery(sort: query.sort, descending: query.descending),
    );
  }

  void _update(CatalogQuery Function(CatalogQuery current) change) {
    final current = state.value;
    // Antes de restaurar no hay controles visibles que llamen aqui.
    if (current == null || !ref.mounted) return;
    final next = change(current);
    if (next == current) return;
    state = AsyncData(next);
    unawaited(_save(next));
  }

  Future<void> _save(CatalogQuery query) async {
    try {
      await ref
          .read(settingsRepositoryProvider)
          .write(catalogQuerySettingKey, query.encode());
    } catch (error) {
      // Los filtros siguen funcionando en esta sesion; solo no se recordaran.
      debugPrint('[ajustes] No se pudo guardar la consulta: $error');
    }
  }
}

final catalogQueryProvider =
    AsyncNotifierProvider<CatalogQueryController, CatalogQuery>(
      CatalogQueryController.new,
    );

// Opciones de los menus; salen de SQLite, asi funcionan offline.
final catalogTypesProvider = StreamProvider<List<PokemonType>>(
  (ref) => ref.watch(pokemonRepositoryProvider).watchTypes(),
);

final catalogGenerationsProvider = StreamProvider<List<Generation>>(
  (ref) => ref.watch(pokemonRepositoryProvider).watchGenerations(),
);

final catalogAbilitiesProvider = StreamProvider<List<Ability>>(
  (ref) => ref.watch(pokemonRepositoryProvider).watchAbilities(),
);
