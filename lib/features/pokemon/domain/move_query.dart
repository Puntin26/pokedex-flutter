enum MoveSort { level, name }

/// Movimientos de un Pokemon en un juego; por defecto solo level-up (RF-DET-05).
class MoveQuery {
  const MoveQuery({
    required this.pokemonId,
    required this.versionGroupId,
    this.learnMethod = 'level-up',
    this.sort = MoveSort.level,
  });

  final int pokemonId;
  final int versionGroupId;
  // null = todos los metodos.
  final String? learnMethod;
  final MoveSort sort;

  @override
  bool operator ==(Object other) =>
      other is MoveQuery &&
      other.pokemonId == pokemonId &&
      other.versionGroupId == versionGroupId &&
      other.learnMethod == learnMethod &&
      other.sort == sort;

  @override
  int get hashCode => Object.hash(pokemonId, versionGroupId, learnMethod, sort);
}
