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

/* ===========================================================
   LIMPIEZA: eliminar primero relaciones, luego medios de pago
=========================================================== */
DELETE FROM cobranzas.pago
DBCC CHECKIDENT ('cobranzas.pago', RESEED, 0) WITH NO_INFOMSGS;
DELETE FROM cobranzas.MedioDePago;
DBCC CHECKIDENT ('cobranzas.MedioDePago', RESEED, 0) WITH NO_INFOMSGS;
GO

/* ===========================================================
   INSERTAR MEDIOS DE PAGO
=========================================================== */
EXEC cobranzas.GestionarMedioDePago 'Tarjeta de débito', 'Insertar';
/*
EXEC cobranzas.GestionarMedioDePago @nombre = 'MasterCard', @debito_automatico = 1, @operacion = 'Insertar';
EXEC cobranzas.GestionarMedioDePago @nombre = 'Tarjeta Naranja', @debito_automatico = 1, @operacion = 'Insertar';
EXEC cobranzas.GestionarMedioDePago @nombre = 'Pago Fácil', @debito_automatico = 0, @operacion = 'Insertar';
EXEC cobranzas.GestionarMedioDePago @nombre = 'Rapipago', @debito_automatico = 0, @operacion = 'Insertar';
EXEC cobranzas.GestionarMedioDePago @nombre = 'Transferencia Mercado Pago', @debito_automatico = 0, @operacion = 'Insertar';
GO
*/
/* ===========================================================
   VERIFICACIÓN: medios cargados
=========================================================== */
SELECT 
    id_medio_pago,
    nombre
FROM cobranzas.MedioDePago;
GO

EXEC cobranzas.RegistrarCobranza 1, '2025-06-30', 30000, 1;

SELECT *
FROM cobranzas.Pago

SELECT *
FROM socios.Socio
