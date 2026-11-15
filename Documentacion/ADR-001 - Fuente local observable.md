# ADR-001: SQLite como fuente del catalogo

Estado: bien para el avance. Fecha: 15 de noviembre de 2026.

## Contexto

El catalogo debe abrir sin esperar a PokeAPI y seguir disponible al reiniciar sin Internet. Tambien hay que guardar favoritos y progreso de descarga sin duplicados.

## Decision

Usar SQLite con Drift como fuente observable del catalogo. Riverpod observa los datos locales y actualiza la pantalla. GraphQL descarga paginas, el coordinador valida, transforma y guarda cada pagina junto con su progreso en una transaccion.

Los registros se actualizan por ID mediante upsert. La sincronizacion conserva favoritos y datos anteriores cuando falla. Una instancia compartida evita descargas simultaneas.

## Alternativas

- Mostrar GraphQL directamente: haria que la pantalla dependiera de la red.
- Guardar JSON o usar solo cache GraphQL: no cubre el modelo relacional y las consultas locales de esta solucion.
- Usar SQLite manualmente: es posible, pero exige implementar las notificaciones y el mapeo que ofrece Drift.

## Consecuencias

El catalogo persiste y la UI recibe cada pagina confirmada sin esperar toda la descarga. Las transacciones evitan guardar paginas a medias. A cambio, hay que mantener mapeos, codigo generado y migraciones.

El bloqueo solo cubre la instancia compartida. La paginacion por offset no garantiza una version fija del servidor. Reconexion automatica, backoff y almacenamiento de imagenes siguen pendientes.

La implementacion se puede revisar en el [coordinador](<../lib/features/pokemon/data/pokemon_sync_coordinator.dart>) y el [repositorio local](<../lib/features/pokemon/data/local_pokemon_repository.dart>). Se verificaron 69 pruebas y el reinicio offline del catalogo en Android. Para el proyecto final se agregara un segundo ADR.
