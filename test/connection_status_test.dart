import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pokedex/app/connection_status_provider.dart';
import 'package:pokedex/app/connection_indicator.dart';
import 'package:pokedex/app/connection_indicator_state.dart';
import 'package:pokedex/app/pokemon_dependencies.dart';
import 'package:pokedex/core/connectivity/connection_monitor.dart';
import 'package:pokedex/core/domain/sync_activity.dart';
import 'package:pokedex/features/pokemon/presentation/pokemon_catalog_controller.dart';

void main() {
  late StreamController<bool> changes;
  late bool network;
  late Future<bool> Function() service;
  ProviderContainer? container;

  setUp(() {
    changes = StreamController<bool>.broadcast();
    network = false;
    service = () async => true;
  });
  tearDown(() async {
    container?.dispose();
    await changes.close();
  });

  Future<void> mount(WidgetTester tester) async {
    addTearDown(() {
      container?.dispose();
      container = null;
    });
    container = ProviderContainer(
      overrides: [
        connectionMonitorProvider.overrideWithValue(
          ConnectionMonitor(
            hasNetwork: () async => network,
            networkChanges: changes.stream,
            isServiceAvailable: () => service(),
          ),
        ),
        // Estas pruebas miran la conexion; el catalogo queda vacio y quieto.
        // Los cambios entre estados firmes esperan el antiparpadeo (IND-06).
        catalogMetadataProvider.overrideWith((ref) => Stream.value(null)),
        catalogSyncActivityProvider.overrideWith(
          (ref) => Stream.value(SyncActivity.idle),
        ),
      ],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container!,
        child: const MaterialApp(home: Scaffold(body: ConnectionIndicator())),
      ),
    );
    await tester.pump();
  }

  testWidgets('Sin red muestra Offline con texto, icono y Semantics', (
    tester,
  ) async {
    var probes = 0;
    service = () async {
      probes++;
      return true;
    };
    await mount(tester);
    expect(find.text('Offline'), findsOneWidget);
    expect(find.byIcon(Icons.wifi_off), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp(r'^Offline\. ')), findsOneWidget);
    expect(probes, 0);
  });

  testWidgets('Wi-Fi con API fallida nunca se declara Online y se recupera', (
    tester,
  ) async {
    network = true;
    service = () async => false;
    await mount(tester);
    expect(find.text('Servicio no disponible'), findsOneWidget);
    expect(find.byIcon(Icons.cloud_off_outlined), findsOneWidget);
    expect(find.text('Online'), findsNothing);
    service = () async => true;
    changes.add(true);
    await tester.pump();
    await tester.pump();
    await tester.pump(DisplayedConnectionStatus.delay);
    expect(find.text('Online'), findsOneWidget);
    expect(find.byIcon(Icons.cloud_done_outlined), findsOneWidget);
    changes.add(false);
    await tester.pump();
    await tester.pump();
    await tester.pump(DisplayedConnectionStatus.delay);
    expect(find.text('Offline'), findsOneWidget);
  });

  testWidgets('Un chequeo pendiente no reemplaza una perdida de red reciente', (
    tester,
  ) async {
    network = true;
    final pending = Completer<bool>();
    service = () => pending.future;
    await mount(tester);
    expect(find.text('Comprobando conexion...'), findsOneWidget);
    changes.add(false);
    await tester.pump();
    await tester.pump();
    pending.complete(true);
    await tester.pump();
    expect(find.text('Offline'), findsOneWidget);
    expect(find.text('Online'), findsNothing);
  });

  testWidgets('Revisa el servicio sin cambiar de red y al volver a la app', (
    tester,
  ) async {
    network = true;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await mount(tester);
    expect(find.text('Online'), findsOneWidget);
    service = () async => false;
    await tester.pump(const Duration(seconds: 30));
    await tester.pump();
    await tester.pump(DisplayedConnectionStatus.delay);
    expect(find.text('Servicio no disponible'), findsOneWidget);
    service = () async => true;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    await tester.pump();
    await tester.pump(DisplayedConnectionStatus.delay);
    expect(find.text('Online'), findsOneWidget);
  });

  testWidgets('Los errores del monitor no rompen la pantalla', (tester) async {
    network = true;
    service = () async => throw StateError('Fallo de servicio');
    await mount(tester);
    expect(find.text('Servicio no disponible'), findsOneWidget);
    changes.addError(StateError('Fallo de eventos'));
    await tester.pump();
    expect(find.text('Servicio no disponible'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Descartar el alcance cancela eventos e ignora resultados tardios',
    (tester) async {
      network = true;
      final pending = Completer<bool>();
      service = () => pending.future;
      await mount(tester);
      await tester.pumpWidget(const SizedBox());
      container!.dispose();
      container = null;
      pending.complete(true);
      await tester.pump();
      await tester.pump(const Duration(seconds: 30));
      expect(changes.hasListener, isFalse);
      expect(tester.takeException(), isNull);
    },
  );
}
