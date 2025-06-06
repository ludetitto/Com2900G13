-- =========================================================================
-- Trabajo Práctico Integrador - Bases de Datos Aplicadas
-- Testing para módulo de Gestión de Cobranzas
-- Grupo N°: 13 | Comisión: 2900 | Fecha de Entrega: 17/06/2025
-- =========================================================================
USE COM2900G13;
GO

-- ===========================
-- DATOS DE PRUEBA NECESARIOS
-- ===========================

-- Insertar solo si no existen
IF NOT EXISTS (SELECT 1 FROM administracion.Persona WHERE dni = '0000000001')
BEGIN
    INSERT INTO administracion.Persona (nombre, apellido, dni, email, fecha_nacimiento, tel_contacto, tel_emergencia, borrado)
    VALUES ('Test', 'User', '0000000001', 'test@email.com', '1990-01-01', '1111111111', '2222222222', 0);
END

IF NOT EXISTS (SELECT 1 FROM administracion.CategoriaSocio WHERE nombre = 'TestCategoria')
BEGIN
    INSERT INTO administracion.CategoriaSocio (nombre, años, costo_membresia, vigencia)
    VALUES ('TestCategoria', 25, 1000.00, '2025-12-31');
END

IF NOT EXISTS (SELECT 1 FROM administracion.Socio WHERE nro_socio = 'SOC1000')
BEGIN
    INSERT INTO administracion.Socio (
        id_persona, id_categoria, nro_socio, obra_social, nro_obra_social, saldo, activo
    )
    VALUES (
        (SELECT id_persona FROM administracion.Persona WHERE dni = '0000000001'),
        (SELECT id_categoria FROM administracion.CategoriaSocio WHERE nombre = 'TestCategoria'),
        'SOC1000', 'OSDE', '112233', 10000.00, 1
    );
END

IF NOT EXISTS (SELECT 1 FROM actividades.ActividadExtra WHERE nombre = 'Excursión')
BEGIN
    INSERT INTO actividades.ActividadExtra (nombre, costo, periodo, es_invitado, vigencia)
    VALUES ('Excursión', 2000.00, 'Junio', 'N', '2025-12-31');
END

IF NOT EXISTS (SELECT 1 FROM cobranzas.MedioDePago WHERE nombre = 'Tarjeta')
    INSERT INTO cobranzas.MedioDePago (nombre, debito_automatico) VALUES ('Tarjeta', 1);

IF NOT EXISTS (SELECT 1 FROM cobranzas.MedioDePago WHERE nombre = 'Transferencia')
    INSERT INTO cobranzas.MedioDePago (nombre, debito_automatico) VALUES ('Transferencia', 1);

IF NOT EXISTS (SELECT 1 FROM facturacion.EmisorFactura WHERE razon_social = 'Club Sol Norte')
BEGIN
    INSERT INTO facturacion.EmisorFactura (razon_social, cuil, direccion, pais, localidad, codigo_postal)
    VALUES ('Club Sol Norte', '30-12345678-9', 'Calle Falsa 123', 'Argentina', 'San Justo', '1754');
END

IF NOT EXISTS (
    SELECT 1 FROM facturacion.Factura 
    WHERE leyenda = 'Consumidor Final' AND anulada = 0 AND id_socio = (SELECT id_socio FROM administracion.Socio WHERE nro_socio = 'SOC1000')
)
BEGIN
    INSERT INTO facturacion.Factura (
        id_emisor, id_socio, leyenda, monto_total, fecha_emision, fecha_vencimiento, estado, anulada
    )
    VALUES (
        (SELECT id_emisor FROM facturacion.EmisorFactura WHERE razon_social = 'Club Sol Norte'),
        (SELECT id_socio FROM administracion.Socio WHERE nro_socio = 'SOC1000'),
        'Consumidor Final', 5000.00, '2025-06-01', '2025-06-30', 'Emitida', 0
    );
END

-- =======================================
-- CADA BLOQUE DE PRUEBA SE EJECUTA SOLO
-- =======================================

-- ✅ PRUEBA 1: Pago válido con actividad extra
DECLARE @idSocio INT = (SELECT id_socio FROM administracion.Socio WHERE nro_socio = 'SOC1000');
DECLARE @idActividadExtra INT = (SELECT id_extra FROM actividades.ActividadExtra WHERE nombre = 'Excursión');
DECLARE @idFacturaValida INT = (
    SELECT TOP 1 id_factura 
    FROM facturacion.Factura 
    WHERE id_socio = @idSocio AND anulada = 0 AND leyenda = 'Consumidor Final'
);

EXEC cobranzas.spRegistrarCobranza 
    @idSocio = @idSocio, 
    @monto = 1500.00, 
    @fecha = '2025-06-03', 
    @medioPago = 'Tarjeta', 
    @idActividadExtra = @idActividadExtra, 
    @idFactura = @idFacturaValida;

SELECT 'PRUEBA 1 - OK' AS Resultado, * FROM cobranzas.Pago WHERE id_factura = @idFacturaValida;
SELECT 'PRUEBA 1 - Saldo actualizado' AS Resultado, saldo FROM administracion.Socio WHERE id_socio = @idSocio;

-- ✅ TEST 2: Pago válido sin actividad extra
DECLARE @idSocio INT = (SELECT id_socio FROM administracion.Socio WHERE nro_socio = 'SOC1000');
DECLARE @idFactura2 INT = (
    SELECT TOP 1 id_factura FROM facturacion.Factura 
    WHERE id_socio = @idSocio AND anulada = 0 AND leyenda = 'Consumidor Final'
);

EXEC cobranzas.spRegistrarCobranza 
    @idSocio = @idSocio,
    @monto = 1000.00,
    @fecha = '2025-06-04',
    @medioPago = 'Transferencia',
    @idActividadExtra = NULL,
    @idFactura = @idFactura2;

SELECT 'TEST 2 - OK' AS Resultado, * FROM cobranzas.Pago WHERE id_factura = @idFactura2;

-- ❌ TEST 3: Medio de pago no registrado
DECLARE @idSocio INT = (SELECT id_socio FROM administracion.Socio WHERE nro_socio = 'SOC1000');
DECLARE @idFactura3 INT = (SELECT TOP 1 id_factura FROM facturacion.Factura WHERE leyenda = 'Consumidor Final');

BEGIN TRY
    EXEC cobranzas.spRegistrarCobranza 
        @idSocio = @idSocio,
        @monto = 900.00,
        @fecha = '2025-06-04',
        @medioPago = 'Bitcoin',
        @idActividadExtra = NULL,
        @idFactura = @idFactura3;
END TRY
BEGIN CATCH
    SELECT 'TEST 3 - ERROR ESPERADO' AS Resultado, ERROR_MESSAGE() AS ErrorMsg;
END CATCH;


-- ❌ TEST 4 y 5: Medio de pago prohibido
DECLARE @idSocio INT = (SELECT id_socio FROM administracion.Socio WHERE nro_socio = 'SOC1000');
DECLARE @idFactura45 INT = (SELECT TOP 1 id_factura FROM facturacion.Factura WHERE leyenda = 'Consumidor Final');

BEGIN TRY
    EXEC cobranzas.spRegistrarCobranza 
        @idSocio = @idSocio, 
        @monto = 500, 
        @fecha = '2025-06-04', 
        @medioPago = 'Efectivo', 
        @idActividadExtra = NULL, 
        @idFactura = @idFactura45;
END TRY
BEGIN CATCH 
    SELECT 'TEST 4 - ERROR ESPERADO' AS Resultado, ERROR_MESSAGE() AS ErrorMsg; 
END CATCH;

BEGIN TRY
    EXEC cobranzas.spRegistrarCobranza 
        @idSocio = @idSocio, 
        @monto = 500, 
        @fecha = '2025-06-04', 
        @medioPago = 'Cheque', 
        @idActividadExtra = NULL, 
        @idFactura = @idFactura45;
END TRY
BEGIN CATCH 
    SELECT 'TEST 5 - ERROR ESPERADO' AS Resultado, ERROR_MESSAGE() AS ErrorMsg; 
END CATCH;

-- ❌ TEST 6: Actividad inexistente
DECLARE @idSocio INT = (SELECT id_socio FROM administracion.Socio WHERE nro_socio = 'SOC1000');
DECLARE @idFactura45 INT = (SELECT TOP 1 id_factura FROM facturacion.Factura WHERE leyenda = 'Consumidor Final');

BEGIN TRY
    EXEC cobranzas.spRegistrarCobranza 
        @idSocio = @idSocio, 
        @monto = 1000, 
        @fecha = '2025-06-04', 
        @medioPago = 'Tarjeta', 
        @idActividadExtra = 9999, -- ID inexistente
        @idFactura = @idFactura45;
END TRY
BEGIN CATCH
    SELECT 'TEST 6 - ERROR ESPERADO' AS Resultado, ERROR_MESSAGE() AS ErrorMsg;
END CATCH;

-- ❌ TEST 7: Factura anulada con leyenda = 'Consumidor Final'
DECLARE @idSocio INT = (SELECT id_socio FROM administracion.Socio WHERE nro_socio = 'SOC1000');

INSERT INTO facturacion.Factura (
    id_emisor, id_socio, leyenda, monto_total, fecha_emision, fecha_vencimiento, estado, anulada
) VALUES (
    (SELECT TOP 1 id_emisor FROM facturacion.EmisorFactura),
    @idSocio,
    'Consumidor Final',
    1000.00,
    '2025-06-01',
    '2025-06-30',
    'Emitida',
    1
);

DECLARE @idFacturaAnulada INT = SCOPE_IDENTITY();

BEGIN TRY
    EXEC cobranzas.spRegistrarCobranza 
        @idSocio = @idSocio, 
        @monto = 500, 
        @fecha = '2025-06-05', 
        @medioPago = 'Tarjeta', 
        @idActividadExtra = NULL, 
        @idFactura = @idFacturaAnulada;
END TRY
BEGIN CATCH
    SELECT 'TEST 7 - ERROR ESPERADO' AS Resultado, ERROR_MESSAGE() AS ErrorMsg;
END CATCH;

-- ❌ TEST 8: Socio inactivo
IF NOT EXISTS (SELECT 1 FROM administracion.Persona WHERE dni = '0000000003')
BEGIN
    INSERT INTO administracion.Persona (nombre, apellido, dni, email, fecha_nacimiento, tel_contacto, tel_emergencia, borrado)
    VALUES ('Inactivo', 'Socio', '0000000003', 'inactivo@email.com', '1995-01-01', '1111222233', '2222333344', 0);
END

DECLARE @idPersonaInactiva INT = (SELECT id_persona FROM administracion.Persona WHERE dni = '0000000003');

IF NOT EXISTS (SELECT 1 FROM administracion.Socio WHERE nro_socio = 'SOCINACTIVO')
BEGIN
    INSERT INTO administracion.Socio (
        id_persona, id_categoria, nro_socio, obra_social, nro_obra_social, saldo, activo
    )
    VALUES (@idPersonaInactiva, (SELECT TOP 1 id_categoria FROM administracion.CategoriaSocio), 'SOCINACTIVO', 'OSDE', '999999', 5000.00, 0);
END

IF NOT EXISTS (
    SELECT 1 FROM facturacion.Factura 
    WHERE leyenda = 'Consumidor Final' AND id_socio = (SELECT id_socio FROM administracion.Socio WHERE nro_socio = 'SOCINACTIVO')
)
BEGIN
    INSERT INTO facturacion.Factura (
        id_emisor, id_socio, leyenda, monto_total, fecha_emision, fecha_vencimiento, estado, anulada
    )
    VALUES ((SELECT TOP 1 id_emisor FROM facturacion.EmisorFactura), (SELECT id_socio FROM administracion.Socio WHERE nro_socio = 'SOCINACTIVO'), 'Consumidor Final', 2000.00, '2025-06-01', '2025-06-30', 'Emitida', 0);
END

DECLARE @idSocioInactivo INT = (SELECT id_socio FROM administracion.Socio WHERE nro_socio = 'SOCINACTIVO');
DECLARE @idFacturaInactivo INT = (SELECT TOP 1 id_factura FROM facturacion.Factura WHERE leyenda = 'Consumidor Final' AND id_socio = @idSocioInactivo);

BEGIN TRY
    EXEC cobranzas.spRegistrarCobranza @idSocio = @idSocioInactivo, @monto = 500, @fecha = '2025-06-05', @medioPago = 'Tarjeta', @idActividadExtra = NULL, @idFactura = @idFacturaInactivo;
END TRY
BEGIN CATCH SELECT 'TEST 8 - ERROR ESPERADO' AS Resultado, ERROR_MESSAGE() AS ErrorMsg; END CATCH;
