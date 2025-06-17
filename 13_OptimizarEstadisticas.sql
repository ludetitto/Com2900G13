/* =========================================================================
   Archivo 13 - Optimización de Estadísticas
   Proyecto: COM2900G13 - Sol Norte
   Descripción: Inspección, actualización y análisis de estadísticas
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

