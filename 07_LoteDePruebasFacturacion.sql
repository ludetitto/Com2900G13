USE COM2900G13;
GO

delete from actividades.Clase
delete from actividades.Actividad


-- Insertar actividades base (sin horarios)
EXEC actividades.GestionarActividad 'Futsal', 25000, '2025-05-31', 'Insertar';
EXEC actividades.GestionarActividad 'Vóley', 30000, '2025-05-31', 'Insertar';
EXEC actividades.GestionarActividad 'Taekwondo', 25000, '2025-05-31', 'Insertar';
EXEC actividades.GestionarActividad 'Baile artístico', 30000, '2025-05-31', 'Insertar';
EXEC actividades.GestionarActividad 'Natación', 45000, '2025-05-31', 'Insertar';
EXEC actividades.GestionarActividad 'Ajedrez', 2000, '2025-05-31', 'Insertar';
GO


-- FUTSAL - Lunes
EXEC actividades.GestionarClase 'Futsal', '34567890', 'Lunes 08:00', 'Menor', 'Insertar';
EXEC actividades.GestionarClase 'Futsal', '34567890', 'Lunes 14:00', 'Cadete', 'Insertar';
EXEC actividades.GestionarClase 'Futsal', '34567890', 'Lunes 19:00', 'Mayor', 'Insertar';

-- VÓLEY - Martes
EXEC actividades.GestionarClase 'Vóley', '34567890', 'Martes 08:00', 'Menor', 'Insertar';
EXEC actividades.GestionarClase 'Vóley', '34567890', 'Martes 14:00', 'Cadete', 'Insertar';
EXEC actividades.GestionarClase 'Vóley', '34567890', 'Martes 19:00', 'Mayor', 'Insertar';

-- TAEKWONDO - Miércoles
EXEC actividades.GestionarClase 'Taekwondo', '34567890', 'Miércoles 08:00', 'Menor', 'Insertar';
EXEC actividades.GestionarClase 'Taekwondo', '34567890', 'Miércoles 14:00', 'Cadete', 'Insertar';
EXEC actividades.GestionarClase 'Taekwondo', '34567890', 'Miércoles 19:00', 'Mayor', 'Insertar';

-- BAILE ARTÍSTICO - Jueves
EXEC actividades.GestionarClase 'Baile artístico', '34567890', 'Jueves 08:00', 'Menor', 'Insertar';
EXEC actividades.GestionarClase 'Baile artístico', '34567890', 'Jueves 14:00', 'Cadete', 'Insertar';
EXEC actividades.GestionarClase 'Baile artístico', '34567890', 'Jueves 19:00', 'Mayor', 'Insertar';

-- NATACIÓN - Viernes
EXEC actividades.GestionarClase 'Natación', '34567890', 'Viernes 08:00', 'Menor', 'Insertar';
EXEC actividades.GestionarClase 'Natación', '34567890', 'Viernes 14:00', 'Cadete', 'Insertar';
EXEC actividades.GestionarClase 'Natación', '34567890', 'Viernes 19:00', 'Mayor', 'Insertar';

-- AJEDREZ - Sábado
EXEC actividades.GestionarClase 'Ajedrez', '34567890', 'Sábado 08:00', 'Menor', 'Insertar';
EXEC actividades.GestionarClase 'Ajedrez', '34567890', 'Sábado 14:00', 'Cadete', 'Insertar';
EXEC actividades.GestionarClase 'Ajedrez', '34567890', 'Sábado 19:00', 'Mayor', 'Insertar';
GO

-- Verificar
SELECT * FROM actividades.Clase;

-- Verificar que se insertaron correctamente
SELECT * FROM actividades.Actividad;
