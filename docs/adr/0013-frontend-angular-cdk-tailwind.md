# ADR-0013: Frontend Angular 22 + CDK + Tailwind con componentes propios

- **Estado**: Aceptado
- **Fecha**: 2026-10-26
- **Reversibilidad**: Media

## Contexto
La app es una PWA móvil primero (NFR-02), con un design system propio diseñado en Penpot y tokens exportados (ADR-0008). El stack del usuario es Angular.

## Opciones consideradas
1. **Angular CDK + Tailwind CSS v4 + componentes propios**: máxima fidelidad al diseño; la accesibilidad la aporta el CDK.
2. **Angular Material 3**: es rápido, pero tiene una estética marcada y personalizarlo a fondo es costoso.
3. **PrimeNG / Spartan**: muchos componentes listos, pero con dependencia del ritmo de un tercero.

## Decisión
- **Angular 22**: standalone, zoneless y signals.
- **Angular CDK** para el comportamiento accesible: overlays, diálogos, foco y listas.
- **Tailwind CSS v4** con los tokens de Penpot como variables CSS.
- Componentes propios en `shared/`, documentados en Storybook.
- Gráficos con Apache ECharts.
- PWA con `@angular/service-worker`.

## Consecuencias
- Positivas: el diseño se implementa tal cual; los tokens son la única fuente de verdad; hay un aprendizaje completo de design system.
- Negativas: más trabajo inicial para construir los componentes base (botón, input de monto, selector de cuenta, modal, toast).
- Qué haría reconsiderar esta decisión: si el plazo aprieta, usar Material 3 en componentes complejos puntuales (ej. el datepicker).
