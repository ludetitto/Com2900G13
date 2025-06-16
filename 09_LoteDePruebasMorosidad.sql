USE COM2900G13;
GO
SET NOCOUNT ON;

/* ===================== LIMPIEZA COMPLETA ===================== */
DELETE FROM cobranzas.Mora;
DBCC CHECKIDENT ('cobranzas.Mora', RESEED, 0) WITH NO_INFOMSGS;
DELETE FROM facturacion.Recargo;
DBCC CHECKIDENT ('facturacion.Recargo', RESEED, 0) WITH NO_INFOMSGS;

/* ===================== INSTERTAR UN RECARGO EN LA TABLA MORA ===================== */

EXEC cobranzas.GestionarRecargo 0.10, 'Mora', '2025-06-30', 'Insertar'
GO

