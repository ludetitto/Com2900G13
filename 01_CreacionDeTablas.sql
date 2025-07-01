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
   
   Consigna: Cree entidades y relaciones. Incluya restricciones y claves.
 ========================================================================= */
USE COM2900G13;
GO

-- =============================
-- ELIMINAR VISTAS Y FUNCIONES
-- =============================

-- Vistas que usan administracion
DROP VIEW IF EXISTS administracion.vwSociosConCategoria;
DROP VIEW IF EXISTS administracion.vwSociosConObraSocial;

-- Funciones y procedimientos específicos
DROP PROCEDURE IF EXISTS cobranzas.AplicarBloqueoVencimiento;

/* =============================
   ELIMINAR PROCEDIMIENTOS
   ============================= */
DROP PROCEDURE IF EXISTS actividades.GestionarInscriptoPiletaVerano
DROP PROCEDURE IF EXISTS actividades.GestionarActividad
DROP PROCEDURE IF EXISTS actividades.GestionarActividadExtra
DROP PROCEDURE IF EXISTS actividades.GestionarClase
DROP PROCEDURE IF EXISTS actividades.GestionarInscriptoClase
DROP PROCEDURE IF EXISTS actividades.GestionarInscriptoColonia
DROP PROCEDURE IF EXISTS actividades.GestionarPresentismoActividadExtra
DROP PROCEDURE IF EXISTS actividades.GestionarPresentismoClase
DROP PROCEDURE IF EXISTS actividades.GestionarInscriptoPileta
DROP PROCEDURE IF EXISTS actividades.GestionarInscriptoReservaSum
DROP PROCEDURE IF EXISTS administracion.ConsultarEstadoSocioyGrupo
DROP PROCEDURE IF EXISTS administracion.VerCuotasPagasGrupoFamiliar

DROP PROCEDURE IF EXISTS actividades.GestionarReservaSum
DROP PROCEDURE IF EXISTS administracion.GestionarInvitado
DROP PROCEDURE IF EXISTS administracion.GestionarSocio
DROP PROCEDURE IF EXISTS administracion.GestionarProfesor
DROP PROCEDURE IF EXISTS administracion.GestionarPersona
DROP PROCEDURE IF EXISTS administracion.GestionarCategoriaSocio
DROP PROCEDURE IF EXISTS administracion.GestionarGrupoFamiliar

DROP PROCEDURE IF EXISTS facturacion.GenerarFacturasMensualesPorFecha
DROP PROCEDURE IF EXISTS facturacion.GenerarCargosActividadExtraPorFecha
DROP PROCEDURE IF EXISTS cobranzas.GenerarPagoACuenta
DROP PROCEDURE IF EXISTS facturacion.GenerarCuotasMensualesPorFecha
DROP PROCEDURE IF EXISTS cobranzas.GestionarMedioDePago
DROP PROCEDURE IF EXISTS cobranzas.RegistrarMedioDePago
DROP PROCEDURE IF EXISTS cobranzas.RegistrarCobranza
DROP PROCEDURE IF EXISTS cobranzas.RegistrarReintegroPorLluvia
DROP PROCEDURE IF EXISTS cobranzas.RegistrarPagoACuenta
DROP PROCEDURE IF EXISTS cobranzas.RegistrarNotaDeCredito
DROP PROCEDURE IF EXISTS cobranzas.HabilitarDebitoAutomatico
DROP PROCEDURE IF EXISTS cobranzas.GenerarReintegroPorLluvia
DROP PROCEDURE IF EXISTS cobranzas.GenerarReembolso
DROP PROCEDURE IF EXISTS cobranzas.DeshabilitarDebitoAutomatico
DROP PROCEDURE IF EXISTS cobranzas.AplicarRecargoVencimiento
DROP PROCEDURE IF EXISTS cobranzas.MorososRecurrentes
DROP PROCEDURE IF EXISTS cobranzas.GenerarReembolsoPorPago
DROP PROCEDURE IF EXISTS cobranzas.GenerarPagoACuentaPorReembolso
DROP PROCEDURE IF EXISTS cobranzas.GestionarRecargo
DROP VIEW IF EXISTS cobranzas.vwNotasConMedioDePago

DROP VIEW IF EXISTS facturacion.vw_FacturasDetalladasConResponsables
DROP PROCEDURE IF EXISTS facturacion.GenerarFacturasActividadesExtraPorFecha
DROP PROCEDURE IF EXISTS facturacion.GenerarCargoClase
DROP PROCEDURE IF EXISTS facturacion.GenerarCargoMembresia
DROP PROCEDURE IF EXISTS facturacion.AnularFactura
DROP PROCEDURE IF EXISTS facturacion.GenerarFacturaSocioActExtra
DROP PROCEDURE IF EXISTS facturacion.GenerarFacturaSocioMensual
DROP PROCEDURE IF EXISTS facturacion.GenerarFacturaInvitado
DROP PROCEDURE IF EXISTS facturacion.GestionarDescuentos
DROP PROCEDURE IF EXISTS facturacion.GestionarEmisorFactura
DROP VIEW IF EXISTS facturacion.vwResponsablesDeFactura

DROP PROCEDURE IF EXISTS tarifas.GestionarTarifaColoniaVerano
DROP PROCEDURE IF EXISTS tarifas.GestionarTarifaReservaSum
DROP PROCEDURE IF EXISTS tarifas.GestionarTarifaPiletaVerano

DROP PROCEDURE IF EXISTS socios.GestionarCategoriaSocio;
DROP PROCEDURE IF EXISTS socios.GestionarSocio;
DROP PROCEDURE IF EXISTS socios.GestionarResponsableGrupoFamiliar;


-- Eliminar vistas del esquema socios si las hubiera
DROP VIEW IF EXISTS socios.vwGrupoFamiliarConCategorias;

-- ===============================
-- Eliminación de todas las claves foráneas
-- ===============================
DECLARE @sql NVARCHAR(MAX) = '';

SELECT @sql += 'ALTER TABLE [' + SCHEMA_NAME(t.schema_id) + '].[' + t.name + '] '
             + 'DROP CONSTRAINT [' + fk.name + '];' + CHAR(13)
FROM sys.foreign_keys fk
JOIN sys.tables t ON fk.parent_object_id = t.object_id;

-- Ejecutar el SQL generado
EXEC sp_executesql @sql;


-- ===============================
-- Eliminación segura de tablas
-- ===============================
DROP TABLE IF EXISTS cobranzas.PagoACuenta;
DROP TABLE IF EXISTS cobranzas.Reembolso;
DROP TABLE IF EXISTS cobranzas.Pago;
DROP TABLE IF EXISTS cobranzas.Mora;
DROP TABLE IF EXISTS cobranzas.MedioDePago;
DROP TABLE IF EXISTS cobranzas.TarjetaDeCredito;


DROP TABLE IF EXISTS facturacion.DetalleFactura;
DROP TABLE IF EXISTS facturacion.Factura;
DROP TABLE IF EXISTS facturacion.CargoActividadExtra;
DROP TABLE IF EXISTS facturacion.CargoClases;
DROP TABLE IF EXISTS facturacion.CargoMembresias;
DROP TABLE IF EXISTS facturacion.CuotaMensual;
DROP TABLE IF EXISTS facturacion.EmisorFactura;

DROP TABLE IF EXISTS actividades.PresentismoClase;
DROP TABLE IF EXISTS actividades.InscriptoClase;
DROP TABLE IF EXISTS actividades.InscriptoCategoriaSocio;
DROP TABLE IF EXISTS actividades.InscriptoColoniaVerano;
DROP TABLE IF EXISTS actividades.InscriptoPiletaVerano;
DROP TABLE IF EXISTS actividades.Clase;
DROP TABLE IF EXISTS actividades.Actividad;

DROP TABLE IF EXISTS tarifas.TarifaColoniaVerano;
DROP TABLE IF EXISTS tarifas.TarifaReservaSum;
DROP TABLE IF EXISTS tarifas.TarifaPiletaVerano;

DROP TABLE IF EXISTS reservas.ReservaSum;

DROP TABLE IF EXISTS socios.GrupoFamiliar;
DROP TABLE IF EXISTS socios.GrupoFamiliarSocio;
DROP TABLE IF EXISTS socios.Tutor;
DROP TABLE IF EXISTS socios.DebitoAutomaticoSocio;
DROP TABLE IF EXISTS socios.Socio;
DROP TABLE IF EXISTS socios.Invitado;
DROP TABLE IF EXISTS socios.CategoriaSocio;

-- ===============================
-- Eliminación segura de esquemas
-- ===============================
DROP SCHEMA IF EXISTS cobranzas;
GO
DROP SCHEMA IF EXISTS facturacion;
GO
DROP SCHEMA IF EXISTS actividades;
GO
DROP SCHEMA IF EXISTS tarifas;
GO
DROP SCHEMA IF EXISTS reservas;
GO
DROP SCHEMA IF EXISTS socios;
GO

-- ===============================
-- Creación de esquemas
-- ===============================

CREATE SCHEMA socios;
GO
CREATE SCHEMA actividades;
GO
CREATE SCHEMA facturacion;
GO
CREATE SCHEMA cobranzas;
GO
CREATE SCHEMA reservas;
GO
CREATE SCHEMA tarifas;
GO

-- ===============================
-- Módulo: SOCIOS
-- ===============================

CREATE TABLE socios.CategoriaSocio (
    id_categoria INT IDENTITY PRIMARY KEY,
    nombre VARCHAR(50),
    edad_minima INT,
    edad_maxima INT,
    costo_membresia DECIMAL(10,2),
    vigencia DATE
);
CREATE TABLE socios.Socio (
    id_socio INT IDENTITY PRIMARY KEY,
    nombre VARCHAR(50),
    apellido VARCHAR(50),
    dni CHAR(8) CONSTRAINT CHK_Socio_DNI CHECK (dni NOT LIKE '%[^0-9]%' AND LEN(dni) = 8),
	nro_socio VARCHAR(50),
    email VARCHAR(100) CONSTRAINT CHK_Socio_Email CHECK (email IS NULL OR email LIKE '%@%.%'),
    fecha_nacimiento DATE,
    tel_contacto VARCHAR(20),
    tel_emergencia VARCHAR(20),
    domicilio VARCHAR(200),
    obra_social VARCHAR(100),
    nro_obra_social VARCHAR(50),
    activo BIT CONSTRAINT CHK_Socio_Activo CHECK (activo IN (0,1)),
    eliminado BIT CONSTRAINT CHK_Socio_Eliminado CHECK (eliminado IN (0,1)),
    saldo DECIMAL(10,2) NOT NULL DEFAULT 0
);

CREATE TABLE socios.GrupoFamiliar (
    id_grupo INT IDENTITY PRIMARY KEY,
    id_socio_rp INT NULL
);


CREATE TABLE socios.GrupoFamiliarSocio (
    id_grupo INT NOT NULL,
    id_socio INT NOT NULL,
    PRIMARY KEY (id_grupo, id_socio),
    FOREIGN KEY (id_grupo) REFERENCES socios.GrupoFamiliar(id_grupo),
    FOREIGN KEY (id_socio) REFERENCES socios.Socio(id_socio)
);


CREATE TABLE socios.Tutor (
    id_tutor INT IDENTITY PRIMARY KEY,
    id_grupo INT NOT NULL, 
    dni VARCHAR(10) NOT NULL CONSTRAINT CHK_Tutor_DNI CHECK (dni NOT LIKE '%[^0-9]%' AND LEN(dni) = 8),
    nombre CHAR(50) NOT NULL,
    apellido CHAR(50) NOT NULL,
    domicilio VARCHAR(200) NOT NULL,
    email VARCHAR(70) NOT NULL CONSTRAINT CHK_Tutor_Email CHECK (email LIKE '%@%.%')
);
GO
CREATE TABLE socios.Invitado (
    id_invitado INT IDENTITY PRIMARY KEY,
	id_socio INT NOT NULL,
    dni CHAR(8) NOT NULL CONSTRAINT CHK_Invitado_DNI CHECK (dni NOT LIKE '%[^0-9]%' AND LEN(dni) = 8),
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    domicilio VARCHAR(150) NOT NULL,
	categoria VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL CONSTRAINT CHK_Invitado_Email CHECK (email LIKE '%@%.%')
);

CREATE TABLE socios.DebitoAutomaticoSocio (
    id_debito INT IDENTITY PRIMARY KEY,
    id_socio INT NOT NULL,
    id_medio_pago INT NOT NULL
);

-- ===============================
-- Módulo: ACTIVIDADES
-- ===============================

CREATE TABLE actividades.Actividad (
    id_actividad INT IDENTITY PRIMARY KEY,
    nombre VARCHAR(100),
    costo DECIMAL(10,2) CONSTRAINT CHK_Actividad_Costo CHECK (costo > 0),
    vigencia DATE
);

CREATE TABLE actividades.Clase (
    id_clase INT IDENTITY PRIMARY KEY,
    id_actividad INT NOT NULL,
    id_categoria INT NOT NULL,
    horario VARCHAR(50),
    nombre_profesor VARCHAR(100),
    apellido_profesor VARCHAR(100)
);

CREATE TABLE actividades.InscriptoClase (
    id_inscripto_clase INT IDENTITY PRIMARY KEY,
	fecha_inscripcion DATE NOT NULL,
    id_socio INT NOT NULL,
    id_clase INT NOT NULL,
	activa BIT
);

CREATE TABLE actividades.PresentismoClase (
    id_presentismo INT IDENTITY PRIMARY KEY,
    id_clase INT NOT NULL,
    id_socio INT NOT NULL,
    fecha DATE NOT NULL,
    estado CHAR(1) CONSTRAINT CHK_PresentismoClase_Estado CHECK (estado IN ('P', 'A', 'J')) -- P: Presente, A: Ausente, J: Justificado
);

CREATE TABLE actividades.InscriptoCategoriaSocio (
    id_inscripto_categoria INT IDENTITY PRIMARY KEY,
    id_socio INT NOT NULL,
    id_categoria INT NOT NULL,
	fecha DATE NOT NULL,
	monto DECIMAL(10, 2) NOT NULL CONSTRAINT CHK_InscriptoCategoriaSocio_Monto CHECK (monto > 0),
	activo BIT
);

CREATE TABLE actividades.InscriptoColoniaVerano (
    id_inscripto_colonia INT IDENTITY PRIMARY KEY,
    id_socio INT NOT NULL,
    id_tarifa_colonia INT NOT NULL,
	fecha DATE NOT NULL,
	monto DECIMAL(10, 2) NOT NULL CONSTRAINT CHK_InscriptoColoniaVerano_Monto CHECK (monto > 0)
);

CREATE TABLE actividades.InscriptoPiletaVerano (
    id_inscripto_pileta INT IDENTITY PRIMARY KEY,
	id_tarifa_pileta INT NOT NULL,
    id_socio INT,
	id_invitado INT NULL,
	fecha DATE NOT NULL,
	monto DECIMAL(10, 2) NOT NULL CONSTRAINT CHK_InscriptoPiletaVerano_Monto CHECK (monto > 0)
);

-- ===============================
-- Módulo: TARIFAS
-- ===============================

CREATE TABLE tarifas.TarifaColoniaVerano (
    id_tarifa_colonia INT IDENTITY PRIMARY KEY,
    costo DECIMAL(10,2) CONSTRAINT CHK_TarifaColoniaVerano_Costo CHECK (costo > 0),
	periodo CHAR(10),
	categoria VARCHAR(50),
	vigencia DATE
);

CREATE TABLE tarifas.TarifaReservaSum (
    id_tarifa_sum INT IDENTITY PRIMARY KEY,
    costo DECIMAL(10,2) CONSTRAINT CHK_TarifaReservaSum_Costo CHECK (costo > 0),
	vigencia DATE
);

CREATE TABLE tarifas.TarifaPiletaVerano (
    id_tarifa_pileta INT IDENTITY PRIMARY KEY,
    costo DECIMAL(10,2) CONSTRAINT CHK_TarifaPiletaVerano_Costo CHECK (costo > 0),
	categoria VARCHAR(50),
    es_invitado BIT CONSTRAINT CHK_TarifaPiletaVerano_Invitado CHECK (es_invitado IN (0,1)),
	vigencia DATE
);

-- ===============================
-- Módulo: RESERVAS
-- ===============================

CREATE TABLE reservas.ReservaSum (
    id_reserva_sum INT IDENTITY PRIMARY KEY,
	id_tarifa_sum INT NOT NULL,
    id_socio INT NOT NULL,
    fecha DATE NOT NULL,
    hora_inicio TIME,
    hora_fin TIME,
	monto DECIMAL(10, 2)
);

-- ===============================
-- Módulo: FACTURACION
-- ===============================




CREATE TABLE facturacion.CuotaMensual (
    id_cuota_mensual INT IDENTITY PRIMARY KEY,
	id_inscripto_categoria INT,
	monto_membresia DECIMAL(10, 2) NOT NULL CONSTRAINT CHK_CuotaMensual_CostoMembresia CHECK (monto_membresia > 0),
	monto_actividad DECIMAL(10, 2) NOT NULL CONSTRAINT CHK_CuotaMensual_CostoActividad CHECK (monto_actividad > 0),
    fecha DATE NOT NULL
);


CREATE TABLE facturacion.CargoClases (
    id_cargo_clase INT IDENTITY PRIMARY KEY,
    id_inscripto_clase INT NOT NULL,
	monto DECIMAL(10, 2) NOT NULL CONSTRAINT CHK_CargoClases_Monto CHECK (monto > 0),
	fecha DATE NOT NULL
);

CREATE TABLE facturacion.CargoActividadExtra (
    id_cargo_extra INT IDENTITY PRIMARY KEY,
    id_inscripto_colonia INT DEFAULT NULL,
    id_inscripto_pileta INT DEFAULT NULL,
    id_reserva_sum INT DEFAULT NULL
);

CREATE TABLE facturacion.EmisorFactura (
    id_emisor INT IDENTITY PRIMARY KEY,
    razon_social VARCHAR(100),
	direccion CHAR(50),
	cuit_emisor CHAR(13) CHECK(cuit_emisor LIKE '[0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]-[0-9]'),
	pais VARCHAR(50),
	localidad VARCHAR(50),
	codigo_postal CHAR(4) CHECK (codigo_postal LIKE '[0-9][0-9][0-9][0-9]'),
	condicion_iva_emisor CHAR(50) NOT NULL

);


CREATE TABLE facturacion.Factura (
    id_factura INT IDENTITY PRIMARY KEY,
    id_emisor INT NOT NULL,
	id_cuota_mensual INT,
	id_cargo_actividad_extra INT,
	nro_comprobante CHAR(8),
	tipo_factura CHAR,
	dni_receptor CHAR(13), 
	condicion_iva_receptor CHAR(50) NOT NULL,
	cae CHAR(14) UNIQUE, 
    monto_total DECIMAL(10,2) CONSTRAINT CHK_Factura_Monto CHECK (monto_total > 0),
    fecha_emision DATE,
    fecha_vencimiento1 DATE,
    fecha_vencimiento2 DATE,
    estado VARCHAR(20),
	saldo_anterior DECIMAL(10,2),
    anulada BIT DEFAULT 0
);

CREATE TABLE facturacion.DetalleFactura (
    id_detalle INT IDENTITY PRIMARY KEY,
    id_factura INT NOT NULL,
    descripcion VARCHAR(100),
    monto DECIMAL(10,2) CONSTRAINT CHK_DetalleFactura_Monto CHECK (monto > 0),
    tipo_item VARCHAR(50),
	cantidad INT
);

-- ===============================
-- Módulo: COBRANZAS
-- ===============================

CREATE TABLE cobranzas.Mora (
    id_mora INT IDENTITY PRIMARY KEY,
	id_socio INT NOT NULL,
    id_factura INT NOT NULL,
    fecha_registro DATE,
    motivo VARCHAR(100),
	facturada BIT,
	monto DECIMAL(10,2)
);

CREATE TABLE cobranzas.Pago (
    id_pago INT IDENTITY PRIMARY KEY ,
    id_factura INT,
	id_medio INT NOT NULL,
	nro_transaccion VARCHAR(20),
	monto DECIMAL(10,2) CONSTRAINT CHK_Pago_Monto CHECK (monto > 0),
    fecha_emision DATETIME,
    estado CHAR(10)
);

CREATE TABLE cobranzas.Reembolso (
    id_reembolso INT IDENTITY PRIMARY KEY,
    id_pago INT NOT NULL,
	monto DECIMAL(10,2) CONSTRAINT CHK_Reembolso_Monto CHECK (monto > 0),
	fecha_emision DATETIME NOT NULL,
    motivo VARCHAR(100)
);

CREATE TABLE cobranzas.PagoACuenta (
    id_pago_cuenta INT IDENTITY PRIMARY KEY,
    id_pago INT NOT NULL,
    id_socio INT NOT NULL,
    fecha DATE,
    monto DECIMAL(10,2) CONSTRAINT CHK_PagoACuenta_Monto CHECK (monto > 0),
	motivo VARCHAR(100)
);

CREATE TABLE cobranzas.MedioDePago (
    id_medio_pago INT IDENTITY PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL
);

CREATE TABLE cobranzas.TarjetaDeCredito(
	id_tarjeta INT IDENTITY PRIMARY KEY,
	id_socio INT NOT NULL,
	nro_tarjeta CHAR(16),
	titular VARCHAR(50),
	fecha_desde DATE,
	fecha_hasta DATE,
	cod_seguridad CHAR(3),
	debito_automatico BIT
);

-- ===============================
-- RELACIONES
-- ===============================

ALTER TABLE actividades.PresentismoClase
ADD CONSTRAINT FK_PresentismoClase_Clase
    FOREIGN KEY (id_clase) REFERENCES actividades.Clase(id_clase);

ALTER TABLE actividades.InscriptoCategoriaSocio
ADD CONSTRAINT FK_InscriptoCategoriaSocio_Socio
    FOREIGN KEY (id_socio) REFERENCES socios.Socio(id_socio);

ALTER TABLE facturacion.CargoActividadExtra
ADD CONSTRAINT FK_CargoActividadExtra_InscriptoColoniaVerano
    FOREIGN KEY (id_inscripto_colonia) REFERENCES actividades.InscriptoColoniaVerano(id_inscripto_colonia);

ALTER TABLE facturacion.CargoActividadExtra
ADD CONSTRAINT FK_CargoActividadExtra_InscriptoPiletaVerano
    FOREIGN KEY (id_inscripto_pileta) REFERENCES actividades.InscriptoPiletaVerano(id_inscripto_pileta);

ALTER TABLE facturacion.CargoActividadExtra
ADD CONSTRAINT FK_CargoActividadExtra_ReservaSum
    FOREIGN KEY (id_reserva_sum) REFERENCES reservas.ReservaSum(id_reserva_sum);

ALTER TABLE actividades.InscriptoCategoriaSocio
ADD CONSTRAINT FK_InscriptoCategoriaSocio_CategoriaSocio
    FOREIGN KEY (id_categoria) REFERENCES socios.CategoriaSocio(id_categoria);

ALTER TABLE actividades.Clase
ADD CONSTRAINT FK_Clase_Actividad
    FOREIGN KEY (id_actividad) REFERENCES actividades.Actividad(id_actividad);

ALTER TABLE actividades.Clase
ADD CONSTRAINT FK_Clase_CategoriaSocio
    FOREIGN KEY (id_categoria) REFERENCES socios.CategoriaSocio(id_categoria);

ALTER TABLE facturacion.Factura
ADD CONSTRAINT FK_Factura_CuotaMensual
    FOREIGN KEY (id_cuota_mensual) REFERENCES facturacion.CuotaMensual(id_cuota_mensual);

ALTER TABLE facturacion.Factura
ADD CONSTRAINT FK_Factura_CargoActividadExtra
    FOREIGN KEY (id_cargo_actividad_extra) REFERENCES facturacion.CargoActividadExtra(id_cargo_extra);

ALTER TABLE facturacion.DetalleFactura
ADD CONSTRAINT FK_DetalleFactura_Factura
    FOREIGN KEY (id_factura) REFERENCES facturacion.Factura(id_factura);

ALTER TABLE facturacion.Factura
ADD CONSTRAINT FK_Factura_EmisorFactura
    FOREIGN KEY (id_emisor) REFERENCES facturacion.EmisorFactura(id_emisor);

ALTER TABLE cobranzas.Mora
ADD CONSTRAINT FK_Mora_Factura
    FOREIGN KEY (id_factura) REFERENCES facturacion.Factura(id_factura);

ALTER TABLE cobranzas.Pago
ADD CONSTRAINT FK_Pago_Factura
    FOREIGN KEY (id_factura) REFERENCES facturacion.Factura(id_factura);

ALTER TABLE facturacion.CuotaMensual
ADD CONSTRAINT FK_CuotaMensual_InscriptoCategoriaSocio
    FOREIGN KEY (id_inscripto_categoria) REFERENCES actividades.InscriptoCategoriaSocio(id_inscripto_categoria);

ALTER TABLE facturacion.CargoClases
ADD CONSTRAINT FK_CargoClases_InscriptoClase
    FOREIGN KEY (id_inscripto_clase) REFERENCES actividades.InscriptoClase(id_inscripto_clase);

ALTER TABLE actividades.InscriptoClase
ADD CONSTRAINT FK_InscriptoClase_Clase
    FOREIGN KEY (id_clase) REFERENCES actividades.Clase(id_clase);


--Tablas de la base de datos
SELECT TABLE_SCHEMA, TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_SCHEMA, TABLE_NAME;