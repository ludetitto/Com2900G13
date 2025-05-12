-- Trabajo Pr�ctico Integrador - Entrega 4
-- Fecha: 19/05/2025
-- Comisi�n: 2900 - Grupo: 13
-- Materia: Bases de Datos Aplicadas
-- Archivo: 00_CreacionBaseDatos.sql
-- Descripci�n: Creaci�n de la base de datos Com3900G13 con configuraci�n ajustada y portable

-- Validar si la base ya existe para evitar duplicados
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'Com3900G13')
BEGIN
    CREATE DATABASE Com3900G13
    ON PRIMARY
    (
        NAME = 'Com3900G13_data',
        SIZE = 20MB,              -- Tama�o inicial razonable para pruebas y demo
        FILEGROWTH = 5MB,         -- Controlado, evita microfragmentaci�n
        MAXSIZE = 1024MB          -- Tope m�ximo seg�n requerimiento de 1 GB en 2 a�os
    )
    LOG ON
    (
        NAME = 'Com3900G13_log',
        SIZE = 10MB,
        FILEGROWTH = 2MB,
        MAXSIZE = 200MB
    );

    -- Ajustar modelo de recuperaci�n si no se requiere backup en caliente
    ALTER DATABASE Com3900G13 SET RECOVERY SIMPLE;
END
ELSE
BEGIN
    PRINT 'La base de datos Com3900G13 ya existe. No se cre� nuevamente.';
END;
GO

-- Usar la base de datos creada o existente
USE Com3900G13;
GO
