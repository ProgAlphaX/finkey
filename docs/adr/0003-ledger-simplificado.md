# ADR-0003: Ledger simplificado (transacción + asientos)

- **Estado**: Aceptado
- **Fecha**: 2026-10-26
- **Reversibilidad**: Baja ⚠️

## Contexto
FinKey maneja ingresos, gastos, transferencias (incluso entre monedas), tarjetas de crédito, deudas, gastos compartidos y saldos entre la pareja. Necesita saldos exactos, patrimonio individual y conjunto, y auditoría (BR-011, BR-032, BR-051, BR-110 a BR-112).

## Opciones consideradas
1. **Tablas separadas por tipo de operación** (gastos, ingresos, transferencias, préstamos…), cada una con su lógica de saldo. Es intuitivo al inicio, pero los saldos y el patrimonio requieren sumar N fuentes con reglas especiales, y cada tipo nuevo multiplica los casos.
2. **Contabilidad de partida doble completa** (las categorías también son cuentas). Es la más rigurosa, pero es demasiado compleja para el usuario y para el MVP.
3. **Ledger simplificado**: cada operación es una `Transaction` con `Entries` (monto con signo por cuenta) y `Allocations` (parte atribuida a cada persona). Hay cuentas virtuales de pareja.

## Decisión
**Ledger simplificado** (`02-domain.md` §1):
- Saldo de una cuenta = Σ asientos.
- Tarjetas y deudas son cuentas de pasivo.
- El saldo entre pareja = saldo de las cuentas virtuales `PartnerReceivable` / `PartnerPayable`.
- Patrimonio = Σ de las cuentas convertidas a PEN.

## Consecuencias
- Positivas: un solo mecanismo para todos los casos; el patrimonio y el saldo entre pareja salen sin lógica especial; es auditable; agregar un tipo de operación nuevo solo define sus asientos.
- Negativas: hay que crear las cuentas virtuales y cuidar el rendimiento del cálculo de saldos (con una proyección cacheada en la misma transacción).
- Qué haría reconsiderar esta decisión: necesitar contabilidad formal (reportes tributarios) → evolucionar a partida doble completa.
