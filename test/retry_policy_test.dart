import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/core/domain/sync_failure.dart';
import 'package:pokedex/core/sync/retry_policy.dart';

// Random fijo: siempre devuelve el mismo valor para que el jitter sea predecible.
class FixedRandom implements Random {
  FixedRandom(this.value);
  final double value;

  @override
  double nextDouble() => value;
  @override
  int nextInt(int max) => (value * max).floor();
  @override
  bool nextBool() => value >= 0.5;
}

void main() {
  late List<Duration> waits;
  late List<String> logs;

  RetryPolicy policy({int maxRetries = 5, double jitter = 0}) => RetryPolicy(
    maxRetries: maxRetries,
    wait: (delay) async => waits.add(delay),
    random: FixedRandom(jitter),
    log: logs.add,
  );

  setUp(() {
    waits = [];
    logs = [];
  });

  test('Espera 2, 4, 8, 16 y 32 s y se rinde tras 5 reintentos', () async {
    var calls = 0;
    final result = policy().run<void>(() async {
      calls++;
      throw const SyncFailure(SyncFailureKind.timeout, 'sin respuesta');
    }, label: 'catalogo');

    await expectLater(
      result,
      throwsA(
        isA<SyncFailure>().having(
          (f) => f.kind,
          'kind',
          SyncFailureKind.timeout,
        ),
      ),
    );
    expect(calls, 6);
    expect(waits, [
      const Duration(seconds: 2),
      const Duration(seconds: 4),
      const Duration(seconds: 8),
      const Duration(seconds: 16),
      const Duration(seconds: 32),
    ]);
    // Un log por reintento + uno al agotar los intentos (PA-08).
    expect(logs, hasLength(6));
    expect(logs.first, contains('catalogo'));
    expect(logs.first, contains('1/5'));
    expect(logs.last, contains('agotados'));
  });

  test('Devuelve el resultado cuando un reintento funciona', () async {
    var calls = 0;
    final value = await policy().run(() async {
      calls++;
      if (calls < 3) {
        throw const SyncFailure(SyncFailureKind.network, 'sin red');
      }
      return 'ok';
    });

    expect(value, 'ok');
    expect(calls, 3);
    expect(waits, [const Duration(seconds: 2), const Duration(seconds: 4)]);
  });

  test('Reintenta solo fallos temporales', () async {
    const temporary = [
      SyncFailureKind.timeout,
      SyncFailureKind.network,
      SyncFailureKind.serviceUnavailable,
      SyncFailureKind.rateLimited,
    ];
    for (final kind in SyncFailureKind.values) {
      waits.clear();
      var calls = 0;
      await expectLater(
        policy(maxRetries: 1).run<void>(() async {
          calls++;
          throw SyncFailure(kind, 'fallo');
        }),
        throwsA(isA<SyncFailure>()),
      );
      final retried = temporary.contains(kind);
      expect(calls, retried ? 2 : 1, reason: kind.name);
      expect(waits, retried ? hasLength(1) : isEmpty, reason: kind.name);
    }
  });

  test('Un error que no es SyncFailure no se reintenta', () async {
    var calls = 0;
    await expectLater(
      policy().run<void>(() async {
        calls++;
        throw StateError('bug');
      }),
      throwsA(isA<StateError>()),
    );
    expect(calls, 1);
    expect(waits, isEmpty);
  });

  test('El jitter suma hasta maxJitter sobre la espera base', () async {
    var calls = 0;
    await policy(jitter: 0.5).run(() async {
      if (calls++ == 0) {
        throw const SyncFailure(SyncFailureKind.timeout, 'lento');
      }
    });
    // 2 s + 50 % de 500 ms de jitter.
    expect(waits, [const Duration(milliseconds: 2250)]);
  });

  test('maxRetries 0 no reintenta (politica para pruebas)', () async {
    await expectLater(
      policy(maxRetries: 0).run<void>(
        () async => throw const SyncFailure(SyncFailureKind.timeout, 'lento'),
      ),
      throwsA(isA<SyncFailure>()),
    );
    expect(waits, isEmpty);
  });

  test('Rechaza configuraciones invalidas', () {
    expect(() => RetryPolicy(maxRetries: -1), throwsArgumentError);
  });
}
