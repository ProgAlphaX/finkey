# ADR-0016: Row-Level Security en Postgres por hogar

- **Estado**: Aceptado
- **Fecha**: 2026-10-27
- **Reversibilidad**: Alta (se pueden desactivar las políticas sin cambiar datos)

## Contexto
- La privacidad es el driver principal (NFR-01). ADR-0004 define el aislamiento en la aplicación: filtros globales de EF por `household_id` + `owner_user_id` y 404 para recursos ajenos.
- Las consultas de Insights usan Dapper, donde los filtros globales no aplican.
- Un solo bug de filtro expondría los datos de otro hogar.

## Opciones consideradas
1. **Solo en la aplicación**: es simple, pero no tiene red de seguridad ante un bug en SQL a mano.
2. **RLS por hogar** como segunda barrera; la privacidad entre miembros sigue en la aplicación.
3. **RLS por hogar y por dueño**: máxima seguridad, pero las políticas se complican con las cuentas compartidas, las cuentas virtuales de pareja y las asignaciones, y es difícil de mantener.

## Decisión
**Opción 2.**
- Las tablas con `household_id` (Ledger, Debts, Planning, Periods, Insights y Notifications) tienen `ENABLE` + `FORCE ROW LEVEL SECURITY`.
- Política: `household_id = nullif(current_setting('app.household_id', true), '')::uuid`. Si el valor no está seteado, **no se devuelven filas** (falla cerrado).
- Cada transacción ejecuta `select set_config('app.household_id', @id, true)` (local a la transacción, compatible con el pooler de Neon en modo transacción):
  - en EF, mediante un interceptor de conexión/transacción;
  - en Dapper, mediante un helper obligatorio.
- Roles:
  - `finkey_owner`: dueño de las tablas; solo migraciones.
  - `finkey_app`: runtime; sin DDL ni `BYPASSRLS`.
- Los jobs recorren los hogares y fijan el contexto de cada uno; no usan un rol privilegiado.
- Fuera de RLS: Identity (el login ocurre antes de conocer el hogar) y Reference (datos globales).
- La privacidad entre miembros (`owner_user_id`) se mantiene en la aplicación y se cubre con la matriz de autorización.

## Consecuencias
- Positivas:
  - Defensa en profundidad: un bug de filtro en EF o Dapper no cruza hogares.
  - Se aprende RLS en un caso real.
- Negativas:
  - Toda conexión debe pasar por el helper o el interceptor; si no, devuelve 0 filas (visible en tests, no silencioso).
  - Las migraciones deben crear las políticas.
  - Un costo de rendimiento mínimo (con índice en `household_id`).
- Qué haría reconsiderar esta decisión: que las políticas complejas degraden el rendimiento o que el pooler no respete `set_config` local; en ese caso, volver a la opción 1 con más tests.
