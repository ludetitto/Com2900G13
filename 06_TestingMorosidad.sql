/* =========================================================================
   Trabajo Práctico Integrador - Bases de Datos Aplicadas
   Grupo N°: 13
   Comisión: 2900
   Fecha de Entrega: 17/06/2025
   Materia: Bases de Datos Aplicadas
   Alumnos: Vignardel Francisco				45778667
            De Titto Lucia					46501934
			Borja Tomas						42353302
			Rodriguez Sebastián Ezequiel	41691928
   
   Consigna: Todos los SP creados deben estar acompañados de juegos de prueba. Se espera que
realicen validaciones básicas en los SP (p/e cantidad mayor a cero, CUIT válido, etc.) y que
en los juegos de prueba demuestren la correcta aplicación de las validaciones.
 ========================================================================= */
USE COM2900G13;
GO

-- (PREVIAMENTE CARGAR LOS LOTES DE PRUEBA DE ADMINISTRATIVA, FACTURACION)
-- FACTURAS CON PRIMER VENCIMIENTO VENCIDAS, SE APLICA RECARGO, NO SE BLOQUEAN A LOS SOCIOS
INSERT INTO facturacion.Factura (id_cuota_mensual, id_emisor, tipo_factura, dni_receptor, condicion_iva_receptor, cae, monto_total, fecha_emision, fecha_vencimiento1, fecha_vencimiento2, estado, saldo_anterior, anulada)
VALUES (3, 0, 'C', '45778667', 'Consumidor Final', '00000000000001', 55000.00, GETDATE(), DATEADD(DAY, -7, GETDATE()), DATEADD(DAY, +2, GETDATE()), 'Emitida', 0.00, 0);

-- Juan Perez (id_socio = 2, id_cuota_mensual = 4)
INSERT INTO facturacion.Factura (id_cuota_mensual, id_emisor, tipo_factura, dni_receptor, condicion_iva_receptor, cae, monto_total, fecha_emision, fecha_vencimiento1, fecha_vencimiento2, estado, saldo_anterior, anulada)
VALUES (4, 0, 'C', '33444555', 'Consumidor Final', '00000000000002', 40000.00, GETDATE(), DATEADD(DAY, -10, GETDATE()), DATEADD(DAY, +5, GETDATE()), 'Emitida', 0.00, 0);
 select * from facturacion.Factura

-- FACTURA FICTICIA, 2DO VENCIMIENTO CUMPLIDO --> SE DEBE BLOQEAR EL SOCIO
INSERT INTO facturacion.Factura (
    id_cuota_mensual, id_emisor, tipo_factura, dni_receptor,
    condicion_iva_receptor, cae, monto_total,
    fecha_emision, fecha_vencimiento1, fecha_vencimiento2,
    estado, saldo_anterior, anulada
)
VALUES (
    5, 0, 'C', '40606060', 'Consumidor Final', '00000000000201',
    55000.00,
    GETDATE(), DATEADD(DAY, -15, GETDATE()), DATEADD(DAY, -10, GETDATE()),
    'Emitida', 0.00, 0
);

/*____________________________________________________________________
  ____________________ PRUEBAS GestionarRecargo ______________________
  ____________________________________________________________________*/

/* ✅ PRUEBA 1: Insertar un nuevo medio de pago */
EXEC cobranzas.GestionarRecargo 
    @porcentaje = 0.1,
	@descripcion = 'Mora',
	@vigencia = '2025-10-01',
    @operacion = 'Insertar';
-- Resultado esperado: Inserta correctamente el recargo.
SELECT * FROM facturacion.Recargo;
GO

/* ❌ PRUEBA 2: Recargo inválido */
EXEC cobranzas.GestionarRecargo 
    @porcentaje = NULL,
	@descripcion = 'Mora',
	@vigencia = NULL,
    @operacion = 'Insertar';
-- Resultado esperado: 'La vigencia del recargo ingresada es inválida.'

/*____________________________________________________________________
  ________________ PRUEBAS AplicarRecargoVencimiento _________________
  ____________________________________________________________________*/

/* ✅ PRUEBA 1: Aplicar recargo a los socios con facturas vencidas */
EXEC cobranzas.AplicarRecargoVencimiento 
    @descripcion_recargo = 'Mora'
-- Resultado esperado: Inserta correctamente las moras a las facturas correspondientes.
SELECT * FROM cobranzas.Mora;
select saldo from socios.Socio where id_socio = 5
GO

/* ❌ PRUEBA 2: Recargo inválido */
EXEC cobranzas.AplicarRecargoVencimiento 
    @descripcion_recargo = 'Morosidad'
-- Resultado esperado: 'No se encontró un recargo válido con la descripción proporcionada.'.
SELECT * FROM cobranzas.Mora;
GO

/*____________________________________________________________________
  ________________ PRUEBAS AplicarBloqueoVencimiento _________________
  ____________________________________________________________________*/

/* ✅ PRUEBA 1: Bloquear socios con facturas vencidas a la 2da fecha. */
EXEC cobranzas.AplicarBloqueoVencimiento
-- Resultado esperado: Socios modificados, campo 'activo' = 0.
SELECT * FROM administracion.Socio;
GO
select nombre, activo from socios.Socio where dni = 40606060
update socios.Socio
set activo=1
/*____________________________________________________________________
  ________________ PRUEBAS AplicarRecargoVencimiento _________________
  ____________________________________________________________________*/

--SETUP TESTING SP AplicarRecargoVencimiento
SELECT* FROM facturacion.Factura

-- CASO 1: Factura a socio individual (dni = 45778667)
INSERT INTO facturacion.Factura (
    id_emisor,
    tipo_factura,
    dni_receptor,
    condicion_iva_receptor,
    cae,
    monto_total,
    fecha_emision,
    fecha_vencimiento1,
    fecha_vencimiento2,
    estado,
    anulada
)
VALUES (
    1,
    'C',
    '45778667',
    'Consumidor Final',
    '00000000000001',
    30000.00,
    '2025-06-01',
    '2025-06-15',
    '2025-06-20',
    'Emitida',
    0
);

-- CASO 2: Factura a socio responsable de grupo (dni = 33444555, grupo 1)
INSERT INTO facturacion.Factura (
    id_emisor,
    tipo_factura,
    dni_receptor,
    condicion_iva_receptor,
    cae,
    monto_total,
    fecha_emision,
    fecha_vencimiento1,
    fecha_vencimiento2,
    estado,
    anulada
)
VALUES (
    1,
    'C',
    '33444555',
    'Consumidor Final',
    '00000000000002',
    40000.00,
    '2025-06-01',
    '2025-06-15',
    '2025-06-20',
    'Emitida',
    0
);

-- CASO 3: Factura a tutor responsable (dni = 50000000, grupo 2)
INSERT INTO facturacion.Factura (
    id_emisor,
    tipo_factura,
    dni_receptor,
    condicion_iva_receptor,
    cae,
    monto_total,
    fecha_emision,
    fecha_vencimiento1,
    fecha_vencimiento2,
    estado,
    anulada
)
VALUES (
    1,
    'C',
    '50000000',
    'Consumidor Final',
    '00000000000003',
    50000.00,
    '2025-06-01',
    '2025-06-15',
    '2025-06-20',
    'Emitida',
    0
);
SELECT id_socio, dni, nombre, saldo 
FROM socios.Socio;
EXEC cobranzas.AplicarRecargoVencimiento;

SELECT * 
FROM cobranzas.Mora 
WHERE fecha_registro = CAST(GETDATE() AS DATE);

-- Ver saldos actualizados
SELECT id_socio, dni, nombre, saldo 
FROM socios.Socio;


--SETUP TESTING SP AplicarBloqueoVencimiento
select * from socios.Socio


-- 1. Factura a Francisco Vignardel (responsable del grupo 1)
INSERT INTO facturacion.Factura (
    id_emisor,
    tipo_factura,
    dni_receptor,
    condicion_iva_receptor,
    cae,
    monto_total,
    fecha_emision,
    fecha_vencimiento1,
    fecha_vencimiento2,
    estado,
    anulada
)
VALUES (
    1, 'C', '45778667', 'Consumidor Final',
    '00000000010001',
    30000.00,
    '2025-05-01',
    '2025-05-15',
    '2025-06-01',
    'Emitida', 0
);

-- 2. Factura a Pedro Lopez (responsable del grupo 3)
INSERT INTO facturacion.Factura (
    id_emisor,
    tipo_factura,
    dni_receptor,
    condicion_iva_receptor,
    cae,
    monto_total,
    fecha_emision,
    fecha_vencimiento1,
    fecha_vencimiento2,
    estado,
    anulada
)
VALUES (
    1, 'C', '41111111', 'Consumidor Final',
    '00000000010002',
    25000.00,
    '2025-05-01',
    '2025-05-15',
    '2025-06-01',
    'Emitida', 0
);

-- 3. Factura a tutor Lucia Gómez (grupo 2, Camila Sosa es parte del grupo)
INSERT INTO facturacion.Factura (
    id_emisor,
    tipo_factura,
    dni_receptor,
    condicion_iva_receptor,
    cae,
    monto_total,
    fecha_emision,
    fecha_vencimiento1,
    fecha_vencimiento2,
    estado,
    anulada
)
VALUES (
    1, 'C', '50000000', 'Consumidor Final',
    '00000000010003',
    10000.00,
    '2025-05-01',
    '2025-05-15',
    '2025-06-01',
    'Emitida', 0
);
EXEC cobranzas.AplicarBloqueoVencimiento;

SELECT id_socio, dni, nombre, activo 
FROM socios.Socio;

--RESET MANUAL


select dni_receptor from facturacion.Factura  where facturacion.Factura.fecha_vencimiento2 < GETDATE()


delete  from facturacion.Factura  where facturacion.Factura.fecha_vencimiento2 < GETDATE()

select nombre, activo from socios.Socio where id_socio = (select id_socio from socios.GrupoFamiliarSocio where id_grupo = 2)



