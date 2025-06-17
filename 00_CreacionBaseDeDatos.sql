/* =========================================================================
   Trabajo Pr�ctico Integrador - Bases de Datos Aplicadas
   Grupo N�: 13
   Comisi�n: 2900
   Fecha de Entrega: 17/06/2025
   Materia: Bases de Datos Aplicadas
   Alumnos: Vignardel Francisco 45778667
            De Titto Lucia		46501934
            Borja Tomas			42353302
   ========================================================================= */

-- Descripci�n: Elimina y recrea la base de datos COM2900G13 con configuraci�n controlada

USE master;
GO

DECLARE @dbName VARCHAR(128) = 'COM2900G13';
DECLARE @dataFile VARCHAR(260);
DECLARE @logFile VARCHAR(260);
DECLARE @dataPath VARCHAR(260);
DECLARE @sql VARCHAR(MAX);

-- Ruta por defecto de archivos de datos
SET @dataPath = CAST(SERVERPROPERTY('InstanceDefaultDataPath') AS NVARCHAR(260));

-- Si existe, eliminar base de datos con rollback inmediato
IF DB_ID(@dbName) IS NOT NULL
BEGIN
    EXEC('ALTER DATABASE [' + @dbName + '] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;');
    EXEC('DROP DATABASE [' + @dbName + '];');
END

-- Crear la base de datos
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
GO

-- Cambiar a la nueva base de datos
USE COM2900G13;
GO
