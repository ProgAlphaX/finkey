# ADR-0006: Comunicación entre módulos — contratos + eventos con outbox

- **Estado**: Aceptado
- **Fecha**: 2026-10-26
- **Reversibilidad**: Media

## Contexto
Los módulos deben estar desacoplados (NFR-03, ADR-0001), pero hay flujos que los cruzan: validar el período antes de registrar, marcar un pago como pagado, generar el pago de una tarjeta al cortar, enviar los avisos.

## Opciones consideradas
1. **Acceso directo a clases o tablas de otro módulo**: es rápido, pero produce un acoplamiento fuerte; descartado.
2. **Solo eventos asíncronos**: el desacople es máximo, pero da una mala experiencia cuando el usuario espera ver el resultado inmediato.
3. **Mixto**: contratos síncronos (interfaces públicas) para las consultas y para los comandos de consistencia inmediata, y eventos de integración con **Outbox** para las reacciones.

## Decisión
**Mixto**:
- Cada módulo publica `Contracts` (interfaces, DTOs y eventos). Es lo único visible desde afuera.
- Los comandos entre módulos que el usuario ve de inmediato se ejecutan en la **misma transacción de BD** (la BD es una sola).
- Los eventos se guardan en una tabla outbox en la misma transacción y se despachan después; los consumidores son idempotentes.
- Sin dependencias circulares, verificado por tests de arquitectura.

## Consecuencias
- Positivas: desacople real; la entrega de eventos es confiable aunque la API se apague (el outbox se despacha en el siguiente request o job); extraer un módulo después implica cambiar solo el transporte.
- Negativas: hay más piezas que un monolito simple (outbox, despachador, registro de eventos procesados).
- Qué haría reconsiderar esta decisión: extraer un módulo a servicio → reemplazar el despachador in-process por un broker de mensajes.
