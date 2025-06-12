USE COM2900G13;
GO

delete from actividades.presentismoClase
delete from actividades.InscriptoClase
delete from actividades.Clase
delete from actividades.Actividad



-- Insertar actividades base (sin horarios)
EXEC actividades.GestionarActividad 'Futsal', 25000, '2025-05-31', 'Insertar';
EXEC actividades.GestionarActividad 'V�ley', 30000, '2025-05-31', 'Insertar';
EXEC actividades.GestionarActividad 'Taekwondo', 25000, '2025-05-31', 'Insertar';
EXEC actividades.GestionarActividad 'Baile art�stico', 30000, '2025-05-31', 'Insertar';
EXEC actividades.GestionarActividad 'Nataci�n', 45000, '2025-05-31', 'Insertar';
EXEC actividades.GestionarActividad 'Ajedrez', 2000, '2025-05-31', 'Insertar';
GO


-- FUTSAL - Lunes
EXEC actividades.GestionarClase 'Futsal', '34567890', 'Lunes 08:00', 'Menor', 'Insertar';
EXEC actividades.GestionarClase 'Futsal', '34567890', 'Lunes 14:00', 'Cadete', 'Insertar';
EXEC actividades.GestionarClase 'Futsal', '34567890', 'Lunes 19:00', 'Mayor', 'Insertar';

-- V�LEY - Martes
EXEC actividades.GestionarClase 'V�ley', '34567890', 'Martes 08:00', 'Menor', 'Insertar';
EXEC actividades.GestionarClase 'V�ley', '34567890', 'Martes 14:00', 'Cadete', 'Insertar';
EXEC actividades.GestionarClase 'V�ley', '34567890', 'Martes 19:00', 'Mayor', 'Insertar';

-- TAEKWONDO - Mi�rcoles
EXEC actividades.GestionarClase 'Taekwondo', '34567890', 'Mi�rcoles 08:00', 'Menor', 'Insertar';
EXEC actividades.GestionarClase 'Taekwondo', '34567890', 'Mi�rcoles 14:00', 'Cadete', 'Insertar';
EXEC actividades.GestionarClase 'Taekwondo', '34567890', 'Mi�rcoles 19:00', 'Mayor', 'Insertar';

-- BAILE ART�STICO - Jueves
EXEC actividades.GestionarClase 'Baile art�stico', '34567890', 'Jueves 08:00', 'Menor', 'Insertar';
EXEC actividades.GestionarClase 'Baile art�stico', '34567890', 'Jueves 14:00', 'Cadete', 'Insertar';
EXEC actividades.GestionarClase 'Baile art�stico', '34567890', 'Jueves 19:00', 'Mayor', 'Insertar';

-- NATACI�N - Viernes
EXEC actividades.GestionarClase 'Nataci�n', '34567890', 'Viernes 08:00', 'Menor', 'Insertar';
EXEC actividades.GestionarClase 'Nataci�n', '34567890', 'Viernes 14:00', 'Cadete', 'Insertar';
EXEC actividades.GestionarClase 'Nataci�n', '34567890', 'Viernes 19:00', 'Mayor', 'Insertar';

-- AJEDREZ - S�bado
EXEC actividades.GestionarClase 'Ajedrez', '34567890', 'S�bado 08:00', 'Menor', 'Insertar';
EXEC actividades.GestionarClase 'Ajedrez', '34567890', 'S�bado 14:00', 'Cadete', 'Insertar';
EXEC actividades.GestionarClase 'Ajedrez', '34567890', 'S�bado 19:00', 'Mayor', 'Insertar';
GO
-- Francisco se inscribe a 3 actividades
EXEC actividades.GestionarInscripcion '45778667', 'Ajedrez', 'S�bado 19:00', 'Mayor', '2025-06-12', 'Insertar';
EXEC actividades.GestionarInscripcion '45778667', 'Futsal', 'Lunes 19:00', 'Mayor', '2025-06-13', 'Insertar';
EXEC actividades.GestionarInscripcion '45778667', 'Taekwondo', 'Mi�rcoles 19:00', 'Mayor', '2025-06-14', 'Insertar';

-- Mariana se inscribe a 1 sola actividad
EXEC actividades.GestionarInscripcion '40505050', 'Baile art�stico', 'Jueves 14:00', 'Cadete', '2025-06-12', 'Insertar';

-- Juan se inscribe a 2 actividades
EXEC actividades.GestionarInscripcion '33444555', 'Taekwondo', 'Mi�rcoles 14:00', 'Cadete', '2025-06-13', 'Insertar';
EXEC actividades.GestionarInscripcion '33444555', 'Ajedrez', 'S�bado 14:00', 'Cadete', '2025-06-14', 'Insertar';

-- Camila se inscribe a 1 sola actividad
EXEC actividades.GestionarInscripcion '40606060', 'Nataci�n', 'Viernes 14:00', 'Cadete', '2025-06-15', 'Insertar';

-- Luciano se inscribe a 2 actividades
EXEC actividades.GestionarInscripcion '40707070', 'V�ley', 'Martes 19:00', 'Mayor', '2025-06-12', 'Insertar';
EXEC actividades.GestionarInscripcion '40707070', 'Baile art�stico', 'Jueves 19:00', 'Mayor', '2025-06-13', 'Insertar';

-- =================== CARGA DE PRESENTISMO DE SOCIOS ===================

-- Francisco (3 clases)
EXEC actividades.GestionarPresentismoClase 'Ajedrez', '45778667', 'S�bado 19:00', 'Mayor', '2025-06-12', 'P', 'Insertar';
EXEC actividades.GestionarPresentismoClase 'Futsal', '45778667', 'Lunes 19:00', 'Mayor', '2025-06-13', 'A', 'Insertar'; -- Ausente
EXEC actividades.GestionarPresentismoClase 'Taekwondo', '45778667', 'Mi�rcoles 19:00', 'Mayor', '2025-06-14', 'J', 'Insertar'; -- Justificada

-- Mariana (1 clase)
EXEC actividades.GestionarPresentismoClase 'Baile art�stico', '40505050', 'Jueves 14:00', 'Cadete', '2025-06-12', 'P', 'Insertar';

-- Juan (2 clases)
EXEC actividades.GestionarPresentismoClase 'Taekwondo', '33444555', 'Mi�rcoles 14:00', 'Cadete', '2025-06-13', 'A', 'Insertar'; -- Ausente
EXEC actividades.GestionarPresentismoClase 'Ajedrez', '33444555', 'S�bado 14:00', 'Cadete', '2025-06-14', 'P', 'Insertar';

-- Camila (1 clase)
EXEC actividades.GestionarPresentismoClase 'Nataci�n', '40606060', 'Viernes 14:00', 'Cadete', '2025-06-15', 'J', 'Insertar'; -- Justificada

-- Luciano (2 clases)
EXEC actividades.GestionarPresentismoClase 'V�ley', '40707070', 'Martes 19:00', 'Mayor', '2025-06-12', 'P', 'Insertar';
EXEC actividades.GestionarPresentismoClase 'Baile art�stico', '40707070', 'Jueves 19:00', 'Mayor', '2025-06-13', 'P', 'Insertar';


-- =================== VERIFICAR ===================

SELECT * FROM actividades.Clase;
SELECT * FROM actividades.Actividad;
SELECT * FROM actividades.InscriptoClase;
SELECT * FROM actividades.presentismoClase ORDER BY fecha;
