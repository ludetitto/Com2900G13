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
  __________________ Pruebas GestionarCategoriaSocio __________________
  _____________________________________________________________________*/

-- ✅ PRUEBA 1: Inserción válida de categoría "Menor"
EXEC administracion.GestionarCategoriaSocio
    @nombre = 'Menor',
    @edad_desde = 0,
    @edad_hasta = 12,
    @costo_membresia = 700.00,
    @vigencia = '2025-12-31',
    @operacion = 'Insertar';
-- Resultado esperado: Categoría "Menor" insertada correctamente
GO
SELECT * FROM administracion.CategoriaSocio;

-- ✅ PRUEBA 2: Inserción válida de categoría "Cadete"
EXEC administracion.GestionarCategoriaSocio
    @nombre = 'Cadete',
    @edad_desde = 13,
    @edad_hasta = 17,
    @costo_membresia = 800.00,
    @vigencia = '2025-12-31',
    @operacion = 'Insertar';
-- Resultado esperado: Categoría "Cadete" insertada correctamente
GO
SELECT * FROM administracion.CategoriaSocio;

-- ✅ PRUEBA 3: Inserción válida de categoría "Mayor" (sin límite superior)
EXEC administracion.GestionarCategoriaSocio
    @nombre = 'Mayor',
    @edad_desde = 18,
    @edad_hasta = 150, --la persona mas longeva verificada vivio 122 años y 164 dias
    @costo_membresia = 1000.00,
    @vigencia = '2025-12-31',
    @operacion = 'Insertar';
-- Resultado esperado: Categoría "Mayor" insertada correctamente
GO
SELECT * FROM administracion.CategoriaSocio;

-- ❌ PRUEBA 4: Insertar categoría sin nombre
EXEC administracion.GestionarCategoriaSocio
    @nombre = '',
    @edad_desde = 0,
    @edad_hasta = 10,
    @costo_membresia = 600.00,
    @vigencia = '2025-06-01',
    @operacion = 'Insertar';
-- Resultado esperado: Error "El nombre de la categoría es obligatorio."
GO
SELECT * FROM administracion.CategoriaSocio;

-- ❌ PRUEBA 5: Insertar categoría sin rango de edad
EXEC administracion.GestionarCategoriaSocio
    @nombre = 'Senior',
    @edad_desde = NULL,
    @edad_hasta = NULL,
    @costo_membresia = 1200.00,
    @vigencia = '2025-12-31',
    @operacion = 'Insertar';
-- Resultado esperado: Error por falta de rango de edad
GO
SELECT * FROM administracion.CategoriaSocio;

-- ✅ PRUEBA 6: Modificar vigencia de la categoría "Menor"
EXEC administracion.GestionarCategoriaSocio
    @nombre = 'Menor',
    @vigencia = '2026-12-31',
    @operacion = 'Modificar';
-- Resultado esperado: Vigencia actualizada para "Menor"
GO
SELECT * FROM administracion.CategoriaSocio;

-- ✅ PRUEBA 7: Eliminar categoría "Cadete"
EXEC administracion.GestionarCategoriaSocio
    @nombre = 'Cadete',
    @operacion = 'Eliminar';
-- Resultado esperado: Categoría eliminada correctamente
GO
SELECT * FROM administracion.CategoriaSocio;

-- ❌ PRUEBA 8: Eliminar categoría inexistente
EXEC administracion.GestionarCategoriaSocio
    @nombre = 'Inexistente',
    @operacion = 'Eliminar';
-- Resultado esperado: Error "No se encontró una categoría con ese nombre para eliminar."
GO
SELECT * FROM administracion.CategoriaSocio;




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
    @categoria = 'Mayor',
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
    @dni = '23456789',
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
    @dni = '34567890',
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
    @dni = '34567890',
    @email = NULL,
    @fecha_nacimiento = NULL,
    @tel_contacto = NULL,
    @tel_emergencia = NULL,
    @operacion = 'Eliminar';
-- Resultado esperado: Profesor eliminado, persona no borrada
GO
SELECT * FROM administracion.Profesor
SELECT * FROM administracion.Persona


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
    @categoria = 'Mayor',
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
    @categoria = 'Cadete',
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

-- ✅ PRUEBA 3: insertar a un socio a el mismo
EXEC administracion.GestionarGrupoFamiliar
    @dni_socio = '33444555',
    @dni_socio_rp = '33444555',
    @operacion = 'Insertar';
-- Resultado esperado: Grupo familiar insertado correctamente
GO
SELECT * FROM administracion.Socio
SELECT * FROM administracion.Persona
SELECT * FROM administracion.GrupoFamiliar

-- ❌ PRUEBA 4: Insertar grupo familiar con socio inexistente
EXEC administracion.GestionarGrupoFamiliar
    @dni_socio = '99999999',
    @dni_socio_rp = '88888888',
    @operacion = 'Insertar';
-- Resultado esperado: Error por FK en socio o socio_rp
GO



/*_____________________________________________________________________
  _____________________ P_ConsultarEstadoSocioyGrupo ______________________
  _____________________________________________________________________*/

  -- 1. Socio existente sin familiares
EXEC administracion.ConsultarEstadoSocioyGrupo @dni = '23456789';
-- Esperado: Datos del titular, sin familiares

-- 2. Socio existente con familiares (buscar un dni real con grupo)
EXEC administracion.ConsultarEstadoSocioyGrupo @dni = '45778667';
-- Esperado: Titular y familiares del grupo

-- 3. Socio sin grupo familiar 
EXEC administracion.ConsultarEstadoSocioyGrupo @dni = '33444555';
-- Esperado: solo muestra al titular

-- 4. DNI inválido
EXEC administracion.ConsultarEstadoSocioyGrupo @dni = '123';
-- Esperado: Error "El DNI debe tener exactamente 8 dígitos numéricos."

-- 5. Socio con mail inválido (buscar dni real con mail mal cargado)
EXEC administracion.ConsultarEstadoSocioyGrupo @dni = '00001111';
-- Esperado: Error "El correo electrónico del socio no tiene un formato válido."

-- 6. Socio inexistente
EXEC administracion.ConsultarEstadoSocioyGrupo @dni = '99999999';
-- Esperado: Error "No existe un socio activo con el DNI especificado."

/*_______________________________________________________________________________
  _________________________________PRUEBA MODULO ________________________________
  _______________________________________________________________________________ */

