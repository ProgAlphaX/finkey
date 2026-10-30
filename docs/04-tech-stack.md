# Stack tecnológico — FinKey

Drivers: seguridad y privacidad ★, usabilidad móvil ★, mantenibilidad ★; restricciones: $0, *scale-to-zero*, 1 dev + IA.
Arquitectura: `03-architecture.md`. ADRs de esta fase: 0010 a 0014.
Las versiones son las estables vigentes a octubre de 2026; se revisan al iniciar el desarrollo.

---

## 1. Backend: matriz de decisión (ADR-0010)

Puntaje 1–5 · Total = Σ peso × puntaje · Máximo posible = 145.

| Criterio | Peso | .NET 10 | Spring Boot (Java 25) | Nota |
|---|---|---|---|---|
| Dominio del equipo | 5 | 5 | 3 | .NET 8/9 con EF y Dapper vs Spring en aprendizaje |
| Objetivo de aprendizaje | 2 | 3 | 5 | Spring enseñaría más, pero el objetivo es el proceso, no el lenguaje |
| Madurez / LTS | 4 | 5 | 5 | .NET 10 LTS (soporte hasta nov. 2028) · Java 25 LTS |
| Ecosistema | 3 | 5 | 5 | Ambos completos para lo que necesitamos |
| Arranque en frío / consumo | 5 | 5 | 3 | Clave con *scale-to-zero*: .NET arranca rápido con poca memoria; la JVM es más lenta salvo con GraalVM native (más complejo) |
| Costo de hosting | 4 | 5 | 3 | Menos memoria → cabe holgado en los free tiers |
| Testabilidad | 3 | 5 | 5 | Testcontainers y tests de arquitectura en ambos |
| Productividad con IA | 3 | 5 | 5 | Ambos muy bien cubiertos |
| **Total** | | **141** | **117** | Diferencia del 17 % → no es empate |

**Resultado: .NET 10.** Spring Boot queda como opción para un proyecto futuro de aprendizaje.

---

## 2. Stack completo

### Backend
| Necesidad | Elección | Motivo / nota |
|---|---|---|
| Runtime | **.NET 10 LTS**, C# 14 | ADR-0010 |
| API | **ASP.NET Core Minimal APIs**, un grupo de endpoints por módulo | Liviano y rápido de arrancar; cada módulo registra sus propios endpoints |
| OpenAPI | `Microsoft.AspNetCore.OpenApi` (nativo) + **Scalar** | Documentación interactiva; el OpenAPI es la fuente para generar el cliente de la PWA |
| Casos de uso | **Handlers propios** (`ICommandHandler` / `IQueryHandler`) + decoradores (validación, logging, transacción) con **Scrutor** | Decisión de diseño, no de licencia: cada endpoint inyecta su handler, así la dependencia es explícita y navegable; el pipeline propio se entiende por dentro. MediatR (Community License, gratis para nosotros) queda como alternativa |
| Validación | **FluentValidation** | Validación de entrada en Application |
| Mapeo | **Mapperly** (generación de código en compilación, MIT); mapeo manual en casos triviales | En lugar de AutoMapper: si falta o se renombra un campo, falla el build y no la ejecución; sin reflexión |
| Persistencia (comandos) | **EF Core 10 + Npgsql**: un `DbContext` por módulo, un esquema por módulo, migraciones por módulo | ADR-0011 |
| Persistencia (lecturas) | **Dapper** en Insights | CQRS ligero (ADR-0002) |
| Convención de nombres | `EFCore.NamingConventions` (snake_case) | Estándar en Postgres |
| IDs | `Guid.CreateVersion7()` (nativo) | ADR-0005 |
| Tiempo | `TimeProvider` + `DateOnly`; zona `America/Lima` | ADR-0005; testeable |
| Autenticación | **ASP.NET Core Identity** (.NET 10) con passkeys + contraseña | ADR-0012 |
| Push | Librería **WebPush** (VAPID) | Web Push estándar; funciona en iOS con la PWA instalada |
| HTTP externo | `HttpClient` + `Microsoft.Extensions.Http.Resilience` | Reintentos y timeouts al consultar el BCRP |
| Observabilidad | `ILogger` con salida JSON + **OpenTelemetry** (trazas y métricas) | Exportación OTLP a Grafana Cloud (ADR-0020) |
| Health checks | `/health/live`, `/health/ready` (incluye la BD) | Usados por el hosting y los smoke tests |
| Calidad de código | `.editorconfig`, `Nullable` habilitado, `TreatWarningsAsErrors`, analyzers de .NET + **SonarAnalyzer.CSharp**, **CSharpier** (formato) | NFR-03 |

### Base de datos
| Necesidad | Elección | Motivo |
|---|---|---|
| Motor | **PostgreSQL 17** (o 18 si Neon ya lo ofrece de forma estable) | Transacciones ACID, `numeric`, `jsonb` (auditoría), window functions para la evolución por período |
| Hosting | **Neon** (un proyecto para stg y otro para prod) | ADR-0009; *scale-to-zero*, $0 |
| Local / CI | Postgres en Docker / Testcontainers | Misma versión mayor en todos los ambientes |

### Frontend (PWA)
| Necesidad | Elección | Motivo |
|---|---|---|
| Framework | **Angular 22** (standalone, zoneless, signals, control flow nativo) | Stack del usuario; actualizar a la 23 cuando salga y estabilice |
| PWA y push | `@angular/service-worker` + `SwPush` | Instalable, caché del *app shell*, Web Push |
| Componentes | **Angular CDK** + **Tailwind CSS v4** + componentes propios en `shared/` | ADR-0013; design system propio desde Penpot |
| Design tokens | Exportados desde Penpot → variables CSS → tema de Tailwind | Una sola fuente de verdad para el diseño |
| Formularios | Reactive Forms tipados (o Signal Forms si ya es estable en la versión usada) | Registro rápido de gasto (NFR-02) |
| Gráficos | **Apache ECharts** (`ngx-echarts`) | Buen rendimiento en móvil, tooltips táctiles, gratis |
| Cliente de API | Generado desde OpenAPI con **ng-openapi-gen** | Nunca DTOs a mano; cambios de contrato detectados en compilación |
| Localización | Locale `es-PE`, `Intl` para S/ y US$ | NFR-10 |
| Documentación de UI | **Storybook** | ADR-0008 |
| Calidad | **angular-eslint** + **Prettier**, TypeScript `strict` | NFR-03 |
| Gestor de paquetes | **pnpm**, Node **24 LTS** | Rápido y determinista |

### Testing
| Capa | Backend | Frontend |
|---|---|---|
| Unitarios | **xUnit v3** + **FluentAssertions v8** + **NSubstitute** + **Bogus** | **Vitest** + Angular Testing Library |
| Arquitectura | **ArchUnitNET** (o NetArchTest) | Reglas de imports con ESLint (`no-restricted-imports` / boundaries) |
| Integración | `WebApplicationFactory` + **Testcontainers (PostgreSQL)** + **Respawn** | — |
| Contrato de API | Snapshot del OpenAPI con **Verify** | Recompilación del cliente generado |
| E2E | **Playwright** (Chromium y WebKit, viewports de móvil y escritorio) contra API + PWA + BD efímera | (mismo) |
| Cobertura | coverlet → reporte en CI | Vitest coverage |

Nota: FluentAssertions v8 usa la licencia de Xceed, gratuita para uso no comercial (FinKey es personal). Si el proyecto llegara a generar ingresos, se compra la licencia o se migra a Shouldly / FluentAssertions 7.x (Apache 2.0).

### Integraciones externas
| Necesidad | Elección | Nota |
|---|---|---|
| Tipo de cambio | **API pública del BCRP**, serie **PD04639PD** (TC sistema bancario SBS, **compra**) | ADR-0014; gratis, sin API key; en feriados devuelve "n.d." → se usa el último valor (BR-122) |
| Feriados de Perú | Carga anual desde la lista oficial (gob.pe), con una API pública de feriados como apoyo si cubre PE | BR-088; se valida al implementar |
| Invitación a la pareja | **Enlace de invitación** (copiar y compartir, ej. por WhatsApp) | El MVP no necesita proveedor de email |
| Email (recuperar contraseña) | **No en el MVP** (passkeys + códigos de recuperación) | Fase 7: si se agrega más adelante, Resend (free tier) |

### Herramientas del proceso
| Necesidad | Elección |
|---|---|
| Repositorio y CI/CD | GitHub + GitHub Actions |
| Commits y versionado | Conventional Commits + **commitlint**; SemVer automático con **release-please** (ADR-0019) |
| Gestión ágil | Jira Free + Atlassian Rovo MCP |
| Diseño | Penpot + MCP · Excalidraw / diseño asistido por IA (wireframes) |
| Orquestación local | **Docker Compose** (Postgres + API + PWA) |
| Dependencias | Dependabot o Renovate |

---

## 3. Notas de seguridad del stack (se profundiza en la Fase 6)
- **Sesión**: preferimos **cookies httpOnly en el mismo sitio** que la PWA, haciendo pasar `/api` por el mismo dominio del frontend (proxy en el hosting estático). Así se evitan los problemas de cookies de terceros en Safari/iOS y no hay tokens accesibles desde JavaScript. Confirmado en la Fase 6: [ADR-0015](adr/0015-sesion-cookie-con-proxy.md) (proxy con una Cloudflare Pages Function) y RLS por hogar en [ADR-0016](adr/0016-rls-por-hogar.md).
- **Passkeys**: soportadas por ASP.NET Core Identity en .NET 10 (registro y login sin contraseña). Ideal para el registro rápido desde el móvil (Face ID / huella).
- **Licencias**: todo el stack es gratuito para FinKey. Todo es open source salvo FluentAssertions v8, que es gratis para uso no comercial. Si FinKey se monetiza, se revisan las licencias.
