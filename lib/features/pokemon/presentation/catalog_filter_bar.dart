import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../domain/catalog_query.dart';
import '../domain/pokemon.dart';
import 'catalog_query_controller.dart';

const catalogSearchFieldKey = Key('catalog-search');
const catalogTypeMenuKey = Key('catalog-type-menu');
const catalogGenerationMenuKey = Key('catalog-generation-menu');
const catalogSortMenuKey = Key('catalog-sort-menu');
const catalogDirectionButtonKey = Key('catalog-direction');

/// Buscador, filtros por tipo y generacion y orden (RF-CAT-03, RF-FIL-01, RF-FIL-03).
class CatalogFilterBar extends ConsumerStatefulWidget {
  const CatalogFilterBar({super.key});

  @override
  ConsumerState<CatalogFilterBar> createState() => _CatalogFilterBarState();
}

class _CatalogFilterBarState extends ConsumerState<CatalogFilterBar> {
  late final TextEditingController _search;

  @override
  void initState() {
    super.initState();
    // La pagina solo crea esta barra cuando la consulta ya se restauro.
    _search = TextEditingController(
      text: ref.read(catalogQueryProvider).requireValue.search,
    )..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // "Limpiar filtros" se pulsa fuera de este widget: vacia tambien el campo.
    ref.listen(catalogQueryProvider, (previous, next) {
      final search = next.value?.search;
      if (search != null &&
          search.isEmpty &&
          (previous?.value?.search.isNotEmpty ?? false) &&
          _search.text.isNotEmpty) {
        _search.clear();
      }
    });
    final query = ref.watch(catalogQueryProvider).requireValue;
    final controller = ref.read(catalogQueryProvider.notifier);
    final types = ref.watch(catalogTypesProvider).value ?? const [];
    final generations = ref.watch(catalogGenerationsProvider).value ?? const [];

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // En telefonos dos menus por fila; en pantallas anchas todos en una.
          final menuWidth = constraints.maxWidth >= 720
              ? 200.0
              : (constraints.maxWidth - 8) / 2;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                key: catalogSearchFieldKey,
                controller: _search,
                onChanged: controller.updateSearch,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  labelText: 'Buscar por nombre',
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(),
                  suffixIcon: _search.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Borrar busqueda',
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _search.clear();
                            controller.clearSearch();
                          },
                        ),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _Menu<int?>(
                    key: catalogTypeMenuKey,
                    width: menuWidth,
                    label: 'Tipo',
                    value: query.typeId,
                    onChanged: controller.setType,
                    options: [
                      (null, 'Todos los tipos'),
                      for (final type in types) (type.id, typeLabel(type)),
                    ],
                  ),
                  _Menu<int?>(
                    key: catalogGenerationMenuKey,
                    width: menuWidth,
                    label: 'Generacion',
                    value: query.generationId,
                    onChanged: controller.setGeneration,
                    options: [
                      (null, 'Todas las generaciones'),
                      for (final generation in generations)
                        (generation.id, generationLabel(generation)),
                    ],
                  ),
                  _Menu<CatalogSort>(
                    key: catalogSortMenuKey,
                    width: menuWidth,
                    label: 'Ordenar por',
                    value: query.sort,
                    onChanged: (sort) {
                      if (sort != null) controller.setSort(sort);
                    },
                    options: const [
                      (CatalogSort.number, 'Numero'),
                      (CatalogSort.name, 'Nombre'),
                      (CatalogSort.baseStatTotal, 'Total base'),
                    ],
                  ),
                  IconButton(
                    key: catalogDirectionButtonKey,
                    tooltip: query.descending
                        ? 'Orden descendente'
                        : 'Orden ascendente',
                    icon: Icon(
                      query.descending
                          ? Icons.arrow_downward
                          : Icons.arrow_upward,
                      // El tooltip es una pista; el lector necesita la etiqueta.
                      semanticLabel: query.descending
                          ? 'Orden descendente'
                          : 'Orden ascendente',
                    ),
                    onPressed: controller.toggleDescending,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Menu<T> extends StatelessWidget {
  const _Menu({
    super.key,
    required this.width,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final double width;
  final String label;
  final T value;
  final List<(T, String)> options;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    // Si el valor guardado ya no existe en las opciones, se muestra "todos".
    final selected = options.any((option) => option.$1 == value)
        ? value
        : options.first.$1;
    return SizedBox(
      width: width,
      child: Semantics(
        label: label,
        child: DropdownButton<T>(
          isExpanded: true,
          value: selected,
          onChanged: onChanged,
          items: [
            for (final (optionValue, text) in options)
              DropdownMenuItem<T>(
                value: optionValue,
                child: Text(text, overflow: TextOverflow.ellipsis),
              ),
          ],
        ),
      ),
    );
  }
}

/// "grass" -> "Grass". Las traducciones llegan con i18n (Fase 6).
String typeLabel(PokemonType type) => _capitalize(type.name);

/// "generation-ii" + "johto" -> "Gen II · Johto".
String generationLabel(Generation generation) {
  final numeral = generation.name.split('-').last.toUpperCase();
  final region = generation.regionName;
  return region == null
      ? 'Gen $numeral'
      : 'Gen $numeral · ${_capitalize(region)}';
}

String _capitalize(String value) =>
    value.isEmpty ? value : value[0].toUpperCase() + value.substring(1);
