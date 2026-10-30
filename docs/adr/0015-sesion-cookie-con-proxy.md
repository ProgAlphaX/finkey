# ADR-0015: Sesión con cookie same-origin mediante proxy `/api`

- **Estado**: Aceptado
- **Fecha**: 2026-10-27
- **Reversibilidad**: Media

## Contexto
- La seguridad es prioridad (NFR-01) y una usuaria usa la PWA en iPhone (Safari/WebKit).
- Con $0 no hay dominio propio: la PWA vive en un subdominio gratuito (ej. `*.pages.dev`) y la API en otro (ej. `*.run.app` / `*.azurecontainerapps.io`). Ambos están en la Public Suffix List, así que son **sitios distintos**.
- Safari (ITP) bloquea las cookies de terceros, por lo que una cookie emitida por la API no llegaría desde la PWA.

## Opciones consideradas
1. **Cookie httpOnly same-origin + proxy `/api`** en el hosting del frontend (Cloudflare Pages Function o Worker; free tier de 100k req/día).
2. **Tokens bearer** (access token en memoria + refresh token rotativo): no necesita proxy, pero el refresh token es accesible desde JavaScript y la superficie ante XSS es mayor.
3. **Dominio propio** (`app.` y `api.` del mismo dominio, same-site): no necesita proxy, pero cuesta ~US$10/año y rompe el $0.

## Decisión
**Opción 1.**
- La PWA llama solo a `/api/*` en su propio origen; una Pages Function de Cloudflare reenvía la petición a la API y le agrega `X-Proxy-Secret` y la IP real del cliente.
- Cookie `__Host-finkey.session`: `HttpOnly; Secure; SameSite=Strict; Path=/`. Expiración deslizante de 14 días, con máximo de 30.
- CSRF: token antiforgery en el header `X-XSRF-TOKEN` para toda mutación, más `SameSite=Strict`.
- La API rechaza las peticiones sin `X-Proxy-Secret` válido (salvo `/health/*` y `/jobs/*`); sin CORS.
- Las llaves de Data Protection se persisten en Postgres para sobrevivir a *scale-to-zero*.

## Consecuencias
- Positivas:
  - Ningún token es accesible desde JavaScript.
  - Funciona en Safari/iOS.
  - Sin CORS.
  - Cloudflare queda delante de la API (TLS, protección básica DDoS).
- Negativas:
  - Un salto extra (Cloudflare → API, unos 10–50 ms).
  - El proxy es una pieza más que desplegar y probar.
  - El free tier del Worker es un límite (holgado: ~500 req/día hoy).
- Qué haría reconsiderar esta decisión:
  - Comprar un dominio propio: se pasa a `api.` same-site y se puede quitar el proxy.
  - Una app nativa: tokens.
