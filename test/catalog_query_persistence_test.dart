import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/app/settings_provider.dart';
import 'package:pokedex/core/database/app_database.dart';
import 'package:pokedex/core/database/local_settings_repository.dart';
import 'package:pokedex/features/pokemon/domain/catalog_query.dart';
import 'package:pokedex/features/pokemon/presentation/catalog_query_controller.dart';

import 'support/fake_settings.dart';

void main() {
  group('CatalogQuery encode/decode', () {
    test('Ida y vuelta conserva todos los campos', () {
      const query = CatalogQuery(
        search: 'pika',
        typeId: 13,
        generationId: 1,
        sort: CatalogSort.baseStatTotal,
        descending: true,
      );
      expect(CatalogQuery.decode(query.encode()), query);
      expect(
        CatalogQuery.decode(const CatalogQuery().encode()),
        const CatalogQuery(),
      );
    });

    test('Dato ausente, corrupto o de otro formato vuelve a los defaults', () {
      for (final raw in [null, '', 'no es json', '[]', '42', '{"sort": 3}']) {
        expect(CatalogQuery.decode(raw), const CatalogQuery(), reason: raw);
      }
    });

    test('Ignora campo por campo lo invalido y conserva lo valido', () {
      final query = CatalogQuery.decode(
        '{"search": "char", "typeId": -4, "generationId": "1", '
        '"sort": "inventado", "descending": "si"}',
      );
      expect(query, const CatalogQuery(search: 'char'));
    });
  });

  group('LocalSettingsRepository (tabla app_setting)', () {
    late AppDatabase database;
    setUp(() => database = AppDatabase(NativeDatabase.memory()));
    tearDown(() => database.close());

    test(
      'Lee null si no existe y sobrescribe por clave sin duplicar',
      () async {
        final settings = LocalSettingsRepository(database);
        expect(await settings.read('catalog.query'), isNull);
        await settings.write('catalog.query', 'a');
        await settings.write('catalog.query', 'b');
        expect(await settings.read('catalog.query'), 'b');
        expect(await database.select(database.appSettings).get(), hasLength(1));
      },
    );
  });

  group('CatalogQueryController guarda y restaura (RF-FIL-04)', () {
    ProviderContainer containerWith(FakeSettings settings) {
      final container = ProviderContainer(
        overrides: [settingsRepositoryProvider.overrideWithValue(settings)],
      );
      addTearDown(container.dispose);
      return container;
    }

    testWidgets('Restaura la consulta guardada al iniciar', (tester) async {
      const saved = CatalogQuery(
        search: 'saur',
        typeId: 12,
        sort: CatalogSort.name,
        descending: true,
      );
      final container = containerWith(
        FakeSettings({catalogQuerySettingKey: saved.encode()}),
      );
      expect(await container.read(catalogQueryProvider.future), saved);
    });

    testWidgets('Cada cambio se guarda; la busqueda tras el debounce', (
      tester,
    ) async {
      final settings = FakeSettings();
      final container = containerWith(settings);
      await container.read(catalogQueryProvider.future);
      final controller = container.read(catalogQueryProvider.notifier);

      controller.setType(12);
      controller.setSort(CatalogSort.baseStatTotal);
      await tester.pump();
      expect(
        CatalogQuery.decode(settings.values[catalogQuerySettingKey]),
        const CatalogQuery(typeId: 12, sort: CatalogSort.baseStatTotal),
      );

      final writesBefore = settings.writes;
      controller.updateSearch('p');
      controller.updateSearch('pi');
      await tester.pump(const Duration(milliseconds: 399));
      expect(settings.writes, writesBefore);
      await tester.pump(const Duration(milliseconds: 1));
      expect(settings.writes, writesBefore + 1);
      expect(
        CatalogQuery.decode(settings.values[catalogQuerySettingKey]).search,
        'pi',
      );
    });

    testWidgets('Sobrevive a un "reinicio": otro contenedor, misma base', (
      tester,
    ) async {
      final settings = FakeSettings();
      final first = containerWith(settings);
      await first.read(catalogQueryProvider.future);
      first.read(catalogQueryProvider.notifier)
        ..setGeneration(2)
        ..toggleDescending();
      await tester.pump();
      first.dispose();

      final second = containerWith(settings);
      expect(
        await second.read(catalogQueryProvider.future),
        const CatalogQuery(generationId: 2, descending: true),
      );
    });

    testWidgets('Si leer las preferencias falla, arranca con los defaults', (
      tester,
    ) async {
      final container = containerWith(BrokenSettings());
      expect(
        await container.read(catalogQueryProvider.future),
        const CatalogQuery(),
      );
    });
  });
}

class BrokenSettings extends FakeSettings {
  @override
  Future<String?> read(String key) async => throw StateError('disco lleno');
}
