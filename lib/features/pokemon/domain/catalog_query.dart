import 'dart:convert';

enum CatalogSort { number, name, baseStatTotal }

const _keep = Object();

/// Busqueda, filtros y orden del catalogo (RF-CAT-03, RF-FIL-01, RF-FIL-03).
/// Se resuelve en SQL; aqui solo se describe la consulta.
class CatalogQuery {
  const CatalogQuery({
    this.search = '',
    this.typeId,
    this.generationId,
    this.sort = CatalogSort.number,
    this.descending = false,
  });

  final String search;
  final int? typeId;
  final int? generationId;
  final CatalogSort sort;
  final bool descending;

  /// PokeAPI guarda nombres en minusculas y con guion ("mr-mime").
  String get normalizedSearch =>
      search.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '-');

  bool get isFiltered =>
      normalizedSearch.isNotEmpty || typeId != null || generationId != null;

  // _keep distingue "no cambiar" de "quitar el filtro" (null).
  CatalogQuery copyWith({
    String? search,
    Object? typeId = _keep,
    Object? generationId = _keep,
    CatalogSort? sort,
    bool? descending,
  }) => CatalogQuery(
    search: search ?? this.search,
    typeId: identical(typeId, _keep) ? this.typeId : typeId as int?,
    generationId: identical(generationId, _keep)
        ? this.generationId
        : generationId as int?,
    sort: sort ?? this.sort,
    descending: descending ?? this.descending,
  );

  /// JSON para guardarla entre sesiones (RF-FIL-04).
  String encode() => jsonEncode({
    'search': search,
    'typeId': typeId,
    'generationId': generationId,
    'sort': sort.name,
    'descending': descending,
  });

  /// Tolerante: un valor guardado corrupto o de otra version no rompe el
  /// arranque; cada campo invalido vuelve a su valor por defecto.
  static CatalogQuery decode(String? raw) {
    if (raw == null || raw.isEmpty) return const CatalogQuery();
    final Object? data;
    try {
      data = jsonDecode(raw);
    } on FormatException {
      return const CatalogQuery();
    }
    if (data is! Map<String, dynamic>) return const CatalogQuery();
    int? positiveId(Object? value) => value is int && value > 0 ? value : null;
    final search = data['search'];
    final descending = data['descending'];
    return CatalogQuery(
      search: search is String ? search : '',
      typeId: positiveId(data['typeId']),
      generationId: positiveId(data['generationId']),
      sort: CatalogSort.values.asNameMap()[data['sort']] ?? CatalogSort.number,
      descending: descending is bool && descending,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is CatalogQuery &&
      other.search == search &&
      other.typeId == typeId &&
      other.generationId == generationId &&
      other.sort == sort &&
      other.descending == descending;

  @override
  int get hashCode =>
      Object.hash(search, typeId, generationId, sort, descending);
}
