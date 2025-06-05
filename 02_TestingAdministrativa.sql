-- =========================================================================
-- Trabajo Práctico Integrador - Bases de Datos Aplicadas
-- Testing para módulo de Gestión de Cobranzas
-- Grupo N°: 13 | Comisión: 2900 | Fecha de Entrega: 17/06/2025
-- =========================================================================

USE COM2900G13;
GO
/*_____________________________________________________________________
  ________________________ P_GestionarPersona ________________________
  _____________________________________________________________________*/

-- ✅ PRUEBA 1: Inserción válida de persona
-- Esperado: Se inserta el registro correctamente
EXEC administracion.P_GestionarPersona
    @nombre = 'Juan',
    @apellido = 'Pérez',
    @dni = '0012345678',
    @email = 'juan.perez@email.com',
    @fecha_nacimiento = '2024-10-25',
    @tel_contacto = '1234567890',
    @tel_emergencia = '0987654321',
    @operacion = 'Insertar';
-- Resultado esperado: Persona insertada sin errores
GO

-- ✅ PRUEBA 2: Modificación válida de persona existente
-- Esperado: Se actualizan los datos correctamente
EXEC administracion.P_GestionarPersona
    @nombre = 'Juan Carlos',
    @apellido = 'Pérez',
    @dni = '0012345678',
    @email = 'juan.carlos@email.com',
    @fecha_nacimiento = '1985-10-25',
    @tel_contacto = '1112223333',
    @tel_emergencia = '4445556666',
    @operacion = 'Modificar';
-- Resultado esperado: Persona modificada sin errores
GO

-- ✅ PRUEBA 3: Eliminación válida de persona
-- Esperado: Se elimina el registro con DNI dado
EXEC administracion.P_GestionarPersona
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
EXEC administracion.P_GestionarPersona|
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
EXEC administracion.P_GestionarPersona
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

/*_____________________________________________________________________
  __________________ P_GestionarCategoriaSocio ________________________
  _____________________________________________________________________*/

-- ✅ PRUEBA 1: Inserción válida de categoría
EXEC administracion.P_GestionarCategoriaSocio
    @nombre = 'Menores',
    @años = 15,
    @costo_membresia = 1000.00,
    @vigencia = '2025-12-31',
    @operacion = 'Insertar';
-- Resultado esperado: Categoría insertada correctamente
GO

-- ✅ PRUEBA 2: Eliminación válida de categoría
EXEC administracion.P_GestionarCategoriaSocio
    @nombre = NULL,
    @años = NULL,
    @costo_membresia = NULL,
    @vigencia = NULL,
    @id_categoria = 1,
    @operacion = 'Eliminar';
-- Resultado esperado: Categoría eliminada correctamente
GO

-- ❌ PRUEBA 3: Insertar categoría sin nombre
EXEC administracion.P_GestionarCategoriaSocio
    @nombre = '',
    @años = 10,
    @costo_membresia = 500.00,
    @vigencia = '2025-06-01',
    @operacion = 'Insertar';
-- Resultado esperado: Error por nombre obligatorio
GO

SELECT TOP 10 * FROM administracion.CategoriaSocio

/*_____________________________________________________________________
  ________________________ P_GestionarSocio ___________________________
  _____________________________________________________________________*/

-- ✅ PRUEBA 1: Inserción válida de socio (persona nueva)
EXEC administracion.P_GestionarSocio
    @nombre = 'Lucas',
    @apellido = 'Martínez',
    @dni = '0034567890',
    @email = 'lucas.martinez@email.com',
    @fecha_nacimiento = '1992-03-10',
    @tel_contacto = '1231231234',
    @tel_emergencia = '4324324321',
    @categoria = 'Menores',
    @nro_socio = 'SOC1001',
    @obra_social = 'OSDE',
    @nro_obra_social = '123456',
    @saldo = 0,
    @operacion = 'Insertar';
-- Resultado esperado: Persona y socio insertados correctamente
GO
SELECT * FROM administracion.Socio
SELECT * FROM administracion.Persona

-- ✅ PRUEBA 2: Eliminación válida de socio
EXEC administracion.P_GestionarSocio
    @nombre = NULL,
    @apellido = NULL,
    @dni = '0034567890',
    @email = NULL,
    @fecha_nacimiento = NULL,
    @tel_contacto = NULL,
    @tel_emergencia = NULL,
    @id_categoria = NULL,
    @nro_socio = NULL,
    @obra_social = NULL,
    @nro_obra_social = NULL,
    @saldo = NULL,
    @activo = NULL,
    @operacion = 'Eliminar';
-- Resultado esperado: Socio eliminado, persona no borrada
GO

-- ❌ PRUEBA 3: Eliminar socio inexistente
EXEC administracion.P_GestionarSocio
    @nombre = NULL,
    @apellido = NULL,
    @dni = '9999999999',
    @email = NULL,
    @fecha_nacimiento = NULL,
    @tel_contacto = NULL,
    @tel_emergencia = NULL,
    @id_categoria = NULL,
    @nro_socio = NULL,
    @obra_social = NULL,
    @nro_obra_social = NULL,
    @saldo = NULL,
    @activo = NULL,
    @operacion = 'Eliminar';
-- Resultado esperado: Error por DNI no encontrado
GO

/*_____________________________________________________________________
  ________________________ P_GestionarProfesor ________________________
  _____________________________________________________________________*/

-- ✅ PRUEBA 1: Inserción válida de profesor (persona nueva)
EXEC administracion.P_GestionarProfesor
    @nombre = 'Ana',
    @apellido = 'García',
    @dni = '0023456789',
    @email = 'ana.garcia@email.com',
    @fecha_nacimiento = '1990-08-15',
    @tel_contacto = '1112223333',
    @tel_emergencia = '3332221111',
    @operacion = 'Insertar';
-- Resultado esperado: Persona y profesor insertados correctamente
GO

-- ✅ PRUEBA 2: Eliminación válida de profesor
EXEC administracion.P_GestionarProfesor
    @nombre = NULL,
    @apellido = NULL,
    @dni = '0023456789',
    @email = NULL,
    @fecha_nacimiento = NULL,
    @tel_contacto = NULL,
    @tel_emergencia = NULL,
    @operacion = 'Eliminar';
-- Resultado esperado: Profesor eliminado, persona no borrada
GO

-- ❌ PRUEBA 3: Eliminación de profesor inexistente
EXEC administracion.P_GestionarProfesor
    @nombre = NULL,
    @apellido = NULL,
    @dni = '9988776655',
    @email = NULL,
    @fecha_nacimiento = NULL,
    @tel_contacto = NULL,
    @tel_emergencia = NULL,
    @operacion = 'Eliminar';
-- Resultado esperado: Error lanzado (no se encuentra la persona)
GO

/*_____________________________________________________________________
  ________________________ P_GestionarInvitado ________________________
  _____________________________________________________________________*/

-- ✅ PRUEBA 1: Inserción válida de invitado
EXEC administracion.P_GestionarInvitado
    @id_socio = 1,
    @dni = '0045678901',
    @operacion = 'Insertar';
-- Resultado esperado: Invitado insertado correctamente
GO

-- ✅ PRUEBA 2: Eliminación válida de invitado
EXEC administracion.P_GestionarInvitado
    @id_socio = NULL,
    @dni = '0045678901',
    @operacion = 'Eliminar';
-- Resultado esperado: Invitado eliminado correctamente
GO

-- ❌ PRUEBA 3: Insertar invitado con DNI ya existente
EXEC administracion.P_GestionarInvitado
    @id_socio = 1,
    @dni = '0045678901',
    @operacion = 'Insertar';
-- Resultado esperado: Error por restricción UNIQUE en DNI
GO

/*_____________________________________________________________________
  _____________________ P_GestionarGrupoFamiliar ______________________
  _____________________________________________________________________*/

-- ✅ PRUEBA 1: Inserción válida de grupo familiar
EXEC administracion.P_GestionarGrupoFamiliar
    @id_socio = 1,
    @id_socio_rp = 2,
    @operacion = 'Insertar';
-- Resultado esperado: Grupo familiar insertado correctamente
GO

-- ✅ PRUEBA 2: Eliminación válida de grupo familiar
EXEC administracion.P_GestionarGrupoFamiliar
    @id_socio = 1,
    @id_socio_rp = 2,
    @operacion = 'Eliminar';
-- Resultado esperado: Grupo familiar eliminado correctamente
GO

-- ❌ PRUEBA 3: Insertar grupo familiar con socio inexistente
EXEC administracion.P_GestionarGrupoFamiliar
    @id_socio = 100,
    @id_socio_rp = 200,
    @operacion = 'Insertar';
-- Resultado esperado: Error por FK en socio o socio_rp
GO

/*_______________________________________________________________________________
  _________________________________PRUEBA MODULO ________________________________
  _______________________________________________________________________________ */
