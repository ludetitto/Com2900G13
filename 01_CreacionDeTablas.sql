/* =========================================================================
   Trabajo Práctico Integrador - Bases de Datos Aplicadas
   Grupo N°: 13
   Comisión: 2900
   Fecha de Entrega: 17/06/2025
   Materia: Bases de Datos Aplicadas
   Alumnos: Vignardel Francisco 45778667
            De Titto Lucia 46501934
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
DROP PROCEDURE IF EXISTS actividades.GestionarActividad
DROP PROCEDURE IF EXISTS actividades.GestionarActividadExtra
DROP PROCEDURE IF EXISTS actividades.GestionarClase
DROP PROCEDURE IF EXISTS actividades.GestionarInscripcion
DROP PROCEDURE IF EXISTS actividades.GestionarPresentismoActividadExtra
DROP PROCEDURE IF EXISTS actividades.GestionarPresentismoClase
DROP PROCEDURE IF EXISTS administracion.ConsultarEstadoSocioyGrupo
DROP PROCEDURE IF EXISTS administracion.VerCuotasPagasGrupoFamiliar

DROP PROCEDURE IF EXISTS administracion.GestionarInvitado
DROP PROCEDURE IF EXISTS administracion.GestionarSocio
DROP PROCEDURE IF EXISTS administracion.GestionarProfesor
DROP PROCEDURE IF EXISTS administracion.GestionarPersona
DROP PROCEDURE IF EXISTS administracion.GestionarCategoriaSocio
DROP PROCEDURE IF EXISTS administracion.GestionarGrupoFamiliar

DROP PROCEDURE IF EXISTS cobranzas.RegistrarCobranza
DROP PROCEDURE IF EXISTS cobranzas.RegistrarReintegroPorLluvia
DROP PROCEDURE IF EXISTS cobranzas.RegistrarPagoACuenta
DROP PROCEDURE IF EXISTS cobranzas.RegistrarNotaDeCredito
DROP PROCEDURE IF EXISTS cobranzas.HabilitarDebitoAutomatico
DROP PROCEDURE IF EXISTS cobranzas.GenerarReintegroPorLluvia
DROP PROCEDURE IF EXISTS cobranzas.GenerarReembolso
DROP PROCEDURE IF EXISTS cobranzas.DeshabilitarDebitoAutomatico
DROP PROCEDURE IF EXISTS cobranzas.AplicarRecargoVencimiento

DROP PROCEDURE IF EXISTS facturacion.AnularFactura
DROP PROCEDURE IF EXISTS facturacion.GenerarFacturaSocioActExtra
DROP PROCEDURE IF EXISTS facturacion.GenerarFacturaSocioMensual
DROP PROCEDURE IF EXISTS facturacion.GenerarFacturaInvitado
DROP PROCEDURE IF EXISTS facturacion.GestionarEmisorFactura

/* ============================
   BORRADO DE OBJETOS DE LA BD
   ============================ */

-- COBRANZAS
DROP TABLE IF EXISTS cobranzas.Notificacion;
DROP TABLE IF EXISTS cobranzas.Mora;
DROP TABLE IF EXISTS cobranzas.NotaDeCredito;
DROP TABLE IF EXISTS cobranzas.PagoACuenta;
DROP TABLE IF EXISTS cobranzas.Pago;
DROP TABLE IF EXISTS cobranzas.MedioDePago;

-- FACTURACION
DROP TABLE IF EXISTS facturacion.Descuento;
DROP TABLE IF EXISTS facturacion.Recargo;
DROP TABLE IF EXISTS facturacion.DetalleFactura;
DROP TABLE IF EXISTS facturacion.Factura;
DROP TABLE IF EXISTS facturacion.EmisorFactura;

-- ACTIVIDADES
DROP TABLE IF EXISTS actividades.presentismoActividadExtra;
DROP TABLE IF EXISTS actividades.ActividadExtra;
DROP TABLE IF EXISTS actividades.presentismoClase;
DROP TABLE IF EXISTS actividades.InscriptoClase;
DROP TABLE IF EXISTS actividades.Clase;
DROP TABLE IF EXISTS actividades.Actividad;

-- ADMINISTRACION
DROP TABLE IF EXISTS administracion.Invitado;
DROP TABLE IF EXISTS administracion.GrupoFamiliar;
DROP TABLE IF EXISTS administracion.Socio;
DROP TABLE IF EXISTS administracion.CategoriaSocio;
DROP TABLE IF EXISTS administracion.Profesor;
DROP TABLE IF EXISTS administracion.Persona;
GO

-- Crear esquemas personalizados
IF EXISTS (SELECT * FROM sys.schemas WHERE name = 'administracion')
    DROP SCHEMA administracion;
GO

CREATE SCHEMA administracion;
GO

IF EXISTS (SELECT * FROM sys.schemas WHERE name = 'actividades')
    DROP SCHEMA actividades;
GO

CREATE SCHEMA actividades;
GO

IF EXISTS (SELECT * FROM sys.schemas WHERE name = 'cobranzas')
    DROP SCHEMA cobranzas;
GO

CREATE SCHEMA cobranzas;
GO

IF EXISTS (SELECT * FROM sys.schemas WHERE name = 'facturacion')
    DROP SCHEMA facturacion;
GO

CREATE SCHEMA facturacion;
GO

/* ================================
   TABLAS DEL MÓDULO ADMINISTRACION
   ================================ */

IF OBJECT_ID('administracion.Persona', 'U') IS NOT NULL
    DROP TABLE administracion.Persona;
GO

CREATE TABLE administracion.Persona (
	id_persona INT IDENTITY(1,1) PRIMARY KEY,
	nombre CHAR(50) NOT NULL,
    apellido CHAR(50) NOT NULL,
    dni VARCHAR(10) UNIQUE NOT NULL,
    email VARCHAR(70),
    fecha_nacimiento DATE NOT NULL,
	domicilio VARCHAR(200) NOT NULL,
    tel_contacto CHAR(15),
    tel_emergencia CHAR(15),
	borrado BIT,
	CONSTRAINT CHK_persona_dni CHECK (
        LEN(LTRIM(RTRIM(dni))) < 10 AND dni LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
    ),
    CONSTRAINT CHK_persona_email CHECK (
        email LIKE '%_@__%.__%'
    ),
    CONSTRAINT CHK_persona_fecha_nacimiento CHECK (
        fecha_nacimiento <= GETDATE()
    )
);
GO

IF OBJECT_ID('administracion.Profesor', 'U') IS NOT NULL
    DROP TABLE administracion.Profesor;
GO
-- Se adopta la notacion par FK:
-- FK_[TablaEnCreacion]_[TablaFK]_[CampoFK]
CREATE TABLE administracion.Profesor (
	id_profesor INT IDENTITY(1,1) PRIMARY KEY,
	id_persona INT,
	CONSTRAINT FK_profesor_persona_id FOREIGN KEY (id_persona) REFERENCES administracion.Persona(id_persona)
);
GO

IF OBJECT_ID('administracion.CategoriaSocio', 'U') IS NOT NULL
    DROP TABLE administracion.CategoriaSocio;
GO

CREATE TABLE administracion.CategoriaSocio (
    id_categoria INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(50),
    edad_desde INT,
	edad_hasta INT,
    costo_membresia DECIMAL(10,2),
    vigencia DATE,
	CONSTRAINT CHK_categoria_nombre CHECK (
        LTRIM(RTRIM(nombre)) <> ''
    ),
    CONSTRAINT CHK_categoria_edad_desde CHECK (
        edad_desde >= 0
    ),
	CONSTRAINT CHK_categoria_edad_hasta CHECK (
        edad_hasta >= 0
    ),
    CONSTRAINT CHK_categoria_costo CHECK (
        costo_membresia >= 0
    ),
    CONSTRAINT CHK_categoria_vigencia CHECK (
        vigencia >= GETDATE()
    )
);
GO

IF OBJECT_ID('administracion.Socio', 'U') IS NOT NULL
    DROP TABLE administracion.Socio;
GO

CREATE TABLE administracion.Socio (
    id_socio INT IDENTITY(1,1) PRIMARY KEY,
	id_persona INT,
    id_categoria INT,
	nro_socio CHAR(20),
    obra_social VARCHAR(100),
	nro_obra_social VARCHAR(100),
    saldo DECIMAL(10,2) NOT NULL,
    activo BIT,
	CONSTRAINT FK_socio_persona_id FOREIGN KEY (id_persona) REFERENCES administracion.Persona(id_persona),
	CONSTRAINT FK_socio_categoria_id FOREIGN KEY (id_categoria) REFERENCES administracion.CategoriaSocio(id_categoria)
);
GO

IF OBJECT_ID('administracion.GrupoFamiliar', 'U') IS NOT NULL
    DROP TABLE administracion.GrupoFamiliar;
GO

CREATE TABLE administracion.GrupoFamiliar (
    id_grupo INT IDENTITY(1,1) PRIMARY KEY,
	id_socio INT,
	id_socio_rp INT,
	CONSTRAINT FK_grupoFamiliar_socio_id FOREIGN KEY (id_socio) REFERENCES administracion.Socio(id_socio),
	CONSTRAINT FK_grupoFamiliar_socio_id_rp FOREIGN KEY (id_socio_rp) REFERENCES administracion.Socio(id_socio)
);
GO

IF OBJECT_ID('administracion.Invitado', 'U') IS NOT NULL
    DROP TABLE administracion.Invitado;
GO

CREATE TABLE administracion.Invitado (
    id_invitado INT IDENTITY(1,1) PRIMARY KEY,
	id_socio INT,
	dni VARCHAR(10) UNIQUE NOT NULL,
	nombre CHAR(50) NOT NULL,
	apellido CHAR(50) NOT NULL,
	email VARCHAR(70) NOT NULL,
	domicilio VARCHAR(200) NOT NULL,
	CONSTRAINT FK_invitado_socio_id FOREIGN KEY (id_socio) REFERENCES administracion.Socio(id_socio),
	CONSTRAINT CHK_invitado_dni CHECK (
        LEN(LTRIM(RTRIM(dni))) < 10 AND dni LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
    ),
);
GO

/* ==============================
   TABLAS DEL MÓDULO ACTIVIDADES
   ============================== */

IF OBJECT_ID('actividades.Actividad', 'U') IS NOT NULL
    DROP TABLE actividades.Actividad;
GO

CREATE TABLE actividades.Actividad (
    id_actividad INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(100),
    costo DECIMAL(10,2),
	vigencia DATE,
);
GO

IF OBJECT_ID('actividades.Clase', 'U') IS NOT NULL
    DROP TABLE actividades.Clase;
GO

CREATE TABLE actividades.Clase (
    id_clase INT IDENTITY(1,1) PRIMARY KEY,
    id_actividad INT,
    id_profesor INT,
    id_categoria INT, 
    horario VARCHAR(20),
    CONSTRAINT FK_clase_actividad_id FOREIGN KEY (id_actividad) REFERENCES actividades.Actividad(id_actividad),
    CONSTRAINT FK_clase_profesor_id FOREIGN KEY (id_profesor) REFERENCES administracion.Profesor(id_profesor),
    CONSTRAINT FK_clase_categoria_id FOREIGN KEY (id_categoria) REFERENCES administracion.CategoriaSocio(id_categoria)
);
GO

IF OBJECT_ID('actividades.inscriptoClase', 'U') IS NOT NULL
    DROP TABLE actividades.inscriptoClase;
GO

CREATE TABLE actividades.InscriptoClase (
    id_inscripto INT IDENTITY(1,1) PRIMARY KEY,
    id_socio INT,
	id_clase INT,
	fecha_inscripcion DATE,
	CONSTRAINT FK_inscriptoClase_socio_id FOREIGN KEY (id_socio) REFERENCES administracion.Socio(id_socio),
	CONSTRAINT FK_inscriptoClase_clase_id FOREIGN KEY (id_clase) REFERENCES actividades.Clase(id_clase)
);
GO

IF OBJECT_ID('actividades.presentismoClase', 'U') IS NOT NULL
    DROP TABLE actividades.presentismoClase;
GO

CREATE TABLE actividades.presentismoClase (
    id_presentismo INT IDENTITY(1,1) PRIMARY KEY,
    id_clase INT,
	id_socio INT,
	fecha DATE,
	condicion CHAR(1),
	CONSTRAINT FK_presentismoClase_clase_id FOREIGN KEY (id_clase) REFERENCES actividades.Clase(id_clase),
	CONSTRAINT FK_presentismoClase_socio_id FOREIGN KEY (id_socio) REFERENCES administracion.Socio(id_socio)
);
GO

IF OBJECT_ID('actividades.ActividadExtra', 'U') IS NOT NULL
    DROP TABLE actividades.ActividadExtra;
GO

CREATE TABLE actividades.ActividadExtra (
    id_extra INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(100),
    costo DECIMAL(10,2),
    periodo CHAR(10),
	es_invitado CHAR(1),
	vigencia DATE
);
GO

IF OBJECT_ID('actividades.presentismoActividadExtra', 'U') IS NOT NULL
    DROP TABLE actividades.presentismoActividadExtra;
GO

CREATE TABLE actividades.presentismoActividadExtra (
    id_presentismo_extra INT IDENTITY(1,1) PRIMARY KEY,
    id_extra INT,
	id_socio INT DEFAULT NULL,
	id_invitado INT DEFAULT NULL,
	fecha DATE,
	condicion CHAR(1),
	CONSTRAINT FK_presentismoActividadExtra_actividad_id FOREIGN KEY (id_extra) REFERENCES actividades.ActividadExtra(id_extra),
	CONSTRAINT FK_presentismoActividadExtra_socio_id FOREIGN KEY (id_socio) REFERENCES administracion.Socio(id_socio),
	CONSTRAINT FK_presentismoActividadExtra_invitado_id FOREIGN KEY (id_invitado) REFERENCES administracion.Invitado(id_invitado)
);
GO

/* =============================
   TABLAS DEL MÓDULO FACTURACION
   ============================= */

IF OBJECT_ID('facturacion.Recargo', 'U') IS NOT NULL
    DROP TABLE facturacion.Recargo;
GO

CREATE TABLE facturacion.Recargo (
	id_recargo INT IDENTITY(1,1) PRIMARY KEY,
	porcentaje DECIMAL(5,2),
	descripcion VARCHAR(50),
	vigencia DATE
)

IF OBJECT_ID('facturacion.Descuento', 'U') IS NOT NULL
    DROP TABLE facturacion.Descuento;
GO

CREATE TABLE facturacion.Descuento (
	id_recargo INT IDENTITY(1,1) PRIMARY KEY,
	porcentaje DECIMAL(5,2),
	descripcion VARCHAR(50),
	vigencia DATE
)

IF OBJECT_ID('facturacion.EmisorFactura', 'U') IS NOT NULL
    DROP TABLE facturacion.EmisorFactura;
GO

CREATE TABLE facturacion.EmisorFactura (
	id_emisor INT IDENTITY(1,1) PRIMARY KEY,
	razon_social VARCHAR(100),
	cuil VARCHAR(20) UNIQUE NOT NULL,
	direccion VARCHAR(200),
	pais VARCHAR(50),
	localidad VARCHAR(50),
	codigo_postal VARCHAR(50)
);
GO

IF OBJECT_ID('facturacion.Factura', 'U') IS NOT NULL
    DROP TABLE facturacion.Factura;
GO

CREATE TABLE facturacion.Factura (
    id_factura INT IDENTITY(1,1) PRIMARY KEY,
	id_emisor INT NOT NULL,
    id_socio INT DEFAULT NULL,
	id_invitado INT DEFAULT NULL,
	leyenda CHAR(50) NOT NULL,
	monto_total DECIMAL(10,2),
	saldo_anterior DECIMAL(10,2),
    fecha_emision DATE,
    fecha_vencimiento1 DATE,
	fecha_vencimiento2 DATE,
	estado CHAR(10),
    anulada BIT,
	CONSTRAINT FK_factura_emisor_id FOREIGN KEY (id_emisor) REFERENCES facturacion.Emisorfactura (id_emisor),
	CONSTRAINT FK_factura_socio_id FOREIGN KEY (id_socio) REFERENCES administracion.Socio (id_socio),
	CONSTRAINT FK_factura_invitado_id FOREIGN KEY (id_invitado) REFERENCES administracion.Invitado (id_invitado)
);
GO

IF OBJECT_ID('facturacion.DetalleFactura', 'U') IS NOT NULL
    DROP TABLE facturacion.DetalleFactura;
GO

CREATE TABLE facturacion.DetalleFactura (
    id_detalle INT IDENTITY(1,1) PRIMARY KEY,
    id_factura INT ,
	id_actividad INT,
	id_extra INT,
	id_categoria INT,
    tipo_item VARCHAR(50),
    descripcion VARCHAR(100),
    monto DECIMAL(10,2),
    cantidad INT,
	CONSTRAINT FK_detalleFactura_factura_id FOREIGN KEY (id_factura) REFERENCES facturacion.Factura (id_factura),
	CONSTRAINT FK_detalleFactura_actividad_id FOREIGN KEY (id_actividad) REFERENCES actividades.Actividad (id_actividad),
	CONSTRAINT FK_detalleFactura_actividadExtra_id FOREIGN KEY (id_extra) REFERENCES actividades.ActividadExtra (id_extra),
	CONSTRAINT FK_detalleFactura_categoriaSocio_id FOREIGN KEY (id_categoria) REFERENCES administracion.CategoriaSocio (id_categoria)
);
GO

/* ===========================
   TABLAS DEL MÓDULO COBRANZAS
   =========================== */

IF OBJECT_ID('cobranzas.MedioDePago', 'U') IS NOT NULL
    DROP TABLE cobranzas.MedioDePago;
GO

CREATE TABLE cobranzas.MedioDePago (
    id_medio INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(100),
    debito_automatico BIT
);
GO

IF OBJECT_ID('cobranzas.Pago', 'U') IS NOT NULL
    DROP TABLE cobranzas.Pago;
GO

CREATE TABLE cobranzas.Pago (
    id_pago INT IDENTITY(1,1) PRIMARY KEY,
	id_factura INT,
    id_medio INT,
	nro_transaccion INT,
	monto DECIMAL(10,2),
    fecha_emision DATETIME,
	fecha_vencimiento DATE,
    estado CHAR(10),
	CONSTRAINT FK_pago_factura_id FOREIGN KEY (id_factura) REFERENCES facturacion.Factura (id_factura),
	CONSTRAINT FK_pago_medio_id FOREIGN KEY (id_medio) REFERENCES cobranzas.MedioDePago (id_medio)
);
GO

IF OBJECT_ID('cobranzas.PagoACuenta', 'U') IS NOT NULL
    DROP TABLE cobranzas.PagoACuenta;
GO

CREATE TABLE cobranzas.PagoACuenta (
    id_pago_cuenta INT IDENTITY(1,1) PRIMARY KEY,
    id_pago INT,
	id_socio INT,
    monto DECIMAL(10,2),
    fecha DATE,
	motivo VARCHAR(100),
	CONSTRAINT FK_pagoACuenta_pago_id FOREIGN KEY (id_pago) REFERENCES cobranzas.Pago (id_pago),
	CONSTRAINT FK_pagoACuenta_socio_id FOREIGN KEY (id_socio) REFERENCES administracion.Socio (id_socio)
);
GO

IF OBJECT_ID('cobranzas.NotaDeCredito', 'U') IS NOT NULL
    DROP TABLE cobranzas.NotaDeCredito;
GO

CREATE TABLE cobranzas.NotaDeCredito (
    id_nota INT IDENTITY(1,1) PRIMARY KEY,
    id_factura INT,
    monto DECIMAL(10,2) NOT NULL,
    fecha_emision DATETIME NOT NULL,
	estado CHAR(20),
	motivo VARCHAR(100),
	CONSTRAINT FK_notaDeCredito_factura_id FOREIGN KEY (id_factura) REFERENCES facturacion.Factura (id_factura)
);
GO

IF OBJECT_ID('cobranzas.Mora', 'U') IS NOT NULL
    DROP TABLE cobranzas.Mora;
GO

CREATE TABLE cobranzas.Mora (
    id_mora INT IDENTITY(1,1) PRIMARY KEY,
    id_socio INT,
	id_factura INT,
	facturada BIT,
	monto DECIMAL(10,2),
	CONSTRAINT FK_mora_factura_id FOREIGN KEY (id_factura) REFERENCES facturacion.Factura (id_factura),
	CONSTRAINT FK_mora_socio_id FOREIGN KEY (id_socio) REFERENCES administracion.Socio (id_socio)
);
GO

IF OBJECT_ID('cobranzas.Notificacion', 'U') IS NOT NULL
    DROP TABLE cobranzas.Notificacion;
GO

CREATE TABLE cobranzas.Notificacion (
    id_notificacion INT IDENTITY(1,1) PRIMARY KEY,
    id_mora INT,
	mensaje VARCHAR(100),
    fecha DATE,
    destinatario VARCHAR(70),
	CONSTRAINT FK_notificacion_mora_id FOREIGN KEY (id_mora) REFERENCES cobranzas.Mora (id_mora)
);
GO