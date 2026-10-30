# ADR-0004: Ownership por hogar/dueño y autorización

- **Estado**: Aceptado
- **Fecha**: 2026-10-26
- **Reversibilidad**: Baja ⚠️

## Contexto
La seguridad y la privacidad son prioridad (NFR-01). Las cuentas son privadas por defecto y se pueden compartir con el hogar (BR-003). El diseño debe permitir más hogares en el futuro (visión: "diseño abierto").

## Opciones consideradas
1. **Solo `user_id` en cada fila**: no modela lo compartido.
2. **Tablas separadas para lo privado y lo compartido**: duplica el modelo.
3. **`household_id` (obligatorio) + `owner_user_id` (null = compartido)** en toda fila de negocio, con filtrado centralizado.
4. Variante: igual que la opción 3, más **Row Level Security** de PostgreSQL.

## Decisión
**Opción 3**:
- Cada agregado tiene `Ownership`.
- Un filtro global en la capa de persistencia restringe todas las consultas al hogar del usuario y, dentro de él, a lo propio o lo compartido.
- Cada caso de uso valida el acceso al recurso.
- Un recurso ajeno responde **404**.
- Tests de integración de autorización por endpoint.
- RLS se evalúa en la Fase 6 como defensa adicional.

## Consecuencias
- Positivas: la privacidad se aplica en un solo lugar; listo para varios hogares (multi-tenant) sin migraciones; tests sistemáticos.
- Negativas: las consultas SQL directas (Insights) deben aplicar el mismo filtro a mano, mitigado con vistas o funciones parametrizadas y tests.
- Qué haría reconsiderar esta decisión: un usuario en varios hogares → `Membership` N:N (el modelo ya lo admite).
