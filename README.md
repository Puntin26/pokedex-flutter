# Pokedex Flutter

Base del avance con persistencia, GraphQL paginado y catalogo local reactivo.

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
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test
flutter build apk --debug
```


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


## Flujo GraphQL a SQLite implementado

El recorrido se localiza en `PokemonSyncCoordinator._synchronize()`: `remote.fetchPage()` -> `PokemonPageDto.fromJson()` -> `toDomain()` -> `local.savePage()`. Este ultimo metodo hace los `upsert` y confirma los datos y la metadata en la misma transaccion. Los streams del repositorio local emiten el cambio. `domain/PokemonSync` permite solicitar sincronizacion sin exponer GraphQL o Drift a la presentacion; los fallos se expresan con `SyncFailure` de Dart puro.

### Consulta y paginacion

`GraphqlPokemonSource.fetchPage()` ejecuta `PokemonCatalog` por POST contra `https://graphql.pokeapi.co/v1beta2`, comprobado el 15 de noviembre de 2026. Se usa el esquema sin el antiguo prefijo `pokemon_v2_`. La consulta solicita solamente ID, nombre, `pokemon_species_id`, tipos con su `slot`, dos URLs de imagen extraidas del JSON mediante `sprites(path: ...)` y el conteo agregado. Incluye formas alternativas: el ID identifica la forma, mientras `pokemon_species_id` representa su numero nacional. Se prefiere official-artwork y se usa el sprite frontal como respaldo; ambos pueden ser nulos. GraphQL solo entrega las URLs; las tarjetas cargan las imagenes referenciadas por los datos locales.

La pagina predeterminada contiene **100 registros**: reduce solicitudes al servicio limitado por tasa y mantiene acotado el trabajo por transaccion. `pageSize` acepta 1 a 100 para pruebas o configuracion. `limit` es cuantos registros pedir y `offset` cuantos saltar, nunca un ID. El orden remoto es `id ASC`, unico y estable; los tipos se piden por `slot ASC`. El orden visual local sigue siendo numero nacional e ID.

Cada respuesta incluye `pokemon_aggregate.aggregate.count`. La pagina debe contener exactamente `min(limit, total - offset)` filas. Se valida toda la pagina antes de guardar: campos requeridos, IDs y numero positivos, nombres, URLs HTTPS cuando existen, uno o dos tipos sin repeticiones y slots 1 a 2. Un campo ausente no se interpreta como un valor nulo valido. Los IDs de la pagina deben crecer; durante un intento tampoco pueden retroceder entre paginas.

Tras confirmar la transaccion, `nextOffset = offset + cantidad recibida`. Se termina cuando `nextOffset == total`; asi no se necesita una solicitud vacia extra cuando el total es multiplo del limite. Un catalogo remoto realmente vacio confirma offset 0 y completitud sin borrar filas locales previas. Una pagina vacia inesperada, truncada o con errores falla en vez de avanzar o repetir indefinidamente. El total debe mantenerse igual durante el intento y al reanudar: si cambia, se registra el error y se requiere `synchronize(restart: true)`.

### Reanudacion, concurrencia y fallos

- Sin metadata se comienza en 0. Si el catalogo esta incompleto, se reanuda en el siguiente offset confirmado, incluso si el proceso anterior termino con estado `syncing` o `failed`. Cambiar el tamano de pagina no invalida ese offset.
- Si la descarga anterior quedo completa, una nueva llamada comienza en 0 para actualizar las filas. `restart: true` tambien comienza en 0. No se borra el catalogo para reiniciar: hasta confirmar la primera pagina se conserva la metadata anterior; si esta falla, el siguiente intento normal usa ese progreso anterior. Para volver a forzar el inicio se indica nuevamente `restart: true`.
- La inyeccion comparte **una instancia de `PokemonSyncCoordinator` por catalogo**, junto con su repositorio y base. Sus llamadas simultaneas devuelven el mismo `Future`: no lanzan otra consulta, y prevalecen las opciones de la primera llamada. El bloqueo se libera con `finally` tanto en exito como en error. No es un bloqueo entre procesos, isolates o instancias independientes.
- Cada pagina intermedia queda `syncing`; la ultima queda `success` e `is_complete = true`. `last_success_at` es la fecha de la ultima pagina confirmada, no necesariamente de una descarga completa. Durante una actualizacion o un error, `is_complete` conserva la completitud del ultimo progreso confirmado hasta guardar una nueva pagina.
- Los errores remotos o de validacion no escriben esa pagina. Un fallo SQLite revierte la pagina y su metadata. El coordinador registra `failed` y `last_error`, conserva offset, fecha correcta y favoritos, y entrega un `SyncFailure`. Si SQLite tampoco permite registrar el error, se propaga el fallo original y se libera igualmente el bloqueo.
- `createPokeApiClient()` limita cada solicitud a **30 segundos** con un link que cierra la espera al vencer el timeout; una respuesta tardia no se procesa. Se desactiva el timeout adicional del cliente para mantener un solo temporizador. Se distinguen timeout, conexion, HTTP de servicio no disponible, HTTP 429, errores GraphQL, respuesta invalida y almacenamiento. Incluso si GraphQL entrega datos junto con errores, se rechaza la pagina completa. Las consultas usan `FetchPolicy.noCache`: SQLite sigue siendo la fuente persistente.

Quien cree el cliente debe ejecutar `client.link.dispose()` al terminar, y cerrar la base con `database.close()`. El manifiesto Android principal declara `INTERNET`, tambien para las futuras compilaciones release. No se agregaron dependencias ni se cambio el esquema SQLite.

La paginacion por offset no ofrece un snapshot del servidor: un cambio de contenido que conserve el total puede pasar inadvertido entre intentos. Un reinicio desde cero vuelve a obtener las filas sin borrar datos locales ausentes ni favoritos. La deteccion completa de eliminaciones y la politica de vigencia quedan pendientes para el proyecto final.

### Verificacion del flujo

La suite `flutter test --no-pub` usa respuestas controladas y un servidor HTTP de loopback, sin depender de Internet. Verifica mapeo, campos parciales, HTTP 429/503, timeout y respuesta tardia, multiples paginas, total exacto o cero, rollback real de SQLite, streams locales, reanudacion tras reapertura en disco, llamadas simultaneas, liberacion del bloqueo y tres sincronizaciones sin duplicar ni perder favoritos. Se conservan las 15 pruebas anteriores.

La comprobacion manual usa solo **dos solicitudes de dos registros**, sin descargar el catalogo completo ni alterar la base de la app:

```powershell
flutter test --no-pub tool/pokeapi_smoke_test.dart --reporter expanded
```

Esa prueba usa el transporte real, DTO y SQLite; confirma dos paginas, metadata, repeticion local sin duplicados y conservacion de un favorito. Se ejecuta aparte porque requiere Internet y disponibilidad de PokeAPI.

## Catalogo local reactivo

`app/pokemon_dependencies.dart` crea una base, cliente, repositorio y coordinador por `ProviderScope`. Los providers se conservan durante ese alcance: reconstruir widgets o volver al catalogo no crea otra instancia ni dispara otra descarga. Al descartar el alcance se cierra la base y se libera `client.link`; el controlador ignora los resultados tardios y atiende los fallos aunque su pantalla ya no exista. Un cierre forzado del proceso depende de la atomicidad de SQLite y de la reanudacion del coordinador.

En `presentation/pokemon_catalog_controller.dart`, `localCatalogProvider` observa `watchCatalog()` y `catalogMetadataProvider` observa `watchSyncMetadata('pokemon_catalog')`. `pokemonCatalogStateProvider` compone esos streams y el resultado de la accion en `PokemonCatalogState`: carga, datos, vacio o error, actividad de sincronizacion y mensaje. Los widgets reciben entidades de dominio; nunca reciben DTO, respuestas GraphQL o filas Drift.

`CatalogSyncController.build()` programa el primer intento sin esperarlo. `PokemonPage` aparece de inmediato; cada pagina confirmada en SQLite actualiza la lista aunque la siguiente descarga siga pendiente. Con datos guardados, la lista permanece desplazable durante la actualizacion o ante un fallo. Se usa `ListView.builder` para construir solo las tarjetas necesarias. El texto de actualizacion es local al catalogo y permanece separado del indicador de disponibilidad del servicio.

`Reintentar` reutiliza el mismo coordinador y reanuda el offset confirmado. Si la respuesta es invalida, solicita `restart: true` en el siguiente intento para permitir recuperarse de un total remoto que cambio. Reiniciar no borra filas ni favoritos. Los fallos locales de lectura vuelven a suscribir sus streams al reintentar. No hay reintentos automaticos, backoff ni eventos de reconexion. Si SQLite tampoco permite registrar un fallo, el controlador muestra el error de la accion para evitar una espera indefinida o una excepcion sin atender.

Las pruebas de pantalla usan SQLite real en memoria, el coordinador existente y respuestas controladas, sin Internet. Cubren arranque inmediato, carga, vacio, datos previos, fallo remoto con y sin datos, reintento, reanudacion, reinicio por cambio remoto, emisiones de datos y metadata, fallos locales y descarte durante una descarga. Una prueba mantiene pendiente la segunda pagina y comprueba datos de la primera en pantalla, desplazamiento, navegacion y reconstruccion sin descargas duplicadas. La ruta adicional existe solo en la prueba. La demostracion de reinicio offline debe comprobarse en Android.


Tarjetas con imagen e indicador global pendientes de integracion.

## Autoria

La aplicacion utiliza la plantilla oficial de Flutter y asistencia de Codex en codigo, pruebas y documentacion. El equipo es responsable de revisar, comprender y explicar el codigo entregado.
