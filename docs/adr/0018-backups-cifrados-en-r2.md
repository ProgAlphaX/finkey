# ADR-0018: Backups diarios cifrados en Cloudflare R2

- **Estado**: Aceptado
- **Fecha**: 2026-10-27
- **Reversibilidad**: Alta

## Contexto
- NFR-06 exige RPO ≤ 24 h.
- El free tier de Neon solo ofrece un restore window de 6 h (point-in-time) y 10 branches. Un error detectado al día siguiente no se podría recuperar.
- Los datos son financieros y personales, y el repositorio es público.

## Opciones consideradas
1. **`pg_dump` diario desde GitHub Actions, cifrado con `age`, en Cloudflare R2**: 10 GB gratis, sin costo de egreso.
2. **Solo el PITR de Neon**: no cumple el RPO ante errores tardíos.
3. **Plan pago de Neon** (restore de 7 días): rompe el $0.
4. **Guardar el dump como artifact de GitHub**: el repo es público y los artifacts quedan expuestos a quien tenga acceso; tienen retención limitada.

## Decisión
- `backup.yml` diario a las 03:00 Lima:
  - `pg_dump -Fc` de prod (y de stg), comprimido;
  - cifrado con la **clave pública** de `age`;
  - subida a R2 `finkey-backups/{env}/{yyyy}/{mm}/{fecha}.dump.age`.
- Retención: 30 diarios + 12 mensuales (el día 1), con *lifecycle rules* de R2.
- La **clave privada** nunca está en la nube ni en GitHub: va en el gestor de contraseñas del usuario, con una copia offline.
- `restore-test.yml` mensual:
  - restaura el último backup en un Postgres efímero del runner;
  - verifica migraciones, conteos e invariantes del ledger;
  - si falla, avisa.
  - Para descifrar usa una clave privada de *test* distinta, porque se cifra para 2 destinatarios: la clave del usuario y la del test, guardada como secreto de GitHub Environment con aprobación manual.
- Antes de cada release a prod: branch de Neon `pre-vX.Y.Z` (rollback rápido dentro de 6 h).

## Consecuencias
- Positivas:
  - RPO ≤ 24 h a $0, con backups cifrados en reposo e independientes del proveedor de BD.
  - Restauración probada todos los meses.
- Negativas:
  - Si se pierde la clave privada, los backups no se pueden leer: por eso hay una copia offline y una clave de test separada.
  - R2 requiere una tarjeta registrada.
- Qué haría reconsiderar esta decisión: que los datos superen el free tier de R2 (lejano) o que se pase a un plan pago de Neon con PITR largo.
