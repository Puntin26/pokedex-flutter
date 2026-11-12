import '../../pokemon/domain/pokemon.dart';

class Favorite {
  const Favorite({required this.pokemon, required this.createdAt});

  final Pokemon pokemon;
  final DateTime createdAt;
}
