# ADR-002: Politica de sincronizacion y reintentos

Estado: aceptada. Fecha: 26 de noviembre de 2026.

## Contexto

El catalogo vive en SQLite (ADR-001), pero la app tiene que actualizarse sola desde PokeAPI cuando el servicio este disponible, sin bloquear la navegacion (OF-11, OF-12, OF-14, OF-20). Un fallo temporal no debe cortar la sincronizacion al primer intento, y los reintentos deben tener limite (OF-15, RNF-RES-02). Si alguien altera el catalogo local, la siguiente sincronizacion debe restaurarlo con lo que diga PokeAPI (OF-19, PS-12). El indicador tiene que separar la conexion, la actividad de sincronizacion y la vigencia de los datos (§7.4, IND-04).

## Decision

**Reintentos.** `RetryPolicy` reintenta solo fallos temporales: timeout, red, servicio no disponible y limite de solicitudes. Espera 2, 4, 8, 16 y 32 s (hasta 5 reintentos) mas hasta 0,5 s aleatorios para no golpear la API todos a la vez. Un dato invalido, un error GraphQL o un fallo de SQLite no se reintenta, porque esperar no lo arregla. Se reintenta solo la pagina que fallo; las ya guardadas no se repiten. Cada intento se escribe en consola.

**Cuando sincronizar.** Al iniciar la app, al recuperar el servicio (de Offline o Servicio no disponible a Online) y cada 15 minutos mientras esta Online. Lo decide `SyncScheduler` a partir del estado del servicio, no solo de la red (OF-11). "Comprobando" no cuenta como cambio. Si dos disparos coinciden, el bloqueo del coordinador los une en una sola descarga.

**Vigencia (PS-03).** El catalogo esta desactualizado si nunca se completo o si su ultima sincronizacion completa tiene mas de 24 h. Al actualizar un catalogo ya completo, sigue marcado como completo y conserva su fecha hasta guardar la ultima pagina; si se corta, se reanuda desde la pagina pendiente.

**Deteccion de alteraciones (PS-12).** Sobrescritura completa en cada sincronizacion: todas las paginas se descargan y se guardan por upsert, y los tipos de cada Pokemon se reemplazan. Asi cualquier cambio local en nombre, imagen o tipos vuelve al valor de PokeAPI en la siguiente sincronizacion (frecuencia: la del punto anterior). Favoritos y demas datos del usuario estan en otras tablas y no se tocan.

**Estado observable.** `SyncActivity` (inactiva, sincronizando, esperando reintento, fallida) vive en memoria y va separada de `ConnectionStatus`. El indicador las combina con la procedencia y la fecha de los datos, y solo muestra un cambio de conexion si dura 1,5 s para no parpadear.

**PA-08.** En debug, una pulsacion larga en el indicador manda las peticiones a `https://127.0.0.1:1`. Es una falla de red real, asi que recorre el mismo camino de errores y reintentos que una caida verdadera.

## Alternativas

- Reintentar cualquier error: repetiria 5 veces respuestas invalidas que no van a cambiar.
- Intervalo fijo entre reintentos: con la API caida generaria trafico constante; el backoff lo reduce.
- Comparar campo por campo o por hash para detectar alteraciones: descarga lo mismo y agrega codigo; con un catalogo de ~1300 registros en paginas de 100, sobrescribir es mas simple y deja siempre a PokeAPI como autoridad (OF-19).
- Sincronizacion incremental: PokeAPI no ofrece marcas de cambio que la hagan viable (§11.1).
- `workmanager` para sincronizar en segundo plano: agrega una dependencia y permisos; el enunciado pide actualizar mientras la app esta en uso.

## Consecuencias

La app se actualiza sola y se recupera de caidas breves sin intervencion. A cambio, cada sincronizacion descarga el catalogo entero (unas 14 paginas), tambien la periodica.

Si la conexion cae durante la espera entre reintentos, la espera no se cancela: hace intentos de mas pero no pierde datos. La marca "desactualizado" se recalcula al cambiar la conexion o el catalogo, no con el paso del tiempo. La sincronizacion al abrir el detalle de un Pokemon (OF-20) llega con la Fase 4.

Implementacion: [politica de reintentos](<../lib/core/sync/retry_policy.dart>), [scheduler](<../lib/core/sync/sync_scheduler.dart>), [vigencia](<../lib/core/domain/freshness_policy.dart>), [coordinador](<../lib/features/pokemon/data/pokemon_sync_coordinator.dart>) e [indicador](<../lib/app/connection_indicator_state.dart>). Pruebas en `test/retry_policy_test.dart`, `test/sync_scheduler_test.dart`, `test/sync_scheduler_app_test.dart`, `test/pokemon_sync_test.dart`, `test/connection_indicator_test.dart` y `test/api_outage_simulation_test.dart`.
