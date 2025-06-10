/* =========================================================================
   Trabajo Práctico Integrador - Bases de Datos Aplicadas
   Grupo N°: 13
   Comisión: 2900
   Fecha de Entrega: 17/06/2025
   Materia: Bases de Datos Aplicadas
   Alumnos: Vignardel Francisco 45778667
            De Titto Lucia 46501934
 ========================================================================= */

USE COM2900G13;
GO
/*_____________________________________________________________________
  ________________________ P_GestionarPersona ________________________
  _____________________________________________________________________*/

-- ✅ PRUEBA 1: Inserción válida de persona
-- Esperado: Se inserta el registro correctamente
EXEC administracion.GestionarPersona
    @nombre = 'Juan',
    @apellido = 'Pérez',
    @dni = '12345678',
    @email = 'juan.perez@email.com',
    @fecha_nacimiento = '2024-10-25',
    @tel_contacto = '1234567890',
    @tel_emergencia = '0987654321',
    @operacion = 'Insertar';
-- Resultado esperado: Persona insertada sin errores
GO
SELECT * FROM administracion.Persona
-- ✅ PRUEBA 2: Modificación válida de persona existente
-- Esperado: Se actualizan los datos correctamente
EXEC administracion.GestionarPersona
    @nombre = NULL,
    @apellido = NULL,
    @dni = '12345678',
    @email = NULL,
    @fecha_nacimiento = '1985-12-25',
    @tel_contacto = NULL,
    @tel_emergencia = NULL,
    @operacion = 'Modificar';
-- Resultado esperado: Persona modificada sin errores
GO
SELECT * FROM administracion.Persona


-- ✅ PRUEBA 3: Eliminación válida de persona
-- Esperado: Se elimina el registro con DNI dado
EXEC administracion.GestionarPersona
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
EXEC administracion.GestionarPersona
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
EXEC administracion.GestionarPersona
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
EXEC administracion.GestionarCategoriaSocio
    @nombre = 'Adulto',
    @años = 18,
    @costo_membresia = 1000.00,
    @vigencia = '2025-12-31',
    @operacion = 'Insertar';
-- Resultado esperado: Categoría insertada correctamente
GO
SELECT TOP 10 * FROM administracion.CategoriaSocio


-- ✅ PRUEBA 2: Eliminación válida de categoría
EXEC administracion.GestionarCategoriaSocio
    @nombre = 'Adulto',
    @años = NULL,
    @costo_membresia = NULL,
    @vigencia = NULL,
    @operacion = 'Eliminar';
-- Resultado esperado: Categoría eliminada correctamente
GO

-- ❌ PRUEBA 3: Insertar categoría sin nombre
EXEC administracion.GestionarCategoriaSocio
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
EXEC administracion.GestionarSocio
    @nombre = 'Franco',
    @apellido = 'Martínez',
    @dni = '23456789',
    @email = 'lucas.martinez@email.com',
    @fecha_nacimiento = '1992-03-10',
    @tel_contacto = '1231231234',
    @tel_emergencia = '4324324321',
    @categoria = 'Adulto',
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
EXEC administracion.GestionarSocio
    @dni = '34567890',
    @operacion = 'Eliminar';

SELECT * FROM administracion.Socio;
SELECT * FROM administracion.Persona;


-- ❌ PRUEBA 3: Eliminar socio inexistente
EXEC administracion.GestionarSocio
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
EXEC administracion.GestionarProfesor
    @nombre = 'Ana',
    @apellido = 'García',
    @dni = '23456789',
    @email = 'ana.garcia@email.com',
    @fecha_nacimiento = '1990-08-15',
    @tel_contacto = '1112223333',
    @tel_emergencia = '3332221111',
    @operacion = 'Insertar';
-- Resultado esperado: Persona y profesor insertados correctamente
GO
SELECT * FROM administracion.Profesor
SELECT * FROM administracion.Persona


-- ✅ PRUEBA 2: Eliminación válida de profesor
EXEC administracion.GestionarProfesor
    @nombre = NULL,
    @apellido = NULL,
    @dni = '23456789',
    @email = NULL,
    @fecha_nacimiento = NULL,
    @tel_contacto = NULL,
    @tel_emergencia = NULL,
    @operacion = 'Eliminar';
-- Resultado esperado: Profesor eliminado, persona no borrada
GO
SELECT * FROM administracion.Profesor


-- ❌ PRUEBA 3: Eliminación de profesor inexistente
EXEC administracion.GestionarProfesor
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

--insertar Socios
EXEC administracion.GestionarSocio
    @nombre = 'Francisco',
    @apellido = 'Vignardel',
    @dni = '45778667',
    @email = 'francisco.vignardel@email.com',
    @fecha_nacimiento = '2004-04-10',
    @tel_contacto = '1231233234',
    @tel_emergencia = '6624324321',
    @categoria = 'Adulto',
    @nro_socio = 'SOC1002',
    @obra_social = 'OSPOCE',
    @nro_obra_social = '654321',
    @saldo = 0,
    @operacion = 'Insertar';
-- Resultado esperado: Persona y socio insertados correctamente
GO

EXEC administracion.GestionarSocio
    @nombre = 'Juan',
    @apellido = 'Perez',
    @dni = '33444555',
    @email = 'juan.perez@email.com',
    @fecha_nacimiento = '2004-04-10',
    @tel_contacto = '3331233234',
    @tel_emergencia = '6624324388',
    @categoria = 'Adulto',
    @nro_socio = 'SOC1003',
    @obra_social = 'VITA',
    @nro_obra_social = '654331',
    @saldo = 0,
    @operacion = 'Insertar';
-- Resultado esperado: Persona y socio insertados correctamente
GO
SELECT * FROM administracion.Socio
SELECT * FROM administracion.Persona

-- ✅ PRUEBA 1: Inserción válida de invitado
EXEC administracion.GestionarInvitado
    @dni_socio = '45778667',
	@dni_invitado = '34567891',
    @operacion = 'Insertar';
-- Resultado esperado: Invitado insertado correctamente
GO

select * from administracion.Persona
select * from administracion.Socio
select * from administracion.Invitado

-- ✅ PRUEBA 2: Eliminación válida de invitado
EXEC administracion.GestionarInvitado
    @dni_socio = '45778667',
	@dni_invitado = '34567891',
    @operacion = 'Eliminar';
-- Resultado esperado: Invitado eliminado correctamente
GO

select * from administracion.Persona
select * from administracion.Socio
select * from administracion.Invitado

-- ❌ PRUEBA 3: Insertar invitado con DNI ya existente
EXEC administracion.GestionarInvitado
    @dni_socio = '45678901',
	@dni_invitado = '12345678',
    @operacion = 'Insertar';
-- Resultado esperado: Error por restricción UNIQUE en DNI
GO

/*_____________________________________________________________________
  _____________________ P_GestionarGrupoFamiliar ______________________
  _____________________________________________________________________*/


-- ✅ PRUEBA 1: Inserción válida de grupo familiar
EXEC administracion.GestionarGrupoFamiliar
    @dni_socio = '23456789',
    @dni_socio_rp = '45778667',
    @operacion = 'Insertar';
-- Resultado esperado: Grupo familiar insertado correctamente
GO

SELECT * FROM administracion.Socio
SELECT * FROM administracion.GrupoFamiliar

-- ✅ PRUEBA 2: Eliminación válida de grupo familiar
EXEC administracion.GestionarGrupoFamiliar
    @dni_socio = '23456789',
    @dni_socio_rp = '45778667',
    @operacion = 'Eliminar';
-- Resultado esperado: Grupo familiar eliminado correctamente
GO
SELECT * FROM administracion.Socio
SELECT * FROM administracion.GrupoFamiliar


-- ❌ PRUEBA 3: Insertar grupo familiar con socio inexistente
EXEC administracion.GestionarGrupoFamiliar
    @dni_socio = '99999999',
    @dni_socio_rp = '88888888',
    @operacion = 'Insertar';
-- Resultado esperado: Error por FK en socio o socio_rp
GO

-- ✅ PRUEBA 4: insertar a un socio a el mismo
EXEC administracion.GestionarGrupoFamiliar
    @dni_socio = '33444555',
    @dni_socio_rp = '33444555',
    @operacion = 'Insertar';
-- Resultado esperado: Grupo familiar insertado correctamente
GO
SELECT * FROM administracion.Socio
SELECT * FROM administracion.Persona
SELECT * FROM administracion.GrupoFamiliar
/*_______________________________________________________________________________
  _________________________________PRUEBA MODULO ________________________________
  _______________________________________________________________________________ */

