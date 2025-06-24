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

EXEC cobranzas.RegistrarCobranza 
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

EXEC cobranzas.RegistrarCobranza 
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
    EXEC cobranzas.RegistrarCobranza 
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
    EXEC cobranzas.RegistrarCobranza 
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
    EXEC cobranzas.RegistrarCobranza 
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
    EXEC cobranzas.RegistrarCobranza 
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
    EXEC cobranzas.RegistrarCobranza 
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
    EXEC cobranzas.RegistrarCobranza @idSocio = @idSocioInactivo, @monto = 500, @fecha = '2025-06-05', @medioPago = 'Tarjeta', @idActividadExtra = NULL, @idFactura = @idFacturaInactivo;
END TRY
BEGIN CATCH SELECT 'TEST 8 - ERROR ESPERADO' AS Resultado, ERROR_MESSAGE() AS ErrorMsg; END CATCH;


-- HABILITAR DEBITO AUTOMATICO TESTING

-- ========================================
-- TEST 1: Habilitar débito automático para un medio válido
-- ========================================
IF NOT EXISTS (SELECT 1 FROM cobranzas.MedioDePago WHERE nombre = 'Tarjeta')
BEGIN
    INSERT INTO cobranzas.MedioDePago (nombre, debito_automatico)
    VALUES ('Tarjeta', 0);
END

EXEC cobranzas.HabilitarDebitoAutomatico @nombreMedio = 'Tarjeta';

SELECT 'TEST 1 - Estado actualizado correctamente' AS Resultado, nombre, debito_automatico 
FROM cobranzas.MedioDePago WHERE nombre = 'Tarjeta';

-- ========================================
-- TEST 2: Intentar habilitar débito automático para medio inexistente
-- ========================================
BEGIN TRY
    EXEC cobranzas.HabilitarDebitoAutomatico @nombreMedio = 'Criptomonedas';
END TRY
BEGIN CATCH
    SELECT 'TEST 2 - ERROR ESPERADO' AS Resultado, ERROR_MESSAGE() AS ErrorMsg;
END CATCH;

-- ========================================
-- TEST 3: Insertar nuevo medio y habilitar débito automático
-- ========================================
IF NOT EXISTS (SELECT 1 FROM cobranzas.MedioDePago WHERE nombre = 'Mastercard')
BEGIN
    INSERT INTO cobranzas.MedioDePago (nombre, debito_automatico)
    VALUES ('Mastercard', 0);
END

EXEC cobranzas.HabilitarDebitoAutomatico @nombreMedio = 'Mastercard';

SELECT 'TEST 3 - Mastercard actualizado' AS Resultado, nombre, debito_automatico
FROM cobranzas.MedioDePago WHERE nombre = 'Mastercard';

-- ========================================
-- TEST 4: Verificación múltiple de estado final
-- ========================================
SELECT 'TEST 4 - Verificación final' AS Resultado, * 
FROM cobranzas.MedioDePago 
WHERE nombre IN ('Tarjeta', 'Mastercard');


-- TESTING DEHABILITAR DEBITO AUTOMATICO

-- ========================================
-- TEST 1: Deshabilitar débito automático de un medio existente
-- ========================================
EXEC cobranzas.DeshabilitarDebitoAutomatico @nombreMedio = 'Tarjeta';

SELECT 'TEST 1 - Tarjeta actualizado' AS Resultado, nombre, debito_automatico
FROM cobranzas.MedioDePago WHERE nombre = 'Tarjeta';

-- ========================================
-- TEST 2: Intentar deshabilitar un medio inexistente
-- ========================================
BEGIN TRY
    EXEC cobranzas.DeshabilitarDebitoAutomatico @nombreMedio = 'VisaBlack';
END TRY
BEGIN CATCH
    SELECT 'TEST 2 - ERROR ESPERADO' AS Resultado, ERROR_MESSAGE() AS ErrorMsg;
END CATCH;

-- ========================================
-- TEST 3: Confirmar estado final de varios medios
-- ========================================
SELECT 'TEST 3 - Verificación final' AS Resultado, * 
FROM cobranzas.MedioDePago 
WHERE nombre IN ('Tarjeta', 'Mastercard');



-- TESTING GenerarReembolso

-- ✅ TEST 1: Reembolso válido
DECLARE @idPagoValido INT = (
    SELECT TOP 1 id_pago
    FROM cobranzas.Pago
    ORDER BY fecha_emision DESC
);

BEGIN TRY
    EXEC cobranzas.GenerarReembolso 
        @idPago = @idPagoValido,
        @monto = 300.00,
        @motivo = 'Error en facturación';
    SELECT 'TEST 1 - OK' AS Resultado, * FROM cobranzas.NotaDeCredito WHERE id_pago = @idPagoValido;
END TRY
BEGIN CATCH
    SELECT 'TEST 1 - ERROR NO ESPERADO' AS Resultado, ERROR_MESSAGE() AS ErrorMsg;
END CATCH;

-- ❌ TEST 2: ID de pago inexistente
BEGIN TRY
    EXEC cobranzas.GenerarReembolso 
        @idPago = -1,
        @monto = 100.00,
        @motivo = 'Pago inválido';
END TRY
BEGIN CATCH
    SELECT 'TEST 2 - ERROR ESPERADO' AS Resultado, ERROR_MESSAGE() AS ErrorMsg;
END CATCH;

-- TESTING RegistrarPagoACuenta

-- ✅ TEST 3: Pago a cuenta válido (ver saldo antes y después)
DECLARE @idSocioPagoCuenta INT = (
    SELECT TOP 1 id_socio FROM administracion.Socio WHERE activo = 1
);
DECLARE @saldoAntes DECIMAL(10,2);
DECLARE @saldoDespues DECIMAL(10,2);

-- Obtener saldo antes
SELECT @saldoAntes = saldo FROM administracion.Socio WHERE id_socio = @idSocioPagoCuenta;

BEGIN TRY
    EXEC cobranzas.RegistrarPagoACuenta 
        @idSocio = @idSocioPagoCuenta,
        @monto = 400.00,
        @fecha = '2025-06-05',
        @medioPago = 'Transferencia';

    -- Obtener saldo después
    SELECT @saldoDespues = saldo FROM administracion.Socio WHERE id_socio = @idSocioPagoCuenta;

    SELECT 'TEST 3 - OK' AS Resultado, 
           @saldoAntes AS SaldoAntes, 
           @saldoDespues AS SaldoDespues;

    SELECT * FROM cobranzas.PagoACuenta 
    WHERE id_socio = @idSocioPagoCuenta 
    ORDER BY fecha DESC;
END TRY
BEGIN CATCH
    SELECT 'TEST 3 - ERROR NO ESPERADO' AS Resultado, ERROR_MESSAGE() AS ErrorMsg;
END CATCH;


-- ❌ TEST 4: Medio de pago inválido
DECLARE @idSocioPagoCuenta INT = (
    SELECT TOP 1 id_socio FROM administracion.Socio WHERE activo = 1
);
BEGIN TRY
    EXEC cobranzas.RegistrarPagoACuenta 
        @idSocio = @idSocioPagoCuenta,
        @monto = 300.00,
        @fecha = '2025-06-05',
        @medioPago = 'Billetes';
END TRY
BEGIN CATCH
    SELECT 'TEST 4 - ERROR ESPERADO' AS Resultado, ERROR_MESSAGE() AS ErrorMsg;
END CATCH;


-- ❌ TEST 5: Socio inactivo
DECLARE @idSocioInactivoCuenta INT = (
    SELECT TOP 1 id_socio FROM administracion.Socio WHERE activo = 0
);

BEGIN TRY
    EXEC cobranzas.RegistrarPagoACuenta 
        @idSocio = @idSocioInactivoCuenta,
        @monto = 200.00,
        @fecha = '2025-06-05',
        @medioPago = 'Tarjeta';
END TRY
BEGIN CATCH
    SELECT 'TEST 5 - ERROR ESPERADO' AS Resultado, ERROR_MESSAGE() AS ErrorMsg;
END CATCH;


/*____________________________________________________________________
  ______________________ CASO DE PRUEBA RE SENCILLO __________________
  ____________________________________________________________________*/
  /*A modo de testeo interno, despues cambiamos esto*/
 
-- Inserta un nuevo emisor para poder usar en facturación
EXEC administracion.GestionarCategoriaSocio
    @nombre = 'Adulto',
	@años = 18,
    @costo_membresia = 1000.00,
    @vigencia = '2025-12-31',
    @operacion = 'Insertar';
GO

EXEC administracion.GestionarSocio
    @nombre = 'Lucas',
    @apellido = 'Martínez',
    @dni = '0034567890',
    @email = 'lucas.martinez@email.com',
    @fecha_nacimiento = '1992-03-10',
    @tel_contacto = '1231231234',
    @tel_emergencia = '4324324321',
    @categoria = 'Adulto',
    @nro_socio = 'SOC1001',
    @obra_social = 'OSDE',
    @nro_obra_social = '123456',
    @operacion = 'Insertar';
GO

EXEC administracion.GestionarInvitado
    @dni_socio = '0034567890',
	@dni_invitado = '0012345678',
    @operacion = 'Insertar';
GO

EXEC actividades.GestionarActividadExtra
	@nombre = 'Yoga',
	@costo = 2000.00,
	@periodo = '2025-02',
	@es_invitado = 'N',
	@vigencia = '2025-06-01',
	@operacion = 'Insertar';
GO

EXEC actividades.GestionarInscriptoActividadExtra
@dni_socio = '0012345678',
@nombre_actividad_extra = 'Yoga',
@fecha_inscripcion = '2025-02-11',
@operacion = 'Insertar';
GO

EXEC actividades.GestionarPresentismoActividadExtra
@nombre_actividad_extra = 'Yoga',
@periodo = '2025-06',
@es_invitado = 'N',
@dni_socio = '0012345678',
@fecha = '2025-06-08',
@condicion = 'P',
@operacion = 'Insertar';
GO

EXEC facturacion.GestionarEmisorFactura
    @razon_social = 'Club Deportivo Central',
    @cuil = '30-12345678-9',
    @direccion = 'Av. Siempre Viva 742',
    @pais = 'Argentina',
    @localidad = 'Rosario',
    @codigo_postal = '2000',
    @operacion = 'Insertar';
GO

EXEC facturacion.GenerarFacturaSocioMensual 
    @dni_socio = '0034567890',
    @cuil_emisor = '30-12345678-9';
GO

EXEC facturacion.GenerarFacturaInvitado
    @dni_invitado = '0012345678',
    @cuil_emisor = '30-12345678-9',
    @descripcion = 'Yoga';
GO

EXEC cobranzas.GenerarReintegroPorLluvia
	@mes = '02',
	@año = '2025',
	@path = 'C:\Users\ldeti\Desktop\College\BDA\TP BDA\Com2900G13\ETL\open-meteo-buenosaires_2025.csv'
GO

SELECT * FROM cobranzas.PagoACuenta
SELECT * FROM facturacion.Factura
SELECT * FROM administracion.Socio