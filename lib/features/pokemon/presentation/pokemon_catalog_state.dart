import '../domain/pokemon.dart';

enum PokemonCatalogStatus { loading, data, empty, error }

class PokemonCatalogState {
  const PokemonCatalogState({
    required this.status,
    required this.pokemon,
    required this.isSyncing,
    this.errorMessage,
  });

  final PokemonCatalogStatus status;
  final List<Pokemon> pokemon;
  final bool isSyncing;
  final String? errorMessage;
}
