# ADR-0007: Jobs disparados por un scheduler externo

- **Estado**: Aceptado
- **Fecha**: 2026-10-26
- **Reversibilidad**: Alta

## Contexto
La API se apaga sola sin tráfico (*scale-to-zero*, requisito de costo $0). Sin embargo, las alertas deben salir a las 08:00 (NFR-05), los períodos deben cerrarse solos (BR-091), el tipo de cambio debe actualizarse a diario (BR-120) y las tarjetas deben cortar en su fecha (BR-014).

## Opciones consideradas
1. **Scheduler en proceso** (librerías de jobs dentro de la API): no corre si la API está apagada, y forzarla a estar siempre encendida rompe el $0.
2. **Worker separado siempre encendido**: tiene costo.
3. **Scheduler externo gratuito** que llama a endpoints internos protegidos e idempotentes.

## Decisión
**Opción 3**:
- Dos jobs: `daily-morning` (08:00) y `daily-midnight` (00:05), ambos en America/Lima.
- El proveedor del scheduler se elige en la Fase 7.
- Los endpoints exigen un secreto y son idempotentes.
- Cada job procesa "todo lo pendiente hasta hoy", así que una ejecución fallida se recupera en la siguiente.
- Cada ejecución se registra.

## Consecuencias
- Positivas: costo $0; funciona con la API apagada; es fácil de probar (un endpoint); es independiente del proveedor.
- Negativas: depende de la puntualidad del scheduler externo (aceptable: NFR-05 tolera 15 min) y hay que proteger los endpoints.
- Qué haría reconsiderar esta decisión: necesitar tareas de alta frecuencia o larga duración → un worker dedicado o un servicio de colas.
