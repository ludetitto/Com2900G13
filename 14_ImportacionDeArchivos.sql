USE COM2900G13;
GO
--========================================
--IMPORTACION DEL ARCHIVO DATOS SOCIOS.CSV
--========================================

-- 1. Crear tabla temporal con columnas reales del archivo CSV
IF OBJECT_ID('tempdb..#SociosRaw') IS NOT NULL DROP TABLE #SociosRaw;
CREATE TABLE #SociosRaw (
    nro_socio NVARCHAR(50),
    nombre NVARCHAR(50),
    apellido NVARCHAR(50),
    dni NVARCHAR(20),
    email NVARCHAR(100),
    fecha_nacimiento NVARCHAR(50),
    tel_contacto NVARCHAR(50),
    tel_emergencia NVARCHAR(100),
    obra_social NVARCHAR(100),
    nro_obra_social NVARCHAR(50),
    tel_emergencia_2 NVARCHAR(100) -- se ignora
);
GO

-- 2. Cargar datos desde el CSV con UTF-8
BULK INSERT #SociosRaw
FROM 'C:\Users\Cisco\Desktop\Unlam\Tercer_Año\BDA\Com2900G13\ETL\Datos_socios.csv'
WITH (
    FIELDTERMINATOR = ';',
    ROWTERMINATOR = '0x0d0a',
    CODEPAGE = '65001',
    FIRSTROW = 2
);
GO

-- 3. Verificación rápida
SELECT TOP 5 * FROM #SociosRaw;
SELECT COUNT(*) AS CantidadCargada FROM #SociosRaw;
GO

-- 4. Crear tabla temporal limpia
IF OBJECT_ID('tempdb..#SociosLimpios') IS NOT NULL DROP TABLE #SociosLimpios;
CREATE TABLE #SociosLimpios (
    nro_socio VARCHAR(50),
    nombre NVARCHAR(50),
    apellido NVARCHAR(50),
    dni CHAR(8),
    email NVARCHAR(100),
    fecha_nacimiento DATE,
    tel_contacto VARCHAR(20),
    tel_emergencia VARCHAR(20),
    domicilio NVARCHAR(200),
    obra_social NVARCHAR(100),
    nro_obra_social NVARCHAR(50)
);
GO

-- 5. Insertar transformando datos, limpiando emails y evitando duplicados
INSERT INTO #SociosLimpios
SELECT
    LTRIM(RTRIM(nro_socio)),
    LTRIM(RTRIM(nombre)),
    LTRIM(RTRIM(apellido)),
    RIGHT('00000000' + LTRIM(RTRIM(dni)), 8),
    emailLimpio,
    TRY_CAST(fecha_nacimiento AS DATE),
    LEFT(tel_contacto, 20),
    LEFT(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
        tel_emergencia, '(', ''), ')', ''), '-', ''), '/', ''), ' ', ''), '.', ''), '+', ''), ',', ''), ';', ''), ':', ''), 20),
    '-' AS domicilio,
    LTRIM(RTRIM(obra_social)),
    LTRIM(RTRIM(nro_obra_social))
FROM (
    SELECT *,
        LTRIM(RTRIM(REPLACE(email, ' ', ''))) AS emailLimpio
    FROM #SociosRaw
) AS SR
WHERE 
    TRY_CAST(fecha_nacimiento AS DATE) IS NOT NULL
    AND LEN(LTRIM(RTRIM(dni))) BETWEEN 7 AND 10
    AND CHARINDEX('@', emailLimpio) > 1
    AND CHARINDEX('.', emailLimpio, CHARINDEX('@', emailLimpio)) > CHARINDEX('@', emailLimpio)
    AND NOT EXISTS (
        SELECT 1
        FROM socios.Socio s
        WHERE s.dni = RIGHT('00000000' + LTRIM(RTRIM(SR.dni)), 8)
           OR s.nro_socio = LTRIM(RTRIM(SR.nro_socio))
    );
GO

-- 6. Insertar en tabla definitiva
INSERT INTO socios.Socio (
    nombre, apellido, dni, nro_socio, email, fecha_nacimiento,
    tel_contacto, tel_emergencia, domicilio,
    obra_social, nro_obra_social,
    activo, eliminado, saldo
)
SELECT
    nombre, apellido, dni, nro_socio, email, fecha_nacimiento,
    tel_contacto, tel_emergencia, domicilio,
    obra_social, nro_obra_social,
    1, 0, 0.00
FROM #SociosLimpios;
GO

-- 7. Verificación final
SELECT *
FROM socios.Socio
ORDER BY id_socio;
GO

-- 8. Limpieza de temporales
DROP TABLE IF EXISTS #SociosRaw;
DROP TABLE IF EXISTS #SociosLimpios;
GO

/* 
=============================================================
BLOQUE DE ELIMINACIÓN EN CASO DE REIMPORTACIÓN
=============================================================
*/
/*

-- 1. Eliminar cargos de clases
DELETE FROM facturacion.CargoClases
WHERE id_inscripto_clase IN (
    SELECT id_inscripto_clase
    FROM actividades.InscriptoClase
    WHERE id_socio IN (
        SELECT id_socio FROM socios.Socio WHERE nro_socio LIKE 'SN-4%'
    )
);
GO

-- 2. Eliminar presentismo
DELETE FROM actividades.PresentismoClase
WHERE id_socio IN (
    SELECT id_socio FROM socios.Socio WHERE nro_socio LIKE 'SN-4%'
);
GO

-- 3. Eliminar inscripciones a clases
DELETE FROM actividades.InscriptoClase
WHERE id_socio IN (
    SELECT id_socio FROM socios.Socio WHERE nro_socio LIKE 'SN-4%'
);
GO

-- 4. Eliminar inscripciones a categoría socio
DELETE FROM actividades.InscriptoCategoriaSocio
WHERE id_socio IN (
    SELECT id_socio FROM socios.Socio WHERE nro_socio LIKE 'SN-4%'
);
GO

-- 5. Eliminar vínculos de grupo familiar
DELETE FROM socios.GrupoFamiliarSocio
WHERE id_socio IN (
    SELECT id_socio FROM socios.Socio WHERE nro_socio LIKE 'SN-4%'
);
GO

-- 6. Eliminar los socios
DELETE FROM socios.Socio
WHERE nro_socio LIKE 'SN-4%';
GO

-- 7. Confirmación
SELECT COUNT(*) AS SociosRestantes
FROM socios.Socio
WHERE nro_socio LIKE 'SN-4%';
GO

*/