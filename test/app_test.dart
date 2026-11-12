import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/main.dart' as app;

void main() {
  testWidgets('La aplicacion inicia sin depender de datos remotos', (
    tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    expect(find.text('Pokedex'), findsOneWidget);
    expect(find.text('Proyecto en preparacion.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
