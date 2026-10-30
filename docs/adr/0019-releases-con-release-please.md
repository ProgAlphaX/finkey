# ADR-0019: Versionado y releases con release-please

- **Estado**: Aceptado
- **Fecha**: 2026-10-27
- **Reversibilidad**: Alta

## Contexto
ADR-0009 define SemVer a partir de Conventional Commits: `vX.Y.Z-rc.N` en stg y `vX.Y.Z` en prod con aprobación manual. Se necesita automatizar el cálculo de la versión, el changelog y el tag.

## Opciones consideradas
1. **release-please** (Google):
   - mantiene un *Release PR* con la versión siguiente y el changelog;
   - al mergearlo, crea el tag y el GitHub Release;
   - no publica nada por sí mismo.
2. **semantic-release**: publica automáticamente en cada merge y soporta canales de prerelease, pero no tiene un punto natural de aprobación humana.
3. **Manual**: propenso a errores y sin changelog consistente.

## Decisión
**release-please** (manifest mode, versión única para el monorepo):
- Cada merge a `main` despliega en stg y actualiza el Release PR.
- La versión de stg es `{versión del Release PR}-rc.{n}`.
- **Mergear el Release PR es la aprobación para prod**: crea el tag `vX.Y.Z`, que dispara `deploy-prod.yml` en el GitHub Environment `production` (solo tags `v*`).
- Mientras la versión sea `0.x`, `feat` sube la MINOR. La `v1.0.0` se publica al completar el MVP.

## Consecuencias
- Positivas:
  - La aprobación es explícita y visible (un PR).
  - Changelog automático, enlazado a las historias de Jira por la clave `FK-xx`.
  - Se promueve la misma imagen de stg a prod.
- Negativas:
  - El sufijo `-rc.N` se calcula con un script propio, porque release-please no lo genera.
- Qué haría reconsiderar esta decisión: necesitar versiones independientes por componente (frontend y backend). release-please lo soporta cambiando a multi-paquete.
