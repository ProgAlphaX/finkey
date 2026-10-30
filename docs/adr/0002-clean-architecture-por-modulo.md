# ADR-0002: Clean Architecture por módulo + vertical slices de lectura

- **Estado**: Aceptado
- **Fecha**: 2026-10-26
- **Reversibilidad**: Media

## Contexto
La mantenibilidad (NFR-03) es prioridad y el usuario quiere separación de responsabilidades sin dependencias fuertes. Los módulos no tienen la misma complejidad: Ledger y Periods concentran las reglas, mientras que Insights solo lee.

## Opciones consideradas
1. **Clean Architecture uniforme en todos los módulos**: es consistente, pero agrega ceremonia innecesaria en los módulos de solo lectura o de pura integración.
2. **Vertical Slice en todo**: es rápido, pero las reglas de dominio ricas tienden a dispersarse.
3. **Mixto según la complejidad del módulo**.

## Decisión
**Mixto**:
- Clean Architecture + DDD táctico (Domain ← Application ← Infrastructure/Api, más Contracts) en Ledger, Periods, Planning y Debts.
- Clean ligero en Identity; capas simples en Reference y Notifications.
- Vertical slices de solo lectura (SQL → DTO) en Insights, como CQRS ligero.
- Reglas de dependencia verificadas con tests de arquitectura en CI (`03-architecture.md` §3).

## Consecuencias
- Positivas: el dominio no depende de frameworks y se prueba en aislamiento; cada módulo usa la ceremonia justa; la IA tiene plantillas claras por tipo de módulo.
- Negativas: hay dos estilos que aprender; existe el riesgo de que alguien "salte" capas, mitigado con los tests de arquitectura.
- Qué haría reconsiderar esta decisión: si un módulo simple gana reglas ricas, se promueve a Clean completo.
