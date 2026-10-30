# Catálogo de reglas de negocio — FinKey

Tipos: **Inv** = invariante · **Res** = restricción · **Cal** = cálculo · **Pol** = política/temporal · **Aut** = autorización.
Cada regla tendrá al menos un test nombrado con su ID (ej. `BR030_SharedExpense_DefaultsTo5050`).

## Hogar y privacidad
| ID | Regla | Tipo | Ejemplo |
|---|---|---|---|
| BR-001 | Todo usuario pertenece como máximo a un hogar en el MVP (el modelo admite varios a futuro) | Res | — |
| BR-002 | Un hogar tiene 2 miembros en el MVP; ambos tienen los mismos permisos sobre lo compartido | Res | — |
| BR-003 | Las cuentas son **privadas por defecto**; solo el dueño las ve. Una cuenta marcada "compartida" es visible y operable por todos los miembros del hogar | Aut | Mi cuenta BCP privada no aparece en el dashboard de mi pareja |
| BR-004 | Toda consulta o comando valida que el usuario sea dueño del recurso o miembro del hogar si es compartido | Aut | Pedir `/accounts/{id}` ajeno → 404 |

## Cuentas
| ID | Regla | Tipo | Ejemplo |
|---|---|---|---|
| BR-010 | Cada cuenta tiene una única moneda (PEN o USD), que no se cambia después de tener movimientos | Inv | — |
| BR-011 | Saldo de cuenta = saldo inicial + ingresos − gastos ± transferencias ± transacciones entre pareja ± ajustes | Cal | — |
| BR-012 | Una cuenta archivada no admite movimientos nuevos y conserva su historial; solo se archiva con saldo 0 | Res | — |
| BR-013 | Una tarjeta de crédito es una cuenta de **pasivo**: los gastos aumentan su deuda; el saldo disponible = línea − deuda | Cal | Línea S/ 5,000, deuda S/ 1,200 → disponible S/ 3,800 |
| BR-014 | En el día de corte se genera automáticamente un pago planificado por la deuda facturada, con vencimiento en el día de pago | Pol | Corte 15, pago 5 → el 15/10 se planifica el pago del 05/11 |
| BR-015 | Pagar la tarjeta desde otra cuenta propia es una **transferencia** (no un gasto), para no duplicar el gasto | Inv | — |
| BR-016 | Se permite exceder la línea con una advertencia (refleja la realidad), no se bloquea | Pol | — |

## Movimientos
| ID | Regla | Tipo | Ejemplo |
|---|---|---|---|
| BR-020 | Los montos se guardan siempre **positivos**; la dirección la da el tipo (ingreso/gasto) | Inv | Gasto de S/ 50 → monto 50, tipo gasto |
| BR-021 | Monto > 0, con 2 decimales, en la moneda de la cuenta | Res | — |
| BR-022 | Categorías predefinidas + personalizadas por usuario/hogar; una categoría usada no se borra, se archiva | Res | — |
| BR-025 | Las transacciones de saldo inicial (`Opening`) no cuentan como ingreso ni gasto en los indicadores | Cal | — |
| BR-023 | La fecha del movimiento es una fecha de calendario en America/Lima; no se permite registrar en un período cerrado (el período aplicable es el del dueño de la cuenta: usuario o hogar, BR-090) | Res | — |

## Gastos compartidos
| ID | Regla | Tipo | Ejemplo |
|---|---|---|---|
| BR-030 | Un gasto compartido se reparte **50/50 por defecto**; se puede editar por porcentaje o monto | Pol | — |
| BR-031 | La suma de las partes es exactamente el total; la diferencia de redondeo (céntimo) va a quien pagó | Inv | S/ 10.01 → 5.01 (pagador) + 5.00 |
| BR-032 | La cuenta de quien paga se reduce por el total; en los reportes de cada uno solo cuenta **su parte** como gasto | Cal | Pago S/ 100 compartido → mi gasto 50, el de mi pareja 50 |
| BR-033 | La parte del otro genera saldo entre pareja a favor de quien pagó | Cal | Mi pareja me debe S/ 50 |

## Pareja (tipo Splitwise)
| ID | Regla | Tipo | Ejemplo |
|---|---|---|---|
| BR-050 | Préstamo entre pareja: sale de una cuenta del prestamista y entra en una del prestatario; genera saldo entre pareja; no es ingreso ni gasto | Inv | — |
| BR-051 | Saldo entre pareja = Σ partes de gastos compartidos pagados por el otro + préstamos − reembolsos/liquidaciones, por moneda | Cal | — |
| BR-052 | Liquidar mueve dinero real entre cuentas de ambos y reduce el saldo; no puede exceder el saldo pendiente | Res | — |
| BR-099 | Las cuentas virtuales de pareja (Por cobrar / Por pagar) se crean automáticamente al unirse al hogar, una por miembro y por moneda usada | Pol | — |
| BR-053 | El saldo entre pareja se lleva **por moneda** (PEN y USD por separado); se muestra un total convertido como referencia | Cal | — |

## Transferencias
| ID | Regla | Tipo | Ejemplo |
|---|---|---|---|
| BR-040 | Transferencia entre cuentas propias: origen ≠ destino; no cambia el patrimonio | Inv | — |
| BR-041 | Si las monedas difieren, se registran ambos montos y el tipo de cambio implícito (monto destino / monto origen) | Cal | US$ 100 → S/ 372.50 (TC 3.725) |
| BR-042 | La comisión de una transferencia se registra como gasto separado en la cuenta origen | Cal | — |

## Deudas
| ID | Regla | Tipo | Ejemplo |
|---|---|---|---|
| BR-060 | Una deuda tiene acreedor, moneda, monto original y, opcionalmente, cuotas con vencimientos (cada cuota → pago planificado) | Res | Préstamo de 12 cuotas |
| BR-061 | Saldo pendiente = monto original − Σ pagos aplicados al capital; nunca negativo | Inv | — |
| BR-062 | Una deuda con saldo 0 pasa a "Saldada" y no admite más pagos | Pol | — |
| BR-063 | Los intereses o cargos de un pago se registran como gasto, no como reducción de la deuda | Cal | — |

## Planificación y alertas
| ID | Regla | Tipo | Ejemplo |
|---|---|---|---|
| BR-080 | Un pago planificado es único o recurrente (mensual, cada N meses, anual) | Res | — |
| BR-081 | Si el día de recurrencia no existe en el mes, se usa el último día del mes | Pol | Día 31 → 30/04, 28/02 o 29/02 |
| BR-082 | Alertas por defecto: 3 días antes, el mismo día y el día siguiente si sigue pendiente (vencido); configurable por pago | Pol | — |
| BR-083 | Las alertas se envían a las 08:00 America/Lima a todos los dispositivos suscritos del dueño (o de ambos si es compartido) | Pol | — |
| BR-084 | Marcar como pagado genera el movimiento/pago real (monto real editable) y detiene las alertas de esa ocurrencia | Cal | — |
| BR-085 | Una alerta no se envía dos veces para la misma ocurrencia y el mismo aviso (idempotencia) | Inv | — |
| BR-078 | La alerta push es personalizada, al estilo de los bancos: nombre del usuario, concepto, monto con su moneda y cuenta o tarjeta de cargo, con un texto según el aviso (3 días antes, hoy o vencido). Al tocarla se abre el detalle de la ocurrencia con la acción "Registrar pago" (BR-084) | Pol | "Ana, hoy vence tu pago de Netflix por S/ 44.90 · Tarjeta BBVA" |
| BR-079 | Cada usuario puede activar "Ocultar montos en notificaciones" (por defecto, desactivado): el push dice solo el concepto, sin monto | Pol | "Ana, hoy vence tu pago de Netflix" |

## Período financiero y cierre
El "mes" de FinKey es un **período financiero** que empieza el día de pago, no el día 1.

| ID | Regla | Tipo | Ejemplo |
|---|---|---|---|
| BR-086 | Cada usuario y cada hogar tienen una **regla de período**: mes calendario, día fijo N, o último día hábil del mes | Res | Mi regla: último día hábil; la del hogar: la que elija el hogar |
| BR-087 | El período **empieza el día de pago** y termina el día anterior al siguiente día de pago | Cal | Pago vie 30/10/2026 → período 30/10 – 29/11 (si el siguiente pago es el lun 30/11) |
| BR-088 | Día hábil = lunes a viernes, excluyendo los feriados nacionales de Perú; si el día calculado no es hábil, se toma el hábil anterior. La lista de feriados se mantiene por año | Cal | Día fijo 15 que cae sábado → viernes 14 |
| BR-089 | El período se nombra por el mes en que termina | Cal | 30/10 – 29/11 → "Noviembre 2026" |
| BR-090 | Solo los períodos abiertos admiten crear, editar o borrar movimientos; un período cerrado es inmutable. Las cuentas privadas siguen el período del usuario y las compartidas el del hogar | Res | — |
| BR-091 | **Cierre automático 3 días después** del fin del período (gracia para registros olvidados); se puede cerrar antes a mano. Push de aviso el día anterior al cierre | Pol | Fin 29/11 → cierre automático 02/12 |
| BR-092 | Durante la gracia conviven 2 períodos abiertos: el anterior (para fechas pasadas) y el nuevo | Pol | — |
| BR-093 | Al cerrar se guarda un snapshot: saldos por cuenta, tipo de cambio de cierre, patrimonio e indicadores | Cal | — |
| BR-094 | Las correcciones de períodos cerrados se hacen con un **ajuste** en un período abierto, con referencia al período corregido | Pol | — |
| BR-095 | Los períodos se cierran en orden; no se cierra uno si el anterior sigue abierto | Res | — |
| BR-096 | Cambiar la regla de período solo afecta a los períodos futuros, nunca a los cerrados | Res | — |
| BR-097 | Todo cambio queda auditado (quién, cuándo, valor anterior/nuevo) | Inv | — |
| BR-098 | Una transacción que afecta cuentas de distintos dueños solo se permite si la fecha está en un período abierto para **todos** los dueños afectados | Res | Gasto compartido con fecha en un período que mi pareja ya cerró → rechazado |

## Ahorros
| ID | Regla | Tipo | Ejemplo |
|---|---|---|---|
| BR-100 | Una meta tiene monto objetivo > 0, fecha objetivo opcional y **una cuenta vinculada**; la moneda de la meta es la de la cuenta | Res | Meta "Viaje" → cuenta de ahorro USD |
| BR-101 | Progreso = saldo de la cuenta vinculada / objetivo (puede superar 100%) | Cal | — |
| BR-102 | Una cuenta tiene como máximo una meta activa; una meta compartida exige una cuenta compartida | Res | — |

## Patrimonio e indicadores
| ID | Regla | Tipo | Ejemplo |
|---|---|---|---|
| BR-110 | Patrimonio = activos (cuentas con saldo) − pasivos (tarjetas + deudas pendientes), convertido a PEN | Cal | — |
| BR-111 | Patrimonio individual = cuentas y deudas privadas del usuario ± su saldo neto con la pareja | Cal | — |
| BR-112 | Patrimonio conjunto = solo cuentas y deudas **compartidas** del hogar (no revela lo privado) | Cal / Aut | — |
| BR-115 | **Total del hogar** (privado A + privado B + compartido): es una opción del hogar que se activa en la configuración y requiere que **ambos** miembros la acepten. Muestra solo totales, nunca el detalle privado | Cal / Aut | — |
| BR-113 | Período actual: se convierte con el tipo de cambio del día; períodos cerrados: con el del snapshot | Cal | — |
| BR-114 | Los indicadores de un usuario cuentan solo su parte de los gastos compartidos (BR-032) | Cal | — |

## Tipo de cambio
| ID | Regla | Tipo | Ejemplo |
|---|---|---|---|
| BR-120 | Un job diario obtiene el tipo de cambio USD→PEN **de compra** de una fuente oficial gratuita (BCRP / SBS) y guarda el histórico | Pol | — |
| BR-121 | Un override manual prevalece sobre el automático para esa fecha (ej. el tipo real de tu banco o casa de cambio) | Pol | — |
| BR-122 | Si la fuente falla o es un día no hábil, se usa el último tipo disponible | Pol | Fin de semana → TC del viernes |
| BR-123 | El tipo de cambio **solo sirve para valorizar** (patrimonio e indicadores en PEN). Los movimientos guardan siempre el **monto real** en la moneda de su cuenta | Inv | Pago de US$ 20 desde la cuenta de ahorro USD → se registra US$ 20, sin conversión |
| BR-124 | Si un gasto en USD se cobra en una cuenta o tarjeta en PEN, se registra el monto en PEN que cobró el banco (opcionalmente con el monto USD original como referencia) | Inv | Suscripción US$ 20 cobrada S/ 76.10 → gasto S/ 76.10 |

## Seguridad
| ID | Regla | Tipo | Ejemplo |
|---|---|---|---|
| BR-071 | 5 intentos fallidos de login → bloqueo de 15 minutos | Pol | — |

---

## Decisiones resueltas (2026-10-25)
- [x] **Metas de ahorro** → vinculadas a una cuenta (BR-100 a BR-102).
- [x] **Cierre** → período financiero desde el día de pago, con regla propia por usuario y por hogar, feriados de Perú y cierre automático con 3 días de gracia (BR-086 a BR-097).
- [x] **Total del hogar** → opción del hogar que activan ambos (BR-115).
- [x] **Tipo de cambio** → compra, de fuente oficial (BCRP/SBS), con override manual; solo para valorizar (BR-120 a BR-124). La fuente concreta de la API se valida en la Fase 4.

## Casos borde cubiertos
- [x] Montos 0 / negativos → BR-020, BR-021
- [x] Monedas distintas → BR-041, BR-053, BR-113
- [x] Fechas inexistentes en recurrencias → BR-081
- [x] Edición de históricos → BR-090, BR-092
- [x] Redondeo en repartos → BR-031
- [x] Zona horaria → BR-023, BR-083
- [ ] Modificación concurrente → concurrencia optimista (se define en la Fase 2)
