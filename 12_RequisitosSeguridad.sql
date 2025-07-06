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

   Consgina: Asigne los roles correspondientes para poder cumplir con este requisito, según el área a la
cual pertenece.
Por otra parte, se requiere que los datos de los empleados se encuentren encriptados, dado
que los mismos contienen información personal.
La información de las cuotas pagadas y adeudadas es de vital importancia para el negocio,
por ello se requiere que se establezcan políticas de respaldo tanto en las ventas diarias
generadas como en los reportes generados.
Plantee una política de respaldo adecuada para cumplir con este requisito y justifique la
misma. No es necesario que incluya el código de creación de los respaldos.
Debe documentar la programación (Schedule) de los backups por día/semana/mes (de
acuerdo a lo que decidan) e indicar el RPO.
   ========================================================================= */

USE COM2900G13
GO

-- Eliminar columnas cifradas

IF EXISTS (
    SELECT * FROM sys.columns 
    WHERE Name = N'saldo_cifrado' 
      AND Object_ID = Object_ID(N'socios.Socio')
)
BEGIN
    ALTER TABLE socios.Socio DROP COLUMN saldo_cifrado;
END

IF EXISTS (
    SELECT * FROM sys.columns 
    WHERE Name = N'monto_cifrado' 
      AND Object_ID = Object_ID(N'cobranzas.Pago')
)
BEGIN
    ALTER TABLE cobranzas.Pago DROP COLUMN monto_cifrado;
END

IF EXISTS (
    SELECT * FROM sys.columns 
    WHERE Name = N'nro_tarjeta_cifrada' 
      AND Object_ID = Object_ID(N'cobranzas.TarjetaDeCredito')
)
BEGIN
    ALTER TABLE cobranzas.TarjetaDeCredito DROP COLUMN nro_tarjeta_cifrada;
END

IF EXISTS (
    SELECT * FROM sys.columns 
    WHERE Name = N'cae_cifrado' 
      AND Object_ID = Object_ID(N'facturacion.Factura')
)
BEGIN
    ALTER TABLE facturacion.Factura DROP COLUMN cae_cifrado;
END

IF EXISTS (
    SELECT * FROM sys.columns 
    WHERE Name = N'monto_cifrado' 
      AND Object_ID = Object_ID(N'facturacion.DetalleFactura')
)
BEGIN
    ALTER TABLE facturacion.DetalleFactura DROP COLUMN monto_cifrado;
END

/*____________________________________________________________________
  ________________________ ASIGNACIÓN DE ROLES _______________________
  ____________________________________________________________________*/

-- ==============================================
-- 1. CREACIÓN DE ROLES
-- ==============================================
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'tesoreria' AND type = 'R')
    CREATE ROLE tesoreria;
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'socios' AND type = 'R')
    CREATE ROLE socios;
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'autoridades' AND type = 'R')
    CREATE ROLE autoridades;
GO

-- 2. CREACIÓN DE LOGINS Y USUARIOS POR ROL

-- Tesorería
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'jefe_tesoreria')
    CREATE LOGIN jefe_tesoreria WITH PASSWORD = 'jefe_tesoreria' MUST_CHANGE, CHECK_EXPIRATION = ON;
GO
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'jefe_tesoreria')
    CREATE USER jefe_tesoreria FOR LOGIN jefe_tesoreria;
GO
ALTER ROLE tesoreria ADD MEMBER jefe_tesoreria;
GO

IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'admin_cobranza')
    CREATE LOGIN admin_cobranza WITH PASSWORD = 'admin_cobranza' MUST_CHANGE, CHECK_EXPIRATION = ON;
GO
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'admin_cobranza')
    CREATE USER admin_cobranza FOR LOGIN admin_cobranza;
GO
ALTER ROLE tesoreria ADD MEMBER admin_cobranza;
GO

IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'admin_facturacion')
    CREATE LOGIN admin_facturacion WITH PASSWORD = 'admin_facturacion' MUST_CHANGE, CHECK_EXPIRATION = ON;
GO
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'admin_facturacion')
    CREATE USER admin_facturacion FOR LOGIN admin_facturacion;
GO
ALTER ROLE tesoreria ADD MEMBER admin_facturacion;
GO


-- Socios
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'admin_socio')
    CREATE LOGIN admin_socio WITH PASSWORD = 'admin_socio' MUST_CHANGE, CHECK_EXPIRATION = ON;
GO
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'admin_socio')
    CREATE USER admin_socio FOR LOGIN admin_socio;
GO
ALTER ROLE socios ADD MEMBER admin_socio;
GO

IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'socio_web')
    CREATE LOGIN socio_web WITH PASSWORD = 'socio_web' MUST_CHANGE, CHECK_EXPIRATION = ON;
GO
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'socio_web')
    CREATE USER socio_web FOR LOGIN socio_web;
GO
ALTER ROLE socios ADD MEMBER socio_web;
GO

-- Autoridades
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'presidente')
    CREATE LOGIN presidente WITH PASSWORD = 'presidente' MUST_CHANGE, CHECK_EXPIRATION = ON;
GO
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'presidente')
    CREATE USER presidente FOR LOGIN presidente;
GO
ALTER ROLE autoridades ADD MEMBER presidente;
GO

IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'vocal')
    CREATE LOGIN vocal WITH PASSWORD = 'vocal' MUST_CHANGE, CHECK_EXPIRATION = ON;
GO
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'vocal')
    CREATE USER vocal FOR LOGIN vocal;
GO
ALTER ROLE autoridades ADD MEMBER vocal;
GO


-- 3. PERMISOS POR ESQUEMA
-- Tesorería
GRANT SELECT, INSERT, UPDATE ON SCHEMA::facturacion TO tesoreria;
GRANT SELECT, INSERT, UPDATE ON SCHEMA::cobranzas TO tesoreria;

-- Restricciones por usuario dentro del rol
DENY INSERT, UPDATE ON SCHEMA::facturacion TO admin_cobranza;
DENY INSERT, UPDATE ON SCHEMA::cobranzas TO admin_facturacion;

-- Socios
GRANT SELECT, INSERT, UPDATE ON SCHEMA::socios TO socios;
DENY INSERT, UPDATE ON SCHEMA::facturacion TO socio_web;

-- Autoridades
GRANT SELECT, INSERT, UPDATE ON SCHEMA::socios TO autoridades;
GRANT SELECT, INSERT, UPDATE ON SCHEMA::actividades TO autoridades;
GRANT SELECT, INSERT, UPDATE ON SCHEMA::facturacion TO autoridades;
GRANT SELECT, INSERT, UPDATE ON SCHEMA::cobranzas TO autoridades;

-- Lectura solamente para algunos
DENY INSERT, UPDATE ON SCHEMA::facturacion TO vocal;

-- 4. CIFRADO DE DATOS SENSIBLES
-- Socios: saldo
IF COL_LENGTH('socios.Socio', 'saldo_cifrado') IS NULL
BEGIN
    ALTER TABLE socios.Socio ADD saldo_cifrado VARBINARY(256);
END
GO

BEGIN
    DECLARE @passphrase NVARCHAR(128) = 'SolNorteClaveSegura';

    UPDATE socios.Socio
    SET saldo_cifrado = EncryptByPassPhrase(@passphrase, CAST(saldo AS NVARCHAR(30)), 1, CONVERT(VARBINARY, id_socio));
END
GO

-- Pago: monto
IF COL_LENGTH('cobranzas.Pago', 'monto_cifrado') IS NULL
BEGIN
    ALTER TABLE cobranzas.Pago ADD monto_cifrado VARBINARY(256);
END
GO

BEGIN
    DECLARE @passphrase NVARCHAR(128) = 'SolNorteClaveSegura';

    UPDATE cobranzas.Pago
    SET monto_cifrado = EncryptByPassPhrase(@passphrase, CAST(monto AS NVARCHAR(30)), 1, CONVERT(VARBINARY, id_pago));
END
GO

-- Tarjeta de crédito
IF COL_LENGTH('cobranzas.TarjetaDeCredito', 'nro_tarjeta_cifrada') IS NULL
BEGIN
    ALTER TABLE cobranzas.TarjetaDeCredito ADD nro_tarjeta_cifrada VARBINARY(256);
END
GO

IF COL_LENGTH('cobranzas.TarjetaDeCredito', 'cod_seguridad_cifrado') IS NULL
BEGIN
    ALTER TABLE cobranzas.TarjetaDeCredito ADD cod_seguridad_cifrado VARBINARY(256);
END
GO

BEGIN
    DECLARE @passphrase NVARCHAR(128) = 'SolNorteClaveSegura';

    UPDATE cobranzas.TarjetaDeCredito
    SET nro_tarjeta_cifrada = EncryptByPassPhrase(@passphrase, nro_tarjeta, 1, CONVERT(VARBINARY, id_tarjeta)),
        cod_seguridad_cifrado = EncryptByPassPhrase(@passphrase, cod_seguridad, 1, CONVERT(VARBINARY, id_tarjeta));
END
GO

-- Factura: cae y vencimiento_cae
IF COL_LENGTH('facturacion.Factura', 'cae_cifrado') IS NULL
BEGIN
    ALTER TABLE facturacion.Factura ADD cae_cifrado VARBINARY(256);
END
GO

IF COL_LENGTH('facturacion.Factura', 'vencimiento_cae_cifrado') IS NULL
BEGIN
    ALTER TABLE facturacion.Factura ADD cae_cifrado VARBINARY(256);
END
GO

BEGIN
    DECLARE @passphrase NVARCHAR(128) = 'SolNorteClaveSegura';

    UPDATE facturacion.Factura
    SET cae_cifrado = EncryptByPassPhrase(@passphrase, cae, 1, CONVERT(VARBINARY, id_factura));
END
GO

-- DetalleFactura: monto
IF COL_LENGTH('facturacion.DetalleFactura', 'monto_cifrado') IS NULL
BEGIN
    ALTER TABLE facturacion.DetalleFactura ADD monto_cifrado VARBINARY(256);
END
GO

BEGIN
    DECLARE @passphrase NVARCHAR(128) = 'SolNorteClaveSegura';

    UPDATE facturacion.DetalleFactura
    SET monto_cifrado = EncryptByPassPhrase(@passphrase, CAST(monto AS NVARCHAR(30)), 1, CONVERT(VARBINARY, id_detalle));
END
GO

-- Declaramos la clave
DECLARE @passphrase NVARCHAR(128) = 'SolNorteClaveSegura';

-- Ejemplo para ver el saldo cifrado y saldo desencriptado (Socios)
SELECT 
    id_socio,
    saldo_cifrado,
    CONVERT(NVARCHAR(30), DecryptByPassPhrase(@passphrase, saldo_cifrado)) AS saldo_desencriptado
FROM socios.Socio;

-- Para pago monto cifrado y monto desencriptado
SELECT 
    id_pago,
    monto_cifrado,
    CONVERT(NVARCHAR(30), DecryptByPassPhrase(@passphrase, monto_cifrado)) AS monto_desencriptado
FROM cobranzas.Pago;

-- Para tarjeta de crédito nro_tarjeta_cifrada y cod_seguridad_cifrado
SELECT 
    id_tarjeta,
    nro_tarjeta_cifrada,
    CONVERT(NVARCHAR(50), DecryptByPassPhrase(@passphrase, nro_tarjeta_cifrada)) AS nro_tarjeta_desencriptado,
    cod_seguridad_cifrado,
    CONVERT(NVARCHAR(10), DecryptByPassPhrase(@passphrase, cod_seguridad_cifrado)) AS cod_seguridad_desencriptado
FROM cobranzas.TarjetaDeCredito;

-- Para factura cae_cifrado y vencimiento_cae_cifrado
SELECT 
    id_factura,
    cae_cifrado,
    CONVERT(NVARCHAR(50), DecryptByPassPhrase(@passphrase, cae_cifrado)) AS cae_desencriptado,
    vencimiento_cae_cifrado,
    CONVERT(NVARCHAR(30), DecryptByPassPhrase(@passphrase, vencimiento_cae_cifrado)) AS vencimiento_cae_desencriptado
FROM facturacion.Factura;

-- Para detalle factura monto_cifrado
SELECT 
    id_detalle,
    monto_cifrado,
    CONVERT(NVARCHAR(30), DecryptByPassPhrase(@passphrase, monto_cifrado)) AS monto_desencriptado
FROM facturacion.DetalleFactura;

GO

-- PRUEBA
DECLARE @passphrase NVARCHAR(128) = 'SolNorteClaveSegura';

-- 1. Verificación: filas con datos cifrados NULL o no NULL en socios.Socio
SELECT 
    id_socio,
    saldo,
    saldo_cifrado,
    CASE WHEN saldo_cifrado IS NULL THEN 'NO CIFRADO' ELSE 'CIFRADO' END AS Estado_Cifrado,
    CONVERT(NVARCHAR(30), DecryptByPassPhrase(@passphrase, saldo_cifrado)) AS saldo_desencriptado
FROM socios.Socio
ORDER BY id_socio;

-- 2. Re-cifrar los datos que no estén cifrados (saldo_cifrado IS NULL)
UPDATE socios.Socio
SET saldo_cifrado = EncryptByPassPhrase(@passphrase, CAST(saldo AS NVARCHAR(30)), 1, CONVERT(VARBINARY, id_socio))
WHERE saldo_cifrado IS NULL OR saldo_cifrado = 0;

-- 3. Verificación post re-cifrado
SELECT 
    id_socio,
    saldo,
    saldo_cifrado,
    CONVERT(NVARCHAR(30), DecryptByPassPhrase(@passphrase, saldo_cifrado)) AS saldo_desencriptado
FROM socios.Socio
ORDER BY id_socio;
