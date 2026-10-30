# FinKey — Resumen de cierre de la planificación

**Fecha:** 2026-10-28 · **Detalle:** `00-vision.md` a `07-roadmap.md` y `adr/`

## Problema
Llevar las finanzas personales y de pareja en un solo lugar: ingresos, gastos, ahorros, deudas, tarjetas y pagos programados, con alertas y evolución mensual. Para 2 usuarios con un hogar compartido. Nunca se conecta a bancos: las transferencias solo se registran.

## MVP (39 historias Must, 11 épicas)
Identidad y hogar · cuentas PEN/USD privadas o compartidas · gastos e ingresos (incl. compartidos 50/50) · transferencias · saldo y préstamos entre la pareja · deudas y tarjetas de crédito · pagos planificados con push · metas de ahorro · dashboard, patrimonio y evolución · período financiero que empieza el día de pago, con cierre automático · tipo de cambio diario (BCRP). Los 7 Should quedan como reserva.

## Arquitectura
Monolito modular (8 módulos: Identity, Ledger, Debts, Planning, Periods, Reference, Notifications, Insights), Clean Architecture por módulo, ledger simplificado, comunicación por contratos y eventos con outbox, jobs disparados por un scheduler externo (la API se apaga sola). Seguridad por diseño: ownership por hogar y dueño, RLS en Postgres, cookie `__Host-` same-origin, passkeys + TOTP.

## Stack
.NET 10 · PostgreSQL (EF Core + Dapper) · ASP.NET Core Identity · Angular 22 PWA + CDK + Tailwind + ECharts · Cloud Run + Neon + Cloudflare Pages/R2 · GitHub Actions + release-please · OpenTelemetry → Grafana Cloud · Docker en todo el flujo.

## Costo mensual estimado: **$0**
Todo en free tiers, con presupuesto de GCP de $1 como alarma. Sin dominio propio ni email transaccional en el MVP. Revisión trimestral de los free tiers.

## Riesgos principales
| # | Riesgo | Mitigación |
|---|---|---|
| 1 | Un free tier cambia o desaparece | Todo dockerizado; migrable en ~1 día (ADR-0017) |
| 2 | Menos horas disponibles de las previstas | Colchón del 25 % por sprint, Should fuera del plan, KPIs de desvío |
| 3 | Passkeys inmaduras en .NET 10 o iOS | Spike al inicio del Sprint 0; contraseña + TOTP como respaldo |
| 4 | Web Push poco confiable en iOS | Probar pronto en un iPhone real; lista de pagos pendientes como respaldo |
| 5 | Fuga de datos entre usuarios u hogares | Matriz de autorización automática + RLS; ambos bloquean el merge |

## Plan (1 punto = 1 hora, ~54 h reales por sprint, ~41 h comprometidas)
| Sprint | Fechas | Contenido | Horas |
|---|---|---|---|
| S0 | 28 oct – 10 nov | Esqueleto, CI/CD, stg y prod con `/health`, login y hogar | 41 |
| S1 | 11 – 24 nov | Cuentas, movimientos, período, transferencias, préstamos | 42 |
| S2 | 25 nov – 8 dic | Pareja, deudas, tarjeta, pagos con push, metas, dashboard | 41 |
| S3 | 9 – 22 dic | Patrimonio, cierre de período, endurecimiento y **release v1.0.0** | 33 |
| S4–S5 | 23 dic – 19 ene | Reserva y Should | — |

**MVP en producción:** Sprint 3, hacia el **22 de diciembre de 2026** (157 h). Con una desviación de 1,5x pasaría al Sprint 4, hacia el 5 de enero de 2027.

## ADRs
0001 Monolito modular · 0002 Clean por módulo · 0003 Ledger simplificado · 0004 Ownership y autorización · 0005 Dinero, fechas e IDs · 0006 Contratos + outbox · 0007 Jobs externos · 0008 Herramientas de diseño · 0009 Ambientes y bases aisladas · 0010 .NET 10 · 0011 PostgreSQL + EF Core + Dapper · 0012 ASP.NET Identity · 0013 Angular + CDK + Tailwind · 0014 Tipo de cambio BCRP · 0015 Sesión por cookie con proxy · 0016 RLS por hogar · 0017 Cloud Run + Cloudflare + Neon · 0018 Backups cifrados en R2 · 0019 release-please · 0020 Observabilidad en Grafana Cloud.

## Siguiente paso
Sprint 0, FK-67: crear el repo público en GitHub, proteger `main` y activar secret scanning, Dependabot y CodeQL. Después, el checklist de `06-devops.md` §10 hasta el primer `/health` desplegado en stg y prod.
