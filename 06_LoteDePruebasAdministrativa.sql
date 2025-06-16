USE COM2900G13;
GO
SET NOCOUNT ON;

/* ===================== LIMPIEZA COMPLETA ===================== */
DELETE FROM facturacion.Recargo;
DBCC CHECKIDENT ('facturacion.Recargo', RESEED, 0) WITH NO_INFOMSGS;

DELETE FROM cobranzas.Mora;
DBCC CHECKIDENT ('cobranzas.Mora', RESEED, 0) WITH NO_INFOMSGS;


DELETE FROM cobranzas.Pago;
DBCC CHECKIDENT ('cobranzas.Pago', RESEED, 0) WITH NO_INFOMSGS;

DELETE FROM cobranzas.MedioDePago;
DBCC CHECKIDENT ('cobranzas.MedioDePago', RESEED, 0) WITH NO_INFOMSGS;

DELETE FROM actividades.presentismoActividadExtra;
DBCC CHECKIDENT ('actividades.presentismoActividadExtra', RESEED, 0) WITH NO_INFOMSGS;
DELETE FROM actividades.presentismoClase;
DBCC CHECKIDENT ('actividades.presentismoClase', RESEED, 0) WITH NO_INFOMSGS;

DELETE FROM actividades.InscriptoClase;
DBCC CHECKIDENT ('actividades.InscriptoClase', RESEED, 0) WITH NO_INFOMSGS;
DELETE FROM actividades.Clase;
DBCC CHECKIDENT ('actividades.Clase', RESEED, 0) WITH NO_INFOMSGS;

DELETE FROM cobranzas.DebitoAutomaticoSocio;


DELETE FROM cobranzas.PagoACuenta;
DBCC CHECKIDENT ('cobranzas.PagoACuenta', RESEED, 0) WITH NO_INFOMSGS;
DELETE FROM cobranzas.NotaDeCredito;
DBCC CHECKIDENT ('cobranzas.NotaDeCredito', RESEED, 0) WITH NO_INFOMSGS;

--DELETE FROM cobranzas.DebitoAutomaticoSocio;
DELETE FROM facturacion.DetalleFactura;
DBCC CHECKIDENT ('facturacion.DetalleFactura', RESEED, 0) WITH NO_INFOMSGS;
DELETE FROM facturacion.Factura;
DBCC CHECKIDENT ('facturacion.Factura', RESEED, 0) WITH NO_INFOMSGS;

DELETE FROM facturacion.EmisorFactura;
DBCC CHECKIDENT ('facturacion.EmisorFactura', RESEED, 0) WITH NO_INFOMSGS;
DELETE FROM actividades.presentismoActividadExtra;
DBCC CHECKIDENT ('actividades.presentismoActividadExtra', RESEED, 0) WITH NO_INFOMSGS;
DELETE FROM actividades.presentismoClase;
DBCC CHECKIDENT ('actividades.presentismoClase', RESEED, 0) WITH NO_INFOMSGS;
DELETE FROM actividades.InscriptoClase;
DBCC CHECKIDENT ('actividades.InscriptoClase', RESEED, 0) WITH NO_INFOMSGS;
DELETE FROM actividades.ActividadExtra;
DBCC CHECKIDENT ('actividades.ActividadExtra', RESEED, 0) WITH NO_INFOMSGS;
DELETE FROM actividades.Clase;
DBCC CHECKIDENT ('actividades.Clase', RESEED, 0) WITH NO_INFOMSGS;
DELETE FROM actividades.Actividad;
DBCC CHECKIDENT ('actividades.Actividad', RESEED, 0) WITH NO_INFOMSGS;
DELETE FROM administracion.Invitado;
DBCC CHECKIDENT ('administracion.Invitado', RESEED, 0) WITH NO_INFOMSGS;
DELETE FROM administracion.GrupoFamiliar;
DBCC CHECKIDENT ('administracion.GrupoFamiliar', RESEED, 0) WITH NO_INFOMSGS;
DELETE FROM administracion.Socio;
DBCC CHECKIDENT ('administracion.Socio', RESEED, 0) WITH NO_INFOMSGS;
DELETE FROM administracion.Profesor;
DBCC CHECKIDENT ('administracion.Profesor', RESEED, 0) WITH NO_INFOMSGS;
DELETE FROM administracion.Persona;
DBCC CHECKIDENT ('administracion.Persona', RESEED, 0) WITH NO_INFOMSGS;
DELETE FROM cobranzas.NotaDeCredito;
DBCC CHECKIDENT ('cobranzas.NotaDeCredito', RESEED, 0) WITH NO_INFOMSGS;
DELETE FROM administracion.Socio;
DBCC CHECKIDENT ('administracion.Socio', RESEED, 0) WITH NO_INFOMSGS;
DELETE FROM administracion.CategoriaSocio;
DBCC CHECKIDENT ('administracion.CategoriaSocio', RESEED, 0) WITH NO_INFOMSGS;
GO

/* ===================== INSERTAR PERSONAS BASE ===================== */
EXEC administracion.GestionarPersona 'Tomas', 'Borja', '55666777', 'tomas.borja@email.com', '2024-10-25', 'Av. San Martin 3200', '1234227890', '0987658821', 'Insertar';
EXEC administracion.GestionarPersona 'Jose', 'Suarez', '99888777', 'jose.suarez@email.com', '1965-10-25', 'Av. San Martin 3499', '1234567990', '0987699321', 'Insertar';
GO

/* ===================== INSERTAR CATEGORÍAS ===================== */
EXEC administracion.GestionarCategoriaSocio 'Menor', 0, 12, 10000, '2025-12-31', 'Insertar';
EXEC administracion.GestionarCategoriaSocio 'Cadete', 13, 17, 15000, '2025-12-31', 'Insertar';
EXEC administracion.GestionarCategoriaSocio 'Mayor', 18, 150, 25000, '2025-12-31', 'Insertar';
GO

/* ===================== INSERTAR SOCIOS ===================== */
EXEC administracion.GestionarSocio 'Francisco', 'Vignardel', '45778667', 'francisco.vignardel@email.com', '2004-04-10', 'Av. Gral. Mosconi 2345', '1231233234', '6624324321', 'Mayor', 'SOC1002', 'OSPOCE', '654321', 0, 'Insertar';
EXEC administracion.GestionarSocio 'Juan', 'Perez', '33444555', 'juan.perez@email.com', '2004-04-10', 'Av. Crovara 2345', '3331233234', '6624324388', 'Cadete', 'SOC1003', 'VITA', '654331', 0, 'Insertar';
EXEC administracion.GestionarSocio 'Mariana', 'Vignardel', '40505050', 'mariana.vignardel@email.com', '2012-09-12', 'Av. Gral. Mosconi 2345', '1112223333', '4445556666', 'Cadete', 'SOC1004', 'OSPOCE', '987654', 0, 'Insertar';
EXEC administracion.GestionarSocio 'Camila', 'Perez', '40606060', 'camila.perez@email.com', '2010-11-25', 'Av. Crovara 2345', '2223334444', '7778889999', 'Cadete', 'SOC1005', 'VITA', '112233', 0, 'Insertar';
EXEC administracion.GestionarSocio 'Luciano', 'Costa', '40707070', 'luciano.costa@email.com', '1995-05-15', 'Calle Falsa 123', '5556667777', '1112223333', 'Mayor','SOC1006','OSDE', '445566', 0, 'Insertar';
GO

/* ===================== INSERTAR PROFESOR ===================== */
EXEC administracion.GestionarProfesor 'Ana', 'García', '34567890', 'ana.garcia@email.com', '1990-08-15', 'Av. Urquiza 8392', '1112223333', '3332221111', 'Insertar';
GO

/* ===================== INSERTAR INVITADO ===================== */
EXEC administracion.GestionarInvitado '45778667', '46501934', 'Lucia', 'De Titto', 'Mayor', 'ldetitto10@email.com', 'Av. Crovara 2345', 'Insertar';
GO

/* ===================== GRUPOS FAMILIARES ===================== */
EXEC administracion.GestionarGrupoFamiliar '40505050', '45778667', 'Insertar';
EXEC administracion.GestionarGrupoFamiliar '40606060', '33444555', 'Insertar';
GO

/* ===================== VERIFICACIÓN FINAL ===================== */
SELECT * FROM administracion.Persona;
SELECT * FROM administracion.Socio;
SELECT * FROM administracion.CategoriaSocio;
SELECT * FROM administracion.Profesor;
SELECT * FROM administracion.Invitado;
SELECT * FROM administracion.GrupoFamiliar;

SELECT * FROM administracion.vwSociosConCategoria ORDER BY apellido, nombre;
SELECT * FROM administracion.vwSociosConObraSocial ORDER BY apellido, nombre;
