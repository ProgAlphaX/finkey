# ADR-0021: Ramas por ambiente (dev → qa → stg → main)

- **Estado**: Aceptado
- **Fecha**: 2026-11-09
- **Reversibilidad**: Alta
- **Reemplaza en parte**: ADR-0019 (cuándo se despliega a stg) y la línea "trunk-based" de `06-devops.md`

## Contexto
La planificación inicial era trunk-based: todo se mergeaba a `main`, que desplegaba a stg. Se quiere que cada rama refleje de verdad su ambiente: lo que está en `qa` ya pasó las pruebas, lo que está en `stg` ya pasó qa, y `main` es producción. Así un cambio recién integrado no aparece en un ambiente superior hasta haber sido probado.

## Opciones consideradas
1. **Trunk-based** (`main` + tags): simple, pero un cambio llega a stg sin una barrera visible entre integración y pruebas.
2. **Ramas por ambiente con promoción por PR**: el rebase-merge reescribe los SHA y las ramas divergen; cada promoción arrastra commits ya aplicados.
3. **Ramas por ambiente con promoción por fast-forward**: los SHA son los mismos en todas las ramas y el historial sigue lineal.

## Decisión
**Opción 3.**

```
FK-n ──PR──► dev ──(CI verde)──► qa ──(suite completa verde)──► stg ──(aprobación de los 2)──► main
```

| Rama | Ambiente | Qué entra | Qué corre | Despliegue |
|---|---|---|---|---|
| `FK-n` | — | Trabajo de una historia | CI rápido en el PR | — |
| `dev` | Integración | PR de `FK-n` (rebase-merge) | Build, unitarios, arquitectura, lint, commitlint, gitleaks | Ninguno (dev local sigue siendo Docker) |
| `qa` | qa | Fast-forward desde `dev` cuando su CI está verde | Integración (Testcontainers), E2E, Lighthouse, CodeQL, Trivy | Ninguno (efímero) |
| `stg` | stg | Fast-forward desde `qa` cuando su suite está verde | Smoke tras el deploy | Automático a stg (`vX.Y.Z-rc.N`) |
| `main` | prod | PR `stg` → `main` tras la aprobación de los 2 usuarios | release-please (Release PR) | Al mergear el Release PR: tag `vX.Y.Z` → prod |

- Las promociones `dev → qa → stg` las hace el job `promote` de `ci.yml` con un push sin force (solo fast-forward) usando `GITHUB_TOKEN`. Por eso `qa` y `stg` no exigen PR: están protegidas contra force-push y borrado, con historial lineal, y por convención nadie hace push directo. Endurecer con un ruleset es una mejora posible.
- `dev` es la rama por defecto del repositorio, para que PRs, Dependabot y los workflows partan de ella.
- `main` conserva el flujo de ADR-0019: release-please, tag `v*` y GitHub Environment `production`.
- El commit de release que release-please crea en `main` se sincroniza de vuelta a `dev` con un PR automático `main → dev`.
- Dependabot apunta a `dev`.

## Consecuencias
- Positivas:
  - Cada rama indica el nivel de confianza del código que contiene.
  - Los SHA son idénticos en todas las ramas, así que el historial sigue lineal.
  - Un cambio roto se detiene en `dev` o `qa` y no llega a stg.
- Negativas:
  - Más ramas y un workflow de promoción que mantener.
  - Una corrección urgente en prod (hotfix) entra por `dev` y recorre todo el camino; si es crítica, se permite un PR directo a `main` con sincronización posterior hacia atrás.
  - Con 2 usuarios, la latencia de llegar a stg es mayor que en trunk-based.
- Qué haría reconsiderar esta decisión: si la promoción se vuelve un obstáculo para el ritmo de entrega, volver a trunk-based con feature flags.
