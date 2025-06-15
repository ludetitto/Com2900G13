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
CREATE LOGIN jefe_tesoreria WITH PASSWORD = 'jefe_tesoreria' MUST_CHANGE, CHECK_EXPIRATION = ON;GOCREATE USER jefe_tesoreria FOR LOGIN jefe_tesoreria;GOALTER ROLE tesoreria ADD MEMBER jefe_tesoreria;GO--///////////////////////////////////////////////////CREATE LOGIN admin_cobranza WITH PASSWORD = 'admin_cobranza' MUST_CHANGE, CHECK_EXPIRATION = ON;
GO
CREATE USER admin_cobranza FOR LOGIN admin_cobranza;GO

ALTER ROLE tesoreria ADD MEMBER admin_cobranza;
GO

--///////////////////////////////////////////////////

CREATE LOGIN admin_morosidad WITH PASSWORD = 'admin_morosidad' MUST_CHANGE, CHECK_EXPIRATION = ON;
CREATE USER admin_morosidad FOR LOGIN admin_morosidad;
ALTER ROLE tesoreria ADD MEMBER admin_morosidad;
GO

--///////////////////////////////////////////////////

CREATE LOGIN admin_facturacion WITH PASSWORD = 'admin_facturacion' MUST_CHANGE, CHECK_EXPIRATION = ON;GO

CREATE USER admin_facturacion FOR LOGIN admin_facturacion;GO

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
