/* =========================================================================
   Trabajo Práctico Integrador - Bases de Datos Aplicadas
   Grupo N°: 13
   Comision: 2900
   Fecha de Entrega: 17/06/2025
   Materia: Bases de Datos Aplicadas
   Alumnos: Vignardel Francisco 45778667
			De Titto Lucia 46501934
			Benvenuto Franco 44760004
   ========================================================================= */

-- Cambiar a la base master para poder eliminar si existe y crear la nueva
USE master;
GO

-- Borrar base si existe
IF DB_ID('SolNorteDB') IS NOT NULL
    DROP DATABASE SolNorteDB;
GO

-- Crear base de datos
CREATE DATABASE SolNorteDB;
GO
