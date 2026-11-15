# Pokedex Flutter

Avance del proyecto de ICC-451-T Desarrollo de Aplicaciones Moviles, PUCMM. La app consulta PokeAPI por GraphQL y guarda el catalogo en SQLite para usarlo sin Internet, incluso despues de cerrar y abrir la aplicacion.

El catalogo muestra nombre, numero nacional, imagen y tipos. Incluye estados de carga, vacio y error con Reintentar, ademas de un indicador global de conectividad.

## Instalacion y ejecucion

Se utilizo Flutter 3.50.0 con Dart 3.14.0. Se necesita Android Studio, Android SDK con licencias aceptadas y un emulador o dispositivo con depuracion USB. La compilacion Android usa SDK 36 y NDK 28.2.13676358. Para iOS se necesita macOS y Xcode, esa plataforma no se ha verificado.

Abrir en Android Studio la carpeta que contiene `pubspec.yaml`, configurar el SDK Flutter y ejecutar desde esa carpeta:

```powershell
flutter doctor -v
flutter pub get
flutter devices
flutter run -d <id-del-dispositivo>
```

La primera instalacion requiere Internet para descargar dependencias. Si se cambian las tablas, regenerar Drift con `dart run build_runner build`. El archivo generado `app_database.g.dart` no se edita a mano.

## Tecnologias

- Flutter y Dart: plataforma y lenguaje del proyecto, `material_ui` aporta los componentes visuales.
- Riverpod: comparte dependencias y observa el estado de la pantalla.
- Drift y drift_flutter: SQLite con relaciones, transacciones y consultas que emiten cambios.
- graphql: ejecuta consultas remotas sin conectar los widgets directamente a GraphQL.
- connectivity_plus: detecta cambios de red, se complementa con una consulta al servicio.
- drift_dev y build_runner: generan el codigo de la base. flutter_test y flutter_lints: pruebas y analisis.

Las versiones estan fijadas en `pubspec.lock`.

## Arquitectura y datos locales

El codigo se organiza por funcionalidades y capas:

```text
lib/app/                 Configuracion e inyeccion de dependencias
lib/core/                Base de datos, red y conectividad
lib/features/pokemon/    presentation, domain y data
lib/features/favorites/  Dominio y repositorio local, pantalla pendiente
test/                    Pruebas automatizadas
Documentacion/           Decision de arquitectura (ADR)
```

`presentation` muestra el estado, `domain` define entidades y contratos en Dart puro, y `data` implementa el acceso a datos. La UI observa SQLite mediante el repositorio y Riverpod. Las respuestas GraphQL solo actualizan la base local.

La base `pokedex.sqlite`, esquema version 1, contiene `pokemon`, `type`, `pokemon_type`, `favorite` y `sync_metadata`. El ID remoto identifica cada Pokemon, distintas formas pueden compartir numero nacional. La relacion Pokemon-tipo tiene clave compuesta y una posicion unica por Pokemon. Cada favorito referencia un Pokemon y guarda su fecha.

Las claves y restricciones evitan duplicados y referencias invalidas. Hay indices para ordenar el catalogo por numero/ID y favoritos por fecha/ID. La metadata guarda recurso, siguiente offset, total, estado, fecha de la ultima pagina confirmada, error y completitud. Los cambios futuros del esquema requieren migraciones que conserven los datos.

## GraphQL y sincronizacion

Se consulta `https://graphql.pokeapi.co/v1beta2` con `noCache`, paginas de 100 registros ordenados por ID y timeout de 30 segundos. Se solicitan identidad, numero nacional, tipos, URLs de imagen y total. `limit` indica cuantos registros pedir, `offset`, cuantos saltar.

`PokemonSyncCoordinator` conecta `fetchPage()` con la validacion del DTO, el mapeo a dominio y `savePage()`. Cada pagina y su progreso se guardan en una transaccion con upsert: actualizar un ID existente no crea duplicados ni modifica favoritos. SQLite emite el cambio y la UI lo muestra mientras continua la descarga.

La primera carga intenta descargar todo el catalogo sin bloquear la pantalla. El offset avanza por la cantidad guardada y termina al alcanzar el total. Una descarga incompleta reanuda el progreso confirmado, una completa comienza desde cero al actualizar. Reintentar permite recuperarse de un fallo y solicita reinicio si la respuesta era invalida.

La instancia compartida del coordinador evita descargas simultaneas y libera el bloqueo en `finally`. Una respuesta fallida o incompleta no se guarda, si falla la transaccion, se revierte la pagina. Los datos anteriores se conservan. La paginacion por offset no garantiza una version fija del servidor y no elimina registros locales ausentes del remoto.

## Conectividad e imagenes

El indicador usa texto e icono: Online, Offline o Servicio no disponible, al iniciar muestra Comprobando conexion. Tener Wi-Fi no basta: se consulta `__typename` en GraphQL, sin cache y con timeout de 5 segundos. Se comprueba al iniciar, cambiar la red, volver a la app y cada 30 segundos.

El monitor solo comprueba el servicio. La sincronizacion ocurre al abrir la app y al reintentar, no automaticamente al reconectar. Online tampoco significa que el catalogo ya este actualizado.

Las imagenes usan la URL guardada y cache en memoria. Si no pueden cargarse, aparece Sin imagen. No se almacenan imagenes en disco para conservarlas tras reiniciar offline.

## Verificacion

```powershell
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test
flutter build apk --debug
```

El 15 de noviembre de 2026 se verificaron formato, analisis sin problemas, 69 pruebas aprobadas y APK Android debug correcto. Se comprobaron primera carga online/offline, reinicio sin Internet y fallo del servicio sin perder el catalogo. Las pruebas automatizadas cubren tambien reanudacion, rollback, concurrencia y tres sincronizaciones sin duplicados ni perdida de favoritos.

Para simular el servicio inaccesible con red activa y datos ya guardados:

```powershell
flutter build apk --debug --dart-define=POKEAPI_ENDPOINT=https://127.0.0.1:1
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

Cerrar y abrir la app: debe conservar el catalogo y mostrar Servicio no disponible. Para restaurarla, compilar sin `--dart-define`, reinstalar con `-r` y reabrir, sin desinstalar ni borrar datos.

## Limites y documentacion

Quedan pendientes detalle, pantalla de favoritos, busqueda, filtros y trivia. Favoritos ya tiene persistencia y repositorio probados. Tambien faltan cache de imagenes en disco, politica de vigencia, reintentos con backoff y sincronizacion al reconectar. El indicador aun no integra Sincronizando ni la fecha de actualizacion. No se agregaron funcionalidades complementarias.

La decision principal esta en [ADR-001](<Documentacion/ADR-001 - Fuente local observable.md>).

El proyecto sigue los enunciados del avance y del proyecto final. Referencias: [Flutter](https://docs.flutter.dev/), [Drift](https://drift.simonbinder.eu/), [Riverpod](https://riverpod.dev/) y [PokeAPI GraphQL](https://pokeapi.co/docs/graphql).

Integrantes: Ian Alvarez y Willian Li Liang.

Se uso la plantilla oficial de Flutter y asistencia de Codex en codigo, pruebas y documentacion.
