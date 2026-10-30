# ADR-0009: Ambientes dev/qa/stg/prod con bases de datos aisladas

- **Estado**: Aceptado
- **Fecha**: 2026-10-26
- **Reversibilidad**: Alta

## Contexto
Se necesitan cuatro ambientes:
- **dev/qa**, para desarrollar y correr los tests unitarios, de integración y E2E (Playwright);
- **stg**, para que ambos usuarios prueben cada versión;
- **prod**, para el uso diario.

Cada paso a prod es una versión SemVer. Restricción: costo $0. Además, los esquemas de BD ya se usan para separar módulos (ADR-0001).

## Opciones consideradas
1. **Una BD con un esquema por ambiente**: choca con los esquemas por módulo (`dev_ledger`, `prod_ledger`…), comparte credenciales y conexión, y un error en dev podría tocar prod. Las migraciones no se pueden probar de forma aislada.
2. **Varias BDs en una misma instancia o proyecto**: es más limpia, pero en Neon el cómputo y el almacenamiento gratuitos son **por proyecto**. Staging consumiría la cuota de prod, y al pasar el límite se suspende todo el proyecto, prod incluida.
3. **Ambientes aislados**:
   - dev local con Docker;
   - qa efímero en CI (Testcontainers);
   - stg y prod en **proyectos Neon separados**.

## Decisión
**Opción 3.**
- Ningún ambiente comparte BD, credenciales ni secretos.
- stg arranca **vacío**: sus datos son solo los que ambos usuarios ingresan a mano durante las pruebas. No hay datos sembrados (seed) ni copias de prod. Solo se cargan los datos de referencia del sistema (categorías por defecto, feriados, tipo de cambio).
- La imagen Docker se construye una vez y se promueve de stg a prod.
- Versionado SemVer con Conventional Commits: `vX.Y.Z-rc.N` en stg y `vX.Y.Z` en prod, con aprobación manual.

## Consecuencias
- Positivas:
  - El costo se mantiene en $0: Docker local y GitHub Actions son gratis, y cada proyecto Neon tiene su propio free tier.
  - El aislamiento es total y los tests son reproducibles.
  - Las migraciones se prueban desde cero en cada PR.
  - Un límite o caída en stg no afecta a prod.
- Negativas: hay que mantener dos proyectos en la nube y sus secretos, y las pruebas en stg requieren ingresar los datos a mano (es intencional: simula el uso real).
- Riesgo: los límites del free tier de Neon cambian (su documentación oficial muestra cifras distintas). Mitigación: monitorear el uso y mantener todo en Docker para poder migrar de proveedor.
- Qué haría reconsiderar esta decisión: si Neon elimina o reduce su free tier → migrar a otro Postgres gestionado; el código no cambia.
