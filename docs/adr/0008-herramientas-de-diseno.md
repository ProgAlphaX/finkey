# ADR-0008: Herramientas de diseño — Penpot + Storybook

- **Estado**: Aceptado
- **Fecha**: 2026-10-22 (formalizado el 2026-10-26)
- **Reversibilidad**: Alta

## Contexto
Se quiere diseñar la UI desde cero y dejarla documentada con ayuda de IA vía MCP, con un costo de $0.

## Opciones consideradas
1. **Figma + MCP oficial**: es el estándar de la industria, pero el plan Starter limita el MCP a muy pocas llamadas por mes y el MCP de escritorio exige un asiento pago.
2. **Penpot + MCP oficial**: open source, gratis y basado en estándares abiertos (SVG, CSS, tokens).
3. **Solo diseño en código** (Storybook): no deja un diseño previo a la implementación.

## Decisión
- Wireframes con Excalidraw o una herramienta de diseño asistido por IA.
- Diseño final y design system en **Penpot vía MCP**.
- Design tokens exportados a la PWA.
- **Storybook** como documentación viva de los componentes implementados.

## Consecuencias
- Positivas: costo $0; flujo completo de diseño a código; tokens compartidos.
- Negativas: Penpot tiene un ecosistema más pequeño que Figma.
- Qué haría reconsiderar esta decisión: necesitar colaborar con diseñadores que solo usan Figma.
