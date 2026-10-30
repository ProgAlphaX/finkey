# ADR-0020: Observabilidad con OpenTelemetry y Grafana Cloud

- **Estado**: Aceptado
- **Fecha**: 2026-10-27
- **Reversibilidad**: Alta (OpenTelemetry es estándar; cambiar de backend es cambiar el endpoint OTLP)

## Contexto
- NFR-09 pide logs estructurados, trazas y alertas ante errores 5xx y jobs fallidos.
- La restricción es $0.
- Con *scale-to-zero* no se puede usar un *uptime pinger*.

## Opciones consideradas
1. **Grafana Cloud free**:
   - logs, trazas y métricas vía OTLP;
   - 10k series y 50 GB de logs/trazas, con 14 días de retención;
   - alertas por email;
   - errores del frontend con Faro.
2. **Solo Cloud Logging/Monitoring de GCP**: integrado y con 50 GiB de logs gratis, pero las trazas y métricas personalizadas tienen límites y costos menos claros, y queda atado a GCP.
3. **Sentry + Better Stack**: buenos, pero son 2 herramientas más con free tiers pequeños.

## Decisión
- El backend exporta por **OTLP** a Grafana Cloud. Stdout en JSON queda también en Cloud Logging como respaldo.
- El frontend usa **Grafana Faro**.
- Métricas de negocio para las alertas: `finkey_job_runs_total`, `finkey_push_sent_total` y `finkey_db_size_bytes`.
- Alertas por *heartbeat* de los jobs, en lugar de pings periódicos.
- En local, `grafana/otel-lgtm` en Docker Compose: el mismo stack, útil para aprender.
- `ForceFlush` de OpenTelemetry al apagarse la instancia.

## Consecuencias
- Positivas:
  - Un solo panel para las tres señales.
  - Estándar abierto.
  - Alertas gratuitas.
  - El aprendizaje es transferible a cualquier empresa.
- Negativas:
  - Retención de 14 días (suficiente).
  - Un proveedor más que administrar.
- Qué haría reconsiderar esta decisión: que el free tier se reduzca → pasar a Cloud Logging + Cloud Trace cambiando solo el exportador.
