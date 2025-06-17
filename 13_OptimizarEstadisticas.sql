/* =========================================================================
   Trabajo Práctico Integrador - Bases de Datos Aplicadas
   Grupo N°: 13
   Comisión: 2900
   Fecha de Entrega: 17/06/2025
   Materia: Bases de Datos Aplicadas
   Alumnos: Vignardel Francisco 45778667
            De Titto Lucia		46501934
			Borja Tomas			42353302

   Objetivo: Inspección, actualización y análisis de estadísticas.
   ========================================================================= */

USE COM2900G13;
GO

-- ======================
-- 1. VER ESTADÍSTICAS EXISTENTES
-- ======================

SELECT 
    OBJECT_NAME(s.object_id) AS tabla,
    COL_NAME(sc.object_id, sc.column_id) AS columna,
    s.name AS estadistica
FROM sys.stats AS s
INNER JOIN sys.stats_columns AS sc
    ON s.stats_id = sc.stats_id AND s.object_id = sc.object_id
ORDER BY tabla, estadistica;
GO

-- ======================
-- 2. ACTUALIZAR ESTADÍSTICAS DE TODAS LAS TABLAS DE LA BASE
-- ======================
EXEC sp_updatestats;
GO

