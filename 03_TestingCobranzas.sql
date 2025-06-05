-- =========================================================================
-- Trabajo Práctico Integrador - Bases de Datos Aplicadas
-- Testing para módulo de Gestión de Cobranzas
-- Grupo N°: 13 | Comisión: 2900 | Fecha de Entrega: 17/06/2025
-- =========================================================================
USE COM2900G13;

-- ===========================
-- DATOS DE PRUEBA NECESARIOS
-- ===========================

-- Crear un socio válido
INSERT INTO socios.Socio (id_persona, id_grupo, id_categoria, obra_social, nro_obra_social, saldo, activo)
VALUES (NULL, NULL, NULL, 'OSDE', 112233, 10000.00, 1);
DECLARE @idSocio INT = SCOPE_IDENTITY();

-- Crear una actividad extra válida
INSERT INTO actividades.ActividadExtra (debito_automatico) VALUES (1);
DECLARE @idActividadExtra INT = SCOPE_IDENTITY();

-- Crear medios de pago
INSERT INTO pagos.MedioDePago (nombre, debito_automatico) VALUES ('Tarjeta', 1);
INSERT INTO pagos.MedioDePago (nombre, debito_automatico) VALUES ('Transferencia', 0);

-- Crear factura válida para el socio
INSERT INTO facturacion.Factura (id_socio, fecha_emision, vencimiento1, vencimiento2, estado, monto_total, anulada)
VALUES (@idSocio, '2025-05-30', '2025-06-30', 'Emitida', 5000.00, 0);
DECLARE @idFacturaValida INT = SCOPE_IDENTITY();

-- Crear otro socio y factura ajena
INSERT INTO socios.Socio (id_persona, id_grupo, id_categoria, obra_social, nro_obra_social, saldo, activo)
VALUES (NULL, NULL, NULL, 'Swiss', 334455, 5000.00, 1);
DECLARE @idOtroSocio INT = SCOPE_IDENTITY();

INSERT INTO facturacion.Factura (id_socio, fecha_emision, vencimiento1, vencimiento2, estado, monto_total, anulada)
VALUES (@idOtroSocio, '2025-05-30', '2025-06-30', 'Emitida', 7000.00, 0);
DECLARE @idFacturaAjena INT = SCOPE_IDENTITY();

-- ======================
-- CASOS DE PRUEBA
-- ======================

-- ✅ PRUEBA 1: Pago válido con actividad extra
-- Resultado esperado: Inserción exitosa en pagos.Pago, saldo del socio disminuye
DECLARE @fecha1 DATE = '2025-06-03';
EXEC pagos.spRegistrarCobranza 
    @idSocio = @idSocio, 
    @monto = 1500.00, 
    @fecha = @fecha1, 
    @medioPago = 'Tarjeta', 
    @idActividadExtra = @idActividadExtra, 
    @idFactura = @idFacturaValida;

SELECT 'PRUEBA 1 - OK' AS Resultado, * FROM pagos.Pago WHERE id_socio = @idSocio;
SELECT 'PRUEBA 1 - Saldo actualizado' AS Resultado, saldo FROM socios.Socio WHERE id_socio = @idSocio;

-- ✅ PRUEBA 2: Pago válido sin actividad extra
-- Resultado esperado: Inserción exitosa en pagos.Pago, sin idActividadExtra, saldo actualizado
DECLARE @fecha2 DATE = '2025-06-03';
EXEC pagos.spRegistrarCobranza 
    @idSocio = @idSocio, 
    @monto = 2000.00, 
    @fecha = @fecha2, 
    @medioPago = 'Tarjeta', 
    @idActividadExtra = NULL, 
    @idFactura = @idFacturaValida;

SELECT 'PRUEBA 2 - OK' AS Resultado, * FROM pagos.Pago WHERE id_socio = @idSocio;
SELECT 'PRUEBA 2 - Saldo actualizado' AS Resultado, saldo FROM socios.Socio WHERE id_socio = @idSocio;

-- ❌ PRUEBA 3: Factura inexistente
-- Resultado esperado: ERROR - 'La factura no existe, no pertenece al socio o está anulada.'
DECLARE @fecha3 DATE = '2025-06-03';
BEGIN TRY
    EXEC pagos.spRegistrarCobranza 
        @idSocio = @idSocio, 
        @monto = 1000.00, 
        @fecha = @fecha3, 
        @medioPago = 'Tarjeta', 
        @idActividadExtra = NULL, 
        @idFactura = 9999;
END TRY
BEGIN CATCH
    SELECT 'PRUEBA 3 - ERROR ESPERADO' AS Resultado, ERROR_MESSAGE() AS ErrorMsg;
END CATCH

-- ❌ PRUEBA 4: Factura que pertenece a otro socio
-- Resultado esperado: ERROR - 'La factura no existe, no pertenece al socio o está anulada.'
DECLARE @fecha4 DATE = '2025-06-03';
BEGIN TRY
    EXEC pagos.spRegistrarCobranza 
        @idSocio = @idSocio, 
        @monto = 1200.00, 
        @fecha = @fecha4, 
        @medioPago = 'Tarjeta', 
        @idActividadExtra = NULL, 
        @idFactura = @idFacturaAjena;
END TRY
BEGIN CATCH
    SELECT 'PRUEBA 4 - ERROR ESPERADO' AS Resultado, ERROR_MESSAGE() AS ErrorMsg;
END CATCH

-- ❌ PRUEBA 5: Medio de pago no registrado
-- Resultado esperado: ERROR - 'Medio de pago no válido. Debe ser uno registrado.'
DECLARE @fecha5 DATE = '2025-06-03';
BEGIN TRY
    EXEC pagos.spRegistrarCobranza 
        @idSocio = @idSocio, 
        @monto = 900.00, 
        @fecha = @fecha5, 
        @medioPago = 'NoExiste', 
        @idActividadExtra = NULL, 
        @idFactura = @idFacturaValida;
END TRY
BEGIN CATCH
    SELECT 'PRUEBA 5 - ERROR ESPERADO' AS Resultado, ERROR_MESSAGE() AS ErrorMsg;
END CATCH

-- ❌ PRUEBA 6: Medio de pago prohibido (Cheque)
-- Resultado esperado: ERROR - 'No se aceptan pagos en Efectivo ni Cheque.'
DECLARE @fecha6 DATE = '2025-06-03';
BEGIN TRY
    EXEC pagos.spRegistrarCobranza 
        @idSocio = @idSocio, 
        @monto = 950.00, 
        @fecha = @fecha6, 
        @medioPago = 'Cheque', 
        @idActividadExtra = NULL, 
        @idFactura = @idFacturaValida;
END TRY
BEGIN CATCH
    SELECT 'PRUEBA 6 - ERROR ESPERADO' AS Resultado, ERROR_MESSAGE() AS ErrorMsg;
END CATCH
