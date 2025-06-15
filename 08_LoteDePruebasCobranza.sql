USE COM2900G13;
GO
SET NOCOUNT ON;
GO

-- Limpiar estado anterior
DELETE FROM cobranzas.Mora;
DBCC CHECKIDENT ('cobranzas.Mora', RESEED, 0) WITH NO_INFOMSGS;
DELETE FROM facturacion.Recargo;
DBCC CHECKIDENT ('facturacion.Recargo', RESEED, 0) WITH NO_INFOMSGS;

DELETE FROM cobranzas.Pago;
DBCC CHECKIDENT ('cobranzas.Pago', RESEED, 0) WITH NO_INFOMSGS;

DELETE FROM cobranzas.MedioDePago;
DBCC CHECKIDENT ('cobranzas.MedioDePago', RESEED, 0) WITH NO_INFOMSGS;

-- Insertar medios de pago válidos
EXEC cobranzas.GestionarMedioDePago @nombre = 'Visa', @debito_automatico = 1, @operacion = 'Insertar';
EXEC cobranzas.GestionarMedioDePago @nombre = 'MasterCard', @debito_automatico = 1, @operacion = 'Insertar';
EXEC cobranzas.GestionarMedioDePago @nombre = 'Tarjeta Naranja', @debito_automatico = 1, @operacion = 'Insertar';
EXEC cobranzas.GestionarMedioDePago @nombre = 'Pago Fácil', @debito_automatico = 0, @operacion = 'Insertar';
EXEC cobranzas.GestionarMedioDePago @nombre = 'Rapipago', @debito_automatico = 0, @operacion = 'Insertar';
EXEC cobranzas.GestionarMedioDePago @nombre = 'Transferencia Mercado Pago', @debito_automatico = 0, @operacion = 'Insertar';
GO

-- ================= REGISTRAR COBRANZAS =================

-- Cobranza para Francisco (buscar su última factura)
DECLARE @facturaFrancisco INT;
SELECT TOP 1 @facturaFrancisco = f.id_factura
FROM facturacion.Factura f
JOIN administracion.Socio s ON f.id_socio = s.id_socio
JOIN administracion.Persona p ON p.id_persona = s.id_persona
WHERE p.dni = '45778667'
ORDER BY f.fecha_emision DESC;


EXEC cobranzas.RegistrarCobranza 
    @dni_socio = '45778667',
    @monto = 107800, -- ajustá si necesitás matchear con monto real
    @fecha = '2025-06-14',
    @medio_pago = 'Visa',
    @nombre_actividad_extra = NULL,
    @id_factura = @facturaFrancisco;
GO

-- Otra cobranza para Francisco (buscar la anterior)
DECLARE @facturaFrancisco2 INT;
SELECT TOP 1 @facturaFrancisco2 = f.id_factura
FROM facturacion.Factura f
JOIN administracion.Socio s ON f.id_socio = s.id_socio
JOIN administracion.Persona p ON p.id_persona = s.id_persona
WHERE p.dni = '45778667'
ORDER BY f.fecha_emision ASC; -- inverso para encontrar la más vieja


EXEC cobranzas.RegistrarCobranza 
    @dni_socio = '45778667',
    @monto = 25000,
    @fecha = '2025-02-27',
    @medio_pago = 'Visa',
    @nombre_actividad_extra = NULL,
    @id_factura = @facturaFrancisco2;
GO

-- ================= VERIFICAR RESULTADOS =================

SELECT * FROM cobranzas.MedioDePago;
SELECT * FROM cobranzas.Pago ORDER BY fecha_emision DESC;
SELECT * FROM facturacion.Factura ORDER BY fecha_emision DESC;
SELECT * FROM administracion.vwSociosConCategoria ORDER BY apellido, nombre;
