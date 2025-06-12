
/* =========================================================================
   Lote de pruebas - Gestión de Facturación
   Fecha de ejecución: 2025-06-12
   ========================================================================= */

USE COM2900G13;
GO

-- Eliminar registros previos solo si existen (Actividad Extra y Participación)
DELETE FROM actividades.ParticipacionActividadExtra 
WHERE id_actividad_extra IN (SELECT id_actividad_extra FROM actividades.ActividadExtra WHERE nombre = 'Pileta Libre Junio');
GO

DELETE FROM actividades.ActividadExtra 
WHERE nombre = 'Pileta Libre Junio';
GO

-- Reinsertar actividad extra actualizada
INSERT INTO actividades.ActividadExtra (nombre, costo, vigencia)
VALUES ('Pileta Libre Junio', 1800.00, '2025-06-30');
GO

-- Asociar actividad extra al socio Francisco Vignardel (id_socio = 26)
INSERT INTO actividades.ParticipacionActividadExtra (id_socio, id_actividad_extra)
VALUES (
    26,
    (SELECT id_actividad_extra FROM actividades.ActividadExtra WHERE nombre = 'Pileta Libre Junio')
);
GO

-- Factura mensual para socio
EXEC facturacion.GenerarFacturaSocioMensual
    @dni_socio = '45778667',
    @cuil_emisor = '30711223344';
GO

-- Factura por actividad extra
EXEC facturacion.GenerarFacturaSocioActExtra
    @dni_socio = '45778667',
    @cuil_emisor = '30711223344';
GO

-- Factura para invitado
EXEC facturacion.GenerarFacturaInvitado
    @dni_invitado = '46501934',
    @cuil_emisor = '30711223344',
    @descripcion = 'Día de Pileta Libre';
GO

-- Visualización final de los datos generados
SELECT * FROM facturacion.Factura;
SELECT * FROM facturacion.DetalleFactura;
SELECT * FROM actividades.ActividadExtra;
SELECT * FROM actividades.ParticipacionActividadExtra;
