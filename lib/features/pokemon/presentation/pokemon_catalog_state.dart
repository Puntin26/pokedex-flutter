import '../domain/pokemon.dart';

// noResults: hay catalogo local, pero la busqueda o los filtros no coinciden.
enum PokemonCatalogStatus { loading, data, empty, noResults, error }

class PokemonCatalogState {
  const PokemonCatalogState({
    required this.status,
    required this.pokemon,
    required this.isSyncing,
    this.errorMessage,
    this.partialDownloaded,
    this.partialTotal,
  });

  final PokemonCatalogStatus status;
  final List<Pokemon> pokemon;
  final bool isSyncing;
  final String? errorMessage;
  // Con valor solo si el catalogo local esta incompleto (RF-FIL-05).
  final int? partialDownloaded;
  final int? partialTotal;

  bool get isPartial => partialTotal != null;
}
