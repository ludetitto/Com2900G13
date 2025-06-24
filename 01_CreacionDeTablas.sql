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

DROP PROCEDURE IF EXISTS administracion.GestionarInvitado
DROP PROCEDURE IF EXISTS administracion.GestionarSocio
DROP PROCEDURE IF EXISTS administracion.GestionarProfesor
DROP PROCEDURE IF EXISTS administracion.GestionarPersona
DROP PROCEDURE IF EXISTS administracion.GestionarCategoriaSocio
DROP PROCEDURE IF EXISTS administracion.GestionarGrupoFamiliar

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

DROP TABLE IF EXISTS administracion.MedioDePago;

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
DROP SCHEMA IF EXISTS administracion;
GO
DROP SCHEMA IF EXISTS socios;
GO

-- ===============================
-- Creación de esquemas
-- ===============================

CREATE SCHEMA socios;
GO
CREATE SCHEMA administracion;
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
-- Módulo: ADMINISTRACION
-- ===============================

CREATE TABLE administracion.MedioDePago (
    id_medio_pago INT IDENTITY PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    debito_automatico BIT NOT NULL
);

-- ===============================
-- Módulo: SOCIOS
-- ===============================

CREATE TABLE socios.CategoriaSocio (
    id_categoria INT IDENTITY PRIMARY KEY,
    descripcion VARCHAR(50),
    edad_minima INT,
    edad_maxima INT,
    costo DECIMAL(10,2),
    vigencia DATE
);
CREATE TABLE socios.Socio (
    id_socio INT IDENTITY PRIMARY KEY,
    nombre VARCHAR(50),
    apellido VARCHAR(50),
    dni CHAR(8),
    email VARCHAR(100),
    fecha_nacimiento DATE,
    telefono VARCHAR(20),
    telefono_emergencia VARCHAR(20),
    direccion VARCHAR(150),
    obra_social VARCHAR(100),
    nro_os VARCHAR(50),
    id_categoria INT NOT NULL,
    activo BIT,
    eliminado BIT,
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
    dni VARCHAR(10) NOT NULL,
    nombre CHAR(50) NOT NULL,
    apellido CHAR(50) NOT NULL,
    domicilio VARCHAR(200) NOT NULL,
    email VARCHAR(70) NOT NULL
);
GO
CREATE TABLE socios.Invitado (
    id_invitado INT IDENTITY PRIMARY KEY,
    dni CHAR(8),
    nombre VARCHAR(50),
    apellido VARCHAR(50),
    domicilio VARCHAR(150),
    email VARCHAR(100),
    id_socio INT NOT NULL
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
    descripcion VARCHAR(100),
    costo DECIMAL(10,2),
    vigencia DATE
);

CREATE TABLE actividades.Clase (
    id_clase INT IDENTITY PRIMARY KEY,
    id_actividad INT NOT NULL,
    id_categoria INT NOT NULL,
    horario VARCHAR(50),
    nombre_profesor VARCHAR(50),
    apellido_profesor VARCHAR(50)
);

CREATE TABLE actividades.InscriptoClase (
    id_inscripcion INT IDENTITY PRIMARY KEY,
	fecha DATE NOT NULL,
    id_socio INT NOT NULL,
    id_clase INT NOT NULL
);

CREATE TABLE actividades.PresentismoClase (
    id_presentismo INT IDENTITY PRIMARY KEY,
    id_inscripcion INT NOT NULL,
    fecha DATE NOT NULL,
    estado CHAR(1) -- P: Presente, A: Ausente, J: Justificado
);

CREATE TABLE actividades.InscriptoCategoriaSocio (
    id_inscripcion INT IDENTITY PRIMARY KEY,
    id_socio INT NOT NULL,
    id_categoria INT NOT NULL,
	fecha DATE NOT NULL,
	monto DECIMAL(10, 2) NOT NULL
);

CREATE TABLE actividades.InscriptoColoniaVerano (
    id_inscripcion INT IDENTITY PRIMARY KEY,
    id_socio INT NOT NULL,
    id_tarifa INT NOT NULL,
	fecha DATE NOT NULL,
	monto DECIMAL(10, 2) NOT NULL
);

CREATE TABLE actividades.InscriptoPiletaVerano (
    id_inscripcion INT IDENTITY PRIMARY KEY,
    id_socio INT,
	id_invitado INT,
    id_tarifa INT NOT NULL,
	fecha DATE NOT NULL,
	monto DECIMAL(10, 2) NOT NULL
);

-- ===============================
-- Módulo: TARIFAS
-- ===============================

CREATE TABLE tarifas.TarifaColoniaVerano (
    id_tarifa INT IDENTITY PRIMARY KEY,
    descripcion VARCHAR(100),
    monto DECIMAL(10,2),
	periodo CHAR(10),
	categoria VARCHAR(50)
);

CREATE TABLE tarifas.TarifaReservaSum (
    id_tarifa INT IDENTITY PRIMARY KEY,
    descripcion VARCHAR(100),
    monto DECIMAL(10,2)
);

CREATE TABLE tarifas.TarifaPiletaVerano (
    id_tarifa INT IDENTITY PRIMARY KEY,
    descripcion VARCHAR(100),
    monto DECIMAL(10,2),
	categoria VARCHAR(50),
    es_invitado BIT
);

-- ===============================
-- Módulo: RESERVAS
-- ===============================

CREATE TABLE reservas.ReservaSum (
    id_reserva INT IDENTITY PRIMARY KEY,
    id_socio INT NOT NULL,
    fecha DATE NOT NULL,
    hora_inicio TIME,
    hora_fin TIME,
    id_tarifa INT NOT NULL
);

-- ===============================
-- Módulo: FACTURACION
-- ===============================

CREATE TABLE facturacion.EmisorFactura (
    id_emisor INT IDENTITY PRIMARY KEY,
    razon_social VARCHAR(100),
    cuil CHAR(13) CHECK(cuil LIKE '[0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]-[0-9]'),
	direccion CHAR(50),
	pais VARCHAR(50),
	localidad VARCHAR(50),
	codigo_postal CHAR(4)
);



CREATE TABLE facturacion.CuotaMensual (
    id_cuota INT IDENTITY PRIMARY KEY,
    mes INT,
    anio INT
);

CREATE TABLE facturacion.CargoMembresias (
    id_cargo INT IDENTITY PRIMARY KEY,
    id_inscripcion_categoria INT NOT NULL,
    id_cuota INT NOT NULL
);

CREATE TABLE facturacion.CargoClases (
    id_cargo INT IDENTITY PRIMARY KEY,
    id_presentismo INT NOT NULL,
    id_cuota INT NOT NULL
);

CREATE TABLE facturacion.CargoActividadExtra (
    id_cargo INT IDENTITY PRIMARY KEY,
    id_inscripcion_colonia INT,
    id_inscripcion_pileta INT,
    id_reserva INT
);

CREATE TABLE facturacion.Factura (
    id_factura INT IDENTITY PRIMARY KEY,
    id_emisor INT NOT NULL,
    id_socio INT,
    monto_total DECIMAL(10,2),
    saldo_anterior DECIMAL(10,2),
    fecha_emision DATE,
    fecha_vencimiento1 DATE,
    fecha_vencimiento2 DATE,
    estado VARCHAR(20),
    anulada BIT DEFAULT 0,
    id_cuota INT,
    id_cargo_actividad_extra INT
);

CREATE TABLE facturacion.DetalleFactura (
    id_detalle INT IDENTITY PRIMARY KEY,
    id_factura INT NOT NULL,
    concepto VARCHAR(100),
    monto DECIMAL(10,2),
    tipo_concepto VARCHAR(50)
);

-- ===============================
-- Módulo: COBRANZAS
-- ===============================

CREATE TABLE cobranzas.Mora (
    id_mora INT IDENTITY PRIMARY KEY,
    id_factura INT NOT NULL,
    fecha_registro DATE,
    notificado BIT DEFAULT 0
);

CREATE TABLE cobranzas.Pago (
    id_pago INT IDENTITY PRIMARY KEY,
    id_factura INT NOT NULL,
    fecha_pago DATE,
    medio_pago VARCHAR(50),
    monto DECIMAL(10,2),
    debito_automatico BIT
);

CREATE TABLE cobranzas.Reembolso (
    id_reembolso INT IDENTITY PRIMARY KEY,
    id_pago INT NOT NULL,
    fecha DATE,
    motivo VARCHAR(100),
    monto DECIMAL(10,2)
);

CREATE TABLE cobranzas.PagoACuenta (
    id_pago_a_cuenta INT IDENTITY PRIMARY KEY,
    id_pago INT NOT NULL,
    id_socio INT NOT NULL,
    fecha DATE,
    monto DECIMAL(10,2)
);

-- ===============================
-- RELACIONES: SOCIOS
-- ===============================

ALTER TABLE socios.Socio
ADD CONSTRAINT FK_Socio_Categoria
    FOREIGN KEY (id_categoria) REFERENCES socios.CategoriaSocio(id_categoria);

ALTER TABLE socios.GrupoFamiliar
ADD CONSTRAINT FK_GrupoFamiliar_Representante
    FOREIGN KEY (id_socio_rp) REFERENCES socios.Socio(id_socio);


ALTER TABLE socios.Tutor
ADD CONSTRAINT FK_Tutor_GrupoFamiliar
    FOREIGN KEY (id_grupo) REFERENCES socios.GrupoFamiliar(id_grupo);


ALTER TABLE socios.Invitado
ADD CONSTRAINT FK_Invitado_Socio
    FOREIGN KEY (id_socio) REFERENCES socios.Socio(id_socio);

ALTER TABLE socios.DebitoAutomaticoSocio
ADD CONSTRAINT FK_Debito_Socio
    FOREIGN KEY (id_socio) REFERENCES socios.Socio(id_socio),
    CONSTRAINT FK_Debito_MedioPago
    FOREIGN KEY (id_medio_pago) REFERENCES administracion.MedioDePago(id_medio_pago);

-- ===============================
-- RELACIONES: ACTIVIDADES
-- ===============================

ALTER TABLE actividades.Clase
ADD CONSTRAINT FK_Clase_Actividad
    FOREIGN KEY (id_actividad) REFERENCES actividades.Actividad(id_actividad),
    CONSTRAINT FK_Clase_Categoria
    FOREIGN KEY (id_categoria) REFERENCES socios.CategoriaSocio(id_categoria);

ALTER TABLE actividades.InscriptoClase
ADD CONSTRAINT FK_InscriptoClase_Socio
    FOREIGN KEY (id_socio) REFERENCES socios.Socio(id_socio),
    CONSTRAINT FK_InscriptoClase_Clase
    FOREIGN KEY (id_clase) REFERENCES actividades.Clase(id_clase);

ALTER TABLE actividades.PresentismoClase
ADD CONSTRAINT FK_Presentismo_InscriptoClase
    FOREIGN KEY (id_inscripcion) REFERENCES actividades.InscriptoClase(id_inscripcion);

ALTER TABLE actividades.InscriptoCategoriaSocio
ADD CONSTRAINT FK_InscriptoCategoria_Socio
    FOREIGN KEY (id_socio) REFERENCES socios.Socio(id_socio),
    CONSTRAINT FK_InscriptoCategoria_Categoria
    FOREIGN KEY (id_categoria) REFERENCES socios.CategoriaSocio(id_categoria);

ALTER TABLE actividades.InscriptoColoniaVerano
ADD CONSTRAINT FK_InscriptoColonia_Socio
    FOREIGN KEY (id_socio) REFERENCES socios.Socio(id_socio),
    CONSTRAINT FK_InscriptoColonia_Tarifa
    FOREIGN KEY (id_tarifa) REFERENCES tarifas.TarifaColoniaVerano(id_tarifa);

ALTER TABLE actividades.InscriptoPiletaVerano
ADD CONSTRAINT FK_InscriptoPileta_Socio
    FOREIGN KEY (id_socio) REFERENCES socios.Socio(id_socio),
	CONSTRAINT FK_InscriptoPileta_Invitado
    FOREIGN KEY (id_invitado) REFERENCES socios.Invitado(id_invitado),
    CONSTRAINT FK_InscriptoPileta_Tarifa
    FOREIGN KEY (id_tarifa) REFERENCES tarifas.TarifaPiletaVerano(id_tarifa);

-- ===============================
-- RELACIONES: RESERVAS
-- ===============================

ALTER TABLE reservas.ReservaSum
ADD CONSTRAINT FK_ReservaSum_Socio
    FOREIGN KEY (id_socio) REFERENCES socios.Socio(id_socio),
    CONSTRAINT FK_ReservaSum_Tarifa
    FOREIGN KEY (id_tarifa) REFERENCES tarifas.TarifaReservaSum(id_tarifa);

-- ===============================
-- RELACIONES: FACTURACION
-- ===============================

ALTER TABLE facturacion.CargoMembresias
ADD CONSTRAINT FK_CargoMembresia_InscriptoCategoria
    FOREIGN KEY (id_inscripcion_categoria) REFERENCES actividades.InscriptoCategoriaSocio(id_inscripcion),
    CONSTRAINT FK_CargoMembresia_Cuota
    FOREIGN KEY (id_cuota) REFERENCES facturacion.CuotaMensual(id_cuota);

ALTER TABLE facturacion.CargoClases
ADD CONSTRAINT FK_CargoClase_Presentismo
    FOREIGN KEY (id_presentismo) REFERENCES actividades.PresentismoClase(id_presentismo),
    CONSTRAINT FK_CargoClase_Cuota
    FOREIGN KEY (id_cuota) REFERENCES facturacion.CuotaMensual(id_cuota);

ALTER TABLE facturacion.CargoActividadExtra
ADD CONSTRAINT FK_CargoExtra_Colonia
    FOREIGN KEY (id_inscripcion_colonia) REFERENCES actividades.InscriptoColoniaVerano(id_inscripcion),
    CONSTRAINT FK_CargoExtra_Pileta
    FOREIGN KEY (id_inscripcion_pileta) REFERENCES actividades.InscriptoPiletaVerano(id_inscripcion),
    CONSTRAINT FK_CargoExtra_Reserva
    FOREIGN KEY (id_reserva) REFERENCES reservas.ReservaSum(id_reserva);

ALTER TABLE facturacion.Factura
ADD CONSTRAINT FK_Factura_Emisor
    FOREIGN KEY (id_emisor) REFERENCES facturacion.EmisorFactura(id_emisor),
    CONSTRAINT FK_Factura_Socio
    FOREIGN KEY (id_socio) REFERENCES socios.Socio(id_socio),
    CONSTRAINT FK_Factura_Cuota
    FOREIGN KEY (id_cuota) REFERENCES facturacion.CuotaMensual(id_cuota),
    CONSTRAINT FK_Factura_CargoExtra
    FOREIGN KEY (id_cargo_actividad_extra) REFERENCES facturacion.CargoActividadExtra(id_cargo);

ALTER TABLE facturacion.DetalleFactura
ADD CONSTRAINT FK_DetalleFactura_Factura
    FOREIGN KEY (id_factura) REFERENCES facturacion.Factura(id_factura);

-- ===============================
-- RELACIONES: COBRANZAS
-- ===============================

ALTER TABLE cobranzas.Mora
ADD CONSTRAINT FK_Mora_Factura
    FOREIGN KEY (id_factura) REFERENCES facturacion.Factura(id_factura);

ALTER TABLE cobranzas.Pago
ADD CONSTRAINT FK_Pago_Factura
    FOREIGN KEY (id_factura) REFERENCES facturacion.Factura(id_factura);

ALTER TABLE cobranzas.Reembolso
ADD CONSTRAINT FK_Reembolso_Pago
    FOREIGN KEY (id_pago) REFERENCES cobranzas.Pago(id_pago);

ALTER TABLE cobranzas.PagoACuenta
ADD CONSTRAINT FK_PagoACuenta_Pago
    FOREIGN KEY (id_pago) REFERENCES cobranzas.Pago(id_pago),
    CONSTRAINT FK_PagoACuenta_Socio
    FOREIGN KEY (id_socio) REFERENCES socios.Socio(id_socio);

--Tablas de la base de datos
SELECT TABLE_SCHEMA, TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_SCHEMA, TABLE_NAME;