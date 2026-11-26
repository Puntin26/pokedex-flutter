abstract interface class PokemonDetailSync {
  /// Descarga el detalle y lo guarda; llamadas simultaneas comparten intento.
  Future<void> synchronize(int pokemonId);
}
