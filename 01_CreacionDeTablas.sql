/* =========================================================================
   Trabajo Práctico Integrador - Bases de Datos Aplicadas
   Grupo N°: 13
   Comisión: 2900
   Fecha de Entrega: 17/06/2025
   Materia: Bases de Datos Aplicadas
   Alumnos: Vignardel Francisco 45778667
            De Titto Lucia 46501934
            Benvenuto Franco 44760004
 ========================================================================= */
USE COM2900G13;
GO

DROP PROCEDURE IF EXISTS pagos.spRegistrarCobranza
DROP PROCEDURE IF EXISTS administracion.spGestionarPersonas

-- TABLAS DEPENDIENTES (pago, pago_a_cuenta, reembolso, etc.)
DROP TABLE IF EXISTS pagos.PagoACuenta;
DROP TABLE IF EXISTS pagos.Reembolso;
DROP TABLE IF EXISTS pagos.Pago;
DROP TABLE IF EXISTS pagos.MedioDePago;

-- OTRAS TABLAS CON RELACIONES CRUZADAS
DROP TABLE IF EXISTS facturacion.Notificacion;
DROP TABLE IF EXISTS facturacion.Morosidad;
DROP TABLE IF EXISTS facturacion.DetalleFactura;
DROP TABLE IF EXISTS facturacion.Factura;
DROP TABLE IF EXISTS facturacion.RazonSocial;

DROP TABLE IF EXISTS actividades.Clase;
DROP TABLE IF EXISTS actividades.Actividad;
DROP TABLE IF EXISTS actividades.Maestro;
DROP TABLE IF EXISTS actividades.ActividadExtra;

DROP TABLE IF EXISTS socios.Socio;
DROP TABLE IF EXISTS socios.GrupoFamiliar;
DROP TABLE IF EXISTS socios.CategoriaSocio;

DROP TABLE IF EXISTS administracion.Empleado;
DROP TABLE IF EXISTS administracion.Rol;
DROP TABLE IF EXISTS administracion.Area;
DROP TABLE IF EXISTS administracion.Persona;

-- ELIMINAR ESQUEMAS (una vez vacíos)
IF SCHEMA_ID('facturacion') IS NOT NULL
	DROP SCHEMA facturacion;

IF SCHEMA_ID('pagos') IS NOT NULL
	DROP SCHEMA pagos;

IF SCHEMA_ID('actividades') IS NOT NULL
	DROP SCHEMA actividades;

IF SCHEMA_ID('socios') IS NOT NULL
	DROP SCHEMA socios;

IF SCHEMA_ID('administracion') IS NOT NULL
	DROP SCHEMA administracion;
GO

-- Crear esquemas personalizados

CREATE SCHEMA administracion;
GO

CREATE SCHEMA socios;
GO

CREATE SCHEMA actividades;
GO

CREATE SCHEMA facturacion;
GO

CREATE SCHEMA pagos;
GO

/* =======================
   TABLAS DEL MÓDULO ADMINISTRACIÓN
   ======================= */

IF OBJECT_ID('administracion.Persona', 'U') IS NOT NULL
    DROP TABLE administracion.Persona;
GO

CREATE TABLE administracion.Persona (
	id_persona INT IDENTITY(1,1) PRIMARY KEY,
	nombre VARCHAR(50),
    apellido CHAR(50),
    dni CHAR(10),
    email VARCHAR(70),
    fecha_nacimiento DATE NOT NULL,
    tel_contacto CHAR(15),
    tel_emergencia CHAR(15),
	borrado BIT
);
GO

IF OBJECT_ID('administracion.Area', 'U') IS NOT NULL
    DROP TABLE administracion.Area;
GO

CREATE TABLE administracion.Area (
    id_area INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion VARCHAR(200)
);
GO

IF OBJECT_ID('administracion.Rol', 'U') IS NOT NULL
    DROP TABLE administracion.Rol;
GO

CREATE TABLE administracion.Rol (
    id_rol INT IDENTITY(1,1) PRIMARY KEY,
	id_area INT REFERENCES administracion.Area (id_area),
    nombre VARCHAR(100) NOT NULL,
    descripcion VARCHAR(200)
);
GO

IF OBJECT_ID('administracion.Empleado', 'U') IS NOT NULL
    DROP TABLE administracion.Empleado;
GO

CREATE TABLE administracion.Empleado (
    id_empleado INT IDENTITY(1,1) PRIMARY KEY,
	id_persona INT REFERENCES administracion.Persona (id_persona),
    id_area INT NOT NULL REFERENCES administracion.Area(id_area),
    id_rol INT NOT NULL REFERENCES administracion.Rol(id_rol),
    username VARCHAR(50) NOT NULL,
    password CHAR(64) NOT NULL,
    fecha_vencimiento_password DATE
);
GO

/* =======================
   TABLAS DEL MÓDULO SOCIOS
   ======================= */
IF OBJECT_ID('socios.GrupoFamiliar', 'U') IS NOT NULL
    DROP TABLE socios.GrupoFamiliar;
GO

CREATE TABLE socios.GrupoFamiliar (
    id_grupo INT IDENTITY(1,1) PRIMARY KEY,
    descuento DECIMAL(4,2)
);
GO

IF OBJECT_ID('socios.CategoriaSocio', 'U') IS NOT NULL
    DROP TABLE socios.CategoriaSocio;
GO

CREATE TABLE socios.CategoriaSocio (
    id_categoria INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(50),
    edad INT,
    costo_membresia DECIMAL(10,2),
    vigencia DATE
);
GO

IF OBJECT_ID('socios.Socio', 'U') IS NOT NULL
    DROP TABLE socios.Socio;
GO

CREATE TABLE socios.Socio (
    id_socio INT IDENTITY(1,1) PRIMARY KEY,
	id_persona INT REFERENCES administracion.Persona (id_persona),
    id_grupo INT REFERENCES socios.GrupoFamiliar (id_grupo),
    id_categoria INT REFERENCES socios.CategoriaSocio (id_categoria),
    obra_social VARCHAR(100),
    nro_obra_social INT,
    saldo DECIMAL(10,2),
    activo BIT,
);
GO

/*CREATE TABLE socios.Invitado (
    id_invitado INT PRIMARY KEY,
    id_socio_responsable INT,
    nombre VARCHAR(50),
    apellido VARCHAR(50),
    dni VARCHAR(8),
    email VARCHAR(100),
    tel_emergencia VARCHAR(20),
    nombre_obra_social VARCHAR(100),
    nro_obra_social VARCHAR(50),
    FOREIGN KEY (id_socio_responsable) REFERENCES socios.Socio(id_socio)
);
GO*/

/* =======================
   TABLAS DEL MÓDULO ACTIVIDADES
   ======================= */

IF OBJECT_ID('actividades.Maestro', 'U') IS NOT NULL
    DROP TABLE actividades.Maestro;
GO

CREATE TABLE actividades.Maestro (
    id_maestro INT IDENTITY(1,1) PRIMARY KEY,
    id_persona INT REFERENCES administracion.Persona (id_persona)
);
GO

IF OBJECT_ID('actividades.Actividad', 'U') IS NOT NULL
    DROP TABLE actividades.Actividad;
GO

CREATE TABLE actividades.Actividad (
    id_actividad INT IDENTITY(1,1) PRIMARY KEY,
    id_maestro INT REFERENCES actividades.Maestro (id_maestro),
    nombre VARCHAR(100),
    costo DECIMAL(10,2),
    horario VARCHAR(50)
);
GO

IF OBJECT_ID('actividades.ActividadExtra', 'U') IS NOT NULL
    DROP TABLE actividades.ActividadExtra;
GO

CREATE TABLE actividades.ActividadExtra (
    id_actividad_extra INT IDENTITY(1,1) PRIMARY KEY,
    debito_automatico BIT
);
GO

IF OBJECT_ID('actividades.Clase', 'U') IS NOT NULL
    DROP TABLE actividades.Clase;
GO

CREATE TABLE actividades.Clase (
    id_clase INT IDENTITY(1,1) PRIMARY KEY,
    id_actividad INT REFERENCES actividades.Actividad (id_actividad),
    fecha DATE,
    hubo_lluvia BIT,
    detalle VARCHAR(100)
);
GO

/* =======================
   TABLAS DEL MÓDULO FACTURACIÓN
   ======================= */

IF OBJECT_ID('pagos.RazonSocial', 'U') IS NOT NULL
    DROP TABLE facturacion.RazonSocial;
GO

CREATE TABLE facturacion.RazonSocial (
	id_emisor INT IDENTITY(1,1) PRIMARY KEY,
	razon_social VARCHAR(100),
	cuil VARCHAR(20) NOT NULL,
	direccion VARCHAR(200),
	pais VARCHAR(50),
	localidad VARCHAR(50),
	codigo_postal VARCHAR(50)
);
GO

IF OBJECT_ID('pagos.Factura', 'U') IS NOT NULL
    DROP TABLE facturacion.Factura;
GO

CREATE TABLE facturacion.Factura (
    id_factura INT IDENTITY(1,1) PRIMARY KEY,
    id_socio INT REFERENCES socios.Socio(id_socio) NOT NULL,
    fecha_emision DATE,
    vencimiento1 DATE,
	vencimiento2 DATE,
    monto_total DECIMAL(10,2),
	estado CHAR(10),
    anulada BIT
);
GO

IF OBJECT_ID('pagos.DetalleFactura', 'U') IS NOT NULL
    DROP TABLE facturacion.DetalleFactura;
GO

CREATE TABLE facturacion.DetalleFactura (
    id_detalle INT IDENTITY(1,1) PRIMARY KEY,
    id_factura INT REFERENCES facturacion.Factura (id_factura),
    tipo_item VARCHAR(50),
    descripcion VARCHAR(100),
    monto DECIMAL(10,2),
    cantidad INT
);
GO

IF OBJECT_ID('pagos.Morosidad', 'U') IS NOT NULL
    DROP TABLE facturacion.Morosidad;
GO

CREATE TABLE facturacion.Morosidad (
    id_morosidad INT IDENTITY(1,1) PRIMARY KEY,
    id_factura INT REFERENCES facturacion.Factura(id_factura),
    recargo DECIMAL(5,2),
	fecha_bloqueo DATE
);
GO

IF OBJECT_ID('pagos.Notificacion', 'U') IS NOT NULL
    DROP TABLE facturacion.Notificacion;
GO

CREATE TABLE facturacion.Notificacion (
    id_notificacion INT IDENTITY(1,1) PRIMARY KEY,
    id_morosidad INT REFERENCES facturacion.Factura(id_factura),
    fecha DATE,
    destinatario VARCHAR(70)
);
GO

/* =======================
   TABLAS DEL MÓDULO PAGOS
   ======================= */

IF OBJECT_ID('pagos.MedioDePago', 'U') IS NOT NULL
    DROP TABLE pagos.MedioDePago;
GO

CREATE TABLE pagos.MedioDePago (
    id_medio INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(50),
    debito_automatico BIT
);
GO

IF OBJECT_ID('pagos.Pago', 'U') IS NOT NULL
    DROP TABLE pagos.Pago;
GO

CREATE TABLE pagos.Pago (
    id_pago INT IDENTITY(1,1) PRIMARY KEY,
    id_socio INT REFERENCES socios.Socio (id_socio),
	id_factura INT REFERENCES facturacion.Factura (id_factura),
    id_medio INT REFERENCES pagos.MedioDePago (id_medio),
    id_actividad_extra INT REFERENCES actividades.ActividadExtra (id_actividad_extra),
    fecha DATE,
    monto DECIMAL(10,2),
    detalle VARCHAR(100),
);
GO

IF OBJECT_ID('pagos.PagoACuenta', 'U') IS NOT NULL
    DROP TABLE pagos.PagoACuenta;
GO

CREATE TABLE pagos.PagoACuenta (
    id_pago_cuenta INT IDENTITY(1,1) PRIMARY KEY,
    id_pago INT REFERENCES pagos.Pago (id_pago),
	id_socio INT REFERENCES socios.Socio (id_socio),
    monto DECIMAL(10,2),
    fecha DATE
);
GO

IF OBJECT_ID('pagos.Reembolso', 'U') IS NOT NULL
    DROP TABLE pagos.Reembolso;
GO

CREATE TABLE pagos.Reembolso (
    id_reembolso INT IDENTITY(1,1) PRIMARY KEY,
    id_pago INT REFERENCES pagos.Pago (id_pago),
	id_clase INT REFERENCES actividades.Clase (id_clase),
    motivo VARCHAR(100),
    monto DECIMAL(10,2),
    medio_pago_original VARCHAR(100),
    fecha DATE
);
GO

/*
CREATE TABLE Clima (
	id_clima INT IDENTITY(1,1) PRIMARY KEY,
	fecha DATE,
	hubo_lluvia BIT,
	detalle VARCHAR(100)
)
*/