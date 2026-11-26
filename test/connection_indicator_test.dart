import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pokedex/app/clock_provider.dart';
import 'package:pokedex/app/connection_indicator.dart';
import 'package:pokedex/app/connection_status_provider.dart';
import 'package:pokedex/app/pokemon_dependencies.dart';
import 'package:pokedex/core/connectivity/connection_monitor.dart';
import 'package:pokedex/core/domain/sync_activity.dart';
import 'package:pokedex/core/domain/sync_metadata.dart';
import 'package:pokedex/features/pokemon/presentation/pokemon_catalog_controller.dart';

// Estado de conexion manejado a mano por el test.
class ManualStatus extends ConnectionStatusController {
  ManualStatus(this.initial);
  final ConnectionStatus initial;

  @override
  ConnectionStatus build() => initial;

  void set(ConnectionStatus status) => state = status;
}

final now = DateTime(2026, 11, 26, 15);

SyncMetadata catalogAt(DateTime lastSuccessAt, {bool isComplete = true}) =>
    SyncMetadata(
      resourceKey: catalogResourceKey,
      lastSuccessAt: lastSuccessAt,
      isComplete: isComplete,
      status: SyncStatus.success,
    );

void main() {
  late ManualStatus status;
  late StreamController<SyncActivity> activity;

  setUp(() => activity = StreamController<SyncActivity>.broadcast());
  // close() espera a que cada oyente reciba "done"; si una prueba falla con el
  // arbol aun montado, esperarlo colgaria la suite.
  tearDown(() => unawaited(activity.close()));

  Future<void> mount(
    WidgetTester tester, {
    ConnectionStatus initial = ConnectionStatus.online,
    SyncMetadata? metadata,
    double textScale = 1,
    double width = 400,
  }) async {
    status = ManualStatus(initial);
    tester.view.physicalSize = Size(width, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          connectionStatusProvider.overrideWith(() => status),
          catalogMetadataProvider.overrideWith((ref) => Stream.value(metadata)),
          catalogSyncActivityProvider.overrideWith((ref) => activity.stream),
          clockProvider.overrideWithValue(() => now),
        ],
        child: MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
            child: const Scaffold(body: ConnectionIndicator()),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  // El evento del stream llega en un microtask y el widget se repinta en el frame siguiente.
  Future<void> emitActivity(WidgetTester tester, SyncActivity next) async {
    activity.add(next);
    await tester.pump();
    await tester.pump();
  }

  Future<void> change(WidgetTester tester, ConnectionStatus next) async {
    status.set(next);
    await tester.pump();
  }

  testWidgets('Online con catalogo vigente: datos remotos y hora', (
    tester,
  ) async {
    await mount(tester, metadata: catalogAt(DateTime(2026, 11, 26, 14, 5)));
    expect(find.text('Online'), findsOneWidget);
    expect(find.text('Datos remotos · actualizado 14:05'), findsOneWidget);
    expect(
      find.bySemanticsLabel('Online. Datos remotos · actualizado 14:05'),
      findsOneWidget,
    );
  });

  testWidgets('Offline muestra datos locales aunque esten vigentes', (
    tester,
  ) async {
    await mount(
      tester,
      initial: ConnectionStatus.offline,
      metadata: catalogAt(DateTime(2026, 11, 26, 9, 30)),
    );
    expect(find.text('Offline'), findsOneWidget);
    expect(find.byIcon(Icons.wifi_off), findsOneWidget);
    expect(find.text('Datos locales · actualizado 09:30'), findsOneWidget);
  });

  testWidgets('Catalogo de mas de 24 h es local y desactualizado', (
    tester,
  ) async {
    await mount(tester, metadata: catalogAt(DateTime(2026, 11, 24, 8, 0)));
    expect(
      find.text('Datos locales · actualizado 24/11 08:00 · desactualizado'),
      findsOneWidget,
    );
  });

  testWidgets('Sin catalogo guardado lo dice', (tester) async {
    await mount(tester, initial: ConnectionStatus.serviceUnavailable);
    expect(find.text('Servicio no disponible'), findsOneWidget);
    expect(find.text('Sin datos guardados'), findsOneWidget);
  });

  testWidgets('Muestra la actividad de sync sin ocultar la conexion', (
    tester,
  ) async {
    await mount(tester, metadata: catalogAt(DateTime(2026, 11, 26, 14, 5)));
    await emitActivity(tester, SyncActivity.syncing);
    expect(find.text('Online'), findsOneWidget);
    expect(find.text('Sincronizando'), findsOneWidget);
    expect(find.byIcon(Icons.sync), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp(r'^Online\. Sincronizando\. ')),
      findsOneWidget,
    );

    await emitActivity(tester, SyncActivity.waitingRetry);
    expect(find.text('Reintentando'), findsOneWidget);
    expect(find.text('Sincronizando'), findsNothing);

    await emitActivity(tester, SyncActivity.idle);
    expect(find.text('Reintentando'), findsNothing);
    expect(find.byIcon(Icons.sync), findsNothing);
  });

  testWidgets('Una caida breve no parpadea (IND-06)', (tester) async {
    await mount(tester);
    await change(tester, ConnectionStatus.offline);
    await tester.pump(const Duration(milliseconds: 800));
    await change(tester, ConnectionStatus.online);
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('Offline'), findsNothing);
    expect(find.text('Online'), findsOneWidget);
  });

  testWidgets('Un cambio que se mantiene aparece tras 1.5 s', (tester) async {
    await mount(tester);
    await change(tester, ConnectionStatus.serviceUnavailable);
    await tester.pump(const Duration(milliseconds: 1400));
    expect(find.text('Online'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Servicio no disponible'), findsOneWidget);
  });

  testWidgets('Comprobando no reemplaza el ultimo estado conocido', (
    tester,
  ) async {
    await mount(tester);
    await change(tester, ConnectionStatus.checking);
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('Online'), findsOneWidget);
    expect(find.text('Comprobando conexion...'), findsNothing);
  });

  testWidgets('Al iniciar el primer resultado aparece de inmediato', (
    tester,
  ) async {
    await mount(tester, initial: ConnectionStatus.checking);
    expect(find.text('Comprobando conexion...'), findsOneWidget);
    await change(tester, ConnectionStatus.offline);
    expect(find.text('Offline'), findsOneWidget);
  });

  testWidgets('Texto al 200 % en pantalla estrecha no desborda', (
    tester,
  ) async {
    await mount(
      tester,
      initial: ConnectionStatus.serviceUnavailable,
      metadata: catalogAt(DateTime(2026, 11, 24, 8, 0)),
      textScale: 2,
      width: 320,
    );
    await emitActivity(tester, SyncActivity.waitingRetry);
    expect(tester.takeException(), isNull);
    expect(find.text('Reintentando'), findsOneWidget);
  });
}
