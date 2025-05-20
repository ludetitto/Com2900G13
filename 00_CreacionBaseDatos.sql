-- Trabajo Práctico Integrador - Entrega 4
-- Fecha: 19/05/2025
-- Comisión: 2900 - Grupo: 13
-- Materia: Bases de Datos Aplicadas
-- Archivo: 00_CreacionBaseDatos.sql
-- Descripción: Creación de la base de datos Com3900G13 con configuración ajustada y portable

-- Se utiliza un mecanismo de SQL dinámico para poder insertar la ruta adecuada.
DECLARE @dbName VARCHAR(128) = 'Com3900G13';
DECLARE @dataFile VARCHAR(260); -- Suficientes caracteres para guardar la ruta.
DECLARE @logFile VARCHAR(260);
DECLARE @dataPath VARCHAR(260);
DECLARE @sql VARCHAR(MAX); -- Puede crecer hasta 2GB (máximo).

-- Se obtiene la ruta del usuario
SET @dataPath = CAST(SERVERPROPERTY('InstanceDefaultDataPath') AS NVARCHAR(260));
SET @dataFile = @dataPath + @dbName + '_data.mdf';
SET @logFile = @dataFile + @dbName + '_log.ldf';

-- Validar si la base ya existe para evitar duplicados
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = @dbName)
BEGIN
    SET @sql = '
	CREATE DATABASE [' + @dbName + ']
    ON PRIMARY
    (
        NAME = ''' + @dbName + ''',
		FILENAME = ''' + @dataFile + ''',
        SIZE = 20MB,              -- Tamaño inicial razonable para pruebas y demo
        FILEGROWTH = 5MB,         -- Controlado, evita microfragmentación
        MAXSIZE = 1024MB          -- Tope máximo según requerimiento de 1 GB en 2 años
    )
    LOG ON
    (
        NAME = ''' + @dbName + '_log'',
		FILENAME = ''' + @logFile + ''',
        SIZE = 10MB,
        FILEGROWTH = 2MB,
        MAXSIZE = 200MB
    );

    ALTER DATABASE [' + @dbName + '] SET RECOVERY SIMPLE;
	';
	EXEC(@sql);
END
ELSE
BEGIN
    PRINT 'La base de datos Com3900G13 ya existe.';
END;

-- Usar la base de datos creada o existente
EXEC('USE [' + @dbName + ']');
GO