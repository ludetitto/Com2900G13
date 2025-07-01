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
delete from socios.categoriaSocio

-- ✅ PRUEBA 1: Inserción válida de categoría "Menor"
EXEC socios.GestionarCategoriaSocio
    @nombre_categoria  = 'Menor',
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
    @nombre_categoria  = 'Cadete',
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
    @nombre_categoria  = 'Mayor',
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
    @nombre_categoria  = 'Menor',
    @edad_minima = 0,
    @edad_maxima = 12,
    @costo = 1000.00,
    @vigencia = '2025-12-31',
    @operacion = 'Insertar';
-- Resultado esperado: Error por descripción ya existente
GO

-- ❌ PRUEBA 5: Insertar categoría con edad inválida
EXEC socios.GestionarCategoriaSocio
    @nombre_categoria  = 'Erronea',
    @edad_minima = 15,
    @edad_maxima = 10,
    @costo = 1200.00,
    @vigencia = '2025-12-31',
    @operacion = 'Insertar';
-- Resultado esperado: Error por rango de edad inválido
GO

-- ❌ PRUEBA 6: Insertar categoría sin descripción
EXEC socios.GestionarCategoriaSocio
    @nombre_categoria  = '',
    @edad_minima = 10,
    @edad_maxima = 15,
    @costo = 1200.00,
    @vigencia = '2025-12-31',
    @operacion = 'Insertar';
-- Resultado esperado: Error por descripción obligatoria
GO

-- ✅ PRUEBA 7: Modificar vigencia de categoría "Cadete"
EXEC socios.GestionarCategoriaSocio
    @nombre_categoria  = 'Cadete',
    @vigencia = '2026-12-31',
    @operacion = 'Modificar';
-- Resultado esperado: Vigencia actualizada correctamente
GO
SELECT * FROM socios.CategoriaSocio;
GO

-- ❌ PRUEBA 8: Modificar categoría inexistente
EXEC socios.GestionarCategoriaSocio
    @nombre_categoria  = 'NoExiste',
    @costo = 999.00,
    @operacion = 'Modificar';
-- Resultado esperado: Error por categoría no encontrada
GO

-- ✅ PRUEBA 9: Eliminar categoría "Cadete"
EXEC socios.GestionarCategoriaSocio
    @nombre_categoria  = 'Cadete',
    @operacion = 'Eliminar';
-- Resultado esperado: Eliminación exitosa
GO
SELECT * FROM socios.CategoriaSocio;
GO

-- ❌ PRUEBA 10: Eliminar categoría inexistente
EXEC socios.GestionarCategoriaSocio
    @nombre_categoria  = 'Desconocida',
    @operacion = 'Eliminar';
-- Resultado esperado: Error por categoría no encontrada
GO

/*_____________________________________________________________________
  ______________________ PRUEBAS socios.GestionarSocio _________________
  _____________________________________________________________________*/
-- ✅ LIMPIEZA previa (opcional)
DELETE FROM actividades.InscriptoCategoriaSocio;
DELETE FROM socios.GrupoFamiliarSocio;
DELETE FROM socios.Tutor;
DELETE FROM socios.GrupoFamiliar;
DELETE FROM socios.Socio;
GO

-- ✅ PRUEBA 1: Alta de socio mayor (individual)
EXEC socios.GestionarSocio
    @nombre = 'Carlos',
    @apellido = 'Gómez',
    @dni = '30000000',
    @nro_socio = 'SN-4001',
    @email = 'carlos.gomez@email.com',
    @fecha_nacimiento = '1990-05-10',
    @telefono = '1111222233',
    @telefono_emergencia = '1133445566',
    @domicilio = 'Calle Mayor 123',
    @obra_social = 'OSDE',
    @nro_os = 'OS123456',
    @operacion = 'Insertar';
GO

-- Verificacion de las tablas
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
    @nro_socio = 'SN-4002',
    @email = 'julian.perez@email.com',
    @fecha_nacimiento = '2012-10-15',
    @telefono = '2233445566',
    @telefono_emergencia = '6677889900',
    @domicilio = 'Calle del Sol 222',
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
-- Verificacion de las tablas
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
    @nro_socio = 'SN-4003',
    @email = 'martina.perez@email.com',
    @fecha_nacimiento = '2010-07-01',
    @telefono = '3344556677',
    @telefono_emergencia = '7788990011',
    @domicilio = 'Calle del Sol 222',
    @obra_social = 'Galeno',
    @nro_os = 'G456',
    @dni_integrante_grupo = '31111111',
    @operacion = 'Insertar';
GO
-- Verificacion de las tablas
SELECT * FROM socios.Socio ORDER BY id_socio;
SELECT * FROM socios.GrupoFamiliar ORDER BY id_grupo;
SELECT * FROM socios.GrupoFamiliarSocio ORDER BY id_grupo, id_socio;
SELECT * FROM socios.Tutor ORDER BY id_grupo;
GO


-- ✅ PRUEBA 4: Alta de mayor a grupo familiar existente
EXEC socios.GestionarSocio
    @nombre = 'Nicolás',
    @apellido = 'Martínez',
    @dni = '32222222',
    @nro_socio = 'SN-4004',
    @email = 'nicolas.martinez@email.com',
    @fecha_nacimiento = '1985-08-20',
    @telefono = '1122334455',
    @telefono_emergencia = '1100110011',
    @domicilio = 'Calle Luna 456',
    @obra_social = 'Swiss Medical',
    @nro_os = 'SM1234',
    @dni_integrante_grupo = '31111113',
    @es_responsable = 0,
    @operacion = 'Insertar';
GO
-- Verificacion de las tablas
SELECT * FROM socios.Socio ORDER BY id_socio;
SELECT * FROM socios.GrupoFamiliar ORDER BY id_grupo;
SELECT * FROM socios.GrupoFamiliarSocio ORDER BY id_grupo, id_socio;
SELECT * FROM socios.Tutor ORDER BY id_grupo;
GO


-- ✅ PRUEBA 5: Alta de mayor que pasa a ser responsable
EXEC socios.GestionarSocio
    @nombre = 'Lucía',
    @apellido = 'Gómez',
    @dni = '34444444',
    @nro_socio = 'SN-4005',
    @email = 'lucia.gomez@email.com',
    @fecha_nacimiento = '1982-06-10',
    @telefono = '555666777',
    @telefono_emergencia = '123456789',
    @domicilio = 'Calle Nueva 999',
    @obra_social = 'IOMA',
    @nro_os = 'IOMA1234',
    @dni_integrante_grupo = '31111111',
    @es_responsable = 1,
    @operacion = 'Insertar';
GO
-- Verificacion de las tablas
SELECT * FROM socios.Socio ORDER BY id_socio;
SELECT * FROM socios.GrupoFamiliar ORDER BY id_grupo;
SELECT * FROM socios.GrupoFamiliarSocio ORDER BY id_grupo, id_socio;
SELECT * FROM socios.Tutor ORDER BY id_grupo;
GO


-- ❌ PRUEBA 6: DNI duplicado
EXEC socios.GestionarSocio
    @nombre = 'Duplicado',
    @apellido = 'Apellido',
    @dni = '30000000',
    @nro_socio = 'SN-9999',
    @email = 'dup@email.com',
    @fecha_nacimiento = '1988-01-01',
    @telefono = '111222333',
    @telefono_emergencia = '000111222',
    @domicilio = 'Calle X',
    @obra_social = 'OSDE',
    @nro_os = 'OS000',
    @operacion = 'Insertar';
-- Esperado: error por DNI duplicado
GO

-- ❌ PRUEBA 7: Menor sin grupo ni tutor
EXEC socios.GestionarSocio
    @nombre = 'Sofía',
    @apellido = 'López',
    @dni = '33333333',
    @nro_socio = 'SN-4006',
    @email = 'sofia.lopez@email.com',
    @fecha_nacimiento = '2015-03-21',
    @telefono = '999111000',
    @telefono_emergencia = '111222000',
    @domicilio = 'Calle N',
    @obra_social = 'IOMA',
    @nro_os = 'I001',
    @operacion = 'Insertar';
-- Esperado: error por falta de tutor
GO


-- ✅ PRUEBA 9: Eliminar socio mayor (Carlos Gómez)
EXEC socios.GestionarSocio
    @dni = '30000000',
    @operacion = 'Eliminar';
GO
-- Verificacion de las tablas
SELECT * FROM socios.Socio ORDER BY id_socio;
SELECT * FROM socios.GrupoFamiliar ORDER BY id_grupo;
SELECT * FROM socios.GrupoFamiliarSocio ORDER BY id_grupo, id_socio;
SELECT * FROM socios.Tutor ORDER BY id_grupo;
GO


-- ✅ PRUEBA 10: Eliminar socio menor (Julián)
EXEC socios.GestionarSocio
    @dni = '31111111',
    @operacion = 'Eliminar';
GO
-- Verificacion de las tablas
SELECT * FROM socios.Socio ORDER BY id_socio;
SELECT * FROM socios.GrupoFamiliar ORDER BY id_grupo;
SELECT * FROM socios.GrupoFamiliarSocio ORDER BY id_grupo, id_socio;
SELECT * FROM socios.Tutor ORDER BY id_grupo;
GO


-- ❌ PRUEBA 11: Eliminar socio inexistente
EXEC socios.GestionarSocio
    @dni = '99999999',
    @operacion = 'Eliminar';
GO

-- ✅ PRUEBA 12: Eliminar responsable Lucía y pasar responsabilidad a Nicolás
EXEC socios.GestionarSocio
    @dni = '34444444',           -- Lucía Gómez
    @dni_nuevo_rp = '32222222',  -- Nicolás Martínez
    @operacion = 'Eliminar';
GO

SELECT * FROM socios.Socio WHERE dni IN ('34444444', '32222222');
SELECT * FROM socios.GrupoFamiliar;
SELECT * FROM socios.Tutor;
GO

-- ✅ PRUEBA 13: Eliminar responsable Nicolás y asignar tutor responsable al grupo

EXEC socios.GestionarSocio
    @dni = '32222222',            -- Nicolás Martínez (responsable actual)
    @dni_tutor = '45555555',      -- Nuevo tutor
    @nombre_tutor = 'Andrea',
    @apellido_tutor = 'Fernández',
    @email_tutor = 'andrea.fernandez@email.com',
    @fecha_nac_tutor = '1980-05-01',
    @telefono_tutor = '1199998888',
    @relacion_tutor = 'Tía',
    @domicilio_tutor = 'Calle de la Tía 789',
    @operacion = 'Eliminar';
GO

-- 🔍 Verificaciones post-eliminación
SELECT * FROM socios.Socio 
SELECT * FROM socios.GrupoFamiliar;
SELECT * FROM socios.Tutor
GO


/*_____________________________________________________________________
  ________ PRUEBAS socios.GestionarResponsableGrupoFamiliar ___________
  _____________________________________________________________________*/

-- ✅ CASO 1: Cambiar SOCIO responsable a otro SOCIO (mayor de edad y del mismo grupo)
EXEC socios.GestionarResponsableGrupoFamiliar
    @dni_grupo = '31111113',               -- Martina, integrante del grupo
    @nuevo_dni_resp = '32222222',          -- Nicolás, nuevo responsable (mayor de edad)
    @tipo_responsable = 'socio';
GO

-- 🔍 Verificación
SELECT * FROM socios.Socio;
SELECT * FROM socios.GrupoFamiliar;
SELECT * FROM socios.GrupoFamiliarSocio;
SELECT * FROM socios.Tutor;
GO

-- ✅ CASO 2: Cambiar SOCIO responsable a un TUTOR (mayor de edad, nuevo)
EXEC socios.GestionarResponsableGrupoFamiliar
    @dni_grupo = '31111113',               -- integrante del grupo
    @nuevo_dni_resp = '40000001',          -- nuevo tutor
    @tipo_responsable = 'tutor',
    @nombre = 'Roberto',
    @apellido = 'Benítez',
    @domicilio = 'Calle Ficticia 123',
    @email = 'roberto.benitez@email.com',
    @fecha_nac_tutor = '1980-01-01';
GO

-- 🔍 Verificación
SELECT * FROM socios.Socio;
SELECT * FROM socios.GrupoFamiliar;
SELECT * FROM socios.GrupoFamiliarSocio;
SELECT * FROM socios.Tutor;
GO

-- ✅ CASO 3: Cambiar TUTOR responsable a otro TUTOR (nuevo, mayor)
EXEC socios.GestionarResponsableGrupoFamiliar
    @dni_grupo = '31111113',
    @nuevo_dni_resp = '40000002',
    @tipo_responsable = 'tutor',
    @nombre = 'Marcela',
    @apellido = 'Sosa',
    @domicilio = 'Calle Nueva 456',
    @email = 'marcela.sosa@email.com',
    @fecha_nac_tutor = '1985-06-15';
GO

-- 🔍 Verificación
SELECT * FROM socios.Socio;
SELECT * FROM socios.GrupoFamiliar;
SELECT * FROM socios.GrupoFamiliarSocio;
SELECT * FROM socios.Tutor;
GO

-- ✅ CASO 4: Cambiar TUTOR responsable a un SOCIO (mayor de edad y del grupo)
EXEC socios.GestionarResponsableGrupoFamiliar
    @dni_grupo = '31111113',
    @nuevo_dni_resp = '32222222',          -- Nicolás Martínez
    @tipo_responsable = 'socio';
GO

-- 🔍 Verificación
SELECT * FROM socios.Socio;
SELECT * FROM socios.GrupoFamiliar;
SELECT * FROM socios.GrupoFamiliarSocio;
SELECT * FROM socios.Tutor;
GO

-- ❌ CASO 5: Intentar asignar SOCIO menor de edad como responsable
-- (31111111 = Julián, menor)
EXEC socios.GestionarResponsableGrupoFamiliar
    @dni_grupo = '31111113',
    @nuevo_dni_resp = '31111111',
    @tipo_responsable = 'socio';
-- Esperado: Error por ser menor de edad
GO

-- ❌ CASO 6: Intentar asignar SOCIO que NO pertenece al grupo
-- (30000000 fue eliminado, o no pertenece)
EXEC socios.GestionarResponsableGrupoFamiliar
    @dni_grupo = '31111113',
    @nuevo_dni_resp = '30000000',
    @tipo_responsable = 'socio';
-- Esperado: Error por no pertenecer al grupo
GO

-- ❌ CASO 7: Intentar asignar TUTOR menor de edad
EXEC socios.GestionarResponsableGrupoFamiliar
    @dni_grupo = '31111113',
    @nuevo_dni_resp = '40000003',
    @tipo_responsable = 'tutor',
    @nombre = 'Menor',
    @apellido = 'Tutor',
    @domicilio = 'Calle Incorrecta',
    @email = 'menor@email.com',
    @fecha_nac_tutor = '2010-01-01';
-- Esperado: Error por ser menor de edad
GO

-- ❌ CASO 8: Tipo de responsable inválido
EXEC socios.GestionarResponsableGrupoFamiliar
    @dni_grupo = '31111113',
    @nuevo_dni_resp = '34444444',
    @tipo_responsable = 'admin';
-- Esperado: Error tipo inválido
GO


/*_____________________________________________________________________
  ______________ PRUEBAS socios.vwGrupoFamiliarConCategorias __________
  _____________________________________________________________________*/


-- Ver todos los grupos con sus integrantes activos y categoría
SELECT * FROM socios.vwGrupoFamiliarConCategorias
ORDER BY id_grupo, es_responsable DESC, apellido;
GO

-- Ver solo integrantes del grupo 6
SELECT * FROM socios.vwGrupoFamiliarConCategorias
WHERE id_grupo = 6;
GO

-- Ver datos del socio Carlos Gómez por DNI
SELECT * FROM socios.vwGrupoFamiliarConCategorias
WHERE dni = '30000000';
GO

-- Contar socios por grupo
SELECT id_grupo, COUNT(*) AS cantidad_socios
FROM socios.vwGrupoFamiliarConCategorias
GROUP BY id_grupo;
GO

-- Ver solo responsables de grupo
SELECT * FROM socios.vwGrupoFamiliarConCategorias
WHERE es_responsable = 1;
GO
