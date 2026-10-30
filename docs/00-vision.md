# Visión — FinKey

## Problema
Llevamos las finanzas personales y de pareja en Excel / Google Sheets y resulta **demasiado tedioso**:
registrar movimientos a mano en una hoja es lento, no avisa cuándo hay que pagar algo y armar la
evolución mes a mes o el patrimonio exige trabajo manual.

## Usuarios
| Persona/rol | Necesidad principal |
|---|---|
| Usuario (yo) | Registrar y planificar mis finanzas; recibir alertas de pagos; ver mi patrimonio |
| Pareja | Lo mismo, con sus propias cuentas (usa iPhone → PWA instalada en iOS) |
| Hogar (ambos) | Ver y gestionar lo compartido: gastos, ahorros, deudas y patrimonio conjunto |

Alcance de usuarios: **solo nosotros dos en el MVP**, con un modelo de datos preparado para
"hogares/grupos" ⚠️, de modo que más adelante puedan entrar otras parejas o familias sin reescribir.

## Objetivos (MVP)
1. **Login** seguro, para cada uno.
2. **Multicuentas**: varias cuentas (efectivo, bancos, billeteras) en **PEN y USD**, registradas a mano.
3. **Ingresos y gastos**: registrarlos más rápido que en Excel.
4. **Transferencias entre cuentas propias** (misma u otra entidad; solo un registro, sin mover dinero real).
5. **Transacciones entre nosotros** (préstamos, pagos o reembolsos de uno a otro).
6. **Deudas**: deudas a pagar (con terceros y entre nosotros), con saldo pendiente y pagos.
7. **Planificación de gastos/pagos** con fecha programada.
8. **Push notifications** de pagos pendientes en la fecha planificada.
9. **Ahorros**: saldo ahorrado y metas.
10. **Patrimonio individual y conjunto** (activos − deudas), convertido a PEN.
11. **Indicadores e histórico mensual**: evolución mes a mes con gráficos. El histórico **empieza en el
    mes en que se comienza a usar la app**; no se cargan meses anteriores del Excel.

## No-objetivos
- ❌ **Conexión con bancos — nunca.** Todo se registra a mano; las "transferencias" son registros, no mueven dinero real.
- ❌ Importar extractos (CSV/PDF) o el histórico del Excel — por ahora.
- ❌ App móvil nativa — basta con la PWA.
- ❌ Inversiones (acciones, cripto).

## Restricciones
- **Presupuesto**: $0 estricto (solo free tiers). Cualquier servicio que pida tarjeta lleva alerta de presupuesto.
- **Tiempo**: ver *Estimación* abajo.
- **Equipo**: 1 dev + IA.
- **Datos**: financieros y personales de 2 personas → privacidad y autorización estrictas entre usuarios.
- **Plataforma**: **PWA instalable** (Android, iOS ≥ 16.4 instalada en la pantalla de inicio, escritorio), responsive.
- **Monedas**: PEN principal y USD permitido por cuenta ⚠️ (cada monto con su moneda; patrimonio convertido a moneda base).
- **Encendido/apagado automático del ambiente** (ver abajo), sin pérdida de datos y sin costo.

## Ambiente con encendido/apagado automático
Requisito: el ambiente debe poder apagarse solo (por inactividad o a una hora definida) y encenderse
solo cuando se usa o cuando toca enviar alertas, **sin perder registros y sin generar costos**.

Enfoque preliminar (se decide en la Fase 7 con un ADR):
- **API con *scale-to-zero*** (ej. Google Cloud Run o Azure Container Apps): se apaga sola sin tráfico
  y se enciende sola con la primera petición (cold start de unos segundos). Apagada no consume cómputo.
- **Ventana horaria opcional**: un cron (GitHub Actions) puede forzar "apagado" (ej. 00:00–06:00) y
  volver a habilitarla a una hora fija.
- **BD separada de la API** (ej. Neon Postgres, que se suspende sola tras unos minutos sin uso): apagar
  la API o la BD **no borra datos**; el almacenamiento persiste. Además: backups automáticos.
- **Alertas**: un scheduler externo despierta la API a la hora de envío (ej. 08:00) para procesar las
  notificaciones del día, aunque nadie la esté usando.
- **Control de costos**: alerta de presupuesto en $1 en el proveedor cloud y revisión de consumo
  contra el free tier. Riesgo: Cloud Run/Azure piden tarjeta; un error de configuración (min instances > 0)
  podría generar cobro → se valida en CI y con alerta de presupuesto.

## Ambientes y versionado
| Ambiente | Base de datos | Uso |
|---|---|---|
| **dev** | PostgreSQL local (Docker) | Desarrollo en la máquina |
| **qa** | PostgreSQL efímero en CI (Testcontainers) | Tests unitarios, de integración, de arquitectura y E2E (Playwright) en cada PR |
| **stg** | Proyecto Neon `finkey-stg` (aislado) | Pruebas de aceptación de ambos usuarios sobre cada versión candidata |
| **prod** | Proyecto Neon `finkey-prod` (aislado) | Uso diario real |

- Cada paso a **prod** es una versión **SemVer** (`vX.Y.Z`) generada a partir de Conventional Commits; stg recibe versiones candidatas (`vX.Y.Z-rc.N`).
- El apagado y encendido automático aplica a stg y prod; stg puede tener una ventana de apagado más amplia.
- Detalle: ADR-0009 y `03-architecture.md` §11.

## Motivación
1. **Usarlo de verdad** para reemplazar el Excel.
2. **Aprender a construir un proyecto desde cero de punta a punta, con IA**: planificación y documentación,
   diseño UI/UX (Penpot), elección de arquitectura, frameworks y base de datos, gestión ágil con Jira,
   testing, CI/CD, observabilidad, escalabilidad y despliegue. Cada decisión queda documentada (ADRs).

## Herramientas del proceso
| Herramienta | Uso | Costo / límite a tener en cuenta |
|---|---|---|
| **Jira Cloud Free** + Atlassian Rovo MCP | Épicas, historias, refinamiento y sprints automatizados desde la IA | Gratis (hasta 10 usuarios); el MCP tiene un límite de llamadas por hora; Jira Automation es limitada en Free |
| **Excalidraw** / diseño asistido por IA (MCP) | Wireframes y exploración rápida de flujos y pantallas | Gratis |
| **Penpot** + MCP oficial | Diseño final y design system documentado (colores, tipografías, componentes, pantallas) | Gratis, open source (cloud o self-hosted) |
| **Storybook** | Documentación viva de los componentes Angular implementados (tokens exportados desde Penpot) | Gratis |
| **GitHub** | Repo, Issues, Actions (CI/CD, crons) | Gratis |

### Decisión: herramientas de diseño (2026-10-22)
- **Elegido**: wireframes con Excalidraw / diseño asistido por IA → diseño final en **Penpot vía MCP** → tokens a Angular + **Storybook**.
- **Descartado**: Figma. En el plan Starter, el MCP oficial está limitado a muy pocas llamadas por mes y el MCP de escritorio exige un asiento pago, lo que rompe el presupuesto de $0.
- **Consecuencias**: el costo sigue en $0 y el flujo diseño → código queda completo; a cambio, Penpot tiene un ecosistema más pequeño que Figma. Se formalizará como ADR en la Fase 3.

## Estimación (opinión profesional)
Supuesto: **~15–20 h/semana**, 1 dev + IA, haciendo todo el proceso completo (no solo el código).

| Etapa | Duración |
|---|---|
| Planificación completa (Fases 1–8) + Jira con backlog refinado | 1 semana |
| Diseño: wireframes + Penpot (design system + ~15 pantallas, móvil primero) | 1.5–2 semanas |
| M0 *Walking skeleton*: repo, CI/CD, deploy, auth, PWA, observabilidad básica | 1 semana |
| M1 Núcleo: cuentas, ingresos/gastos, transferencias, transacciones entre nosotros | 1.5–2 semanas |
| M2 Diferencial: planificación de pagos, push, deudas, ahorros/metas | 1.5–2 semanas |
| M3 Indicadores: patrimonio individual/conjunto, histórico mensual, gráficos | 1 semana |
| M4 Endurecimiento: E2E, seguridad, rendimiento, apagado/encendido automático | 1 semana |
| **Total** | **≈ 8–10 semanas (~2–2.5 meses)** |

- La IA acelera el **código** (2–3x); no acelera tanto el diseño, las decisiones, la revisión, la configuración de cloud ni el debugging de despliegue, que es justo lo que quieres aprender.
- **Optimista: 6 semanas** (si se limita el diseño a pocas pantallas y se paraleliza). **Con imprevistos: 12 semanas.**
- Primera versión **usable** (M1 en producción, ya reemplaza al Excel): ~**5 semanas**.

## Referencias
| Fuente | Qué tomar | Qué evitar |
|---|---|---|
| Excel / Sheets actual | Las categorías y la estructura que ya usamos | Registro lento, sin alertas, reportes manuales |

## Métricas de éxito
- Registrar un movimiento en < 10 s desde el celular.
- Cero pagos olvidados: cada pago planificado genera alerta.
- Dejar de usar el Excel al mes de lanzar el MVP.
- Ver patrimonio individual y conjunto, y la evolución mensual, en una pantalla.
- Costo mensual: $0.

## Riesgos detectados
- ⚠️ Alcance amplio para el MVP → se entrega por milestones; el M1 ya es usable.
- ⚠️ *Scale-to-zero* y cold starts: las alertas dependen de un scheduler externo que despierte la API.
- ⚠️ Proveedores cloud que piden tarjeta → alerta de presupuesto obligatoria.
- Push en iOS requiere la PWA instalada en la pantalla de inicio (el iPhone de la pareja es compatible).
