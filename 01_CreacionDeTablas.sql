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
USE SolNorteDB;
GO

-- Crear esquemas personalizados
CREATE SCHEMA administracion;
GO

CREATE SCHEMA socios;
GO

CREATE SCHEMA actividades;
GO

CREATE SCHEMA pagos;
GO

CREATE SCHEMA facturacion;
GO

/* =======================
   TABLAS DEL MÓDULO ADMINISTRACIÓN
   ======================= */

CREATE TABLE administracion.Area (
    id_area INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion VARCHAR(200)
);
GO

CREATE TABLE administracion.Rol (
    id_rol INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion VARCHAR(200)
);
GO

CREATE TABLE administracion.Usuario (
    id_usuario INT PRIMARY KEY,
    id_area INT NOT NULL,
    id_rol INT NOT NULL,
    username VARCHAR(50) NOT NULL,
    password VARCHAR(100) NOT NULL,
    fecha_vencimiento_password DATE,
    FOREIGN KEY (id_area) REFERENCES administracion.Area(id_area),
    FOREIGN KEY (id_rol) REFERENCES administracion.Rol(id_rol)
);
GO

/* =======================
   TABLAS DEL MÓDULO SOCIOS
   ======================= */

CREATE TABLE socios.GrupoFamiliar (
    id_grupo INT PRIMARY KEY,
    id_socio_ref INT NOT NULL,
    descuento DECIMAL(4,2)
);
GO

CREATE TABLE socios.CategoriaSocio (
    id_categoria INT PRIMARY KEY,
    nombre VARCHAR(50),
    edad INT,
    costo_membresia DECIMAL(8,2),
    vigencia DATE
);
GO

CREATE TABLE socios.Socio (
    id_socio INT PRIMARY KEY,
    id_grupo INT,
    id_categoria INT NOT NULL,
    nombre VARCHAR(50),
    apellido VARCHAR(50),
    dni CHAR(8),
    email VARCHAR(100),
    fecha_nacimiento DATE,
    tel_contacto VARCHAR(20),
    tel_emergencia VARCHAR(20),
    obra_social VARCHAR(100),
    nro_obra_social VARCHAR(50),
    saldo DECIMAL(10,2),
    activo BIT,
    FOREIGN KEY (id_grupo) REFERENCES socios.GrupoFamiliar(id_grupo),
    FOREIGN KEY (id_categoria) REFERENCES socios.CategoriaSocio(id_categoria)
);
GO

CREATE TABLE socios.Invitado (
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
GO

/* =======================
   TABLAS DEL MÓDULO ACTIVIDADES
   ======================= */

CREATE TABLE actividades.Meastro (
    id_maestro INT PRIMARY KEY,
    nombre VARCHAR(100),
    apellido VARCHAR(100),
    tel_contacto VARCHAR(50)
);
GO

CREATE TABLE actividades.Actividad (
    id_actividad INT PRIMARY KEY,
    id_maestro INT,
    nombre VARCHAR(100),
    costo DECIMAL(7,2),
    horario NVARCHAR(50),
    FOREIGN KEY (id_maestro) REFERENCES actividades.Meastro(id_maestro)
);
GO

/* =======================
   TABLAS DEL MÓDULO PAGOS
   ======================= */

CREATE TABLE pagos.MedioDePago (
    id_medio INT PRIMARY KEY,
    nombre VARCHAR(50),
    debito_automatico BIT
);
GO

CREATE TABLE pagos.Pago (
    id_pago INT PRIMARY KEY,
    id_socio INT,
    id_medio INT,
    id_actividad INT,
    fecha DATE,
    monto DECIMAL(10,2),
    detalle VARCHAR(100),
    FOREIGN KEY (id_socio) REFERENCES socios.Socio(id_socio),
    FOREIGN KEY (id_medio) REFERENCES pagos.MedioDePago(id_medio),
    FOREIGN KEY (id_actividad) REFERENCES actividades.Actividad(id_actividad)
);
GO

CREATE TABLE pagos.PagoACuenta (
    id_pago_cuenta INT PRIMARY KEY,
    id_pago INT,
    monto DECIMAL(10,2),
    fecha DATE,
    FOREIGN KEY (id_pago) REFERENCES pagos.Pago(id_pago)
);
GO

CREATE TABLE pagos.Reembolso (
    id_reembolso INT PRIMARY KEY,
    id_pago INT,
    medio VARCHAR(100),
    monto DECIMAL(10,2),
    medio_pago_original VARCHAR(100),
    fecha DATE,
    FOREIGN KEY (id_pago) REFERENCES pagos.Pago(id_pago)
);
GO

/* =======================
   TABLAS DEL MÓDULO FACTURACIÓN Y CLASES
   ======================= */

CREATE TABLE facturacion.Factura (
    id_factura INT PRIMARY KEY,
    id_socio INT NOT NULL,
    fecha_emision DATE,
    vencimiento DATE,
    estado VARCHAR(20),
    monto_total DECIMAL(10,2),
    anulada BIT,
    FOREIGN KEY (id_socio) REFERENCES socios.Socio(id_socio)
);
GO

CREATE TABLE facturacion.DetalleFactura (
    id_detalle INT PRIMARY KEY,
    id_factura INT,
    tipo_item VARCHAR(50),
    descripcion VARCHAR(100),
    monto DECIMAL(10,2),
    cantidad INT,
    FOREIGN KEY (id_factura) REFERENCES facturacion.Factura(id_factura)
);
GO

CREATE TABLE actividades.Clase (
    id_clase INT PRIMARY KEY,
    id_actividad INT,
    fecha DATE,
    hubo_lluvia BIT,
    detalle VARCHAR(100),
    FOREIGN KEY (id_actividad) REFERENCES actividades.Actividad(id_actividad)
);
GO

CREATE TABLE facturacion.Morosidad (
    id_morosidad INT PRIMARY KEY,
    id_factura INT,
    fecha_2do_venc DATE,
    recargo DECIMAL(10,2),
    FOREIGN KEY (id_factura) REFERENCES facturacion.Factura(id_factura)
);
GO

CREATE TABLE facturacion.Notificacion (
    id_notif INT PRIMARY KEY,
    id_factura INT,
    fecha DATE,
    destinatario VARCHAR(100),
    FOREIGN KEY (id_factura) REFERENCES facturacion.Factura(id_factura)
);
GO