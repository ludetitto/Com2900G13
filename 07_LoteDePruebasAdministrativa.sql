/* =========================================================================
   Trabajo Práctico Integrador - Bases de Datos Aplicadas
   Grupo N°: 13
   Comisión: 2900
   Fecha de Entrega: 17/06/2025
   Materia: Bases de Datos Aplicadas
   Alumnos: Vignardel Francisco              45778667
            De Titto Lucia                   46501934
            Borja Tomas                      42353302
            Rodriguez Sebastián Ezequiel     41691928

   Objetivo: Testing en bloque.
 ========================================================================= */

USE COM2900G13;
GO
SET NOCOUNT ON;

/* ==========================================================
   LIMPIEZA COMPLETA DE TABLAS SOCIOS Y GRUPOS FAMILIARES
========================================================== */

DELETE FROM cobranzas.Reembolso
DBCC CHECKIDENT ('cobranzas.Reembolso', RESEED, 0) WITH NO_INFOMSGS;

DELETE FROM cobranzas.PagoACuenta
DBCC CHECKIDENT ('cobranzas.PagoACuenta', RESEED, 0) WITH NO_INFOMSGS;

DELETE FROM cobranzas.Mora
DBCC CHECKIDENT ('cobranzas.Mora', RESEED, 0) WITH NO_INFOMSGS;

DELETE FROM cobranzas.Pago
DBCC CHECKIDENT ('cobranzas.pago', RESEED, 0) WITH NO_INFOMSGS;

DELETE FROM cobranzas.MedioDePago;
DBCC CHECKIDENT ('cobranzas.MedioDePago', RESEED, 0) WITH NO_INFOMSGS;

DELETE FROM facturacion.DetalleFactura;
DBCC CHECKIDENT ('facturacion.DetalleFactura', RESEED, 0) WITH NO_INFOMSGS;

DELETE FROM facturacion.Factura;
DBCC CHECKIDENT ('facturacion.Factura', RESEED, 0) WITH NO_INFOMSGS;

DELETE FROM facturacion.CuotaMensual;
DBCC CHECKIDENT ('facturacion.CuotaMensual', RESEED, 0);

-- 1. Presentismo y clases
DELETE FROM actividades.PresentismoClase;
DBCC CHECKIDENT ('actividades.PresentismoClase', RESEED, 0);

DELETE FROM facturacion.CargoClases;
DBCC CHECKIDENT ('facturacion.CargoClases', RESEED, 0);

DELETE FROM actividades.InscriptoClase;
DBCC CHECKIDENT ('actividades.InscriptoClase', RESEED, 0);

DELETE FROM actividades.Clase;
DBCC CHECKIDENT ('actividades.Clase', RESEED, 0);

-- 3. Inscripciones a categorías
DELETE FROM actividades.InscriptoCategoriaSocio;
DBCC CHECKIDENT ('actividades.InscriptoCategoriaSocio', RESEED, 0);

-- 4. Grupo Familiar - relaciones y tutores
DELETE FROM socios.GrupoFamiliarSocio;
DELETE FROM socios.Tutor;
DBCC CHECKIDENT ('socios.Tutor', RESEED, 0);

-- 5. Grupos familiares
DELETE FROM socios.GrupoFamiliar;
DBCC CHECKIDENT ('socios.GrupoFamiliar', RESEED, 0);

-- 6. Socios
DELETE FROM socios.Socio;
DBCC CHECKIDENT ('socios.Socio', RESEED, 0);

-- 7. Categorías de socio
DELETE FROM socios.CategoriaSocio;
DBCC CHECKIDENT ('socios.CategoriaSocio', RESEED, 0);

GO

/* ==========================================================
   CATEGORÍAS BASE
========================================================== */
EXEC socios.GestionarCategoriaSocio 'Menor', 0, 12, 10000, '2025-12-31', 'Insertar';
GO
EXEC socios.GestionarCategoriaSocio 'Cadete', 13, 17, 15000, '2025-12-31', 'Insertar';
GO
EXEC socios.GestionarCategoriaSocio 'Mayor', 18, 99, 25000, '2025-12-31', 'Insertar';
GO

/* ==========================================================
   SOCIOS BASE INDIVIDUALES
========================================================== */
EXEC socios.GestionarSocio 
    @nombre = 'Francisco', @apellido = 'Vignardel', @dni = '45778667',
    @email = 'francisco.vignardel@email.com', @fecha_nacimiento = '2004-04-10',
    @telefono = '1231233234', @telefono_emergencia = '6624324321',
    @domicilio = 'Av. Mosconi 2345', @obra_social = 'OSPOCE', @nro_os = '654321',
	@nro_socio = 'S4001',
    @es_responsable = 1, @operacion = 'Insertar';
GO

EXEC socios.GestionarSocio 
    @nombre = 'Juan', @apellido = 'Perez', @dni = '33444555',
    @email = 'juan.perez@email.com', @fecha_nacimiento = '2008-04-10',
    @telefono = '3331233234', @telefono_emergencia = '6624324388',
    @domicilio = 'Av. Crovara 2345', @obra_social = 'VITA', @nro_os = '654331',
    @dni_integrante_grupo = '45778667', @es_responsable = 0, @operacion = 'Insertar';
GO

EXEC socios.GestionarSocio 
    @nombre = 'Camila', @apellido = 'Sosa', @dni = '40606060',
    @email = 'camila.sosa@email.com', @fecha_nacimiento = '2015-09-12',
    @telefono = '1112221111', @telefono_emergencia = '9999999999',
    @domicilio = 'Calle Falsa 123', @obra_social = 'IOMA', @nro_os = '123123',
    @nombre_tutor = 'Lucía', @apellido_tutor = 'Gómez', @dni_tutor = '50000000',
    @email_tutor = 'lucia.tutor@email.com', @fecha_nac_tutor = '1980-10-10',
    @telefono_tutor = '1133224455', @relacion_tutor = 'Madre',
    @domicilio_tutor = 'Calle Falsa 123', @es_responsable = 0, @operacion = 'Insertar';
GO

/* ==========================================================
   GRUPOS FAMILIARES (PASO A PASO)
========================================================== */
EXEC socios.GestionarSocio 
    @nombre = 'Pedro', @apellido = 'Lopez', @dni = '41111111',
    @email = 'pedro.lopez@email.com', @fecha_nacimiento = '1985-01-01',
    @telefono = '1111111111', @telefono_emergencia = '2222222222',
    @domicilio = 'Calle Uno 111', @obra_social = 'Swiss Medical', @nro_os = 'OS111',
    @es_responsable = 1, @operacion = 'Insertar';
GO

EXEC socios.GestionarSocio 
    @nombre = 'Julián', @apellido = 'Lopez', @dni = '41111112',
    @email = 'julian.lopez@email.com', @fecha_nacimiento = '2009-03-03',
    @telefono = '2223334444', @telefono_emergencia = '3334445555',
    @domicilio = 'Calle Uno 111', @obra_social = 'Swiss Medical', @nro_os = 'OS112',
    @dni_integrante_grupo = '41111111', @es_responsable = 0, @operacion = 'Insertar';
GO

EXEC socios.GestionarSocio 
    @nombre = 'Andrea', @apellido = 'Martínez', @dni = '42222222',
    @email = 'andrea.martinez@email.com', @fecha_nacimiento = '1980-07-20',
    @telefono = '9998887777', @telefono_emergencia = '6665554444',
    @domicilio = 'Calle Dos 222', @obra_social = 'OSDE', @nro_os = 'OS222',
    @es_responsable = 1, @operacion = 'Insertar';
GO

EXEC socios.GestionarSocio 
    @nombre = 'Sofía', @apellido = 'Martínez', @dni = '42222223',
    @email = 'sofia.martinez@email.com', @fecha_nacimiento = '2013-06-01',
    @telefono = '1113335555', @telefono_emergencia = '4445556666',
    @domicilio = 'Calle Dos 222', @obra_social = 'OSDE', @nro_os = 'OS223',
    @dni_integrante_grupo = '42222222', @es_responsable = 0, @operacion = 'Insertar';
GO

EXEC socios.GestionarSocio 
    @nombre = 'Valentín', @apellido = 'Ruiz', @dni = '43333334',
    @email = 'valentin.ruiz@email.com', @fecha_nacimiento = '2016-05-22',
    @telefono = '1231231234', @telefono_emergencia = '9998887777',
    @domicilio = 'Calle Tres 333', @obra_social = 'IOMA', @nro_os = 'OS334',
    @nombre_tutor = 'Roberto', @apellido_tutor = 'Ruiz', @dni_tutor = '60000001',
    @email_tutor = 'roberto.ruiz@email.com', @fecha_nac_tutor = '1975-03-05',
    @telefono_tutor = '1199887766', @relacion_tutor = 'Padre',
    @domicilio_tutor = 'Calle Tres 333', @es_responsable = 0, @operacion = 'Insertar';
GO

EXEC socios.GestionarSocio 
    @nombre = 'Emilia', @apellido = 'Torres', @dni = '44444444',
    @email = 'emilia.torres@email.com', @fecha_nacimiento = '2017-12-01',
    @telefono = '1212121212', @telefono_emergencia = '3434343434',
    @domicilio = 'Calle Cuatro 444', @obra_social = 'Medife', @nro_os = 'OS444',
    @nombre_tutor = 'Mónica', @apellido_tutor = 'Torres', @dni_tutor = '60000002',
    @email_tutor = 'monica.torres@email.com', @fecha_nac_tutor = '1970-11-11',
    @telefono_tutor = '1177889900', @relacion_tutor = 'Madre',
    @domicilio_tutor = 'Calle Cuatro 444', @es_responsable = 0, @operacion = 'Insertar';
GO

/* ==========================================================
   VERIFICACIONES
========================================================== */
SELECT * FROM socios.CategoriaSocio;
SELECT * FROM socios.Socio;
SELECT * FROM socios.GrupoFamiliar;
SELECT * FROM socios.GrupoFamiliarSocio;
SELECT * FROM socios.Tutor;
SELECT * FROM actividades.InscriptoCategoriaSocio
GO
