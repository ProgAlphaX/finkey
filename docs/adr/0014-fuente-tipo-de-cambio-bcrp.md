# ADR-0014: Fuente del tipo de cambio — API del BCRP (SBS compra)

- **Estado**: Aceptado
- **Fecha**: 2026-10-26
- **Reversibilidad**: Alta

## Contexto
Se necesita un tipo de cambio USD→PEN **de compra**, realista, diario y gratuito, para valorizar el patrimonio (BR-120 a BR-124).

## Opciones consideradas
1. **API pública del BCRP**, serie **PD04639PD** (TC sistema bancario SBS, compra): es oficial, gratis, sin API key, con histórico desde 1997.
2. **BCRP PD04645PD** (cierre interbancario de compra, 13:30): es interbancario, menos representativo de lo que paga un banco a una persona.
3. **Casas de cambio online**: son más "reales", pero no tienen una API oficial (habría que hacer scraping frágil).
4. **APIs comerciales de divisas**: tienen free tiers limitados y no son una fuente peruana oficial.

## Decisión
- **BCRP PD04639PD**, mediante el endpoint `/estadisticas/series/api/PD04639PD/json/{desde}/{hasta}`.
- Los valores "n.d." (feriados y fines de semana) usan el último disponible (BR-122).
- El usuario puede registrar a mano el tipo real de su banco o casa de cambio (BR-121).

## Consecuencias
- Positivas: oficial, gratis y estable; el override manual cubre la diferencia con el tipo real.
- Negativas: el valor se publica con desfase (a veces el del día anterior), lo cual es aceptable para valorizar.
- Qué haría reconsiderar esta decisión: que el BCRP cambie o retire la API → adaptador alternativo (el puerto `IExchangeRateProvider` lo aísla).
