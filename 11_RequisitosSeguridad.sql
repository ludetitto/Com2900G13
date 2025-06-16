/* =========================================================================
   Trabajo Práctico Integrador - Bases de Datos Aplicadas
   Grupo N°: 13
   Comisión: 2900
   Fecha de Entrega: 17/06/2025
   Materia: Bases de Datos Aplicadas
   Alumnos: Vignardel Francisco 45778667
            De Titto Lucia 46501934
   ========================================================================= */

USE COM2900G13
GO

/*____________________________________________________________________
  ________________________ ASIGNACIÓN DE ROLES _______________________
  ____________________________________________________________________*/

/*	------------------------------------------------------
	1) CREACIÓN DE ROLES
	------------------------------------------------------
	- tesoreria: Para usuarios que manejan tareas de facturación y cobranzas.
	- socios: Para usuarios relacionados con la gestión administrativa de socios.
	- autoridades: Para cargos de alta jerarquía que necesitan acceso amplio a datos.
	------------------------------------------------------*/

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'tesoreria' AND type = 'R')
    CREATE ROLE tesoreria;
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'socios' AND type = 'R')
    CREATE ROLE socios;
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'autoridades' AND type = 'R')
    CREATE ROLE autoridades;
GO

/*	------------------------------------------------------
	2) CREACIÓN DE USUARIOS Y ASIGNACIÓN A ROLES
	------------------------------------------------------
	- Se crean los logins y usuarios correspondientes, con política de cambio
	  obligatorio de contraseña en el primer inicio.
	- Cada usuario se agrega al rol que corresponda según su función:
	   * Jefe y admins de tesorería → rol 'tesoreria'
	   * Usuarios administrativos de socios → rol 'socios'
	   * Presidente, vicepresidente, secretario y vocal → rol 'autoridades'
	------------------------------------------------------*/

CREATE LOGIN jefe_tesoreria WITH PASSWORD = 'jefe_tesoreria' MUST_CHANGE, CHECK_EXPIRATION = ON;
GO

CREATE USER jefe_tesoreria FOR LOGIN jefe_tesoreria;
GO

ALTER ROLE tesoreria ADD MEMBER jefe_tesoreria;
GO

--///////////////////////////////////////////////////

CREATE LOGIN admin_cobranza WITH PASSWORD = 'admin_cobranza' MUST_CHANGE, CHECK_EXPIRATION = ON;
GO

CREATE USER admin_cobranza FOR LOGIN admin_cobranza;
GO

ALTER ROLE tesoreria ADD MEMBER admin_cobranza;
GO

--///////////////////////////////////////////////////

CREATE LOGIN admin_morosidad WITH PASSWORD = 'admin_morosidad' MUST_CHANGE, CHECK_EXPIRATION = ON;
CREATE USER admin_morosidad FOR LOGIN admin_morosidad;
ALTER ROLE tesoreria ADD MEMBER admin_morosidad;
GO

--///////////////////////////////////////////////////

CREATE LOGIN admin_facturacion WITH PASSWORD = 'admin_facturacion' MUST_CHANGE, CHECK_EXPIRATION = ON;
GO

CREATE USER admin_facturacion FOR LOGIN admin_facturacion;
GO

ALTER ROLE tesoreria ADD MEMBER admin_facturacion;
GO

--///////////////////////////////////////////////////

CREATE LOGIN admin_socio WITH PASSWORD = 'admin_socio' MUST_CHANGE, CHECK_EXPIRATION = ON;
GO

CREATE USER admin_socio FOR LOGIN admin_socio;
GO

ALTER ROLE socios ADD MEMBER admin_socio;
GO

--///////////////////////////////////////////////////

CREATE LOGIN socio_web WITH PASSWORD = 'socio_web' MUST_CHANGE, CHECK_EXPIRATION = ON;
GO

CREATE USER socio_web FOR LOGIN socio_web;
GO

ALTER ROLE socios ADD MEMBER socio_web;
GO

--///////////////////////////////////////////////////

CREATE LOGIN presidente WITH PASSWORD = 'presidente' MUST_CHANGE, CHECK_EXPIRATION = ON;
GO

CREATE USER presidente FOR LOGIN presidente;
GO

ALTER ROLE autoridades ADD MEMBER presidente;
GO

--///////////////////////////////////////////////////

CREATE LOGIN vicepresidente WITH PASSWORD = 'vicepresidente' MUST_CHANGE, CHECK_EXPIRATION = ON;
GO

CREATE USER vicepresidente FOR LOGIN vicepresidente;
GO

ALTER ROLE autoridades ADD MEMBER vicepresidente;
GO

--///////////////////////////////////////////////////

CREATE LOGIN secretario WITH PASSWORD = 'secretario' MUST_CHANGE, CHECK_EXPIRATION = ON;
GO

CREATE USER secretario FOR LOGIN secretario;
GO

ALTER ROLE autoridades ADD MEMBER secretario;
GO

--///////////////////////////////////////////////////

CREATE LOGIN vocal WITH PASSWORD = 'vocal' MUST_CHANGE, CHECK_EXPIRATION = ON;
GO

CREATE USER vocal FOR LOGIN vocal;
GO

ALTER ROLE autoridades ADD MEMBER vocal;
GO

/*	------------------------------------------------------
	3) ASIGNACIÓN DE PERMISOS POR ROL
	------------------------------------------------------
	- El rol 'tesoreria' tiene permisos para leer (SELECT), crear (INSERT) y modificar (UPDATE)
	  en los esquemas 'facturacion' y 'cobranzas'.
	- El rol 'socios' tiene permisos para leer, crear y modificar en el esquema 'administracion'.
	- El rol 'autoridades' tiene permisos amplios de lectura, creación y modificación en
	  varios esquemas: 'administracion', 'actividades', 'facturacion' y 'cobranzas'.
	------------------------------------------------------
	- A pesar de pertenecer a roles con permisos amplios, a ciertos usuarios se les 
  deniegan permisos específicos para evitar modificaciones indebidas:
	   * admin_cobranza y admin_morosidad no pueden insertar ni actualizar en 'facturacion'.
	   * admin_facturacion no puede insertar ni actualizar en 'cobranzas'.
	   * socio_web no puede insertar ni actualizar en 'facturacion'.
	   * secretario y vocal tienen solo permisos de lectura en 'facturacion' (se les niega insertar y actualizar).
   ------------------------------------------------------*/

GRANT SELECT, INSERT, UPDATE ON SCHEMA::facturacion TO tesoreria
GRANT SELECT, INSERT, UPDATE ON SCHEMA::cobranzas TO tesoreria

DENY INSERT, UPDATE ON SCHEMA::facturacion TO admin_cobranza
DENY INSERT, UPDATE ON SCHEMA::facturacion TO admin_morosidad
DENY INSERT, UPDATE ON SCHEMA::cobranzas TO admin_facturacion

GRANT SELECT, INSERT, UPDATE ON SCHEMA::administracion TO socios

DENY INSERT, UPDATE ON SCHEMA::facturacion TO socio_web

GRANT SELECT, INSERT, UPDATE ON SCHEMA::administracion TO autoridades
GRANT SELECT, INSERT, UPDATE ON SCHEMA::actividades TO autoridades
GRANT SELECT, INSERT, UPDATE, INSERT, UPDATEECT ON SCHEMA::facturacion TO autoridades
GRANT SELECT, INSERT, UPDATE ON SCHEMA::cobranzas TO autoridades

DENY INSERT, UPDATE ON SCHEMA::facturacion TO secretario
DENY INSERT, UPDATE ON SCHEMA::facturacion TO vocal

/* ------------------------------------------------------
   4) CIFRADO DE DATOS SENSIBLES EN TABLAS CRÍTICAS
   ------------------------------------------------------
   - Se agregan columnas VARBINARY para guardar los datos cifrados.
   - Se usa EncryptByPassPhrase() para cifrar campos sensibles.
   - El passphrase debería venir desde la capa de aplicación segura.
   ------------------------------------------------------*/

USE COM2900G13;
GO

/*____________________________________________________________________
  _______________________ ENCRIPTACIÓN DE DATOS ______________________
  ____________________________________________________________________*/

/*	------------------------------------------------------
	1) REVISIÓN DE DUPLICIDAD
	------------------------------------------------------
	Asegurar que las columnas no estén duplicadas
	------------------------------------------------------*/

IF COL_LENGTH('administracion.Persona', 'dni_cifrado') IS NULL
ALTER TABLE administracion.Persona
ADD dni_cifrado VARBINARY(256),
    fecha_nacimiento_cifrado VARBINARY(256),
    email_cifrado VARBINARY(256),
    tel_contacto_cifrado VARBINARY(256),
    tel_emergencia_cifrado VARBINARY(256);
GO

IF COL_LENGTH('administracion.Socio', 'obra_social_cifrada') IS NULL
ALTER TABLE administracion.Socio
ADD obra_social_cifrada VARBINARY(256),
    nro_obra_social_cifrada VARBINARY(256),
    saldo_cifrado VARBINARY(256);
GO

IF COL_LENGTH('administracion.Invitado', 'dni_cifrado') IS NULL
ALTER TABLE administracion.Invitado
ADD dni_cifrado VARBINARY(256);
GO

IF COL_LENGTH('facturacion.Factura', 'monto_total_cifrado') IS NULL
ALTER TABLE facturacion.Factura
ADD monto_total_cifrado VARBINARY(256);
GO

IF COL_LENGTH('cobranzas.Pago', 'monto_cifrado') IS NULL
ALTER TABLE cobranzas.Pago
ADD monto_cifrado VARBINARY(256);
GO

IF COL_LENGTH('cobranzas.PagoACuenta', 'monto_cifrado') IS NULL
ALTER TABLE cobranzas.PagoACuenta
ADD monto_cifrado VARBINARY(256);
GO

IF COL_LENGTH('cobranzas.NotaDeCredito', 'monto_cifrado') IS NULL
ALTER TABLE cobranzas.NotaDeCredito
ADD monto_cifrado VARBINARY(256),
    motivo_cifrado VARBINARY(256);
GO

/*	------------------------------------------------------
	2) CIFRADO POR TABLA
	------------------------------------------------------
	Cifrar los campos de todas las tablas que contienen 
	datos sensibles.
	------------------------------------------------------*/

-- Persona
DECLARE @passphrase NVARCHAR(128) = 'SolNorteClaveSegura';
UPDATE administracion.Persona
SET dni_cifrado = EncryptByPassPhrase(@passphrase, CAST(dni AS NVARCHAR(20)), 1, CONVERT(VARBINARY, id_persona)),
    fecha_nacimiento_cifrado = EncryptByPassPhrase(@passphrase, CAST(fecha_nacimiento AS NVARCHAR(20)), 1, CONVERT(VARBINARY, id_persona)),
    email_cifrado = EncryptByPassPhrase(@passphrase, email, 1, CONVERT(VARBINARY, id_persona)),
    tel_contacto_cifrado = EncryptByPassPhrase(@passphrase, tel_contacto, 1, CONVERT(VARBINARY, id_persona)),
    tel_emergencia_cifrado = EncryptByPassPhrase(@passphrase, tel_emergencia, 1, CONVERT(VARBINARY, id_persona));
GO

-- Socio
DECLARE @passphrase NVARCHAR(128) = 'SolNorteClaveSegura';
UPDATE administracion.Socio
SET obra_social_cifrada = EncryptByPassPhrase(@passphrase, obra_social, 1, CONVERT(VARBINARY, id_socio)),
    nro_obra_social_cifrada = EncryptByPassPhrase(@passphrase, nro_obra_social, 1, CONVERT(VARBINARY, id_socio)),
    saldo_cifrado = EncryptByPassPhrase(@passphrase, CAST(saldo AS NVARCHAR(30)), 1, CONVERT(VARBINARY, id_socio));
GO

-- Invitado
DECLARE @passphrase NVARCHAR(128) = 'SolNorteClaveSegura';
UPDATE administracion.Invitado
SET dni_cifrado = EncryptByPassPhrase(@passphrase, CAST(dni AS NVARCHAR(20)), 1, CONVERT(VARBINARY, id_invitado));
GO

-- Factura
DECLARE @passphrase NVARCHAR(128) = 'SolNorteClaveSegura';
UPDATE facturacion.Factura
SET monto_total_cifrado = EncryptByPassPhrase(@passphrase, CAST(monto_total AS NVARCHAR(30)), 1, CONVERT(VARBINARY, id_factura));
GO

-- Pago
DECLARE @passphrase NVARCHAR(128) = 'SolNorteClaveSegura';
UPDATE cobranzas.Pago
SET monto_cifrado = EncryptByPassPhrase(@passphrase, CAST(monto AS NVARCHAR(30)), 1, CONVERT(VARBINARY, id_pago));
GO

-- PagoACuenta
DECLARE @passphrase NVARCHAR(128) = 'SolNorteClaveSegura';
UPDATE cobranzas.PagoACuenta
SET monto_cifrado = EncryptByPassPhrase(@passphrase, CAST(monto AS NVARCHAR(30)), 1, CONVERT(VARBINARY, id_pago_cuenta));
GO

-- NotaDeCredito
DECLARE @passphrase NVARCHAR(128) = 'SolNorteClaveSegura';
UPDATE cobranzas.NotaDeCredito
SET monto_cifrado = EncryptByPassPhrase(@passphrase, CAST(monto AS NVARCHAR(30)), 1, CONVERT(VARBINARY, id_nota)),
    motivo_cifrado = EncryptByPassPhrase(@passphrase, motivo, 1, CONVERT(VARBINARY, id_nota));
GO
