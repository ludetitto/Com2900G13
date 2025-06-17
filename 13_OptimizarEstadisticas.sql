/* =========================================================================
   Archivo 13 - Optimizaci�n de Estad�sticas
   Proyecto: COM2900G13 - Sol Norte
   Descripci�n: Inspecci�n, actualizaci�n y an�lisis de estad�sticas
   ========================================================================= */

USE COM2900G13;
GO

-- ======================
-- 1. VER ESTAD�STICAS EXISTENTES
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
-- 2. ACTUALIZAR ESTAD�STICAS DE TODAS LAS TABLAS DE LA BASE
-- ======================
EXEC sp_updatestats;
GO

