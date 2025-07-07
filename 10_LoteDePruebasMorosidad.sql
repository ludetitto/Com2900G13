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

/* =====================================================
   LIMPIEZA: eliminar tablas del módulo de morosidad
   ======================================================== */
DELETE FROM cobranzas.Mora;
DBCC CHECKIDENT ('cobranzas.Mora', RESEED, 0) WITH NO_INFOMSGS;
DELETE FROM cobranzas.PagoACuenta;
DBCC CHECKIDENT ('cobranzas.PagoACuenta', RESEED, 0) WITH NO_INFOMSGS;
DELETE FROM cobranzas.Reembolso;
DBCC CHECKIDENT ('cobranzas.Reembolso', RESEED, 0) WITH NO_INFOMSGS;

/* =====================================================
   Aplicar recargo por 1er vencimiento de factura
   ======================================================== */
EXEC cobranzas.AplicarRecargoVencimiento
GO

-- cobranzas.Mora
SELECT *
FROM cobranzas.Mora;

SELECT * FROM socios.Socio

/* =====================================================
   Aplicar bloqueo por 2do vencimiento de factura
   ======================================================== */
EXEC cobranzas.AplicarBloqueoVencimiento
GO

EXEC facturacion.GenerarCuotasMensualesPorFecha '2025-03-30';
GO

EXEC facturacion.GenerarFacturasMensualesPorFecha '2025-03-30';
GO
/*
EXEC facturacion.GenerarCuotasMensualesPorFecha '2025-04-30';
GO

EXEC facturacion.GenerarFacturasMensualesPorFecha '2025-04-30';
GO
*/
-- facturacion.Factura
SELECT *
FROM facturacion.Factura;

SELECT *
FROM facturacion.DetalleFactura

-- administracion.vwSociosConCategoria
SELECT *
FROM socios.Socio

SELECT *
FROM cobranzas.Mora;