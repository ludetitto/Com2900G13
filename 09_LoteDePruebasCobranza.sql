/* =========================================================================
   Trabajo Pr�ctico Integrador - Bases de Datos Aplicadas
   Grupo N�: 13
   Comisi�n: 2900
   Fecha de Entrega: 17/06/2025
   Materia: Bases de Datos Aplicadas
   Alumnos: Vignardel Francisco				45778667
            De Titto Lucia					46501934
			Borja Tomas						42353302
			Rodriguez Sebasti�n Ezequiel	41691928
   
   Objetivo: Testing en bloque.
 ========================================================================= */

USE COM2900G13;
GO
SET NOCOUNT ON;
GO

/* ===========================================================
   LIMPIEZA: eliminar primero relaciones, luego medios de pago
=========================================================== */
DELETE FROM socios.DebitoAutomaticoSocio;
DELETE FROM administracion.MedioDePago;
DBCC CHECKIDENT ('administracion.MedioDePago', RESEED, 0) WITH NO_INFOMSGS;
GO

/* ===========================================================
   INSERTAR MEDIOS DE PAGO
=========================================================== */
EXEC cobranzas.GestionarMedioDePago @nombre = 'Visa', @debito_automatico = 1, @operacion = 'Insertar';
EXEC cobranzas.GestionarMedioDePago @nombre = 'MasterCard', @debito_automatico = 1, @operacion = 'Insertar';
EXEC cobranzas.GestionarMedioDePago @nombre = 'Tarjeta Naranja', @debito_automatico = 1, @operacion = 'Insertar';
EXEC cobranzas.GestionarMedioDePago @nombre = 'Pago F�cil', @debito_automatico = 0, @operacion = 'Insertar';
EXEC cobranzas.GestionarMedioDePago @nombre = 'Rapipago', @debito_automatico = 0, @operacion = 'Insertar';
EXEC cobranzas.GestionarMedioDePago @nombre = 'Transferencia Mercado Pago', @debito_automatico = 0, @operacion = 'Insertar';
GO

/* ===========================================================
   VERIFICACI�N: medios cargados
=========================================================== */
SELECT 
    id_medio_pago,
    nombre,
    debito_automatico
FROM administracion.MedioDePago;
GO
