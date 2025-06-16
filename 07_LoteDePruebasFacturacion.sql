USE COM2900G13;
GO
SET NOCOUNT ON;
GO

DELETE FROM cobranzas.Mora;

DBCC CHECKIDENT ('cobranzas.Mora', RESEED, 0) WITH NO_INFOMSGS;
DELETE FROM facturacion.Recargo;
DBCC CHECKIDENT ('facturacion.Recargo', RESEED, 0) WITH NO_INFOMSGS;

-- Borrar pagos y medio de pago
DELETE FROM cobranzas.Pago;
DELETE FROM cobranzas.MedioDePago;
DBCC CHECKIDENT ('cobranzas.Pago', RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('cobranzas.MedioDePago', RESEED, 0) WITH NO_INFOMSGS;


DELETE FROM facturacion.DetalleFactura;
DELETE FROM facturacion.Factura;
DBCC CHECKIDENT ('facturacion.DetalleFactura', RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('facturacion.Factura', RESEED, 0) WITH NO_INFOMSGS;

-- Borrar emisor de factura
DELETE FROM facturacion.EmisorFactura;
DBCC CHECKIDENT ('facturacion.EmisorFactura', RESEED, 0) WITH NO_INFOMSGS;

-- Borrar actividad extra y su presentismo
DELETE FROM actividades.presentismoActividadExtra;
DELETE FROM actividades.ActividadExtra;
DBCC CHECKIDENT ('actividades.presentismoActividadExtra', RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('actividades.ActividadExtra', RESEED, 0) WITH NO_INFOMSGS;

-- Borrar actividad regular y sus relaciones
DELETE FROM actividades.presentismoClase;
DELETE FROM actividades.InscriptoClase;
DELETE FROM actividades.Clase;
DELETE FROM actividades.Actividad;
DBCC CHECKIDENT ('actividades.presentismoClase', RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('actividades.InscriptoClase', RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('actividades.Clase', RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('actividades.Actividad', RESEED, 0) WITH NO_INFOMSGS;


-- Insertar actividades base (sin horarios)
EXEC actividades.GestionarActividad 'Futsal', 25000, '2025-05-31', 'Insertar';
EXEC actividades.GestionarActividad 'V�ley', 30000, '2025-05-31', 'Insertar';
EXEC actividades.GestionarActividad 'Taekwondo', 25000, '2025-05-31', 'Insertar';
EXEC actividades.GestionarActividad 'Baile art�stico', 30000, '2025-05-31', 'Insertar';
EXEC actividades.GestionarActividad 'Nataci�n', 45000, '2025-05-31', 'Insertar';
EXEC actividades.GestionarActividad 'Ajedrez', 2000, '2025-05-31', 'Insertar';
GO

-- FUTSAL - Lunes
EXEC actividades.GestionarClase 'Futsal', '34567890', 'Lunes 08:00', 'Menor', 'Insertar';
EXEC actividades.GestionarClase 'Futsal', '34567890', 'Lunes 14:00', 'Cadete', 'Insertar';
EXEC actividades.GestionarClase 'Futsal', '34567890', 'Lunes 19:00', 'Mayor', 'Insertar';
GO
-- V�LEY - Martes
EXEC actividades.GestionarClase 'V�ley', '34567890', 'Martes 08:00', 'Menor', 'Insertar';
EXEC actividades.GestionarClase 'V�ley', '34567890', 'Martes 14:00', 'Cadete', 'Insertar';
EXEC actividades.GestionarClase 'V�ley', '34567890', 'Martes 19:00', 'Mayor', 'Insertar';
GO
-- TAEKWONDO - Mi�rcoles
EXEC actividades.GestionarClase 'Taekwondo', '34567890', 'Mi�rcoles 08:00', 'Menor', 'Insertar';
EXEC actividades.GestionarClase 'Taekwondo', '34567890', 'Mi�rcoles 14:00', 'Cadete', 'Insertar';
EXEC actividades.GestionarClase 'Taekwondo', '34567890', 'Mi�rcoles 19:00', 'Mayor', 'Insertar';
GO
-- BAILE ART�STICO - Jueves
EXEC actividades.GestionarClase 'Baile art�stico', '34567890', 'Jueves 08:00', 'Menor', 'Insertar';
EXEC actividades.GestionarClase 'Baile art�stico', '34567890', 'Jueves 14:00', 'Cadete', 'Insertar';
EXEC actividades.GestionarClase 'Baile art�stico', '34567890', 'Jueves 19:00', 'Mayor', 'Insertar';
GO
-- NATACI�N - Viernes
EXEC actividades.GestionarClase 'Nataci�n', '34567890', 'Viernes 08:00', 'Menor', 'Insertar';
EXEC actividades.GestionarClase 'Nataci�n', '34567890', 'Viernes 14:00', 'Cadete', 'Insertar';
EXEC actividades.GestionarClase 'Nataci�n', '34567890', 'Viernes 19:00', 'Mayor', 'Insertar';
GO
-- AJEDREZ - S�bado
EXEC actividades.GestionarClase 'Ajedrez', '34567890', 'S�bado 08:00', 'Menor', 'Insertar';
EXEC actividades.GestionarClase 'Ajedrez', '34567890', 'S�bado 14:00', 'Cadete', 'Insertar';
EXEC actividades.GestionarClase 'Ajedrez', '34567890', 'S�bado 19:00', 'Mayor', 'Insertar';
GO

-- Francisco se inscribe a 3 actividades
EXEC actividades.GestionarInscripcion '45778667', 'Ajedrez', 'S�bado 19:00', 'Mayor', '2025-06-12', 'Insertar';
EXEC actividades.GestionarInscripcion '45778667', 'Futsal', 'Lunes 19:00', 'Mayor', '2025-06-13', 'Insertar';
EXEC actividades.GestionarInscripcion '45778667', 'Taekwondo', 'Mi�rcoles 19:00', 'Mayor', '2025-06-14', 'Insertar';
GO
-- Mariana se inscribe a 1 sola actividad
EXEC actividades.GestionarInscripcion '40505050', 'Baile art�stico', 'Jueves 14:00', 'Cadete', '2025-06-12', 'Insertar';
GO
-- Juan se inscribe a 2 actividades
EXEC actividades.GestionarInscripcion '33444555', 'Taekwondo', 'Mi�rcoles 14:00', 'Cadete', '2025-06-13', 'Insertar';
EXEC actividades.GestionarInscripcion '33444555', 'Ajedrez', 'S�bado 14:00', 'Cadete', '2025-06-14', 'Insertar';
GO
-- Camila se inscribe a 1 sola actividad
EXEC actividades.GestionarInscripcion '40606060', 'Nataci�n', 'Viernes 14:00', 'Cadete', '2025-06-15', 'Insertar';
GO
-- Luciano se inscribe a 2 actividades
EXEC actividades.GestionarInscripcion '40707070', 'V�ley', 'Martes 19:00', 'Mayor', '2025-06-12', 'Insertar';
EXEC actividades.GestionarInscripcion '40707070', 'Baile art�stico', 'Jueves 19:00', 'Mayor', '2025-06-13', 'Insertar';
GO
-- =================== CARGA DE PRESENTISMO DE SOCIOS ===================

-- Francisco (3 clases)
EXEC actividades.GestionarPresentismoClase 'Ajedrez', '45778667', 'S�bado 19:00', 'Mayor', '2025-06-12', 'P', 'Insertar';
EXEC actividades.GestionarPresentismoClase 'Futsal', '45778667', 'Lunes 19:00', 'Mayor', '2025-06-13', 'A', 'Insertar'; -- Ausente
EXEC actividades.GestionarPresentismoClase 'Taekwondo', '45778667', 'Mi�rcoles 19:00', 'Mayor', '2025-06-14', 'J', 'Insertar'; -- Justificada
GO
-- Mariana (1 clase)
EXEC actividades.GestionarPresentismoClase 'Baile art�stico', '40505050', 'Jueves 14:00', 'Cadete', '2025-06-12', 'P', 'Insertar';
GO
-- Juan (2 clases)
EXEC actividades.GestionarPresentismoClase 'Taekwondo', '33444555', 'Mi�rcoles 14:00', 'Cadete', '2025-06-13', 'A', 'Insertar'; -- Ausente
EXEC actividades.GestionarPresentismoClase 'Ajedrez', '33444555', 'S�bado 14:00', 'Cadete', '2025-06-14', 'P', 'Insertar';
GO
-- Camila (1 clase)
EXEC actividades.GestionarPresentismoClase 'Nataci�n', '40606060', 'Viernes 14:00', 'Cadete', '2025-06-15', 'J', 'Insertar'; -- Justificada
GO
-- Luciano (2 clases)
EXEC actividades.GestionarPresentismoClase 'V�ley', '40707070', 'Martes 19:00', 'Mayor', '2025-06-12', 'P', 'Insertar';
EXEC actividades.GestionarPresentismoClase 'Baile art�stico', '40707070', 'Jueves 19:00', 'Mayor', '2025-06-13', 'P', 'Insertar';
GO

-- =================== CARGA DE EMISOR DE FACTURA ===================
EXEC facturacion.GestionarEmisorFactura 'Sol del Norte S.A.', '20-12345678-4', 'Av. Presidente Per�n 1234', 'Argentina', 'La Matanza', '1234', 'Insertar'
GO
-- =================== GENERACI�N DE FACTURA MENSUAL ===================
EXEC facturacion.GenerarFacturaSocioMensual '45778667', '20-12345678-4';
EXEC facturacion.GenerarFacturaSocioMensual '33444555', '20-12345678-4';
EXEC facturacion.GenerarFacturaSocioMensual '40707070', '20-12345678-4';
GO



-- =================== CARGA DE ACTIVIDADES EXTRA ===================

-- Insertar actividades extra para invitados
EXEC actividades.GestionarActividadExtra 'Pileta verano', 30000, 'Dia', 'S', '2025-06-28', 'Insertar';
EXEC actividades.GestionarActividadExtra 'Colonia de verano', 30000, 'Dia', 'S', '2025-06-28', 'Insertar';
EXEC actividades.GestionarActividadExtra 'Alquiler de SUM', 30000, 'Dia', 'S', '2025-06-28', 'Insertar';
GO
-- Insertar actividades extra para socios
EXEC actividades.GestionarActividadExtra 'Pileta verano', 25000, 'Dia', 'N', '2025-06-28', 'Insertar';
EXEC actividades.GestionarActividadExtra 'Colonia de verano', 25000, 'Dia', 'N', '2025-06-28', 'Insertar';
EXEC actividades.GestionarActividadExtra 'Alquiler de SUM', 25000, 'Dia', 'N', '2025-06-28', 'Insertar';
GO
EXEC actividades.GestionarActividadExtra 'Pileta verano', 625000, 'Mes', 'N', '2025-06-28', 'Insertar';
EXEC actividades.GestionarActividadExtra 'Colonia de verano', 625000, 'Mes', 'N', '2025-06-28', 'Insertar';
EXEC actividades.GestionarActividadExtra 'Alquiler de SUM', 625000, 'Mes', 'N', '2025-06-28', 'Insertar';
GO
EXEC actividades.GestionarActividadExtra 'Pileta verano', 2000000, 'Temporada', 'N', '2025-06-28', 'Insertar';
EXEC actividades.GestionarActividadExtra 'Colonia de verano', 2000000, 'Temporada', 'N', '2025-06-28', 'Insertar';
EXEC actividades.GestionarActividadExtra 'Alquiler de SUM', 2000000, 'Temporada', 'N', '2025-06-28', 'Insertar';
GO

-- =================== CARGA DE PRESENTISMO DE INVITADOS ===================

-- Francisco (2 actividades, 1 presencia)
EXEC actividades.GestionarPresentismoActividadExtra 'Alquiler de SUM', 'Dia', 'N', '45778667', '2025-06-01', 'P', 'Insertar';
EXEC actividades.GestionarPresentismoActividadExtra 'Pileta verano', 'Dia', 'N', '45778667', '2025-06-05', 'A', 'Insertar'; -- Ausente
GO
-- Mariana (1 actividad, 5 presencias)
EXEC actividades.GestionarPresentismoActividadExtra 'Colonia de verano', 'Temporada', 'N', '40505050', '2025-06-01', 'P', 'Insertar';
EXEC actividades.GestionarPresentismoActividadExtra 'Colonia de verano', 'Temporada', 'N', '40505050', '2025-06-02', 'P', 'Insertar';
EXEC actividades.GestionarPresentismoActividadExtra 'Colonia de verano', 'Temporada', 'N', '40505050', '2025-06-03', 'P', 'Insertar';
EXEC actividades.GestionarPresentismoActividadExtra 'Colonia de verano', 'Temporada', 'N', '40505050', '2025-06-04', 'P', 'Insertar';
EXEC actividades.GestionarPresentismoActividadExtra 'Colonia de verano', 'Temporada', 'N', '40505050', '2025-06-05', 'P', 'Insertar';
GO
-- Luciano (1 actividad, 2 presencias)
EXEC actividades.GestionarPresentismoActividadExtra 'Pileta verano', 'Mes', 'N', '40707070', '2025-06-05', 'A', 'Insertar';
EXEC actividades.GestionarPresentismoActividadExtra 'Pileta verano', 'Mes', 'N', '40707070', '2025-06-06', 'P', 'Insertar';
EXEC actividades.GestionarPresentismoActividadExtra 'Pileta verano', 'Mes', 'N', '40707070', '2025-06-10', 'A', 'Insertar';
EXEC actividades.GestionarPresentismoActividadExtra 'Pileta verano', 'Mes', 'N', '40707070', '2025-06-12', 'P', 'Insertar';
GO
-- Lucia (2 actividades, 2 presencias)
EXEC actividades.GestionarPresentismoActividadExtra 'Alquiler de SUM', 'Dia', 'S', '46501934', '2025-06-01', 'P', 'Insertar';
EXEC actividades.GestionarPresentismoActividadExtra 'Pileta verano', 'Dia', 'S', '46501934', '2025-06-05', 'P', 'Insertar';
GO

-- =================== GENERACI�N DE FACTURA INVITADOS ===================
EXEC facturacion.GenerarFacturaInvitado '46501934', '20-12345678-4', 'Alquiler de SUM', '2025-06-01';
EXEC facturacion.GenerarFacturaInvitado '46501934', '20-12345678-4', 'Pileta verano', '2025-06-05';

GO
-- =================== GENERACION DE FACTURA SOCIOS ===================
EXEC facturacion.GenerarFacturaSocioActExtra '45778667', '20-12345678-4', 'Alquiler de SUM', '2025-06-01';
EXEC facturacion.GenerarFacturaSocioActExtra '45778667', '20-12345678-4', 'Pileta verano', '2025-06-05';
EXEC facturacion.GenerarFacturaSocioActExtra '40505050', '20-12345678-4', 'Colonia de verano', '2025-06-01';
EXEC facturacion.GenerarFacturaSocioActExtra '40707070', '20-12345678-4', 'Pileta verano', '2025-06-06';

GO
-- =================== VERIFICAR ===================
SELECT * FROM actividades.Actividad;
SELECT * FROM actividades.Clase;
SELECT * FROM actividades.InscriptoClase;
SELECT * FROM actividades.presentismoClase ORDER BY fecha;
SELECT * FROM actividades.ActividadExtra;
SELECT * FROM actividades.presentismoActividadExtra ORDER BY fecha;
SELECT * FROM facturacion.EmisorFactura;
SELECT * FROM facturacion.Factura;
SELECT * FROM facturacion.DetalleFactura;
SELECT * FROM facturacion.vwResponsablesDeFactura ORDER BY fecha_emision DESC;
SELECT * FROM administracion.vwSociosConCategoria ORDER BY apellido, nombre;