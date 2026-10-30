# ADR-0001: Monolito modular

- **Estado**: Aceptado
- **Fecha**: 2026-10-26
- **Decisores**: Equipo FinKey
- **Reversibilidad**: Baja ⚠️

## Contexto
Hay un solo desarrollador, presupuesto de $0 y requisitos de mantenibilidad (NFR-03) y de *scale-to-zero*. El dominio tiene 8 áreas con reglas propias (`02-domain.md`) y todavía está en descubrimiento.

## Opciones consideradas
1. **Monolito en capas tradicional**: es simple, pero las capas horizontales mezclan todos los dominios y con el tiempo crece el acoplamiento.
2. **Monolito modular**: un solo despliegue con módulos verticales aislados. Tiene costo operativo bajo y fronteras claras.
3. **Microservicios**: dan despliegue y escalado independientes, pero multiplican la infraestructura, el costo y la complejidad (red, consistencia eventual, observabilidad distribuida).

## Decisión
**Monolito modular**: un despliegue, 8 módulos, un esquema de BD por módulo, comunicación solo por contratos públicos y eventos (ADR-0006). Las fronteras se verifican con tests de arquitectura.

## Consecuencias
- Positivas: un solo contenedor y una sola BD → encaja con $0 y *scale-to-zero*; refactorizar entre módulos es barato; transacciones ACID locales.
- Negativas: todos los módulos escalan juntos; un bug grave puede afectar a toda la app.
- Qué haría reconsiderar esta decisión: un módulo con necesidades de escala o de ritmo de despliegue muy distintas (ej. Notifications con miles de usuarios) → extraerlo a servicio, lo que el diseño de contratos y outbox ya facilita.
