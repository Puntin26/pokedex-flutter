import 'dart:math';

import 'package:flutter/foundation.dart';

import '../domain/sync_failure.dart';

typedef RetryWait = Future<void> Function(Duration delay);
typedef RetryLog = void Function(String message);

/// Reintentos con backoff exponencial y limite (RNF-RES-02, OF-15).
/// Espera base * 2^(n-1) + jitter: 2, 4, 8, 16, 32 s con los valores por defecto.
class RetryPolicy {
  RetryPolicy({
    this.maxRetries = 5,
    this.baseDelay = const Duration(seconds: 2),
    this.maxJitter = const Duration(milliseconds: 500),
    RetryWait? wait,
    Random? random,
    RetryLog? log,
  }) : _wait = wait ?? Future<void>.delayed,
       _random = random ?? Random(),
       _log = log ?? debugPrint {
    if (maxRetries < 0) {
      throw ArgumentError.value(maxRetries, 'maxRetries', 'No puede ser < 0.');
    }
  }

  /// Sin reintentos: el primer fallo se propaga tal cual.
  factory RetryPolicy.none() => RetryPolicy(maxRetries: 0);

  final int maxRetries;
  final Duration baseDelay;
  final Duration maxJitter;
  final RetryWait _wait;
  final Random _random;
  final RetryLog _log;

  /// Solo fallos temporales: un dato invalido o un error de SQLite no se arregla esperando.
  static bool isRetryable(SyncFailure failure) => switch (failure.kind) {
    SyncFailureKind.timeout ||
    SyncFailureKind.network ||
    SyncFailureKind.serviceUnavailable ||
    SyncFailureKind.rateLimited => true,
    SyncFailureKind.graphql ||
    SyncFailureKind.invalidResponse ||
    SyncFailureKind.storage => false,
  };

  /// Espera antes del reintento numero [retry] (empieza en 1).
  Duration delayFor(int retry) {
    final jitter = maxJitter * _random.nextDouble();
    return baseDelay * (1 << (retry - 1)) + jitter;
  }

  Future<T> run<T>(
    Future<T> Function() action, {
    String label = 'sincronizacion',
    void Function(Duration delay)? onRetry,
  }) async {
    for (var retry = 1; ; retry++) {
      try {
        return await action();
      } on SyncFailure catch (failure) {
        if (!isRetryable(failure)) rethrow;
        if (retry > maxRetries) {
          if (maxRetries > 0) {
            _log(
              '[sync] $label: reintentos agotados ($maxRetries) -> $failure',
            );
          }
          rethrow;
        }
        final delay = delayFor(retry);
        _log(
          '[sync] $label: fallo $failure; reintento $retry/$maxRetries '
          'en ${delay.inMilliseconds} ms',
        );
        onRetry?.call(delay);
        await _wait(delay);
      }
    }
  }
}
