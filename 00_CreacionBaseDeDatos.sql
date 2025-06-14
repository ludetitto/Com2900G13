/* =========================================================================
   Trabajo Práctico Integrador - Bases de Datos Aplicadas
   Grupo N°: 13
   Comisión: 2900
   Fecha de Entrega: 17/06/2025
   Materia: Bases de Datos Aplicadas
   Alumnos: Vignardel Francisco 45778667
            De Titto Lucia		46501934
			Borja Tomas			42353302
   ========================================================================= */

-- Descripción: Creación de la base de datos Com3900G13 con configuración ajustada y portable
-- Se utiliza un mecanismo de SQL dinámico para poder insertar la ruta adecuada.

--Eliminar La Base De Datos
--USE MASTER
--ALTER DATABASE COM2900G13 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
--DROP DATABASE COM2900G13

DECLARE @dbName VARCHAR(128) = 'COM2900G13';
DECLARE @dataFile VARCHAR(260);
DECLARE @logFile VARCHAR(260);
DECLARE @dataPath VARCHAR(260);
DECLARE @sql VARCHAR(MAX);

-- Se obtiene la ruta por defecto del servidor para almacenar archivos de base de datos
SET @dataPath = CAST(SERVERPROPERTY('InstanceDefaultDataPath') AS NVARCHAR(260));

IF DB_ID(@dbName) IS NULL
BEGIN
    SET @dataFile = @dataPath + @dbName + '.mdf';
    SET @logFile = @dataPath + @dbName + '_log.ldf';

    SET @sql = '
    CREATE DATABASE [' + @dbName + ']
    ON PRIMARY (
        NAME = ''' + @dbName + '_data'',
        FILENAME = ''' + @dataFile + ''',
        SIZE = 20MB,
        MAXSIZE = 500MB,
        FILEGROWTH = 10MB
    )
    LOG ON (
        NAME = ''' + @dbName + '_log'',
        FILENAME = ''' + @logFile + ''',
        SIZE = 10MB,
        FILEGROWTH = 10MB,
        MAXSIZE = 200MB
    );

    ALTER DATABASE [' + @dbName + '] SET RECOVERY SIMPLE;
    ';
    EXEC(@sql);
END
ELSE
BEGIN
    PRINT 'La base de datos ' + @dbName + ' ya existe.';
END;
GO
-- Usar la base de datos creada o existente
USE COM2900G13;
GO
