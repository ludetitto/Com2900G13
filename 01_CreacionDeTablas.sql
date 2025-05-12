-- Trabajo Práctico Integrador - Entrega 4
-- Fecha: 19/05/2025
-- Comisión: 2900 - Grupo: 13
-- Materia: Bases de Datos Aplicadas
-- Descripción: Creación de tablas con validación para reejecución segura

-- Crear esquema si no existe
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'sol_norte')
    EXEC('CREATE SCHEMA sol_norte');
GO

-- Eliminar tablas si existen (en orden inverso por dependencias)
DROP TABLE IF EXISTS
    sol_norte.Notificacion,
    sol_norte.Morosidad,
    sol_norte.Reintegro,
    sol_norte.Clima,
    sol_norte.PagoACuenta,
    sol_norte.Pago,
    sol_norte.DetalleFactura,
    sol_norte.Factura,
    sol_norte.MedioDePago,
    sol_norte.ActividadExtra,
    sol_norte.Actividad,
    sol_norte.Invitado,
    sol_norte.Socio,
    sol_norte.GrupoFamiliar,
    sol_norte.Usuario,
    sol_norte.CategoriaSocio,
    sol_norte.RolSocio;
GO

-- Crear tablas (orden correcto)

CREATE TABLE sol_norte.RolSocio (
    id_rol INT PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL,
    descripcion VARCHAR(100)
);

CREATE TABLE sol_norte.CategoriaSocio (
    id_categoria INT PRIMARY KEY,
    nombre VARCHAR(50),
    años INT,
    costo_membresía DECIMAL(10, 2),
    vigencia DATE
);

CREATE TABLE sol_norte.Usuario (
    id_usuario INT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    password VARCHAR(64) NOT NULL,
    rol VARCHAR(20),
    fecha_vencimiento_password DATE
);

CREATE TABLE sol_norte.GrupoFamiliar (
    id_grupo INT PRIMARY KEY,
    id_adulto_responsable INT,
    descuento DECIMAL(5, 2)
);

CREATE TABLE sol_norte.Socio (
    id_socio INT PRIMARY KEY,
    id_usuario INT NOT NULL,
    id_categoria INT NOT NULL,
    id_rol INT NOT NULL,
    dni INT NOT NULL,
    nombre VARCHAR(50),
    apellido VARCHAR(50),
    email VARCHAR(70),
    fecha_nacimiento DATE,
    tel_contacto VARCHAR(20),
    tel_emergencia VARCHAR(20),
    nombre_obra_social VARCHAR(50),
    nro_obra_social INT,
    FOREIGN KEY (id_usuario) REFERENCES sol_norte.Usuario(id_usuario),
    FOREIGN KEY (id_categoria) REFERENCES sol_norte.CategoriaSocio(id_categoria),
    FOREIGN KEY (id_rol) REFERENCES sol_norte.RolSocio(id_rol)
);

CREATE TABLE sol_norte.Invitado (
    id_invitado INT PRIMARY KEY,
    id_socio_responsable INT NOT NULL,
    nombre VARCHAR(50),
    apellido VARCHAR(50),
    dni INT,
    email VARCHAR(70),
    tel_emergencia VARCHAR(20),
    nombre_obra_social VARCHAR(50),
    nro_obra_social INT,
    FOREIGN KEY (id_socio_responsable) REFERENCES sol_norte.Socio(id_socio)
);

CREATE TABLE sol_norte.Actividad (
    id_actividad INT PRIMARY KEY,
    nombre VARCHAR(50),
    costo DECIMAL(10, 2),
    horarios VARCHAR(100)
);

CREATE TABLE sol_norte.ActividadExtra (
    id_extra INT PRIMARY KEY,
    nombre VARCHAR(50),
    costo DECIMAL(10, 2)
);

CREATE TABLE sol_norte.MedioDePago (
    id_medio INT PRIMARY KEY,
    nombre VARCHAR(50),
    debito_automatico BIT
);

CREATE TABLE sol_norte.Factura (
    id_factura INT PRIMARY KEY,
    fecha_emision DATE,
    vencimiento1 DATE,
    vencimiento2 DATE,
    monto_total DECIMAL(10, 2),
    estado VARCHAR(20)
);

CREATE TABLE sol_norte.DetalleFactura (
    id_detalle_factura INT PRIMARY KEY,
    id_factura INT NOT NULL,
    tipo_item VARCHAR(50),
    descripcion VARCHAR(100),
    monto DECIMAL(10, 2),
    cantidad INT,
    FOREIGN KEY (id_factura) REFERENCES sol_norte.Factura(id_factura)
);

CREATE TABLE sol_norte.Pago (
    id_pago INT PRIMARY KEY,
    id_socio INT NOT NULL,
    id_factura INT NOT NULL,
    id_medio INT,
    id_extra INT,
    monto DECIMAL(10, 2),
    fecha DATE,
    estado VARCHAR(20),
    FOREIGN KEY (id_socio) REFERENCES sol_norte.Socio(id_socio),
    FOREIGN KEY (id_factura) REFERENCES sol_norte.Factura(id_factura),
    FOREIGN KEY (id_medio) REFERENCES sol_norte.MedioDePago(id_medio),
    FOREIGN KEY (id_extra) REFERENCES sol_norte.ActividadExtra(id_extra)
);

CREATE TABLE sol_norte.PagoACuenta (
    id_pago_cuenta INT PRIMARY KEY,
    id_pago INT NOT NULL,
    id_socio INT NOT NULL,
    monto DECIMAL(10, 2),
    fecha DATE,
    FOREIGN KEY (id_pago) REFERENCES sol_norte.Pago(id_pago),
    FOREIGN KEY (id_socio) REFERENCES sol_norte.Socio(id_socio)
);

CREATE TABLE sol_norte.Clima (
    id_clima INT PRIMARY KEY,
    fecha DATE,
    hubo_lluvia BIT,
    detalle VARCHAR(100)
);

CREATE TABLE sol_norte.Reintegro (
    id_reintegro INT PRIMARY KEY,
    id_pago INT NOT NULL,
    id_pago_cuenta INT NOT NULL,
    id_clima INT NOT NULL,
    motivo VARCHAR(100),
    monto DECIMAL(10, 2),
    fecha DATE,
    FOREIGN KEY (id_pago) REFERENCES sol_norte.Pago(id_pago),
    FOREIGN KEY (id_pago_cuenta) REFERENCES sol_norte.PagoACuenta(id_pago_cuenta),
    FOREIGN KEY (id_clima) REFERENCES sol_norte.Clima(id_clima)
);

CREATE TABLE sol_norte.Morosidad (
    id_morosidad INT PRIMARY KEY,
    id_factura INT NOT NULL,
    recargo DECIMAL(5, 2),
    fecha_bloqueo DATE,
    FOREIGN KEY (id_factura) REFERENCES sol_norte.Factura(id_factura)
);

CREATE TABLE sol_norte.Notificacion (
    id_notificacion INT PRIMARY KEY,
    id_morosidad INT NOT NULL,
    mensaje VARCHAR(100),
    fecha DATE,
    destinatario VARCHAR(100),
    FOREIGN KEY (id_morosidad) REFERENCES sol_norte.Morosidad(id_morosidad)
);
