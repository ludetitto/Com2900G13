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
   
   Objetivo: Testing en bloque.
 ========================================================================= */

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
-- cobranzas.MedioDePago
SELECT 
    id_medio,
    nombre,
    debito_automatico
FROM cobranzas.MedioDePago;

-- cobranzas.Pago
SELECT 
    id_pago,
    id_factura,
    id_medio,
    nro_transaccion,
    monto,
    fecha_emision,
    fecha_vencimiento,
    estado
FROM cobranzas.Pago
ORDER BY fecha_emision DESC;

-- facturacion.Factura
SELECT 
    id_factura,
    id_emisor,
    id_socio,
    id_invitado,
    leyenda,
    monto_total,
    saldo_anterior,
    fecha_emision,
    fecha_vencimiento1,
    fecha_vencimiento2,
    estado,
    anulada
FROM facturacion.Factura
ORDER BY fecha_emision DESC;

-- administracion.vwSociosConCategoria
SELECT 
    dni,
    nombre,
    apellido,
    fecha_nacimiento,
    email,
    id_socio,
    saldo,
    categoria,
    costo_membresia,
    vigencia
FROM administracion.vwSociosConCategoria
ORDER BY apellido, nombre;
