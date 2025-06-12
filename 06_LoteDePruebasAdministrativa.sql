USE COM2900G13;
GO

/* ===================== LIMPIEZA COMPLETA ===================== */
DELETE FROM actividades.InscriptoClase;
DELETE FROM actividades.Clase;
DELETE FROM actividades.Actividad;
DELETE FROM administracion.GrupoFamiliar;
DELETE FROM administracion.Invitado;
DELETE FROM administracion.Socio;
DELETE FROM administracion.Profesor;
DELETE FROM administracion.CategoriaSocio;
DELETE FROM administracion.Persona;
GO

/* ===================== INSERTAR PERSONAS BASE ===================== */
-- Tomas y Jose
EXEC administracion.GestionarPersona 'Tomas', 'Borja', '55666777', 'tomas.borja@email.com', '2024-10-25', 'Av. San Martin 3200', '1234227890', '0987658821', 'Insertar';
EXEC administracion.GestionarPersona 'Jose', 'Suarez', '99888777', 'jose.suarez@email.com', '1965-10-25', 'Av. San Martin 3499', '1234567990', '0987699321', 'Insertar';
GO

/* ===================== INSERTAR CATEGORÍAS ===================== */
EXEC administracion.GestionarCategoriaSocio 'Menor', 0, 12, 700.00, '2025-12-31', 'Insertar';
EXEC administracion.GestionarCategoriaSocio 'Cadete', 13, 17, 800.00, '2025-12-31', 'Insertar';
EXEC administracion.GestionarCategoriaSocio 'Mayor', 18, 150, 1000.00, '2025-12-31', 'Insertar';
GO

/* ===================== INSERTAR SOCIOS ===================== */
EXEC administracion.GestionarSocio 'Francisco', 'Vignardel', '45778667', 'francisco.vignardel@email.com', '2004-04-10', 'Av. Gral. Mosconi 2345', '1231233234', '6624324321', 'Mayor', 'SOC1002', 'OSPOCE', '654321', 0, 'Insertar';
EXEC administracion.GestionarSocio 'Juan', 'Perez', '33444555', 'juan.perez@email.com', '2004-04-10', 'Av. Crovara 2345', '3331233234', '6624324388', 'Cadete', 'SOC1003', 'VITA', '654331', 0, 'Insertar';
EXEC administracion.GestionarSocio 'Mariana', 'Vignardel', '40505050', 'mariana.vignardel@email.com', '2012-09-12', 'Av. Gral. Mosconi 2345', '1112223333', '4445556666', 'Cadete', 'SOC1004', 'OSPOCE', '987654', 0, 'Insertar';
EXEC administracion.GestionarSocio 'Camila', 'Perez', '40606060', 'camila.perez@email.com', '2010-11-25', 'Av. Crovara 2345', '2223334444', '7778889999', 'Cadete', 'SOC1005', 'VITA', '112233', 0, 'Insertar';
EXEC administracion.GestionarSocio 'Luciano', 'Costa', '40707070', 'luciano.costa@email.com', '1995-05-15', 'Calle Falsa 123', '5556667777', '1112223333', 'Mayor', 'SOC1006', 'OSDE', '445566', 0, 'Insertar';
GO

/* ===================== INSERTAR PROFESOR ===================== */
EXEC administracion.GestionarProfesor 'Ana', 'García', '34567890', 'ana.garcia@email.com', '1990-08-15', 'Av. Urquiza 8392', '1112223333', '3332221111', 'Insertar';
GO

/* ===================== INSERTAR INVITADO ===================== */
EXEC administracion.GestionarInvitado '45778667', '46501934', 'Lucia', 'De Titto', 'ldetitto10@email.com', 'Av. Crovara 2345', 'Insertar';
GO

/* ===================== GRUPOS FAMILIARES ===================== */
EXEC administracion.GestionarGrupoFamiliar '40505050', '45778667', 'Insertar'; -- Mariana con Francisco
EXEC administracion.GestionarGrupoFamiliar '40606060', '33444555', 'Insertar'; -- Camila con Juan
GO


/* ===================== VERIFICACIÓN FINAL ===================== */
SELECT * FROM administracion.Persona;
SELECT * FROM administracion.Socio;
SELECT * FROM administracion.CategoriaSocio;
SELECT * FROM administracion.Profesor;
SELECT * FROM administracion.Invitado;
SELECT * FROM administracion.GrupoFamiliar;

/* ===================== CONSULTA FINAL ===================== */
SELECT 
    P.dni,
    P.nombre,
    P.apellido,
    P.fecha_nacimiento,
    P.email,
    S.id_socio,
    C.nombre AS categoria,
    C.costo_membresia,
    C.vigencia
FROM administracion.Socio S
JOIN administracion.Persona P ON S.id_persona = P.id_persona
JOIN administracion.CategoriaSocio C ON S.id_categoria = C.id_categoria
ORDER BY P.apellido, P.nombre;
