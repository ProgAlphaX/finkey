# ADR-0005: Representación de dinero, fechas e IDs

- **Estado**: Aceptado
- **Fecha**: 2026-10-26
- **Reversibilidad**: Baja ⚠️

## Contexto
Hay montos en PEN y USD, tipos de cambio diarios, períodos financieros por fecha de calendario en Lima y datos accesibles desde la PWA (BR-020 a BR-023, BR-041, BR-086 a BR-089).

## Decisión
| Tema | Decisión |
|---|---|
| Montos | `numeric(18,2)` + `char(3)` de moneda; VO `Money`; nunca `float`/`double` |
| Tipos de cambio | `numeric(12,6)` |
| Fechas de negocio (transacción, vencimiento, período) | `date` (calendario America/Lima), sin hora |
| Timestamps técnicos | `timestamptz` en UTC |
| Zona horaria | Guardada por usuario y por hogar; "hoy" se calcula en esa zona |
| IDs | UUID v7 (ordenables en el tiempo, no secuenciales, generables en el cliente) |

## Opciones descartadas
- Montos en enteros (céntimos): válido, pero menos legible y sin ventaja real con `numeric`.
- Fechas de negocio como `timestamptz`: provoca errores de "cambio de día" (un gasto a las 21:00 en Lima es "mañana" en UTC).
- IDs `bigint` autoincrementales: exponen conteos y complican la generación en el cliente.

## Consecuencias
- Positivas: precisión exacta; no hay bugs de zona horaria en los períodos; IDs seguros para exponer.
- Negativas: UUID ocupa más espacio que `bigint` (irrelevante a esta escala).
