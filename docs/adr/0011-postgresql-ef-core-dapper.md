# ADR-0011: PostgreSQL + EF Core (comandos) + Dapper (lecturas)

- **Estado**: Aceptado
- **Fecha**: 2026-10-26
- **Reversibilidad**: Baja ⚠️ (motor) · Media (acceso a datos)

## Contexto
El ledger requiere transacciones ACID y `numeric` exacto (ADR-0003, ADR-0005). Insights necesita consultas agregadas por período. Cada módulo es dueño de su esquema (ADR-0001). La restricción de costo es $0 con *scale-to-zero* (ADR-0009).

## Opciones consideradas
1. **PostgreSQL**: gratis; tiene free tiers con *scale-to-zero* (Neon); ofrece `numeric`, `jsonb` y window functions.
2. **SQL Server**: es conocido, pero no hay un free tier equivalente con *scale-to-zero* y licencias para todos los ambientes.
3. **Acceso solo con EF Core**: los reportes complejos quedan menos controlados.
4. **Acceso solo con Dapper**: hay mucho código repetitivo para los agregados y no hay migraciones.

## Decisión
- **PostgreSQL 17** (o 18 si está estable en Neon).
- **EF Core 10 + Npgsql** para los comandos: un `DbContext` por módulo, con su esquema y su historial de migraciones.
- **Dapper** para las consultas de Insights, sobre vistas o proyecciones que aplican el filtro de ownership (ADR-0004).
- Nombres en snake_case.

## Consecuencias
- Positivas: los agregados se mapean con productividad; las consultas de reportes usan SQL explícito y optimizable; cada módulo migra de forma independiente.
- Negativas: son dos tecnologías de acceso, y las consultas Dapper deben replicar el filtro de seguridad (mitigado con tests de autorización).
- Qué haría reconsiderar esta decisión: rendimiento insuficiente en lecturas → vistas materializadas (Fase 5).
