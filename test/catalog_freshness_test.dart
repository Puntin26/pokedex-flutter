import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/core/domain/freshness_policy.dart';
import 'package:pokedex/core/domain/sync_metadata.dart';

void main() {
  const policy = FreshnessPolicy();
  final now = DateTime.utc(2026, 11, 26, 12);

  SyncMetadata metadata({DateTime? lastSuccessAt, bool isComplete = true}) =>
      SyncMetadata(
        resourceKey: 'pokemon_catalog',
        lastSuccessAt: lastSuccessAt,
        isComplete: isComplete,
      );

  test('Vigencia por defecto de 24 h (PS-03)', () {
    expect(policy.maxAge, const Duration(hours: 24));
  });

  test('Sin datos o sin fecha esta desactualizado', () {
    expect(policy.isStale(null, now), isTrue);
    expect(policy.isStale(metadata(), now), isTrue);
  });

  test('Completo y reciente esta vigente; justo en el limite tambien', () {
    expect(
      policy.isStale(
        metadata(lastSuccessAt: now.subtract(const Duration(hours: 1))),
        now,
      ),
      isFalse,
    );
    expect(
      policy.isStale(
        metadata(lastSuccessAt: now.subtract(const Duration(hours: 24))),
        now,
      ),
      isFalse,
    );
  });

  test('Mas de 24 h esta desactualizado', () {
    expect(
      policy.isStale(
        metadata(
          lastSuccessAt: now.subtract(const Duration(hours: 24, minutes: 1)),
        ),
        now,
      ),
      isTrue,
    );
  });

  test('Un catalogo parcial siempre esta desactualizado', () {
    expect(
      policy.isStale(metadata(lastSuccessAt: now, isComplete: false), now),
      isTrue,
    );
  });
}
