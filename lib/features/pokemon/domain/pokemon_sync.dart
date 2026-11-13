abstract interface class PokemonSync {
  Future<void> synchronize({bool restart = false});
}
