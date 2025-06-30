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

-- ================== LIMPIEZA DE FACTURACIÓN ==================

DELETE FROM cobranzas.pago
DBCC CHECKIDENT ('cobranzas.pago', RESEED, 0) WITH NO_INFOMSGS;
DELETE FROM cobranzas.MedioDePago;
DBCC CHECKIDENT ('cobranzas.MedioDePago', RESEED, 0) WITH NO_INFOMSGS;
DELETE FROM facturacion.DetalleFactura;
DELETE FROM facturacion.Factura;
DBCC CHECKIDENT ('facturacion.DetalleFactura', RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('facturacion.Factura', RESEED, 0) WITH NO_INFOMSGS;

-- ================== LIMPIEZA DE ACTIVIDADES ==================
DELETE FROM actividades.PresentismoClase;
DELETE FROM facturacion.CuotaMensual;
DELETE FROM facturacion.CargoClases; -- primero borrar cargos
DELETE FROM facturacion.CuotaMensual;
DELETE FROM facturacion.CargoActividadExtra;
DELETE FROM actividades.InscriptoClase;
DELETE FROM actividades.Clase;
DELETE FROM actividades.Actividad;

DBCC CHECKIDENT ('facturacion.CargoClases', RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('facturacion.CargoActividadExtra', RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('actividades.InscriptoClase', RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('actividades.Clase', RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('actividades.Actividad', RESEED, 0) WITH NO_INFOMSGS;

-- ================== LIMPIEZA DE EMISOR Y TARIFAS ==================
DELETE FROM facturacion.EmisorFactura;
DBCC CHECKIDENT ('facturacion.EmisorFactura', RESEED, 0) WITH NO_INFOMSGS;

-- Borrar actividad regular y sus relaciones
DELETE FROM actividades.presentismoClase;
DELETE FROM actividades.InscriptoClase;
DELETE FROM actividades.Clase;
DELETE FROM actividades.Actividad;
DELETE FROM actividades.InscriptoColoniaVerano
DELETE FROM actividades.InscriptoPiletaVerano
DELETE FROM reservas.ReservaSum
DBCC CHECKIDENT ('actividades.presentismoClase', RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('actividades.InscriptoClase', RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('actividades.Clase', RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('actividades.Actividad', RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('actividades.InscriptoColoniaVerano', RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('actividades.InscriptoPiletaVerano', RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('reservas.ReservaSum', RESEED, 0) WITH NO_INFOMSGS;

DELETE FROM tarifas.TarifaColoniaVerano;
DELETE FROM tarifas.TarifaPiletaVerano;
DELETE FROM tarifas.TarifaReservaSum;
DBCC CHECKIDENT ('tarifas.TarifaColoniaVerano', RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('tarifas.TarifaPiletaVerano', RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('tarifas.TarifaReservaSum', RESEED, 0) WITH NO_INFOMSGS;

-- Insertar actividades base (sin horarios)
EXEC actividades.GestionarActividad 'Futsal', 25000, '2025-05-31', 'Insertar';
EXEC actividades.GestionarActividad 'Vóley', 30000, '2025-05-31', 'Insertar';
EXEC actividades.GestionarActividad 'Taekwondo', 25000, '2025-05-31', 'Insertar';
EXEC actividades.GestionarActividad 'Baile artístico', 30000, '2025-05-31', 'Insertar';
EXEC actividades.GestionarActividad 'Natación', 45000, '2025-05-31', 'Insertar';
EXEC actividades.GestionarActividad 'Ajedrez', 2000, '2025-05-31', 'Insertar';
GO

-- Insertar tarifas de actividades extra
EXEC tarifas.GestionarTarifaPiletaVerano 'Mayor', '0', 25000, '2025-09-25', 'Insertar'
EXEC tarifas.GestionarTarifaPiletaVerano 'Mayor', '1', 30000, '2025-09-25', 'Insertar'
EXEC tarifas.GestionarTarifaPiletaVerano 'Menor', '0', 15000, '2025-09-25', 'Insertar'
EXEC tarifas.GestionarTarifaPiletaVerano 'Menor', '1', 2000, '2025-09-25', 'Insertar'
GO

EXEC tarifas.GestionarTarifaReservaSum 25000, '2025-09-25', 'Insertar'
GO

EXEC tarifas.GestionarTarifaColoniaVerano 'Mayor', 'Dia', 25000, '2025-09-25', 'Insertar'
EXEC tarifas.GestionarTarifaColoniaVerano 'Menor', 'Dia', 15000, '2025-09-25','Insertar'
EXEC tarifas.GestionarTarifaColoniaVerano 'Mayor', 'Mes', 625000, '2025-09-25', 'Insertar'
EXEC tarifas.GestionarTarifaColoniaVerano 'Menor', 'Mes', 375000, '2025-09-25','Insertar'
EXEC tarifas.GestionarTarifaColoniaVerano 'Mayor', 'Temporada', 2000000, '2025-09-25','Insertar'
EXEC tarifas.GestionarTarifaColoniaVerano 'Menor', 'Temporada', 1200000, '2025-09-25', 'Insertar'
GO
-- FUTSAL - Lunes
EXEC actividades.GestionarClase 'Futsal', 'Gabriel', 'Mirabelli', 'Lunes 08:00', 'Menor', 'Insertar';
EXEC actividades.GestionarClase 'Futsal', 'Jair', 'Hnatiuk', 'Lunes 14:00', 'Cadete', 'Insertar';
EXEC actividades.GestionarClase 'Futsal', 'Valeria', 'De Rosa', 'Lunes 19:00', 'Mayor', 'Insertar';
GO
-- Vóley - Martes
EXEC actividades.GestionarClase 'Vóley', 'Nestor', 'Pan', 'Martes 08:00', 'Menor', 'Insertar';
EXEC actividades.GestionarClase 'Vóley', 'Matias', 'Mendoza', 'Martes 14:00', 'Cadete', 'Insertar';
EXEC actividades.GestionarClase 'Vóley', 'Nestor', 'Pan', 'Martes 19:00', 'Mayor', 'Insertar';
GO
-- TAEKWONDO - Miércoles
EXEC actividades.GestionarClase 'Taekwondo', 'Gabriel', 'Mirabelli', 'Miércoles 08:00', 'Menor', 'Insertar';
EXEC actividades.GestionarClase 'Taekwondo', 'Nestor', 'Pan', 'Miércoles 14:00', 'Cadete', 'Insertar';
EXEC actividades.GestionarClase 'Taekwondo', 'Nestor', 'Pan', 'Miércoles 19:00', 'Mayor', 'Insertar';
GO
-- BAILE artístico - Jueves
EXEC actividades.GestionarClase 'Baile artístico', 'Valeria', 'De Rosa', 'Jueves 08:00', 'Menor', 'Insertar';
EXEC actividades.GestionarClase 'Baile artístico', 'Valeria', 'De Rosa', 'Jueves 14:00', 'Cadete', 'Insertar';
EXEC actividades.GestionarClase 'Baile artístico', 'Valeria', 'De Rosa', 'Jueves 19:00', 'Mayor', 'Insertar';
GO
-- Natación - Viernes
EXEC actividades.GestionarClase 'Natación', 'Matias', 'Mendoza', 'Viernes 08:00', 'Menor', 'Insertar';
EXEC actividades.GestionarClase 'Natación', 'Jair', 'Hnatiuk', 'Viernes 14:00', 'Cadete', 'Insertar';
EXEC actividades.GestionarClase 'Natación', 'Matias', 'Mendoza', 'Viernes 19:00', 'Mayor', 'Insertar';
GO
-- AJEDREZ - Sábado
EXEC actividades.GestionarClase 'Ajedrez', 'Jair', 'Hnatiuk', 'Sábado 08:00', 'Menor', 'Insertar';
EXEC actividades.GestionarClase 'Ajedrez', 'Matias', 'Mendoza', 'Sábado 14:00', 'Cadete', 'Insertar';
EXEC actividades.GestionarClase 'Ajedrez', 'Gabriel', 'Mirabelli', 'Sábado 19:00', 'Mayor', 'Insertar';
GO

/* ==========================================================
   INSCRIPCIÓN DE SOCIOS A CLASES
========================================================== */
-- FRANCISCO (45778667) - Mayor
EXEC actividades.GestionarInscriptoClase '45778667', 'Futsal',     'Lunes 19:00',      'Mayor', '2025-06-13', 'Insertar';
EXEC actividades.GestionarInscriptoClase '45778667', 'Taekwondo',  'Miércoles 19:00',  'Mayor', '2025-06-14', 'Insertar';
EXEC actividades.GestionarInscriptoClase '45778667', 'Ajedrez',    'Sábado 19:00',     'Mayor', '2025-06-15', 'Insertar';
GO

-- JUAN (33444555) - Cadete
EXEC actividades.GestionarInscriptoClase '33444555', 'Taekwondo',  'Miércoles 14:00',  'Cadete', '2025-06-13', 'Insertar';
EXEC actividades.GestionarInscriptoClase '33444555', 'Ajedrez',    'Sábado 14:00',     'Cadete', '2025-06-14', 'Insertar';
GO

-- CAMILA (40606060) - Menor (pero le ponés Cadete, verificado a propósito)
EXEC actividades.GestionarInscriptoClase '40606060', 'Natación',   'Viernes 14:00',    'Cadete', '2025-06-15', 'Insertar';
GO

-- PEDRO (41111111) - Mayor
EXEC actividades.GestionarInscriptoClase '41111111', 'Vóley',      'Martes 19:00',     'Mayor',  '2025-06-10', 'Insertar';
GO

-- JULIÁN (41111112) - Cadete
EXEC actividades.GestionarInscriptoClase '41111112', 'Futsal',     'Lunes 14:00',      'Cadete', '2025-06-11', 'Insertar';
GO

-- ANDREA (42222222) - Mayor
EXEC actividades.GestionarInscriptoClase '42222222', 'Baile artístico', 'Jueves 19:00',  'Mayor',  '2025-06-12', 'Insertar';
GO

-- SOFÍA (42222223) - Menor
EXEC actividades.GestionarInscriptoClase '42222223', 'Baile artístico', 'Jueves 08:00',  'Menor',  '2025-06-10', 'Insertar';
GO

-- VALENTÍN (43333334) - Menor
EXEC actividades.GestionarInscriptoClase '43333334', 'Taekwondo',  'Miércoles 08:00',  'Menor',  '2025-06-13', 'Insertar';
GO

-- EMILIA (44444444) - Menor
EXEC actividades.GestionarInscriptoClase '44444444', 'Natación',   'Viernes 08:00',    'Menor',  '2025-06-14', 'Insertar';
GO

/* ==========================================================
   INSCRIPCIÓN DE SOCIOS E INVITADOS A ACTIVIDADES EXTRA
   ========================================================== */
EXEC actividades.GestionarInscriptoPiletaVerano '45778667', NULL, NULL, NULL, NULL, NULL, NULL, '2025-06-15', 'Insertar';
EXEC actividades.GestionarInscriptoPiletaVerano '33444555', NULL, NULL, NULL, NULL, NULL, NULL, '2025-06-20', 'Insertar';
EXEC actividades.GestionarInscriptoPiletaVerano '45778667', '55500001', 'Lucas', 'Gonzalez', 'Menor', 'lucas.gonzalez@mail.com', 'Calle Falsa 100', '2025-06-25', 'Insertar';
GO

EXEC actividades.GestionarInscriptoColonia '45778667', 'Mayor', 'Mes','2025-06-10', 'Insertar';
EXEC actividades.GestionarInscriptoColonia '42222223', 'Menor', 'Temporada', '2025-06-12', 'Insertar';
GO

EXEC actividades.GestionarReservaSum '45778667', '2025-06-05', '10:00', '13:00', 'Insertar';
EXEC actividades.GestionarReservaSum '42222222', '2025-06-07', '15:00', '18:00', 'Insertar';
GO

-- =================== CARGA DE EMISOR DE FACTURA ===================
EXEC facturacion.GestionarEmisorFactura 'Sol del Norte S.A.', '20-12345678-4', 'Av. Presidente Per�n 1234', 'Argentina', 'La Matanza', '1234', 'Insertar'
GO
-- FRANCISCO (45778667) - Mayor
EXEC actividades.GestionarPresentismoClase '45778667', 'Futsal',    'Lunes 19:00', 'Mayor', '2025-06-17', 'P', 'Insertar';
EXEC actividades.GestionarPresentismoClase '45778667', 'Futsal',    'Lunes 19:00', 'Mayor', '2025-06-24', 'A', 'Insertar';
EXEC actividades.GestionarPresentismoClase '45778667', 'Taekwondo', 'Miércoles 19:00', 'Mayor', '2025-06-19', 'J', 'Insertar';
EXEC actividades.GestionarPresentismoClase '45778667', 'Ajedrez',   'Sábado 19:00', 'Mayor', '2025-06-22', 'P', 'Insertar';
GO

-- JUAN (33444555) - Cadete
EXEC actividades.GestionarPresentismoClase '33444555', 'Taekwondo', 'Miércoles 14:00', 'Cadete', '2025-06-19', 'A', 'Insertar';
EXEC actividades.GestionarPresentismoClase '33444555', 'Ajedrez',   'Sábado 14:00', 'Cadete', '2025-06-22', 'P', 'Insertar';
EXEC actividades.GestionarPresentismoClase '33444555', 'Ajedrez',   'Sábado 14:00', 'Cadete', '2025-06-29', 'J', 'Insertar';
GO

-- CAMILA (40606060) - Cadete
EXEC actividades.GestionarPresentismoClase '40606060', 'Natación', 'Viernes 14:00', 'Cadete', '2025-06-21', 'P', 'Insertar';
EXEC actividades.GestionarPresentismoClase '40606060', 'Natación', 'Viernes 14:00', 'Cadete', '2025-06-28', 'A', 'Insertar';
GO

-- PEDRO (41111111) - Mayor
EXEC actividades.GestionarPresentismoClase '41111111', 'Vóley', 'Martes 19:00', 'Mayor', '2025-06-18', 'P', 'Insertar';
EXEC actividades.GestionarPresentismoClase '41111111', 'Vóley', 'Martes 19:00', 'Mayor', '2025-06-25', 'J', 'Insertar';
GO

-- JULIÁN (41111112) - Cadete
EXEC actividades.GestionarPresentismoClase '41111112', 'Futsal', 'Lunes 14:00', 'Cadete', '2025-06-17', 'A', 'Insertar';
EXEC actividades.GestionarPresentismoClase '41111112', 'Futsal', 'Lunes 14:00', 'Cadete', '2025-06-24', 'P', 'Insertar';
GO

-- ANDREA (42222222) - Mayor
EXEC actividades.GestionarPresentismoClase '42222222', 'Baile artístico', 'Jueves 19:00', 'Mayor', '2025-06-20', 'P', 'Insertar';
EXEC actividades.GestionarPresentismoClase '42222222', 'Baile artístico', 'Jueves 19:00', 'Mayor', '2025-06-27', 'J', 'Insertar';
GO

-- SOFÍA (42222223) - Menor
EXEC actividades.GestionarPresentismoClase '42222223', 'Baile artístico', 'Jueves 08:00', 'Menor', '2025-06-20', 'A', 'Insertar';
EXEC actividades.GestionarPresentismoClase '42222223', 'Baile artístico', 'Jueves 08:00', 'Menor', '2025-06-27', 'P', 'Insertar';
GO

-- VALENTÍN (43333334) - Menor
EXEC actividades.GestionarPresentismoClase '43333334', 'Taekwondo', 'Miércoles 08:00', 'Menor', '2025-06-19', 'P', 'Insertar';
EXEC actividades.GestionarPresentismoClase '43333334', 'Taekwondo', 'Miércoles 08:00', 'Menor', '2025-06-26', 'J', 'Insertar';
GO

-- EMILIA (44444444) - Menor
EXEC actividades.GestionarPresentismoClase '44444444', 'Natación', 'Viernes 08:00', 'Menor', '2025-06-21', 'A', 'Insertar';
EXEC actividades.GestionarPresentismoClase '44444444', 'Natación', 'Viernes 08:00', 'Menor', '2025-06-28', 'P', 'Insertar';
GO

-- =================== CARGA DE CARGO DE CLASES ===================

-- FRANCISCO (45778667)
EXEC facturacion.GenerarCargoClase '45778667', '2025-06-17'; -- Futsal - P
EXEC facturacion.GenerarCargoClase '45778667', '2025-06-22'; -- Ajedrez - P
GO

-- JUAN (33444555)
EXEC facturacion.GenerarCargoClase '33444555', '2025-06-22'; -- Ajedrez - P
GO

-- CAMILA (40606060)
EXEC facturacion.GenerarCargoClase '40606060', '2025-06-21'; -- Natación - P
GO

-- PEDRO (41111111)
EXEC facturacion.GenerarCargoClase '41111111', '2025-06-18'; -- Vóley - P
GO

-- JULIÁN (41111112)
EXEC facturacion.GenerarCargoClase '41111112', '2025-06-24'; -- Futsal - P
GO

-- ANDREA (42222222)
EXEC facturacion.GenerarCargoClase '42222222', '2025-06-20'; -- Baile artístico - P
GO

-- SOFÍA (42222223)
EXEC facturacion.GenerarCargoClase '42222223', '2025-06-27'; -- Baile artístico - P
GO

-- VALENTÍN (43333334)
EXEC facturacion.GenerarCargoClase '43333334', '2025-06-19'; -- Taekwondo - P
GO

-- EMILIA (44444444)
EXEC facturacion.GenerarCargoClase '44444444', '2025-06-28'; -- Natación - P
GO

EXEC facturacion.GenerarCuotasMensualesPorFecha '2025-06-30';
GO

EXEC facturacion.GenerarCargosActividadExtraPorFecha '2025-06-30';
GO

EXEC facturacion.GenerarFacturasMensualesPorFecha '2025-06-30';
GO

EXEC facturacion.GenerarFacturasActividadesExtraPorFecha '2025-06-30';
GO

/*
-- =================== GENERACI�N DE FACTURA MENSUAL ===================
EXEC facturacion.GenerarFacturaCuotasMensualesPorFecha '45778667', '20-12345678-4';
EXEC facturacion.GenerarFacturaSocioMensual '33444555', '20-12345678-4';
EXEC facturacion.GenerarFacturaSocioMensual '40707070', '20-12345678-4';
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

-- =================== GENERACI�N DE FACTURA SOCIOS ===================
EXEC facturacion.GenerarFacturaSocioActExtra '45778667', '20-12345678-4', 'Alquiler de SUM', '2025-06-01';
EXEC facturacion.GenerarFacturaSocioActExtra '45778667', '20-12345678-4', 'Pileta verano', '2025-06-01';
EXEC facturacion.GenerarFacturaSocioActExtra '40505050', '20-12345678-4', 'Colonia de verano', '2025-06-01';
EXEC facturacion.GenerarFacturaSocioActExtra '40707070', '20-12345678-4', 'Pileta verano', '2025-06-01';
GO
*/
-- =================== VERIFICAR ===================

-- ACTIVIDADES
SELECT id_actividad, nombre, costo, vigencia
FROM actividades.Actividad;

SELECT id_clase, id_actividad, nombre_profesor, apellido_profesor, id_categoria, horario
FROM actividades.Clase;

SELECT id_socio, id_clase, fecha_inscripcion
FROM actividades.InscriptoClase;

SELECT id_presentismo, id_socio, id_clase, fecha, estado
FROM actividades.presentismoClase
ORDER BY fecha;

-- Para debug
SELECT *
FROM tarifas.TarifaColoniaVerano

SELECT *
FROM tarifas.TarifaPiletaVerano

SELECT *
FROM tarifas.TarifaReservaSum

SELECT *
FROM actividades.InscriptoColoniaVerano

SELECT *
FROM actividades.InscriptoPiletaVerano

SELECT *
FROM reservas.ReservaSum

SELECT *
FROM facturacion.CargoClases

SELECT *
FROM facturacion.CuotaMensual

SELECT *
FROM facturacion.CargoActividadExtra

SELECT * FROM socios.GrupoFamiliar
SELECT * FROM socios.Tutor
SELECT *
FROM facturacion.vw_FacturasDetalladasConResponsables
ORDER BY id_factura ASC
GO

SELECT *
FROM facturacion.Factura

SELECT *
FROM facturacion.DetalleFactura

/*
SELECT id_extra, , costo, periodo, categoria, es_invitado, vigencia
FROM actividades.ActividadExtra;

SELECT id_extra, id_socio, id_invitado, fecha, condicion
FROM actividades.presentismoActividadExtra
ORDER BY fecha;

-- FACTURACIÓN
SELECT id_emisor, razon_social, cuil, direccion, pais, localidad, codigo_postal
FROM facturacion.EmisorFactura;

SELECT id_factura, id_emisor, id_socio, id_invitado, leyenda, monto_total, saldo_anterior, fecha_emision, fecha_vencimiento1, fecha_vencimiento2, estado, anulada
FROM facturacion.Factura;

SELECT id_detalle, id_factura, id_actividad, id_extra, id_categoria, tipo_item, descripcion, monto, cantidad
FROM facturacion.DetalleFactura;

-- Vista
SELECT 
    id_factura,
    socio_facturado,
    id_socio_responsable,
    dni_responsable,
    nombre_responsable,
    apellido_responsable,
    monto_total,
    estado,
    fecha_emision,
    fecha_vencimiento1,
    fecha_vencimiento2
FROM facturacion.vwResponsablesDeFactura
ORDER BY fecha_emision DESC;
*/
-- ADMINISTRACIÓN (vista ya detallada antes)
/*
SELECT 
    dni, nombre, apellido, fecha_nacimiento, email, id_socio, saldo, 
    categoria, costo_membresia, vigencia
FROM administracion.vwSociosConCategoria
ORDER BY apellido, nombre;
*/