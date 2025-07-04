USE COM2900G13;
GO

-- PASOS DE EJECUCIÓN: Bloque completo

/* ==========================================================
   BLOQUE DE LIMPIEZA COMPLETA DE DATOS SOCIOS Y GRUPOS
   ========================================================== */
DELETE FROM actividades.InscriptoClase
DBCC CHECKIDENT ('actividades.InscriptoClase', RESEED, 0) WITH NO_INFOMSGS;
DELETE FROM actividades.PresentismoClase
DBCC CHECKIDENT ('actividades.PresentismoClase', RESEED, 0) WITH NO_INFOMSGS;
DELETE FROM actividades.Clase
DBCC CHECKIDENT ('actividades.Clase', RESEED, 0) WITH NO_INFOMSGS;
DELETE FROM actividades.Actividad
DBCC CHECKIDENT ('actividades.Actividad', RESEED, 0) WITH NO_INFOMSGS;
DELETE FROM actividades.InscriptoCategoriaSocio
DBCC CHECKIDENT ('actividades.InscriptoCategoriaSocio', RESEED, 0) WITH NO_INFOMSGS;
DELETE FROM socios.CategoriaSocio
DBCC CHECKIDENT ('socios.CategoriaSocio', RESEED, 0) WITH NO_INFOMSGS;
DELETE FROM socios.GrupoFamiliarSocio;
DBCC CHECKIDENT ('socios.GrupoFamiliar', RESEED, 0) WITH NO_INFOMSGS;
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
    nro_socio VARCHAR(50),
    nombre VARCHAR(50),
    apellido VARCHAR(50),
    dni VARCHAR(20),
    email VARCHAR(100),
    fecha_nacimiento VARCHAR(50),
    tel_contacto VARCHAR(50),
    tel_emergencia VARCHAR(100),
    obra_social VARCHAR(100),
    nro_obra_social VARCHAR(50),
    tel_emergencia_2 VARCHAR(100)
);
GO

/*
	Cisco: C:\Users\Cisco\Desktop\Unlam\Tercer_Año\BDA\Com2900G13\ETL\Datos_socios.csv
	Lu: C:\Users\ldeti\Desktop\College\BDA\TP BDA\Com2900G13\ETL\Datos_socios.csv
*/

BULK INSERT #SociosRaw
FROM 'C:\Users\FranciscoVignardel\Desktop\UNLaM\BDA\Com2900G13\ETL\Datos_socios.csv'
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
    nro_socio VARCHAR(50),
    nro_socio_rp VARCHAR(50),
    nombre VARCHAR(50),
    apellido VARCHAR(50),
    dni CHAR(8),
    email VARCHAR(100),
    fecha_nacimiento VARCHAR(50),
    tel_contacto VARCHAR(50),
    tel_emergencia VARCHAR(100),
    obra_social VARCHAR(100),
    nro_obra_social VARCHAR(50),
    tel_emergencia_2 VARCHAR(100)
);
GO


/*
	Cisco: C:\Users\Cisco\Desktop\Unlam\Tercer_Año\BDA\Com2900G13\ETL\Grupo_familiar.csv
	Lu: C:\Users\ldeti\Desktop\College\BDA\TP BDA\Com2900G13\ETL\Datos_socios.csv
*/

BULK INSERT #GrupoFamiliarRaw
FROM 'C:\Users\FranciscoVignardel\Desktop\UNLaM\BDA\Com2900G13\ETL\Grupo_familiar.csv'
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

-- Inserción manual de las tarifas de membresía
EXEC socios.GestionarCategoriaSocio 'Menor', 0, 12, 10000, '2025-12-31', 'Insertar';
GO
EXEC socios.GestionarCategoriaSocio 'Cadete', 13, 17, 15000, '2025-12-31', 'Insertar';
GO
EXEC socios.GestionarCategoriaSocio 'Mayor', 18, 99, 25000, '2025-12-31', 'Insertar';
GO

INSERT INTO actividades.InscriptoCategoriaSocio (id_socio, id_categoria, fecha, monto, activo)
SELECT
	S.id_socio, 
	CS.id_categoria, 
	GETDATE(), 
	CS.costo_membresia, 
	S.activo
FROM socios.Socio S
JOIN socios.CategoriaSocio CS ON CS.edad_maxima >= DATEDIFF(YEAR, S.fecha_nacimiento, GETDATE()) AND CS.edad_minima <= DATEDIFF(YEAR, S.fecha_nacimiento, GETDATE())
WHERE id_socio NOT IN (SELECT id_socio FROM actividades.InscriptoCategoriaSocio)

SELECT * FROM actividades.InscriptoCategoriaSocio

-- ================================
-- PARTE 3: PRESENTISMO ACTIVIDADES
-- ================================

IF OBJECT_ID('tempdb..#PresentismoRaw') IS NOT NULL DROP TABLE #PresentismoRaw;
CREATE TABLE #PresentismoRaw (
    nro_socio VARCHAR(50),
    actividad VARCHAR(50),
    fecha_asistencia VARCHAR(50),
    asistencia VARCHAR(10),
    profesor VARCHAR(100)
);
GO

IF OBJECT_ID('tempdb..#PresentismoInsertado') IS NOT NULL DROP TABLE #PresentismoInsertado;
CREATE TABLE #PresentismoInsertado (
    id_presentismo INT,
    id_clase INT,
    id_socio INT,
    fecha DATE,
    estado CHAR(1)
);
GO

/*
	Cisco: C:\Users\Cisco\Desktop\Unlam\Tercer_Año\BDA\Com2900G13\ETL\Presentismo_actividades.csv
	Lu: C:\Users\ldeti\Desktop\College\BDA\TP BDA\Com2900G13\ETL\Presentismo_actividades.csv
*/

BULK INSERT #PresentismoRaw
FROM 'C:\Users\FranciscoVignardel\Desktop\UNLaM\BDA\Com2900G13\ETL\Presentismo_actividades.csv'
WITH (
    FIELDTERMINATOR = ';',
    ROWTERMINATOR = '0x0d0a',
    CODEPAGE = '65001',
    FIRSTROW = 2
);
GO

SELECT * FROM #PresentismoRaw

-- Inserción manual de las actividades y tarifas
EXEC actividades.GestionarActividad 'Futsal', 25000, '2025-05-31', 'Insertar';
EXEC actividades.GestionarActividad 'Vóley', 30000, '2025-05-31', 'Insertar';
EXEC actividades.GestionarActividad 'Taekwondo', 25000, '2025-05-31', 'Insertar';
EXEC actividades.GestionarActividad 'Baile artístico', 30000, '2025-05-31', 'Insertar';
EXEC actividades.GestionarActividad 'Natación', 45000, '2025-05-31', 'Insertar';
EXEC actividades.GestionarActividad 'Ajedrez', 2000, '2025-05-31', 'Insertar';
GO

-- Inserción manual de las clases
-- FUTSAL - Lunes
EXEC actividades.GestionarClase 'Futsal', 'Pablo', 'Rodriguez', 'Lunes 08:00', 'Menor', 'Insertar';
EXEC actividades.GestionarClase 'Futsal', 'Pablo', 'Rodriguez', 'Lunes 14:00', 'Cadete', 'Insertar';
EXEC actividades.GestionarClase 'Futsal', 'Pablo', 'Rodriguez', 'Lunes 19:00', 'Mayor', 'Insertar';
GO
-- Vóley - Martes
EXEC actividades.GestionarClase 'Vóley', 'Ana Paula', 'Alvarez', 'Martes 08:00', 'Menor', 'Insertar';
EXEC actividades.GestionarClase 'Vóley', 'Ana Paula', 'Alvarez', 'Martes 14:00', 'Cadete', 'Insertar';
EXEC actividades.GestionarClase 'Vóley', 'Ana Paula', 'Alvarez', 'Martes 19:00', 'Mayor', 'Insertar';
GO
-- TAEKWONDO - Miércoles
EXEC actividades.GestionarClase 'Taekwondo', 'Kito', 'Mihaji', 'Miércoles 08:00', 'Menor', 'Insertar';
EXEC actividades.GestionarClase 'Taekwondo', 'Kito', 'Mihaji', 'Miércoles 14:00', 'Cadete', 'Insertar';
EXEC actividades.GestionarClase 'Taekwondo', 'Kito', 'Mihaji', 'Miércoles 19:00', 'Mayor', 'Insertar';
GO
-- BAILE artístico - Jueves
EXEC actividades.GestionarClase 'Baile artístico', 'Carolina', 'Herreta', 'Jueves 08:00', 'Menor', 'Insertar';
EXEC actividades.GestionarClase 'Baile artístico', 'Carolina', 'Herreta', 'Jueves 14:00', 'Cadete', 'Insertar';
EXEC actividades.GestionarClase 'Baile artístico', 'Carolina', 'Herreta', 'Jueves 19:00', 'Mayor', 'Insertar';
GO
-- Natación - Viernes
EXEC actividades.GestionarClase 'Natación', 'Paula', 'Quiroga', 'Viernes 08:00', 'Menor', 'Insertar';
EXEC actividades.GestionarClase 'Natación', 'Paula', 'Quiroga', 'Viernes 14:00', 'Cadete', 'Insertar';
EXEC actividades.GestionarClase 'Natación', 'Paula', 'Quiroga', 'Viernes 19:00', 'Mayor', 'Insertar';
GO
-- AJEDREZ - Sábado
EXEC actividades.GestionarClase 'Ajedrez', 'Hector', 'Alvarez', 'Sábado 08:00', 'Menor', 'Insertar';
EXEC actividades.GestionarClase 'Ajedrez', 'Hector', 'Alvarez', 'Sábado 14:00', 'Cadete', 'Insertar';
EXEC actividades.GestionarClase 'Ajedrez', 'Roxana', 'Gutierrez', 'Sábado 19:00', 'Mayor', 'Insertar';
GO

INSERT INTO actividades.PresentismoClase (id_clase, id_socio, fecha, estado)
OUTPUT INSERTED.id_presentismo, INSERTED.id_clase, INSERTED.id_socio, INSERTED.fecha, INSERTED.estado
INTO #PresentismoInsertado (id_presentismo, id_clase, id_socio, fecha, estado)
SELECT DISTINCT
    C.id_clase,
    S.id_socio,
    TRY_CAST(R.fecha_asistencia AS DATE),
    CAST(LTRIM(RTRIM(R.asistencia)) AS CHAR(1))
FROM #PresentismoRaw R
JOIN socios.Socio S 
    ON S.nro_socio = LTRIM(RTRIM(R.nro_socio))
JOIN actividades.Actividad A 
    ON A.nombre = LTRIM(RTRIM(R.actividad))
JOIN actividades.Clase C 
    ON C.id_actividad = A.id_actividad
WHERE 
    TRY_CAST(R.fecha_asistencia AS DATE) IS NOT NULL
    AND R.asistencia IN ('P', 'A', 'J')
    AND EXISTS (
        SELECT 1
        FROM socios.CategoriaSocio CS
        JOIN actividades.InscriptoCategoriaSocio ICS 
            ON ICS.id_categoria = CS.id_categoria
        WHERE CS.id_categoria = C.id_categoria
          AND ICS.id_socio = S.id_socio
    )
    AND NOT EXISTS (
        SELECT 1
        FROM actividades.PresentismoClase PC
        WHERE PC.id_clase = C.id_clase
          AND PC.id_socio = S.id_socio
          AND PC.fecha = TRY_CAST(R.fecha_asistencia AS DATE)
    );

INSERT INTO actividades.InscriptoClase(fecha_inscripcion, id_socio, id_clase, activa)
SELECT
	MIN(PC.fecha),
	S.id_socio,
	C.id_clase, 
	S.activo
FROM socios.Socio S
JOIN actividades.PresentismoClase PC ON PC.id_socio = S.id_socio
JOIN actividades.Clase C ON PC.id_clase = C.id_clase

JOIN actividades.Actividad A ON A.id_actividad = C.id_actividad
WHERE NOT EXISTS (
    SELECT id_socio
    FROM actividades.InscriptoClase IC
    WHERE IC.id_socio = S.id_socio AND IC.id_clase = C.id_clase
)
GROUP BY S.id_socio, C.id_clase, S.activo

-- Verificación final de inserción
SELECT * FROM actividades.Actividad;
SELECT * FROM actividades.Clase;
SELECT * FROM actividades.InscriptoClase
SELECT * FROM actividades.PresentismoClase

-- Limpieza de temporales
DROP TABLE IF EXISTS #PresentismoRaw;
DROP TABLE IF EXISTS #PresentismoInsertado;
GO
