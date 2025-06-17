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

/* ===================== LIMPIEZA COMPLETA ===================== */
DELETE FROM cobranzas.Mora;
DBCC CHECKIDENT ('cobranzas.Mora', RESEED, 0) WITH NO_INFOMSGS;
DELETE FROM facturacion.Recargo;
DBCC CHECKIDENT ('facturacion.Recargo', RESEED, 0) WITH NO_INFOMSGS;



EXEC cobranzas.GestionarRecargo 0.10, 'Mora', '2025-06-30', 'Insertar'
GO

EXEC cobranzas.AplicarRecargoVencimiento 'Mora'
GO


-- cobranzas.Mora
SELECT 
    id_mora,
    id_socio,
    id_factura,
    facturada,
    monto
FROM cobranzas.Mora;

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
FROM facturacion.Factura;

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
