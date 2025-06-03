-- =========================================================================
-- Trabajo Práctico Integrador - Bases de Datos Aplicadas
-- Testing para módulo de Gestión de Cobranzas
-- Grupo N°: 13 | Comisión: 2900 | Fecha de Entrega: 17/06/2025
-- =========================================================================

USE COM2900G13;
GO
/*_____________________________________________________________________
  ________________________ spGestionarPersonas ________________________
  _____________________________________________________________________*/

-- ✅ PRUEBA 1: Inserción válida de persona
-- Esperado: Se inserta el registro correctamente
EXEC administracion.spGestionarPersonas
    @nombre = 'Juan',
    @apellido = 'Pérez',
    @dni = '12345678',
    @email = 'juan.perez@email.com',
    @fecha_nacimiento = '1985-10-25',
    @tel_contacto = '1234567890',
    @tel_emergencia = '0987654321',
    @operacion = 'Insertar';
-- Resultado esperado: Persona insertada sin errores
GO

-- ✅ PRUEBA 2: Modificación válida de persona existente
-- Esperado: Se actualizan los datos correctamente
EXEC administracion.spGestionarPersonas
    @nombre = 'Juan Carlos',
    @apellido = 'Pérez',
    @dni = '12345678',
    @email = 'juan.carlos@email.com',
    @fecha_nacimiento = '1985-10-25',
    @tel_contacto = '1112223333',
    @tel_emergencia = '4445556666',
    @operacion = 'Modificar';
-- Resultado esperado: Persona modificada sin errores
GO

-- ✅ PRUEBA 3: Eliminación válida de persona
-- Esperado: Se elimina el registro con DNI dado
EXEC administracion.spGestionarPersonas
    @nombre = NULL,
    @apellido = NULL,
    @dni = '12345678',
    @email = NULL,
    @fecha_nacimiento = NULL,
    @tel_contacto = NULL,
    @tel_emergencia = NULL,
    @operacion = 'Eliminar';
-- Resultado esperado: Persona eliminada sin errores
GO

-- ❌ PRUEBA 4: Modificar persona inexistente
EXEC administracion.spGestionarPersonas
    @nombre = 'No Existe',
    @apellido = 'Apellido',
    @dni = '99999999',
    @email = 'noexiste@email.com',
    @fecha_nacimiento = '2000-01-01',
    @tel_contacto = '0000000000',
    @tel_emergencia = '0000000000',
    @operacion = 'Modificar';
-- Resultado esperado: Error lanzado por RAISERROR y sin modificación
GO

-- ❌ PRUEBA 5: Operación inválida
-- Esperado: Error por operación no permitida
EXEC administracion.spGestionarPersonas
    @nombre = NULL,
    @apellido = NULL,
    @dni = '12345678',
    @email = NULL,
    @fecha_nacimiento = NULL,
    @tel_contacto = NULL,
    @tel_emergencia = NULL,
    @operacion = 'Actualizar';
-- Resultado esperado: Error lanzado por RAISERROR de operación inválida
GO

/*____________________________________________________________________
  _________________________ spGestionarAreas _________________________
  ____________________________________________________________________*/

-- ✅ PRUEBA 1: Inserción de nueva área 'Tesorería'
-- Esperado: Inserción exitosa
EXEC administracion.spGestionarAreas
    @nombre = 'Tesorería',
    @descripcion = 'Área encargada de la gestión financiera',
    @operacion = 'Insertar';
GO

-- ✅ PRUEBA 2: Modificación de la descripción de 'Tesorería'
-- Esperado: Actualización exitosa
EXEC administracion.spGestionarAreas
    @nombre = 'Tesorería',
    @descripcion = 'Área responsable del control financiero y pagos',
    @operacion = 'Modificar';
GO

-- ❌ PRUEBA 3: Intentar modificar un área que no existe ('Cocina')
-- Esperado: Falla con mensaje "No existe el rol para modificar."
EXEC administracion.spGestionarAreas
    @nombre = 'Cocina',
    @descripcion = 'Área de preparación de alimentos',
    @operacion = 'Modificar';
GO

-- ✅ PRUEBA 4: Eliminación del área 'Tesorería'
-- Esperado: Eliminación exitosa
EXEC administracion.spGestionarAreas
    @nombre = 'Tesorería',
    @descripcion = NULL,
    @operacion = 'Eliminar';
GO

-- ❌ PRUEBA 5: Operación no reconocida ('Actualizar')
-- Esperado: Error "Operación inválida. Usar Insertar, Modificar o Eliminar."
EXEC administracion.spGestionarAreas
    @nombre = 'Administración',
    @descripcion = 'Área general',
    @operacion = 'Actualizar';
GO

/*____________________________________________________________________
  _________________________ spGestionarRoles _________________________
  ____________________________________________________________________*/

-- ✅ PRUEBA 1: Inserción válida
-- Esperado: Inserta un rol "Profesor" en el área 2
EXEC administracion.spGestionarRoles
    @nombre = 'Profesor',
    @descripcion = 'Encargado de dictar clases',
    @id_area = 2,
    @operacion = 'Insertar';
GO

-- ❌ PRUEBA 2: Modificar rol inexistente
-- Esperado: Error "No existe el rol en el área indicada para modificar."
EXEC administracion.spGestionarRoles
    @nombre = 'Gerente',
    @descripcion = 'Modificado',
    @id_area = 3,
    @operacion = 'Modificar';
GO

-- ✅ PRUEBA 3: Modificar descripción del rol "Profesor" en área 2
-- Esperado: Actualiza la descripción
EXEC administracion.spGestionarRoles
    @nombre = 'Profesor',
    @descripcion = 'Dicta clases de forma presencial y virtual',
    @id_area = 2,
    @operacion = 'Modificar';
GO

-- ✅ PRUEBA 4: Eliminar rol existente
-- Esperado: Se elimina el registro "Profesor" en área 2
EXEC administracion.spGestionarRoles
    @nombre = 'Profesor',
    @descripcion = '', -- no se usa en Eliminar
    @id_area = 2,
    @operacion = 'Eliminar';
GO

-- ❌ PRUEBA 5: Operación inválida
-- Esperado: Error "Operación inválida..."
EXEC administracion.spGestionarRoles
    @nombre = 'Administrador',
    @descripcion = 'Supervisa el sistema',
    @id_area = 1,
    @operacion = 'Actualizar';
GO

