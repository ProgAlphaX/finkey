# ADR-0017: Hosting — Cloud Run + Cloudflare Pages + Neon, con Cloud Scheduler

- **Estado**: Aceptado
- **Fecha**: 2026-10-27
- **Reversibilidad**: Alta (todo va en Docker; los jobs son endpoints HTTP)

## Contexto
- Restricción de $0 (NFR-04).
- *Scale-to-zero* con encendido automático y sin pérdida de datos (visión).
- Alertas a las 08:00 ±15 min (NFR-05).
- Sesión same-origin mediante proxy (ADR-0015).
- AWS excluido por decisión del usuario: sus créditos son para otro proyecto. Neon corre sobre AWS, pero en la cuenta de Neon, no del usuario.

## Opciones consideradas
1. **Google Cloud Run**:
   - free tier de 180k vCPU-s, 360k GiB-s y 2M requests al mes;
   - Cloud Scheduler con OIDC (3 jobs gratis);
   - deploy desde GitHub con Workload Identity Federation.
2. **Azure Container Apps**:
   - el mismo free grant y ecosistema Microsoft;
   - la configuración es más pesada (environment, Log Analytics, que puede cobrar) y los jobs serían Container Apps Jobs o un cron externo.
3. **Render / Koyeb / Fly.io**: sus free tiers son más limitados o cambiantes, y algunos apagan el servicio o piden tarjeta sin un free tier claro.

## Decisión
- **API**:
  - Cloud Run en `us-east4`, con un proyecto GCP por ambiente (`finkey-stg`, `finkey-prod`) y una billing account con presupuesto de $1;
  - `min-instances=0`, max 1 (stg) / 2 (prod), 1 vCPU / 512 MiB, facturación por request.
- **Base de datos**: Neon en `aws-us-east-1` (Virginia). Queda a ~1–2 ms de `us-east4`, porque cada request hace varias consultas y conviene que la API y la BD estén juntas. Desde Lima, la latencia es de ~100 ms por request.
- **PWA y proxy**: Cloudflare Pages (`finkey`, `finkey-stg`) + Pages Function `/api/*`.
- **Imágenes**: Artifact Registry, conservando las últimas 3.
- **Scheduler**:
  - prod: Cloud Scheduler en zona `America/Lima`, con token OIDC de una cuenta de servicio dedicada;
  - stg: GitHub Actions `schedule`. Su imprecisión es aceptable allí y así no se supera el límite de 3 jobs gratis.

## Consecuencias
- Positivas:
  - $0 con holgura (< 5 % del free tier).
  - Jobs autenticados sin secretos compartidos.
  - Deploy sin llaves JSON.
  - Cambiar de proveedor es barato.
- Negativas:
  - Hay que cuidar 3 proveedores: GCP, Cloudflare y Neon.
  - Cloud Run requiere una billing account con tarjeta (el presupuesto alerta, pero no frena).
  - La latencia desde Lima es de ~100 ms (aceptable según NFR-07).
- Qué haría reconsiderar esta decisión:
  - que el free tier cambie;
  - que se necesite una región en Sudamérica (por latencia o por ley de datos);
  - pasar a un dominio propio (se simplificaría el proxy).
