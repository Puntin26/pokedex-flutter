import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/core/connectivity/connection_monitor.dart';
import 'package:pokedex/core/sync/sync_scheduler.dart';

// Timer manual: el test decide cuando "pasa" el periodo.
class FakeTimer implements Timer {
  FakeTimer(this.period, this.callback);
  final Duration period;
  final void Function(Timer) callback;
  bool cancelled = false;
  int ticks = 0;

  void fire() {
    if (cancelled) return;
    ticks++;
    callback(this);
  }

  @override
  void cancel() => cancelled = true;
  @override
  bool get isActive => !cancelled;
  @override
  int get tick => ticks;
}

void main() {
  late int syncs;
  late List<FakeTimer> timers;
  late SyncScheduler scheduler;

  setUp(() {
    syncs = 0;
    timers = [];
    scheduler = SyncScheduler(
      synchronize: () async => syncs++,
      period: const Duration(minutes: 15),
      periodicTimer: (period, callback) {
        final timer = FakeTimer(period, callback);
        timers.add(timer);
        return timer;
      },
      log: (_) {},
    );
  });
  tearDown(() => scheduler.dispose());

  void emit(List<ConnectionStatus> statuses) {
    for (final status in statuses) {
      scheduler.onStatus(status);
    }
  }

  FakeTimer? activeTimer() =>
      timers.where((timer) => timer.isActive).singleOrNull;

  test('Al iniciar online no duplica la sync de arranque', () {
    emit([ConnectionStatus.checking, ConnectionStatus.online]);
    expect(syncs, 0);
    expect(activeTimer(), isNotNull);
  });

  test('Reconexion offline -> online dispara una sola sync', () {
    emit([
      ConnectionStatus.checking,
      ConnectionStatus.offline,
      ConnectionStatus.checking,
      ConnectionStatus.online,
      ConnectionStatus.online,
      ConnectionStatus.checking,
      ConnectionStatus.online,
    ]);
    expect(syncs, 1);
  });

  test('Recuperacion del servicio con red tambien sincroniza (PA-08)', () {
    emit([ConnectionStatus.online, ConnectionStatus.serviceUnavailable]);
    expect(syncs, 0);
    emit([ConnectionStatus.online]);
    expect(syncs, 1);
  });

  test('Cada caida y recuperacion cuenta como una reconexion', () {
    emit([
      ConnectionStatus.offline,
      ConnectionStatus.online,
      ConnectionStatus.offline,
      ConnectionStatus.serviceUnavailable,
      ConnectionStatus.online,
    ]);
    expect(syncs, 2);
  });

  test('Sincroniza cada periodo solo mientras esta online', () {
    emit([ConnectionStatus.online]);
    final timer = activeTimer()!;
    expect(timer.period, const Duration(minutes: 15));
    timer.fire();
    timer.fire();
    expect(syncs, 2);

    emit([ConnectionStatus.offline]);
    expect(timer.cancelled, isTrue);
    expect(activeTimer(), isNull);
    timer.fire();
    expect(syncs, 2);
  });

  test('checking no detiene ni reinicia el timer periodico', () {
    emit([ConnectionStatus.online]);
    final timer = activeTimer()!;
    emit([ConnectionStatus.checking, ConnectionStatus.online]);
    expect(activeTimer(), same(timer));
    expect(timers, hasLength(1));
  });

  test('Un fallo de la sync no rompe el scheduler', () async {
    final logs = <String>[];
    scheduler.dispose();
    scheduler = SyncScheduler(
      synchronize: () async {
        syncs++;
        throw StateError('fallo');
      },
      periodicTimer: (period, callback) => FakeTimer(period, callback),
      log: logs.add,
    );
    emit([ConnectionStatus.offline, ConnectionStatus.online]);
    await pumpEventQueue();
    emit([ConnectionStatus.offline, ConnectionStatus.online]);
    await pumpEventQueue();
    expect(syncs, 2);
    expect(logs.where((line) => line.contains('fallo:')), hasLength(2));
  });

  test('dispose cancela el timer e ignora estados posteriores', () {
    emit([ConnectionStatus.online]);
    final timer = activeTimer()!;
    scheduler.dispose();
    expect(timer.cancelled, isTrue);
    emit([ConnectionStatus.offline, ConnectionStatus.online]);
    expect(syncs, 0);
  });
}
