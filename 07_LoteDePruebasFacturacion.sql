USE COM2900G13;
GO

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

-- Verificar
SELECT * FROM actividades.Clase;

-- Verificar que se insertaron correctamente
SELECT * FROM actividades.Actividad;
