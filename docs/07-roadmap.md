# Roadmap y flujo de trabajo — FinKey (Fase 8)

Fuentes: `01-requirements.md` (historias HU-xxx), `03-architecture.md`, `05-quality.md` (DoR/DoD), `06-devops.md` §10.
Ritmo acordado el 2026-10-28: **sprints de 2 semanas (miércoles a martes)**, con el horario real de desarrollo.

## 1. Capacidad y estimación
- Capacidad: ~30 h/semana nominales (horario detallado solo en notas locales).
- Realista: ~27 h/semana (jueves y sábados fallan algunas veces) → **~54 h por sprint**. El Sprint 0 tiene 59 h nominales (el primer miércoles son 3 h).
- **1 punto de historia = 1 hora real**, con desarrollo asistido por IA. Mínimo de 1 h por issue: lo que toma minutos vale 1 h o se agrupa con otra tarea.
- Se compromete ~**41 h por sprint (≈ 75 % de la capacidad)**; el resto es colchón para bugs, depuración y lo imprevisto.
- **KPIs**: al pasar cada issue a Finalizado se registra en un comentario `Real: X h`. Por sprint se compara horas estimadas vs. reales, el factor de desvío y las horas comprometidas vs. completadas, en un Excel fuera del repo.
- Carga actual (horas): S0 41 · S1 42 · S2 41 · S3 33 → **157 h** del alcance Must, incluida la E12 de endurecimiento. Los Sprints 4 y 5 quedan como reserva.
- **Los Should (7 historias, 12 h) quedan fuera del plan** y entran solo si sobra capacidad.
- Si un sprint se desborda, se recorta del final de ese sprint, nunca la DoD (tests, seguridad).
- Las estimaciones son optimistas por diseño (IA); se recalibran al cerrar el Sprint 0 y el 1.

## 2. Principios de orden
1. **Walking skeleton primero**: lo difícil de infraestructura (CI/CD, deploy stg y prod, migraciones, RLS, proxy, observabilidad) se resuelve en el Sprint 0, no al final.
2. **Rebanadas verticales** (PWA → API → BD → test), nunca capas completas.
3. **Dependencia técnica → valor → riesgo.** Lo incierto (auth con passkeys, push en iOS, cierre de período) se adelanta.
4. Cada sprint termina con algo **desplegado en stg y usable**.
5. Historias de ≤ 1–2 días; si son más grandes, se dividen en tareas (TSK).

## 3. Plan por sprint

| Sprint | Fechas | Hito | Historias / contenido | Horas | Resultado demostrable |
|---|---|---|---|---|---|
| **S0** | 28 oct – 10 nov | M0 Walking skeleton + acceso | Checklist de `06-devops.md` §10; solución .NET (SharedKernel, BuildingBlocks, Host, Migrator, tests de arquitectura); PWA con shell; pipelines; HU-101, 102, 103 | 41 | `/health` en stg y prod con CI verde; login con passkey y hogar de la pareja |
| **S1** | 11 – 24 nov | M1 Núcleo | HU-201 a 204, 1101, 1001, 1002, 301 a 306, 401, 402, 501 | 42 | Cuentas PEN/USD, gastos e ingresos (incl. compartidos) en < 10 s, período, transferencias, préstamos |
| **S2** | 25 nov – 8 dic | M2 Valor diferencial | HU-502, 503, 601, 602, 603 a 605, 701 a 704, 104, 801, 802, 901 | 41 | Saldo de pareja, deudas, tarjeta, pagos planificados con push (incl. iPhone), metas y dashboard |
| **S3** | 9 – 22 dic | M3 Insights + M4 Endurecimiento | HU-902, 903, 904, 1003, 1004; E12 (seguridad, restore-test, accesibilidad, E2E, README, aceptación y release) | 33 | Patrimonio, evolución, cierre automático y **release v1.0.0 (MVP)** |
| S4 | 23 dic – 5 ene | Reserva | Colchón; luego Should (HU-403, 504, 705, 803, 905, 906, 1102) | — | Según capacidad |
| S5 | 6 – 19 ene | Reserva | Segundo colchón | — | — |

### Riesgos por sprint (lo incierto primero)
- **S0**: configuración de cuentas externas (GCP, Neon, Cloudflare, R2, Grafana) y proxy same-origin con cookie `__Host-`.
- **S0**: passkeys con ASP.NET Core Identity en .NET 10 (spike de 1 día al inicio) y alta del TOTP.
- **S2**: Web Push en iOS (requiere PWA instalada) y envío puntual a las 08:00 desde un job.
- **S3**: cierre de período y `period_summary` (reglas de último día hábil y gracia de +3 días).

## 4. Registro de riesgos

| ID | Riesgo | Prob. | Impacto | Mitigación |
|---|---|---|---|---|
| R1 | Un free tier cambia o se elimina | M | A | Todo dockerizado; la API y la PWA pueden moverse de proveedor en 1 día (ADR-0017) |
| R2 | Capacidad menor a 27 h/semana | M | M | Alcance Must fijo, Should fuera del plan; revisión de velocidad al cierre de cada sprint |
| R3 | Passkeys inmaduras en .NET 10 o en iOS | M | M | Spike en S0; la contraseña con TOTP es el respaldo (ADR-0012) |
| R4 | Web Push en iOS poco confiable | M | A | Probar temprano en un iPhone real; la lista de pagos pendientes en la app es el respaldo |
| R5 | Arranque en frío incómodo | A | B | ReadyToRun, caché del service worker, skeletons (arquitectura §10.3) |
| R6 | Un módulo se acopla a otro | M | A | Tests de arquitectura desde S0; bloquean el merge |
| R7 | Fuga de datos entre usuarios u hogares | B | A | Matriz de autorización automática + RLS (ADR-0004, ADR-0016) |
| R8 | La API del BCRP cambia o cae | M | B | Último tipo de cambio disponible y corrección manual (BR-121) |
| R9 | Pérdida de las llaves `age` de los backups | B | A | Copia en el gestor de contraseñas y copia offline; el restore-test mensual lo comprueba |

## 5. Flujo de desarrollo asistido por IA

### Por historia
1. **Spec corta**: historia (HU) + criterios + reglas BR-xxx afectadas, tomadas de `docs/`. La historia debe cumplir la DoR (`05-quality.md` §5).
2. **Plan** (modo plan) → el usuario lo revisa.
3. **Implementación en incrementos pequeños**, un commit atómico por paso funcional: `feat(ledger): add shared expense split FK-37`.
4. **Tests** en el mismo cambio (una regla nueva lleva su test).
5. **Revisión** (`/code-review`) y luego `/simplify` si hace falta.
6. **PR** con rebase-merge (conserva los commits atómicos). La DoD de `05-quality.md` §6 manda.

### Reglas
- `docs/` es la fuente de verdad: cuando cambia una decisión, se escribe un ADR nuevo.
- **Decisiones irreversibles requieren confirmación humana**: modelo de datos, auth, migraciones aplicadas, borrado de datos.
- Verificar siempre: compilar, correr los tests y probar la app antes de dar algo por hecho.
- Una historia por sesión; el contexto vive en los docs y en Jira, no en la conversación.
- Ramas: solo la clave (`FK-37`). Jira: títulos `HU - …`, `TSK - …`, `BUG - …`; flujo Por hacer → En curso → En revisión → En pruebas → Finalizado.
- Ningún archivo de la herramienta de IA se versiona en el repo público (ver `.git/info/exclude`).

## 6. Backlog en Jira
- Espacio **FinKey**, clave **FK**, tipos Epic / Historia / Tarea / Error.
- Se cargan: las 11 épicas (E1–E11), las 39 historias Must más las 7 Should (estas sin sprint) y las tareas del Sprint 0.
- Las tareas (TSK) y los bugs posteriores se crean a medida que surgen.
- Cada historia lleva en su descripción los criterios de aceptación y las reglas BR-xxx de `01-requirements.md`.

## 7. Siguiente paso concreto
Cargar el backlog en Jira, abrir el **Sprint 0** y empezar por el checklist de `06-devops.md` §10 (repo público, proyectos GCP/Neon/Cloudflare, primer "hello world" con `/health` en stg y prod).
