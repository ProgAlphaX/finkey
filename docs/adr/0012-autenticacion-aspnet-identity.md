# ADR-0012: Autenticación con ASP.NET Core Identity (passkeys + contraseña)

- **Estado**: Aceptado
- **Fecha**: 2026-10-26
- **Reversibilidad**: Baja ⚠️

## Contexto
La seguridad es prioridad (NFR-01). El MVP tiene 2 usuarios con un diseño abierto a más hogares. La restricción es $0, sin depender de terceros con límites cambiantes. El uso es principalmente móvil, con una usuaria en iPhone.

## Opciones consideradas
1. **ASP.NET Core Identity** (.NET 10): integrado; soporta passkeys; los usuarios viven en el Postgres propio; $0 sin límites.
2. **Proveedor gestionado** (Auth0 / Clerk): muy seguro y con MFA listo, pero genera dependencia externa y límites del free tier.
3. **Keycloak self-hosted**: estándar OIDC, pero hay que operarlo y su memoria no encaja con *scale-to-zero*.

## Decisión
**ASP.NET Core Identity** dentro del módulo Identity:
- Login con **passkeys** (Face ID / huella) como método principal.
- La contraseña es la alternativa y **siempre exige TOTP** (app autenticadora); hay 10 códigos de recuperación (decisión de la Fase 6).
- Bloqueo tras 5 intentos fallidos (BR-071).
- Sesión: **cookie httpOnly `__Host-`, SameSite=Strict**, same-origin mediante un proxy `/api` en Cloudflare (ver [ADR-0015](0015-sesion-cookie-con-proxy.md)).

## Consecuencias
- Positivas: $0; control total; experiencia móvil excelente con passkeys; se aprende la autenticación por dentro.
- Negativas: la configuración segura (cookies, CSRF, rate limiting, recuperación de cuenta) es responsabilidad propia; se cubre con el checklist de la Fase 6.
- Qué haría reconsiderar esta decisión: abrir la app al público con login social o MFA corporativo → evaluar migrar a un IdP OIDC.
