USE COM2900G13;
GO
SET NOCOUNT ON;
GO

DELETE FROM cobranzas.Pago;
DBCC CHECKIDENT ('cobranzas.Pago', RESEED, 0) WITH NO_INFOMSGS;

DELETE FROM cobranzas.MedioDePago;
DBCC CHECKIDENT ('cobranzas.MedioDePago', RESEED, 0) WITH NO_INFOMSGS;


-- Insertar medios de pago - Tarjetas de crédito (con débito automático habilitado)
EXEC cobranzas.GestionarMedioDePago @nombre = 'Visa',         @debito_automatico = 1, @operacion = 'Insertar';
EXEC cobranzas.GestionarMedioDePago @nombre = 'MasterCard',   @debito_automatico = 1, @operacion = 'Insertar';
EXEC cobranzas.GestionarMedioDePago @nombre = 'Tarjeta Naranja', @debito_automatico = 1, @operacion = 'Insertar';

-- Insertar medios de pago - Otros (sin débito automático)
EXEC cobranzas.GestionarMedioDePago @nombre = 'Pago Fácil',   @debito_automatico = 0, @operacion = 'Insertar';
EXEC cobranzas.GestionarMedioDePago @nombre = 'Rapipago',     @debito_automatico = 0, @operacion = 'Insertar';
EXEC cobranzas.GestionarMedioDePago @nombre = 'Transferencia Mercado Pago', @debito_automatico = 0, @operacion = 'Insertar';
GO


-- ================= REGISTRAR COBRANZA PARA FACTURA =================
-- Supone que la factura con ID 1 está asociada al socio '45778667'
EXEC cobranzas.RegistrarCobranza 
    @dni_socio = '45778667',
    @monto = 107800,
    @fecha = '2025-06-14',
    @medio_pago = 'Visa',
    @id_factura = 1;
GO

EXEC cobranzas.RegistrarCobranza 
    @dni_socio = '45778667',
    @monto = 25000,
    @fecha = '2025-02-27',
    @medio_pago = 'Visa',
    @id_factura = 6;
GO

-- ================= REGISTRAR COBRANZA PARA FACTURA =================


-- ================= VERIFICAR RESULTADOS =================

select * from cobranzas.MedioDePago

SELECT * FROM cobranzas.Pago WHERE id_factura = 1;

SELECT * FROM administracion.vwSociosConCategoria ORDER BY apellido, nombre;
