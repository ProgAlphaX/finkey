# Requisitos — FinKey

Reglas de negocio referenciadas (BR-xxx): ver `01-business-rules.md`.
Prioridad MoSCoW: **Must** (MVP) · **Should** (MVP si da el tiempo) · **Could** (después) · **Won't** (no por ahora).

## Épicas
| ID | Épica | Descripción | Prioridad |
|---|---|---|---|
| E1 | Identidad y hogar | Registro, login, hogar compartido, invitación a la pareja, preferencias | Must |
| E2 | Cuentas | Multicuentas PEN/USD: efectivo, débito/ahorro, billetera, tarjeta de crédito; privadas o compartidas | Must |
| E3 | Movimientos | Ingresos y gastos con categoría; gastos compartidos con reparto | Must |
| E4 | Transferencias | Entre cuentas propias (misma u otra entidad, misma u otra moneda) | Must |
| E5 | Pareja | Préstamos, reembolsos y saldo automático entre nosotros | Must |
| E6 | Deudas y tarjetas | Deudas con terceros (cuotas/pagos) y ciclo de tarjeta de crédito | Must |
| E7 | Planificación y alertas | Pagos planificados (únicos/recurrentes) y push notifications | Must |
| E8 | Ahorros | Metas de ahorro con progreso | Must |
| E9 | Indicadores y patrimonio | Dashboard mensual, patrimonio individual/conjunto, evolución mes a mes | Must |
| E10 | Período financiero y cierre | Períodos desde el día de pago, cierre automático, snapshot, ajustes | Must |
| E11 | Tipo de cambio | Tipo de cambio diario automático con corrección manual | Must |

---

## Historias de usuario

### E1 — Identidad y hogar
**HU-101** Como usuario quiero registrarme e iniciar sesión de forma segura para acceder a mis finanzas. — *Must*
- Dado un usuario registrado, cuando inicia sesión con credenciales válidas, entonces accede a su dashboard.
- Dado 5 intentos fallidos seguidos, entonces la cuenta se bloquea temporalmente (BR-071).

**HU-102** Como usuario quiero crear un hogar e invitar a mi pareja para compartir finanzas. — *Must*
- Dado que creo un hogar, cuando invito por email/enlace, entonces mi pareja se une al aceptar la invitación (BR-001, BR-002).

**HU-103** Como usuario quiero configurar mi moneda base (PEN) y mi zona horaria (America/Lima). — *Must*

**HU-104** Como usuario quiero activar las notificaciones push en cada dispositivo donde instalé la PWA. — *Must*

### E2 — Cuentas
**HU-201** Como usuario quiero crear cuentas con tipo, entidad, moneda y saldo inicial. — *Must*
- Tipos: efectivo, débito/ahorro, billetera digital, tarjeta de crédito (BR-010, BR-011).

**HU-202** Como usuario quiero marcar una cuenta como compartida con el hogar o mantenerla privada. — *Must* (BR-003)

**HU-203** Como usuario quiero archivar una cuenta que ya no uso sin perder su historial. — *Must* (BR-012)

**HU-204** Como usuario quiero ver el saldo actual de cada cuenta y el total por moneda. — *Must*

### E3 — Movimientos
**HU-301** Como usuario quiero registrar un gasto en menos de 10 s desde el celular. — *Must*
- Campos mínimos: monto, cuenta, categoría; fecha = hoy por defecto (BR-020, BR-021).

**HU-302** Como usuario quiero registrar un ingreso. — *Must*

**HU-303** Como usuario quiero marcar un gasto como compartido y repartirlo (50/50 por defecto, editable). — *Must* (BR-030, BR-031)

**HU-304** Como usuario quiero usar categorías predefinidas y crear las mías. — *Must* (BR-022)

**HU-305** Como usuario quiero filtrar movimientos por mes, cuenta, categoría y tipo. — *Must*

**HU-306** Como usuario quiero editar o eliminar un movimiento del mes abierto. — *Must* (BR-090)

### E4 — Transferencias
**HU-401** Como usuario quiero registrar una transferencia entre mis cuentas, de la misma o de otra entidad. — *Must* (BR-040)

**HU-402** Como usuario quiero transferir entre cuentas de distinta moneda indicando ambos montos. — *Must* (BR-041)

**HU-403** Como usuario quiero registrar la comisión de una transferencia. — *Should* (BR-042)

### E5 — Pareja
**HU-501** Como usuario quiero registrar un préstamo a mi pareja o de mi pareja. — *Must* (BR-050)

**HU-502** Como usuario quiero ver el saldo neto entre nosotros ("quién le debe a quién"). — *Must* (BR-051)

**HU-503** Como usuario quiero saldar total o parcialmente el saldo con una transacción. — *Must* (BR-052)

**HU-504** Como usuario quiero ver el detalle de qué compone el saldo entre nosotros. — *Should*

### E6 — Deudas y tarjetas
**HU-601** Como usuario quiero registrar una deuda con un tercero (monto, acreedor, cuotas opcionales, vencimientos). — *Must* (BR-060)

**HU-602** Como usuario quiero registrar pagos de una deuda y ver el saldo pendiente. — *Must* (BR-061, BR-062)

**HU-603** Como usuario quiero configurar mi tarjeta de crédito con línea, día de corte y día de pago. — *Must* (BR-013)

**HU-604** Como usuario quiero que, con el corte, se genere el pago planificado del estado de cuenta. — *Must* (BR-014)

**HU-605** Como usuario quiero pagar la tarjeta desde otra cuenta sin que cuente como gasto doble. — *Must* (BR-015)

### E7 — Planificación y alertas
**HU-701** Como usuario quiero planificar un pago (único o recurrente) con fecha, monto estimado y cuenta. — *Must* (BR-080, BR-081)

**HU-702** Como usuario quiero recibir push 3 días antes, el mismo día y si el pago quedó vencido, con días configurables por pago. — *Must* (BR-082, BR-083)

**HU-703** Como usuario quiero marcar un pago planificado como pagado y que se genere el movimiento real. — *Must* (BR-084)

**HU-704** Como usuario quiero ver un calendario o lista de pagos pendientes del mes. — *Must*

**HU-705** Como usuario quiero planificar pagos compartidos del hogar que nos alerten a ambos. — *Should*

### E8 — Ahorros
**HU-801** Como usuario quiero crear una meta de ahorro vinculada a una cuenta, con monto objetivo y fecha opcional. — *Must* (BR-100, BR-102)

**HU-802** Como usuario quiero ver el progreso de cada meta. — *Must* (BR-101)

**HU-803** Como hogar queremos metas de ahorro compartidas. — *Should*

### E9 — Indicadores y patrimonio
**HU-901** Como usuario quiero un dashboard del mes con ingresos, gastos, neto y gastos por categoría. — *Must*

**HU-902** Como usuario quiero ver mi patrimonio individual (activos − pasivos) en PEN. — *Must* (BR-110, BR-111)

**HU-903** Como hogar queremos ver el patrimonio conjunto. — *Must* (BR-112)

**HU-904** Como usuario quiero ver la evolución período a período con gráficos (ingresos, gastos, ahorro, patrimonio). — *Must* (BR-113)

**HU-905** Como usuario quiero comparar el período actual con el anterior. — *Should*

**HU-906** Como hogar queremos activar (ambos) la vista "total del hogar". — *Should* (BR-115)

### E10 — Período financiero y cierre
**HU-1001** Como usuario quiero configurar mi regla de período (mes calendario, día fijo o último día hábil) para que mi "mes" empiece el día que cobro. — *Must* (BR-086 a BR-089)

**HU-1002** Como hogar queremos definir la regla de período de lo compartido. — *Must* (BR-086, BR-090)

**HU-1003** Como usuario quiero que el período se cierre solo 3 días después de terminar, con aviso previo, o cerrarlo antes a mano. — *Must* (BR-091 a BR-093, BR-095)

**HU-1004** Como usuario quiero corregir un período cerrado mediante un ajuste en un período abierto. — *Must* (BR-094)

### E11 — Tipo de cambio
**HU-1101** Como usuario quiero que el tipo de cambio USD→PEN (compra) se actualice solo cada día. — *Must* (BR-120, BR-123)

**HU-1102** Como usuario quiero corregir manualmente el tipo de cambio de un día. — *Should* (BR-121)

### Could / Won't
- *Could*: exportar a CSV, modo oscuro, presupuestos por categoría, adjuntar comprobantes, búsqueda de texto.
- *Won't*: conexión bancaria (nunca), importar extractos o Excel, inversiones, app nativa.

---

## Requisitos no funcionales
★ = las 3 prioridades que mandan sobre la arquitectura. El costo $0 es una **restricción** dura.

| ID | Atributo | Escenario medible | Prioridad |
|---|---|---|---|
| NFR-01 | Seguridad y privacidad ★ | Un usuario nunca puede leer ni modificar cuentas privadas del otro; verificado por tests de autorización en cada endpoint. HTTPS, tokens de vida corta, MFA opcional | Alta |
| NFR-02 | Usabilidad móvil ★ | Registrar un gasto en ≤ 3 toques + monto (< 10 s). PWA instalable en Android e iOS. Lighthouse PWA/Accesibilidad ≥ 90 | Alta |
| NFR-03 | Mantenibilidad ★ | Módulos con fronteras verificadas por tests de arquitectura; agregar un módulo no modifica otros; cobertura ≥ 80% en dominio | Alta |
| NFR-04 | Costo | $0/mes; alerta de presupuesto en $1 | Restricción |
| NFR-05 | Confiabilidad de alertas | Cada alerta se envía dentro de los 15 min siguientes a la hora programada (08:00 America/Lima) | Alta |
| NFR-06 | Integridad de datos | Ninguna operación deja saldos inconsistentes (transacciones ACID); RPO ≤ 24 h con backups diarios | Alta |
| NFR-07 | Rendimiento | p95 < 500 ms con la API ya encendida; cold start ≤ 5 s aceptable | Media |
| NFR-08 | Disponibilidad | 99% mensual; se aceptan la ventana de apagado y los cold starts | Media |
| NFR-09 | Observabilidad | Logs estructurados, trazas y alertas ante errores 5xx y jobs fallidos | Media |
| NFR-10 | Localización | UI en español (es-PE), formatos de moneda S/ y US$, fechas dd/MM/yyyy | Media |

---

## Glosario
| Término | Definición | No confundir con |
|---|---|---|
| Usuario | Persona con login en FinKey | Cuenta |
| Hogar | Grupo de usuarios que comparten finanzas (MVP: la pareja) | — |
| Cuenta | Lugar donde hay dinero o deuda: efectivo, banco, billetera, tarjeta | Usuario |
| Entidad | Banco o emisor de una cuenta (BCP, Interbank, Yape…) | Cuenta |
| Movimiento | Ingreso o gasto que cambia el patrimonio | Transferencia |
| Transferencia | Traslado entre cuentas propias; no cambia el patrimonio (salvo comisión) | Movimiento |
| Transacción entre pareja | Préstamo, reembolso o liquidación entre miembros del hogar | Transferencia |
| Gasto compartido | Gasto que se reparte entre los miembros del hogar | Cuenta compartida |
| Saldo entre pareja | Monto neto que un miembro le debe al otro | Deuda con terceros |
| Deuda | Obligación con un tercero (banco, persona), con saldo pendiente | Saldo entre pareja |
| Pago planificado | Pago futuro programado (único o recurrente) que genera alertas | Movimiento |
| Meta de ahorro | Objetivo de monto (y fecha opcional) | Cuenta de ahorro |
| Patrimonio | Activos − pasivos, convertido a la moneda base | Saldo |
| Período financiero | "Mes" de FinKey: desde el día de pago hasta el día anterior al siguiente pago | Mes calendario |
| Regla de período | Cómo se calcula el día de pago: mes calendario, día fijo o último día hábil | — |
| Cierre | Acción (automática o manual) que congela un período y guarda su snapshot | — |
| Moneda base | Moneda de referencia de los reportes (PEN) | Moneda de la cuenta |
