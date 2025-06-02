USE COM2900G13;
GO

-- =========================================================================
-- Trabajo Práctico Integrador - Bases de Datos Aplicadas
-- Testing para módulo de Gestión de Cobranzas
-- Grupo N°: 13 | Comisión: 2900 | Fecha de Entrega: 17/06/2025
-- =========================================================================

-- ✅ PRUEBA 1: Inserción válida con medio aceptado (Visa)
-- Esperado: Inserta correctamente la cobranza
EXEC pagos.spRegistrarCobranza 
    @idCobranza = 1, 
    @idSocio = 100, 
    @monto = 500.00, 
    @fecha = GETDATE(), 
    @medioPago = 'Visa';
GO
-- Resultado esperado: Inserción exitosa en la tabla pagos.Pago
EXEC sp_helptext 'pagos.spRegistrarCobranza';


-- ❌ PRUEBA 2: Inserción con medio de pago NO permitido (Efectivo)
-- Esperado: Falla la validación, no se inserta y se hace rollback
EXEC pagos.spRegistrarCobranza 
    @idCobranza = 2, 
    @idSocio = 101, 
    @monto = 300.00, 
    @fecha = GETDATE(), 
    @medioPago = 'Efectivo';
-- Resultado esperado: Error "Medio de pago no permitido..." y sin inserción
GO

-- ❌ PRUEBA 3: Repetición de ID (violación de clave primaria)
-- Esperado: Falla por duplicidad de idCobranza y se hace rollback
EXEC pagos.spRegistrarCobranza 
    @idCobranza = 1, 
    @idSocio = 102, 
    @monto = 600.00, 
    @fecha = GETDATE(), 
    @medioPago = 'MasterCard';
-- Resultado esperado: Error de duplicación de clave y sin inserción
GO

-- ✅ PRUEBA 4: Medio de pago válido con otro valor permitido (Pago Fácil)
-- Esperado: Inserta correctamente la cobranza
EXEC pagos.spRegistrarCobranza 
    @idCobranza = 3, 
    @idSocio = 103, 
    @monto = 750.00, 
    @fecha = GETDATE(), 
    @medioPago = 'Pago Fácil';
-- Resultado esperado: Inserción exitosa en la tabla pagos.Pago
GO

-- ✅ CONSULTA: Verificar los registros insertados correctamente
-- Deberías ver las cobranzas con ID 1 y 3 únicamente
SELECT * FROM pagos.Pago;
GO
