-- =========================================================================
-- Trabajo Práctico Integrador - Bases de Datos Aplicadas
-- Testing para módulo de Gestión de Cobranzas
-- Grupo N°: 13 | Comisión: 2900 | Fecha de Entrega: 17/06/2025
-- =========================================================================

USE COM2900G13;
GO
/*_____________________________________________________________________
  ________________________ P_GestionarPersonas ________________________
  _____________________________________________________________________*/

-- ✅ PRUEBA 1: Inserción válida de persona
-- Esperado: Se inserta el registro correctamente
EXEC administracion.P_GestionarPersonas
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
EXEC administracion.P_GestionarPersonas
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
EXEC administracion.P_GestionarPersonas
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
EXEC administracion.P_GestionarPersonas
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
EXEC administracion.P_GestionarPersonas
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
  _________________________ P_ImportarSocios _________________________
  ____________________________________________________________________*/

  EXEC Administracion.P_ImportarSocios
    @RutaArchivo = 'C:\Users\ldeti\Documents\SQL Server Management Studio\Code Snippets\SQL\My Code Snippets\csv.csv';

SELECT * FROM administracion.Persona
DELETE FROM administracion.Persona
WHERE dni > 0