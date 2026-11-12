# Pokedex Flutter

Proyecto de ICC-451-T Desarrollo de Aplicaciones Moviles, PUCMM. Base Flutter para Android e iOS con persistencia SQLite estructurada.

## Alcance

Pantalla inicial y modelo local con Pokemon, tipos, favoritos y metadata. Los repositorios permiten observar y guardar datos; GraphQL y el catalogo visual todavia no estan conectados.

## Requisitos y ejecucion

- Flutter estable 3.50.0 con Dart 3.14.0, version utilizada para preparar esta base.
- Git y Android Studio con Android SDK, command-line tools y licencias aceptadas. La plantilla utiliza SDK Platform 36, build-tools 36.0.0 y NDK 28.2.13676358.
- Un emulador Android o un dispositivo con depuracion USB.
- Internet para descargar dependencias y herramientas en la primera compilacion.
- Para iOS: macOS con Xcode y las herramientas que indique `flutter doctor`. El proyecto iOS se incluye como base; no se verifica su compilacion desde Windows.

Ejecutar estos comandos desde esta carpeta, la que contiene `pubspec.yaml`:

```powershell
flutter --version
flutter doctor -v
flutter pub get
flutter devices
flutter run -d <id-del-dispositivo>
```

Agregar la carpeta `bin` del SDK Flutter al `PATH`. En Android Studio, abrir la carpeta que contiene `pubspec.yaml`, instalar los plugins Flutter y Dart y configurar la ruta del SDK.

Comandos de verificacion:

```powershell
dart run build_runner build
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug
```

## Tecnologias

Flutter y Dart para la app; Drift y drift_flutter para SQLite, transacciones y streams; Riverpod para estado e inyeccion. El cliente graphql y connectivity_plus estan instalados para la integracion posterior. drift_dev y build_runner generan el codigo de Drift.

## Arquitectura

Organizacion por funcionalidades y capas presentation, domain y data. El dominio es Dart puro. Los repositorios locales implementan contratos del dominio y convierten filas SQLite en entidades.

## Persistencia local implementada


`AppDatabase` define el esquema SQLite version **1** y activa `PRAGMA foreign_keys = ON` en cada apertura. Su constructor normal abre la base mediante `drift_flutter`; tambien acepta un `QueryExecutor` para pruebas. La conexion es diferida: se abre con la primera consulta. `appDatabaseProvider` comparte la instancia entre consumidores y registra `close()` al liberar su alcance.

| Tabla | Campos y restricciones |
|---|---|
| `pokemon` | `id` remoto positivo como PK; `national_number` positivo; `name` no vacio; `image_url` opcional; `updated_at` obligatorio. El numero nacional no es unico: distintas formas pueden compartirlo. |
| `type` | `id` remoto positivo como PK y `name` unico, no vacio. |
| `pokemon_type` | FKs a Pokemon y tipo; PK compuesta `(pokemon_id, type_id)`; unicidad de `(pokemon_id, slot)`; `slot` entre 1 y 2. Al borrar un Pokemon se eliminan sus relaciones de tipos. |
| `favorite` | `pokemon_id` es PK y FK; `created_at` obligatorio. Un favorito impide borrar accidentalmente el Pokemon asociado. |
| `sync_metadata` | `resource_key` no vacio como PK; `next_offset` no negativo (inicial 0); `total_count` opcional y no negativo; `status`; `last_success_at` y `last_error` opcionales; `is_complete` inicialmente falso. |

Indices: `pokemon_national_order(national_number, id)` apoya el orden del catalogo; `favorite_creation_order(created_at, pokemon_id)` apoya favoritos recientes primero. Las PK y restricciones unicas generan los indices para identidad, joins y orden de tipos por Pokemon. No se agregan indices de busqueda o filtros todavia, pues esas consultas no pertenecen a esta tarea.

`LocalPokemonRepository.watchCatalog()` devuelve Pokemon ordenados por numero e ID, con tipos ordenados por `slot`; `watchTypes()` observa los tipos por nombre. Los joins tambien observan las tablas relacionadas. El mapper devuelve entidades del dominio, nunca filas de Drift. `LocalFavoritesRepository` permite observar favoritos con sus Pokemon y tipos, agregar y eliminar. Repetir un alta conserva su fecha original.

`savePage(pokemon, metadata)` ejecuta una sola transaccion: hace `upsert` por ID de Pokemon y tipos, reemplaza las relaciones de tipos de los Pokemon recibidos y guarda la metadata al final. Cualquier fallo revierte **toda** la pagina y su progreso. No borra Pokemon ausentes de esa pagina ni modifica favoritos. Usa actualizacion por conflicto, sin reemplazar la fila referenciada por los datos del usuario. Una pagina repetida no duplica entidades.

La metadata se consulta con `readSyncMetadata()` o `watchSyncMetadata()` por recurso (`pokemon_catalog`); antes del primer registro devuelve `null`. `next_offset` representa el siguiente offset **confirmado**, `total_count` el total remoto conocido, `last_success_at` la ultima pagina confirmada y `is_complete` si se llego al final del catalogo. `status` admite `idle`, `syncing`, `success` y `failed`; describe sincronizacion, no disponibilidad de red. `updateSyncStatus()` registra actividad o errores sin cambiar offset, total, ultima fecha correcta ni completitud. El coordinador limpia `last_error` al empezar y calcula el progreso de cada pagina.

Las fechas se almacenan como timestamps SQLite con precision de segundos y se entregan al dominio en UTC. `image_url` guarda una referencia, no descarga ni garantiza disponibilidad offline de imagenes.

Migraciones: una instalacion nueva crea todas las tablas. No existe un esquema previo que migrar. Se conserva el esquema inicial en `drift_schemas/drift_schema_v1.json`, exportado con `dart run drift_dev schema dump lib/core/database/app_database.dart drift_schemas/`. Los cambios futuros deben incrementar `schemaVersion`, agregar una migracion explicita y probar conservacion de datos; una transicion sin implementar falla en vez de borrar la base. Favoritos deben conservarse tambien durante las migraciones. `build.yaml` identifica la base para las herramientas de migracion.

## Verificacion

Analisis sin problemas y 15 pruebas aprobadas, incluidas reapertura de SQLite, transacciones, restricciones y conservacion de favoritos.

## Autoria

La aplicacion utiliza la plantilla oficial de Flutter y asistencia de Codex en codigo, pruebas y documentacion. El equipo es responsable de revisar, comprender y explicar el codigo entregado.
