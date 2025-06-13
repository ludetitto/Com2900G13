USE COM2900G13;
GO

SET NOCOUNT ON;
GO

DELETE FROM cobranzas.MedioDePago
DBCC CHECKIDENT ('cobranzas.MedioDePago', RESEED, 0)WITH NO_INFOMSGS;
DELETE FROM cobranzas.Pago
DBCC CHECKIDENT ('cobranzas.Pago', RESEED, 0)WITH NO_INFOMSGS;
DELETE FROM facturacion.DetalleFactura
DBCC CHECKIDENT ('facturacion.DetalleFactura', RESEED, 0)WITH NO_INFOMSGS;
DELETE FROM facturacion.Factura
DBCC CHECKIDENT ('facturacion.Factura', RESEED, 0)WITH NO_INFOMSGS;
DELETE FROM facturacion.EmisorFactura
DBCC CHECKIDENT ('facturacion.EmisorFactura', RESEED, 0)WITH NO_INFOMSGS;
DELETE FROM actividades.presentismoClase
DBCC CHECKIDENT ('actividades.presentismoClase', RESEED, 0)WITH NO_INFOMSGS;
DELETE FROM actividades.InscriptoClase
DBCC CHECKIDENT ('actividades.InscriptoClase', RESEED, 0)WITH NO_INFOMSGS;
DELETE FROM actividades.Clase
DBCC CHECKIDENT ('actividades.Clase', RESEED, 0)WITH NO_INFOMSGS;
DELETE FROM actividades.Actividad
DBCC CHECKIDENT ('actividades.Actividad', RESEED, 0)WITH NO_INFOMSGS;
DELETE FROM actividades.presentismoActividadExtra
DBCC CHECKIDENT ('actividades.presentismoActividadExtra', RESEED, 0)WITH NO_INFOMSGS;
DELETE FROM actividades.ActividadExtra
DBCC CHECKIDENT ('actividades.ActividadExtra', RESEED, 0)WITH NO_INFOMSGS;
go

-- Insertar actividades base (sin horarios)
EXEC actividades.GestionarActividad 'Futsal', 25000, '2025-05-31', 'Insertar';
EXEC actividades.GestionarActividad 'Vóley', 30000, '2025-05-31', 'Insertar';
EXEC actividades.GestionarActividad 'Taekwondo', 25000, '2025-05-31', 'Insertar';
EXEC actividades.GestionarActividad 'Baile artístico', 30000, '2025-05-31', 'Insertar';
EXEC actividades.GestionarActividad 'Natación', 45000, '2025-05-31', 'Insertar';
EXEC actividades.GestionarActividad 'Ajedrez', 2000, '2025-05-31', 'Insertar';
GO

-- FUTSAL - Lunes
EXEC actividades.GestionarClase 'Futsal', '34567890', 'Lunes 08:00', 'Menor', 'Insertar';
EXEC actividades.GestionarClase 'Futsal', '34567890', 'Lunes 14:00', 'Cadete', 'Insertar';
EXEC actividades.GestionarClase 'Futsal', '34567890', 'Lunes 19:00', 'Mayor', 'Insertar';

-- VÓLEY - Martes
EXEC actividades.GestionarClase 'Vóley', '34567890', 'Martes 08:00', 'Menor', 'Insertar';
EXEC actividades.GestionarClase 'Vóley', '34567890', 'Martes 14:00', 'Cadete', 'Insertar';
EXEC actividades.GestionarClase 'Vóley', '34567890', 'Martes 19:00', 'Mayor', 'Insertar';

-- TAEKWONDO - Miércoles
EXEC actividades.GestionarClase 'Taekwondo', '34567890', 'Miércoles 08:00', 'Menor', 'Insertar';
EXEC actividades.GestionarClase 'Taekwondo', '34567890', 'Miércoles 14:00', 'Cadete', 'Insertar';
EXEC actividades.GestionarClase 'Taekwondo', '34567890', 'Miércoles 19:00', 'Mayor', 'Insertar';

-- BAILE ARTÍSTICO - Jueves
EXEC actividades.GestionarClase 'Baile artístico', '34567890', 'Jueves 08:00', 'Menor', 'Insertar';
EXEC actividades.GestionarClase 'Baile artístico', '34567890', 'Jueves 14:00', 'Cadete', 'Insertar';
EXEC actividades.GestionarClase 'Baile artístico', '34567890', 'Jueves 19:00', 'Mayor', 'Insertar';

-- NATACIÓN - Viernes
EXEC actividades.GestionarClase 'Natación', '34567890', 'Viernes 08:00', 'Menor', 'Insertar';
EXEC actividades.GestionarClase 'Natación', '34567890', 'Viernes 14:00', 'Cadete', 'Insertar';
EXEC actividades.GestionarClase 'Natación', '34567890', 'Viernes 19:00', 'Mayor', 'Insertar';

-- AJEDREZ - Sábado
EXEC actividades.GestionarClase 'Ajedrez', '34567890', 'Sábado 08:00', 'Menor', 'Insertar';
EXEC actividades.GestionarClase 'Ajedrez', '34567890', 'Sábado 14:00', 'Cadete', 'Insertar';
EXEC actividades.GestionarClase 'Ajedrez', '34567890', 'Sábado 19:00', 'Mayor', 'Insertar';
GO
-- Francisco se inscribe a 3 actividades
EXEC actividades.GestionarInscripcion '45778667', 'Ajedrez', 'Sábado 19:00', 'Mayor', '2025-06-12', 'Insertar';
EXEC actividades.GestionarInscripcion '45778667', 'Futsal', 'Lunes 19:00', 'Mayor', '2025-06-13', 'Insertar';
EXEC actividades.GestionarInscripcion '45778667', 'Taekwondo', 'Miércoles 19:00', 'Mayor', '2025-06-14', 'Insertar';

-- Mariana se inscribe a 1 sola actividad
EXEC actividades.GestionarInscripcion '40505050', 'Baile artístico', 'Jueves 14:00', 'Cadete', '2025-06-12', 'Insertar';

-- Juan se inscribe a 2 actividades
EXEC actividades.GestionarInscripcion '33444555', 'Taekwondo', 'Miércoles 14:00', 'Cadete', '2025-06-13', 'Insertar';
EXEC actividades.GestionarInscripcion '33444555', 'Ajedrez', 'Sábado 14:00', 'Cadete', '2025-06-14', 'Insertar';

-- Camila se inscribe a 1 sola actividad
EXEC actividades.GestionarInscripcion '40606060', 'Natación', 'Viernes 14:00', 'Cadete', '2025-06-15', 'Insertar';

-- Luciano se inscribe a 2 actividades
EXEC actividades.GestionarInscripcion '40707070', 'Vóley', 'Martes 19:00', 'Mayor', '2025-06-12', 'Insertar';
EXEC actividades.GestionarInscripcion '40707070', 'Baile artístico', 'Jueves 19:00', 'Mayor', '2025-06-13', 'Insertar';

-- =================== CARGA DE PRESENTISMO DE SOCIOS ===================

-- Francisco (3 clases)
EXEC actividades.GestionarPresentismoClase 'Ajedrez', '45778667', 'Sábado 19:00', 'Mayor', '2025-06-12', 'P', 'Insertar';
EXEC actividades.GestionarPresentismoClase 'Futsal', '45778667', 'Lunes 19:00', 'Mayor', '2025-06-13', 'A', 'Insertar'; -- Ausente
EXEC actividades.GestionarPresentismoClase 'Taekwondo', '45778667', 'Miércoles 19:00', 'Mayor', '2025-06-14', 'J', 'Insertar'; -- Justificada

-- Mariana (1 clase)
EXEC actividades.GestionarPresentismoClase 'Baile artístico', '40505050', 'Jueves 14:00', 'Cadete', '2025-06-12', 'P', 'Insertar';

-- Juan (2 clases)
EXEC actividades.GestionarPresentismoClase 'Taekwondo', '33444555', 'Miércoles 14:00', 'Cadete', '2025-06-13', 'A', 'Insertar'; -- Ausente
EXEC actividades.GestionarPresentismoClase 'Ajedrez', '33444555', 'Sábado 14:00', 'Cadete', '2025-06-14', 'P', 'Insertar';

-- Camila (1 clase)
EXEC actividades.GestionarPresentismoClase 'Natación', '40606060', 'Viernes 14:00', 'Cadete', '2025-06-15', 'J', 'Insertar'; -- Justificada

-- Luciano (2 clases)
EXEC actividades.GestionarPresentismoClase 'Vóley', '40707070', 'Martes 19:00', 'Mayor', '2025-06-12', 'P', 'Insertar';
EXEC actividades.GestionarPresentismoClase 'Baile artístico', '40707070', 'Jueves 19:00', 'Mayor', '2025-06-13', 'P', 'Insertar';

-- =================== CARGA DE EMISOR DE FACTURA ===================
EXEC facturacion.GestionarEmisorFactura 'Sol del Norte S.A.', '20-12345678-4', 'Av. Presidente Perón 1234', 'Argentina', 'La Matanza', '1234', 'Insertar'

-- =================== GENERACIÓN DE FACTURA MENSUAL ===================
EXEC facturacion.GenerarFacturaSocioMensual '45778667', '20-12345678-4';
EXEC facturacion.GenerarFacturaSocioMensual '33444555', '20-12345678-4';
EXEC facturacion.GenerarFacturaSocioMensual '40707070', '20-12345678-4';

-- =================== CARGA DE ACTIVIDADES EXTRA ===================

-- Insertar actividades extra para invitados
EXEC actividades.GestionarActividadExtra 'Pileta verano', 30000, 'Dia', 'S', '2025-02-28', 'Insertar';
EXEC actividades.GestionarActividadExtra 'Colonia de verano', 30000, 'Dia', 'S', '2025-02-28', 'Insertar';
EXEC actividades.GestionarActividadExtra 'Alquiler de SUM', 30000, 'Dia', 'S', '2025-02-28', 'Insertar';

-- Insertar actividades extra para socios
EXEC actividades.GestionarActividadExtra 'Pileta verano', 25000, 'Dia', 'N', '2025-02-28', 'Insertar';
EXEC actividades.GestionarActividadExtra 'Colonia de verano', 25000, 'Dia', 'N', '2025-02-28', 'Insertar';
EXEC actividades.GestionarActividadExtra 'Alquiler de SUM', 25000, 'Dia', 'N', '2025-02-28', 'Insertar';

EXEC actividades.GestionarActividadExtra 'Pileta verano', 625000, 'Mes', 'N', '2025-02-28', 'Insertar';
EXEC actividades.GestionarActividadExtra 'Colonia de verano', 625000, 'Mes', 'N', '2025-02-28', 'Insertar';
EXEC actividades.GestionarActividadExtra 'Alquiler de SUM', 625000, 'Mes', 'N', '2025-02-28', 'Insertar';

EXEC actividades.GestionarActividadExtra 'Pileta verano', 2000000, 'Temporada', 'N', '2025-02-28', 'Insertar';
EXEC actividades.GestionarActividadExtra 'Colonia de verano', 2000000, 'Temporada', 'N', '2025-02-28', 'Insertar';
EXEC actividades.GestionarActividadExtra 'Alquiler de SUM', 2000000, 'Temporada', 'N', '2025-02-28', 'Insertar';

-- =================== CARGA DE PRESENTISMO DE INVITADOS ===================

-- Francisco (2 actividades, 1 presencia)
EXEC actividades.GestionarPresentismoActividadExtra 'Alquiler de SUM', 'Dia', 'N', '45778667', '2025-03-01', 'P', 'Insertar';
EXEC actividades.GestionarPresentismoActividadExtra 'Pileta verano', 'Dia', 'N', '45778667', '2025-03-05', 'A', 'Insertar'; -- Ausente

-- Mariana (1 actividad, 5 presencias)
EXEC actividades.GestionarPresentismoActividadExtra 'Colonia de verano', 'Temporada', 'N', '40505050', '2025-03-01', 'P', 'Insertar';
EXEC actividades.GestionarPresentismoActividadExtra 'Colonia de verano', 'Temporada', 'N', '40505050', '2025-03-02', 'P', 'Insertar';
EXEC actividades.GestionarPresentismoActividadExtra 'Colonia de verano', 'Temporada', 'N', '40505050', '2025-03-03', 'P', 'Insertar';
EXEC actividades.GestionarPresentismoActividadExtra 'Colonia de verano', 'Temporada', 'N', '40505050', '2025-03-04', 'P', 'Insertar';
EXEC actividades.GestionarPresentismoActividadExtra 'Colonia de verano', 'Temporada', 'N', '40505050', '2025-03-05', 'P', 'Insertar';

-- Luciano (1 actividad, 2 presencias)
EXEC actividades.GestionarPresentismoActividadExtra'Pileta verano', 'Mes', 'N', '40707070', '2025-03-05', 'A', 'Insertar';
EXEC actividades.GestionarPresentismoActividadExtra 'Pileta verano', 'Mes', 'N', '40707070', '2025-03-06', 'P', 'Insertar'; -- Ausente
EXEC actividades.GestionarPresentismoActividadExtra 'Pileta verano', 'Mes', 'N', '40707070', '2025-03-10', 'A', 'Insertar';
EXEC actividades.GestionarPresentismoActividadExtra 'Pileta verano', 'Mes', 'N', '40707070', '2025-03-12', 'P', 'Insertar'; -- Ausente

-- Lucia (2 actividades, 2 presencias)
EXEC actividades.GestionarPresentismoActividadExtra 'Alquiler de SUM', 'Dia', 'S', '46501934', '2025-03-01', 'P', 'Insertar';
EXEC actividades.GestionarPresentismoActividadExtra 'Pileta verano', 'Dia', 'S', '46501934', '2025-03-05', 'P', 'Insertar';

-- =================== GENERACIÓN DE FACTURA INVITADOS ===================
EXEC facturacion.GenerarFacturaInvitado '46501934', '20-12345678-4', 'Alquiler de SUM';
EXEC facturacion.GenerarFacturaInvitado'46501934', '20-12345678-4', 'Pileta verano';

-- =================== VERIFICAR ===================
SELECT * FROM actividades.Clase;
SELECT * FROM actividades.Actividad;
SELECT * FROM actividades.InscriptoClase;
SELECT * FROM actividades.presentismoClase ORDER BY fecha;
SELECT * FROM actividades.ActividadExtra;
SELECT * FROM facturacion.EmisorFactura
SELECT * FROM facturacion.Factura
SELECT * FROM facturacion.DetalleFactura