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
DELETE FROM cobranzas.PagoACuenta
DBCC CHECKIDENT ('cobranzas.PagoACuenta', RESEED, 0) WITH NO_INFOMSGS;
DELETE FROM cobranzas.Reembolso
DBCC CHECKIDENT ('cobranzas.Reembolso', RESEED, 0) WITH NO_INFOMSGS;
DELETE FROM cobranzas.Pago
DBCC CHECKIDENT ('cobranzas.Pago', RESEED, 0) WITH NO_INFOMSGS;
DELETE FROM cobranzas.MedioDePago;
DBCC CHECKIDENT ('cobranzas.MedioDePago', RESEED, 0) WITH NO_INFOMSGS;
GO

/* ===========================================================
   INSERTAR MEDIOS DE PAGO
=========================================================== */
EXEC cobranzas.GestionarMedioDePago 'Tarjeta de débito', 'Insertar';
GO
EXEC cobranzas.GestionarMedioDePago 'Visa', 'Insertar';
GO
EXEC cobranzas.GestionarMedioDePago 'MasterCard', 'Insertar';
GO
EXEC cobranzas.GestionarMedioDePago 'Tarjeta Naranja', 'Insertar';
GO
EXEC cobranzas.GestionarMedioDePago 'Pago Fácil', 'Insertar'
GO
EXEC cobranzas.GestionarMedioDePago 'Rapipago', 'Insertar';
GO
EXEC cobranzas.GestionarMedioDePago 'Transferencia Mercado Pago', 'Insertar';

/* ===========================================================
   VERIFICACIÓN: medios cargados
=========================================================== */
SELECT 
    id_medio_pago,
    nombre
FROM cobranzas.MedioDePago;
GO
EXEC cobranzas.RegistrarCobranza 7, '2025-01-30', 200000, 'Visa';
EXEC cobranzas.RegistrarCobranza 6, '2025-01-30', 200000, 'Visa';
EXEC cobranzas.RegistrarCobranza 5, '2025-01-28', 2000, 'Mastercard';

SELECT *
FROM cobranzas.Pago

SELECT *
FROM socios.Socio


SELECT *
FROM cobranzas.Reembolso

SELECT *
FROM cobranzas.PagoACuenta

SELECT *
FROM socios.Socio