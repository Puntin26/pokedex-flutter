import 'package:material_ui/material_ui.dart';

/// Lugar reservado para la trivia "¿Quien es este Pokemon?" (Fase 6).
class TriviaPage extends StatelessWidget {
  const TriviaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trivia')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'La trivia "¿Quien es este Pokemon?" estara disponible pronto.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
