import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pokedex/features/pokemon/domain/pokemon.dart';
import 'package:pokedex/features/pokemon/presentation/pokemon_card.dart';

Pokemon pokemon({String? imageUrl, bool twoTypes = true}) => Pokemon(
  id: 10001,
  nationalNumber: 1,
  name: 'bulbasaur',
  imageUrl: imageUrl,
  updatedAt: DateTime.utc(2026, 11, 15),
  types: [
    const PokemonTypeSlot(type: PokemonType(id: 12, name: 'grass'), slot: 1),
    if (twoTypes)
      const PokemonTypeSlot(type: PokemonType(id: 4, name: 'poison'), slot: 2),
  ],
);

void main() {
  testWidgets('Carga la imagen desde HTTP local sin cambiar el espacio', (
    tester,
  ) async {
    late HttpServer server;
    late HttpClient client;
    await tester.runAsync(() async {
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      server.listen((request) async {
        request.response.add(
          base64Decode(
            'R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7',
          ),
        );
        await request.response.close();
      });
      client = _LocalImageHttpOverrides().createHttpClient(null);
    });
    debugNetworkImageHttpClientProvider = () => client;
    addTearDown(() async {
      debugNetworkImageHttpClientProvider = null;
      client.close(force: true);
      await server.close(force: true);
    });
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PokemonCard(
            pokemon: pokemon(
              imageUrl: 'http://127.0.0.1:${server.port}/image.gif',
            ),
          ),
        ),
      ),
    );
    expect(find.byIcon(Icons.image_outlined), findsOneWidget);
    final cardSize = tester.getSize(find.byType(PokemonCard));
    for (var attempt = 0; attempt < 50; attempt++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await tester.pump();
      if (find.byType(RawImage).evaluate().isNotEmpty) break;
    }
    expect(tester.widget<RawImage>(find.byType(RawImage)).image, isNotNull);
    expect(find.text('Sin imagen'), findsNothing);
    expect(tester.getSize(find.byType(PokemonCard)), cardSize);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Muestra numero nacional, nombre, ambos tipos e imagen ausente', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: PokemonCard(pokemon: pokemon())),
      ),
    );
    expect(find.text('#1'), findsOneWidget);
    expect(find.text('#10001'), findsNothing);
    expect(find.text('bulbasaur'), findsOneWidget);
    expect(find.text('grass'), findsOneWidget);
    expect(find.text('poison'), findsOneWidget);
    expect(find.text('Sin imagen'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('Una URL que falla muestra respaldo sin perder los datos', (
    tester,
  ) async {
    // flutter_test responde HTTP 400, sin hacer solicitudes a Internet.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PokemonCard(
            pokemon: pokemon(imageUrl: 'https://example.com/missing.png'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Sin imagen'), findsOneWidget);
    expect(find.text('bulbasaur'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Un tipo y texto grande caben en una pantalla estrecha', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: Scaffold(
            body: ListView(
              children: [PokemonCard(pokemon: pokemon(twoTypes: false))],
            ),
          ),
        ),
      ),
    );
    expect(find.byType(Chip), findsOneWidget);
    expect(find.text('grass'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

// Permite solo a esta prueba usar su servidor HTTP de loopback.
class _LocalImageHttpOverrides extends HttpOverrides {}
