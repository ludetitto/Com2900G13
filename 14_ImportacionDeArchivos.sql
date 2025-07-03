USE COM2900G13;
GO

/* ==========================================================
   BLOQUE DE LIMPIEZA COMPLETA DE DATOS SOCIOS Y GRUPOS
   ========================================================== */
DELETE FROM socios.GrupoFamiliarSocio;
DELETE FROM socios.GrupoFamiliar;
DBCC CHECKIDENT ('socios.GrupoFamiliar', RESEED, 0) WITH NO_INFOMSGS;
DELETE FROM socios.Socio;
DBCC CHECKIDENT ('socios.Socio', RESEED, 0) WITH NO_INFOMSGS;
GO

-- ===============================
-- PARTE 1: SOCIOS PRINCIPALES
-- ===============================

IF OBJECT_ID('tempdb..#GrupoTempResponsables') IS NOT NULL DROP TABLE #GrupoTempResponsables;
CREATE TABLE #GrupoTempResponsables (
    id_socio INT,
    nro_socio VARCHAR(50)
);
GO

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
    tel_emergencia_2 NVARCHAR(100)
);
GO

BULK INSERT #SociosRaw
FROM 'C:\Users\Cisco\Desktop\Unlam\Tercer_Año\BDA\Com2900G13\ETL\Datos_socios.csv'
WITH (
    FIELDTERMINATOR = ';',
    ROWTERMINATOR = '0x0d0a',
    CODEPAGE = '65001',
    FIRSTROW = 2
);
GO

INSERT INTO socios.Socio (
    nombre, apellido, dni, nro_socio, email, fecha_nacimiento,
    tel_contacto, tel_emergencia, domicilio,
    obra_social, nro_obra_social,
    activo, eliminado, saldo
)
OUTPUT INSERTED.id_socio, INSERTED.nro_socio INTO #GrupoTempResponsables (id_socio, nro_socio)
SELECT
    LTRIM(RTRIM(nombre)),
    LTRIM(RTRIM(apellido)),
    RIGHT('00000000' + LTRIM(RTRIM(dni)), 8),
    LTRIM(RTRIM(nro_socio)),
    CASE WHEN email LIKE '%@%.%' THEN LTRIM(RTRIM(REPLACE(email, ' ', ''))) ELSE NULL END,
    TRY_CONVERT(DATE, fecha_nacimiento, 103),
    LEFT(tel_contacto, 20),
    LEFT(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
        tel_emergencia, '(', ''), ')', ''), '-', ''), '/', ''), ' ', ''), '.', ''), '+', ''), ',', ''), ';', ''), ':', ''), 20),
    '-' AS domicilio,
    LTRIM(RTRIM(obra_social)),
    LTRIM(RTRIM(nro_obra_social)),
    1, 0, 0.00
FROM #SociosRaw SR
WHERE TRY_CONVERT(DATE, fecha_nacimiento, 103) IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 FROM socios.Socio s
    WHERE s.dni = RIGHT('00000000' + LTRIM(RTRIM(SR.dni)), 8)
       OR s.nro_socio = LTRIM(RTRIM(SR.nro_socio))
);
GO

INSERT INTO socios.GrupoFamiliar (id_socio_rp)
SELECT id_socio
FROM #GrupoTempResponsables;
GO

INSERT INTO socios.GrupoFamiliarSocio (id_grupo, id_socio)
SELECT GF.id_grupo, GTR.id_socio
FROM socios.GrupoFamiliar GF
JOIN #GrupoTempResponsables GTR ON GF.id_socio_rp = GTR.id_socio;
GO

-- Verificación de inserción
SELECT * FROM socios.Socio;
SELECT * FROM socios.GrupoFamiliar;
SELECT * FROM socios.GrupoFamiliarSocio;

-- ===============================
-- PARTE 2: GRUPOS FAMILIARES
-- ===============================

IF OBJECT_ID('tempdb..#GrupoFamiliarRaw') IS NOT NULL DROP TABLE #GrupoFamiliarRaw;
CREATE TABLE #GrupoFamiliarRaw (
    nro_socio NVARCHAR(50),
    nro_socio_rp NVARCHAR(50),
    nombre NVARCHAR(50),
    apellido NVARCHAR(50),
    dni CHAR(8),
    email NVARCHAR(100),
    fecha_nacimiento NVARCHAR(50),
    tel_contacto NVARCHAR(50),
    tel_emergencia NVARCHAR(100),
    obra_social NVARCHAR(100),
    nro_obra_social NVARCHAR(50),
    tel_emergencia_2 NVARCHAR(100)
);
GO

BULK INSERT #GrupoFamiliarRaw
FROM 'C:\Users\Cisco\Desktop\Unlam\Tercer_Año\BDA\Com2900G13\ETL\Grupo_familiar.csv'
WITH (
    FIELDTERMINATOR = ';',
    ROWTERMINATOR = '0x0d0a',
    CODEPAGE = '65001',
    FIRSTROW = 2
);
GO

INSERT INTO socios.Socio (
    nombre, apellido, dni, nro_socio, email, fecha_nacimiento,
    tel_contacto, tel_emergencia, domicilio,
    obra_social, nro_obra_social,
    activo, eliminado, saldo
)
OUTPUT INSERTED.id_socio, INSERTED.nro_socio INTO #GrupoTempResponsables (id_socio, nro_socio)
SELECT
    LTRIM(RTRIM(nombre)),
    LTRIM(RTRIM(apellido)),
    RIGHT('00000000' + LTRIM(RTRIM(dni)), 8),
    LTRIM(RTRIM(nro_socio)),
    CASE WHEN email LIKE '%@%.%' THEN LTRIM(RTRIM(REPLACE(email, ' ', ''))) ELSE NULL END,
    TRY_CONVERT(DATE, fecha_nacimiento, 103),
    LEFT(tel_contacto, 20),
    LEFT(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
        tel_emergencia, '(', ''), ')', ''), '-', ''), '/', ''), ' ', ''), '.', ''), '+', ''), ',', ''), ';', ''), ':', ''), 20),
    '-' AS domicilio,
    LTRIM(RTRIM(obra_social)),
    LTRIM(RTRIM(nro_obra_social)),
    1, 0, 0.00
FROM #GrupoFamiliarRaw GFR
WHERE TRY_CONVERT(DATE, fecha_nacimiento, 103) IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 FROM socios.Socio s
    WHERE s.dni = RIGHT('00000000' + LTRIM(RTRIM(GFR.dni)), 8)
       OR s.nro_socio = LTRIM(RTRIM(GFR.nro_socio))
);
GO

INSERT INTO socios.GrupoFamiliarSocio (id_grupo, id_socio)
SELECT
    GF.id_grupo,
    S.id_socio
FROM #GrupoFamiliarRaw GFR
JOIN socios.Socio S ON S.nro_socio = LTRIM(RTRIM(GFR.nro_socio))
JOIN socios.Socio RP ON RP.nro_socio = LTRIM(RTRIM(GFR.nro_socio_rp))
JOIN socios.GrupoFamiliar GF ON GF.id_socio_rp = RP.id_socio
WHERE NOT EXISTS (
    SELECT 1 FROM socios.GrupoFamiliarSocio GFS
    WHERE GFS.id_grupo = GF.id_grupo AND GFS.id_socio = S.id_socio
);
GO

-- Verificación final de inserción
SELECT * FROM socios.Socio;
SELECT * FROM socios.GrupoFamiliar;
SELECT * FROM socios.GrupoFamiliarSocio;

-- Limpieza de temporales
DROP TABLE IF EXISTS #SociosRaw;
DROP TABLE IF EXISTS #GrupoFamiliarRaw;
DROP TABLE IF EXISTS #GrupoTempResponsables;
GO
