/* =========================================================================
   Trabajo Práctico Integrador - Bases de Datos Aplicadas
   Grupo N°: 13
   Comisión: 2900
   Fecha de Entrega: 17/06/2025
   Materia: Bases de Datos Aplicadas
   Alumnos: Vignardel Francisco				45778667
            De Titto Lucia					46501934
			Borja Tomas						42353302
			Rodriguez Sebastián Ezequiel	41691928

   Consigna: Todos los SP creados deben estar acompañados de juegos de prueba. Se espera que
realicen validaciones básicas en los SP (p/e cantidad mayor a cero, CUIT válido, etc.) y que
en los juegos de prueba demuestren la correcta aplicación de las validaciones.
 ========================================================================= */

USE COM2900G13;
GO

/*_____________________________________________________________________
  _______________ PRUEBAS socios.GestionarCategoriaSocio ______________
  _____________________________________________________________________*/

-- ✅ PRUEBA 1: Inserción válida de categoría "Menor"
EXEC socios.GestionarCategoriaSocio
    @descripcion = 'Menor',
    @edad_minima = 0,
    @edad_maxima = 12,
    @costo = 1000.00,
    @vigencia = '2025-12-31',
    @operacion = 'Insertar';
-- Resultado esperado: Categoría insertada correctamente
GO
SELECT * FROM socios.CategoriaSocio;
GO

-- ✅ PRUEBA 2: Inserción válida de categoría "Cadete"
EXEC socios.GestionarCategoriaSocio
    @descripcion = 'Cadete',
    @edad_minima = 13,
    @edad_maxima = 17,
    @costo = 1500.00,
    @vigencia = '2025-12-31',
    @operacion = 'Insertar';
-- Resultado esperado: Categoría insertada correctamente
GO
SELECT * FROM socios.CategoriaSocio;
GO

-- ✅ PRUEBA 3: Inserción válida de categoría "Mayor"
EXEC socios.GestionarCategoriaSocio
    @descripcion = 'Mayor',
    @edad_minima = 18,
    @edad_maxima = 99,
    @costo = 2000.00,
    @vigencia = '2025-12-31',
    @operacion = 'Insertar';
-- Resultado esperado: Categoría insertada correctamente
GO
SELECT * FROM socios.CategoriaSocio;
GO

-- ❌ PRUEBA 4: Insertar categoría duplicada
EXEC socios.GestionarCategoriaSocio
    @descripcion = 'Menor',
    @edad_minima = 0,
    @edad_maxima = 12,
    @costo = 1000.00,
    @vigencia = '2025-12-31',
    @operacion = 'Insertar';
-- Resultado esperado: Error por descripción ya existente
GO

-- ❌ PRUEBA 5: Insertar categoría con edad inválida
EXEC socios.GestionarCategoriaSocio
    @descripcion = 'Erronea',
    @edad_minima = 15,
    @edad_maxima = 10,
    @costo = 1200.00,
    @vigencia = '2025-12-31',
    @operacion = 'Insertar';
-- Resultado esperado: Error por rango de edad inválido
GO

-- ❌ PRUEBA 6: Insertar categoría sin descripción
EXEC socios.GestionarCategoriaSocio
    @descripcion = '',
    @edad_minima = 10,
    @edad_maxima = 15,
    @costo = 1200.00,
    @vigencia = '2025-12-31',
    @operacion = 'Insertar';
-- Resultado esperado: Error por descripción obligatoria
GO

-- ✅ PRUEBA 7: Modificar vigencia de categoría "Cadete"
EXEC socios.GestionarCategoriaSocio
    @descripcion = 'Cadete',
    @vigencia = '2026-12-31',
    @operacion = 'Modificar';
-- Resultado esperado: Vigencia actualizada correctamente
GO
SELECT * FROM socios.CategoriaSocio;
GO

-- ❌ PRUEBA 8: Modificar categoría inexistente
EXEC socios.GestionarCategoriaSocio
    @descripcion = 'NoExiste',
    @costo = 999.00,
    @operacion = 'Modificar';
-- Resultado esperado: Error por categoría no encontrada
GO

-- ✅ PRUEBA 9: Eliminar categoría "Cadete"
EXEC socios.GestionarCategoriaSocio
    @descripcion = 'Cadete',
    @operacion = 'Eliminar';
-- Resultado esperado: Eliminación exitosa
GO
SELECT * FROM socios.CategoriaSocio;
GO

-- ❌ PRUEBA 10: Eliminar categoría inexistente
EXEC socios.GestionarCategoriaSocio
    @descripcion = 'Desconocida',
    @operacion = 'Eliminar';
-- Resultado esperado: Error por categoría no encontrada
GO

/*_____________________________________________________________________
  ______________________ PRUEBAS socios.GestionarSocio _________________
  _____________________________________________________________________*/
-- ✅ LIMPIEZA previa (opcional)
DELETE FROM socios.GrupoFamiliarSocio;
DELETE FROM socios.GrupoFamiliar;
DELETE FROM socios.Tutor;
DELETE FROM socios.Socio;
GO

-- ✅ PRUEBA 1: Alta de socio mayor (individual)
EXEC socios.GestionarSocio
    @nombre = 'Carlos',
    @apellido = 'Gómez',
    @dni = '30000000',
    @email = 'carlos.gomez@email.com',
    @fecha_nacimiento = '1990-05-10',
    @telefono = '1111222233',
    @telefono_emergencia = '1133445566',
    @direccion = 'Calle Mayor 123',
    @obra_social = 'OSDE',
    @nro_os = 'OS123456',
    @operacion = 'Insertar';
GO

-- 🔍 Verificaciones completas
SELECT * FROM socios.Socio ORDER BY id_socio;
SELECT * FROM socios.GrupoFamiliar ORDER BY id_grupo;
SELECT * FROM socios.GrupoFamiliarSocio ORDER BY id_grupo, id_socio;
SELECT * FROM socios.Tutor ORDER BY id_grupo;
GO

-- ✅ PRUEBA 2: Alta de socio menor con tutor y grupo nuevo
EXEC socios.GestionarSocio
    @nombre = 'Julián',
    @apellido = 'Pérez',
    @dni = '31111111',
    @email = 'julian.perez@email.com',
    @fecha_nacimiento = '2012-10-15',
    @telefono = '2233445566',
    @telefono_emergencia = '6677889900',
    @direccion = 'Calle del Sol 222',
    @obra_social = 'Galeno',
    @nro_os = 'G123',
    @nombre_tutor = 'Laura',
    @apellido_tutor = 'Martínez',
    @dni_tutor = '31111112',
    @email_tutor = 'laura.martinez@email.com',
    @fecha_nac_tutor = '1980-04-12',
    @telefono_tutor = '1199988877',
    @relacion_tutor = 'Madre',
    @domicilio_tutor = 'Calle del Sol 222',
    @operacion = 'Insertar';
GO

-- 🔍 Verificaciones completas
SELECT * FROM socios.Socio ORDER BY id_socio;
SELECT * FROM socios.GrupoFamiliar ORDER BY id_grupo;
SELECT * FROM socios.GrupoFamiliarSocio ORDER BY id_grupo, id_socio;
SELECT * FROM socios.Tutor ORDER BY id_grupo;
GO


-- ✅ PRUEBA 3: Alta de menor a grupo existente (usando DNI de Julián)
EXEC socios.GestionarSocio
    @nombre = 'Martina',
    @apellido = 'Pérez',
    @dni = '31111113',
    @email = 'martina.perez@email.com',
    @fecha_nacimiento = '2010-07-01',
    @telefono = '3344556677',
    @telefono_emergencia = '7788990011',
    @direccion = 'Calle del Sol 222',
    @obra_social = 'Galeno',
    @nro_os = 'G456',
    @dni_integrante_grupo = '31111111',
    @operacion = 'Insertar';
GO

-- 🔍 Verificaciones completas
SELECT * FROM socios.Socio ORDER BY id_socio;
SELECT * FROM socios.GrupoFamiliar ORDER BY id_grupo;
SELECT * FROM socios.GrupoFamiliarSocio ORDER BY id_grupo, id_socio;
SELECT * FROM socios.Tutor ORDER BY id_grupo;
GO



-- ✅ PRUEBA 4: Alta de mayor a grupo familiar existente (usando DNI de Julián)
EXEC socios.GestionarSocio
    @nombre = 'Nicolás',
    @apellido = 'Martínez',
    @dni = '32222222',
    @email = 'nicolas.martinez@email.com',
    @fecha_nacimiento = '1985-08-20',
    @telefono = '1122334455',
    @telefono_emergencia = '1100110011',
    @direccion = 'Calle Luna 456',
    @obra_social = 'Swiss Medical',
    @nro_os = 'SM1234',
    @dni_integrante_grupo = '31111111', -- Referencia: Julián ya tiene grupo
    @es_responsable = 0, -- No reemplaza al tutor como responsable
    @operacion = 'Insertar';
GO

-- 🔍 Verificaciones completas
SELECT * FROM socios.Socio ORDER BY id_socio;
SELECT * FROM socios.GrupoFamiliar ORDER BY id_grupo;
SELECT * FROM socios.GrupoFamiliarSocio ORDER BY id_grupo, id_socio;
SELECT * FROM socios.Tutor ORDER BY id_grupo;
GO

-- ✅ PRUEBA 5: Alta de mayor a grupo familiar existente y pasa a ser responsable
EXEC socios.GestionarSocio
    @nombre = 'Lucía',
    @apellido = 'Gómez',
    @dni = '34444444',
    @email = 'lucia.gomez@email.com',
    @fecha_nacimiento = '1982-06-10',
    @telefono = '555666777',
    @telefono_emergencia = '123456789',
    @direccion = 'Calle Nueva 999',
    @obra_social = 'IOMA',
    @nro_os = 'IOMA1234',
    @dni_integrante_grupo = '31111111', -- Julián: referencia para unirse al grupo
    @es_responsable = 1, -- Esta vez se designa como nueva responsable del grupo
    @operacion = 'Insertar';
GO

-- 🔍 Verificaciones completas
SELECT * FROM socios.Socio ORDER BY id_socio;
SELECT * FROM socios.GrupoFamiliar ORDER BY id_grupo;
SELECT * FROM socios.GrupoFamiliarSocio ORDER BY id_grupo, id_socio;
SELECT * FROM socios.Tutor ORDER BY id_grupo;
GO



-- ❌ PRUEBA 6: Insertar socio con DNI duplicado (Carlos Gómez ya existe con ese DNI)
EXEC socios.GestionarSocio
    @nombre = 'Duplicado',
    @apellido = 'Apellido',
    @dni = '30000000', -- Ya existe en la base
    @email = 'dup@email.com',
    @fecha_nacimiento = '1988-01-01',
    @telefono = '111222333',
    @telefono_emergencia = '000111222',
    @direccion = 'Calle X',
    @obra_social = 'OSDE',
    @nro_os = 'OS000',
    @operacion = 'Insertar';
-- Resultado esperado: Error "Ya existe un socio con ese DNI"
GO

-- ❌ PRUEBA 7: Insertar menor sin grupo ni tutor (debería fallar)
EXEC socios.GestionarSocio
    @nombre = 'Sofía',
    @apellido = 'López',
    @dni = '33333333',
    @email = 'sofia.lopez@email.com',
    @fecha_nacimiento = '2015-03-21', -- Edad < 18
    @telefono = '999111000',
    @telefono_emergencia = '111222000',
    @direccion = 'Calle N',
    @obra_social = 'IOMA',
    @nro_os = 'I001',
    @operacion = 'Insertar';
-- Resultado esperado: Error "Los datos del tutor son obligatorios para menores sin grupo."
GO


-- ❌ PRUEBA 8: Insertar con categoría no existente (edad fuera de rango)
-- Solo ejecutarla si no existe categoría para esa edad
-- Resultado esperado: Error: No existe categoría para la edad
-- OMITIDA si ya se cargaron categorías para todos los rangos

-- ✅ PRUEBA 9: Eliminar socio (mayor con grupo propio que será convertido en tutor)
EXEC socios.GestionarSocio
    @dni = '30000000',
    @operacion = 'Eliminar';
-- ✅ Resultado esperado: 
-- - El socio se elimina.
-- - Si era responsable de un grupo, se lo reemplaza por NULL como responsable.
-- - Se inserta como Tutor con sus datos personales.
GO

-- 🔎 Verificaciones completas tras la eliminación
SELECT * FROM socios.Socio;
SELECT * FROM socios.GrupoFamiliar;
SELECT * FROM socios.GrupoFamiliarSocio;
SELECT * FROM socios.Tutor;
GO

-- ✅ PRUEBA 10: Eliminar socio menor (Julián Pérez)
EXEC socios.GestionarSocio
    @dni = '31111111',
    @operacion = 'Eliminar';
-- ✅ Resultado esperado:
-- - El socio menor es eliminado.
-- - Se elimina también su tutor asociado.
-- - Su entrada en GrupoFamiliarSocio se elimina.
-- - El grupo puede seguir existiendo si tiene más integrantes.
GO

-- 🔎 Verificaciones completas tras la eliminación
SELECT * FROM socios.Socio;
SELECT * FROM socios.Tutor;
SELECT * FROM socios.GrupoFamiliar;
SELECT * FROM socios.GrupoFamiliarSocio;
GO


-- ❌ PRUEBA 11: Eliminar socio inexistente
EXEC socios.GestionarSocio
    @dni = '99999999',
    @operacion = 'Eliminar';
-- Resultado esperado: Error por socio no encontrado
GO
