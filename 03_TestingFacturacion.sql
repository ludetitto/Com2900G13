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
  ________________________ GestionarActividad _______________________
  _____________________________________________________________________*/

-- ✅ PRUEBA 1: Inserción válida de actividad
EXEC actividades.GestionarActividad
    @nombre = 'Ajedrez',
    @costo = 3500.00,
    @vigencia = '2025-07-01',
    @operacion = 'Insertar';
GO
SELECT * FROM actividades.Actividad;

-- ✅ PRUEBA 2: Modificación válida de actividad existente
EXEC actividades.GestionarActividad
    @nombre = 'Ajedrez',
    @costo = 4000.00,
    @vigencia = NULL,
    @operacion = 'Modificar';
GO
SELECT * FROM actividades.Actividad;

-- ✅ PRUEBA 3: Eliminación válida de actividad
EXEC actividades.GestionarActividad
    @nombre = 'Ajedrez',
    @costo = NULL,
    @vigencia = NULL,
    @operacion = 'Eliminar';
GO
SELECT * FROM actividades.Actividad;

-- ❌ PRUEBA 4: Modificar actividad inexistente
EXEC actividades.GestionarActividad
    @nombre = 'No Existe',
    @costo = 1000.00,
    @vigencia = '2025-08-01',
    @operacion = 'Modificar';
GO

-- ❌ PRUEBA 5: Operación inválida
EXEC actividades.GestionarActividad
    @nombre = 'Ajedrez',
    @costo = 1000.00,
    @vigencia = '2025-09-01',
    @operacion = 'Actualizar';
GO

/*___________________________________________________________________
  _________________________ GestionarClase __________________________
  ___________________________________________________________________*/

-- Ver datos de referencia
SELECT * FROM administracion.Profesor;
SELECT * FROM administracion.Persona;
SELECT * FROM administracion.CategoriaSocio;

-- ✅ PRUEBA 1: Inserción válida de clase
EXEC actividades.GestionarClase
    @nombre_actividad = 'Ajedrez',
    @dni_profesor = '34567890',
    @horario = 'Miércoles 17:00',
    @nombre_categoria = 'Mayor',
    @operacion = 'Insertar';
GO
SELECT * FROM actividades.Clase;

-- ✅ PRUEBA 2: Modificación válida de clase
EXEC actividades.GestionarClase
    @nombre_actividad = 'Ajedrez',
    @dni_profesor = '34567890',
    @horario = 'Miércoles 15:00',
    @nombre_categoria = 'Mayor',
    @operacion = 'Modificar';
GO
SELECT * FROM actividades.Clase;

-- ✅ PRUEBA 3: Eliminación válida de clase
EXEC actividades.GestionarClase
    @nombre_actividad = 'Ajedrez',
    @dni_profesor = '34567890',
    @horario = 'Miércoles 15:00',
    @nombre_categoria = 'Mayor',
    @operacion = 'Eliminar';
GO
SELECT * FROM actividades.Clase;

-- ❌ PRUEBA 4: Modificar clase inexistente
EXEC actividades.GestionarClase
    @nombre_actividad = 'Actividad Fantasma',
    @dni_profesor = '00000000',
    @horario = 'Domingo 12:00',
    @nombre_categoria = 'Mayor',
    @operacion = 'Modificar';
GO

-- ❌ PRUEBA 5: Operación inválida
EXEC actividades.GestionarClase
    @nombre_actividad = 'Ajedrez',
    @dni_profesor = '34567890',
    @horario = 'Miércoles 17:00',
    @nombre_categoria = 'Mayor',
    @operacion = 'Actualizar';
GO

/*_____________________________________________________________________
  _______________________ GestionarInscripcion ________________________
  _____________________________________________________________________*/

-- Ver socios y clases existentes
SELECT * FROM administracion.Socio;
SELECT * FROM administracion.Persona;
SELECT * FROM actividades.Clase;
-- ✅ Francisco (Mayor) se inscribe a Ajedrez
EXEC actividades.GestionarInscripcion
    @dni_socio = '45778667',
    @nombre_actividad = 'Ajedrez',
    @horario = 'Sábado 19:00',
    @nombre_categoria = 'Mayor',
    @fecha_inscripcion = '2025-06-12',
    @operacion = 'Insertar';

select * from actividades.InscriptoClase

-- ✅ Mariana (Menor) se inscribe a Natación
EXEC actividades.GestionarInscripcion
    @dni_socio = '40505050',
    @nombre_actividad = 'Natación',
    @horario = 'Viernes 08:00',
    @nombre_categoria = 'Menor',
    @fecha_inscripcion = '2025-06-12',
    @operacion = 'Insertar';

select * from actividades.InscriptoClase

-- ✅ Camila (Menor) se inscribe a Vóley
EXEC actividades.GestionarInscripcion
    @dni_socio = '40606060',
    @nombre_actividad = 'Vóley',
    @horario = 'Martes 08:00',
    @nombre_categoria = 'Menor',
    @fecha_inscripcion = '2025-06-12',
    @operacion = 'Insertar';

select * from actividades.InscriptoClase


-- ✅ Luciano (Mayor) se inscribe a Futsal
EXEC actividades.GestionarInscripcion
    @dni_socio = '40707070',
    @nombre_actividad = 'Futsal',
    @horario = 'Lunes 19:00',
    @nombre_categoria = 'Mayor',
    @fecha_inscripcion = '2025-06-12',
    @operacion = 'Insertar';

select * from actividades.InscriptoClase


-- ✅ Juan Perez (Mayor) se inscribe a Baile artístico
EXEC actividades.GestionarInscripcion
    @dni_socio = '33444555',
    @nombre_actividad = 'Baile artístico',
    @horario = 'Jueves 14:00',
    @nombre_categoria = 'Cadete',
    @fecha_inscripcion = '2025-06-12',
    @operacion = 'Insertar';

	select * from actividades.InscriptoClase


-- ❌ Error esperado: José intenta inscribirse a clase inexistente
EXEC actividades.GestionarInscripcion
    @dni_socio = '99888777',
    @nombre_actividad = 'Karate',
    @horario = 'Martes 10:00',
    @nombre_categoria = 'Mayor',
    @fecha_inscripcion = '2025-06-12',
    @operacion = 'Insertar';

-- Ver inscripciones actuales
SELECT * FROM actividades.InscriptoClase;


/*_____________________________________________________________________
  ___________________ GestionarPresentismoClase _______________________
  _____________________________________________________________________*/


-- ✅ PRUEBA 1: Inserción válida de presentismo
-- Esperado: Se registra correctamente el presentismo
EXEC actividades.GestionarPresentismoClase
    @nombre_actividad = 'Ajedrez',
    @dni_socio = '40505050',
    @horario = 'Sábado 19:00',
    @nombre_categoria = 'Mayor',
    @fecha = '2025-02-06',
    @condicion = 'P',
    @operacion = 'Insertar';
GO

-- Verificar inserción
SELECT * FROM actividades.presentismoClase;
GO

-- ✅ PRUEBA 2: Modificación válida de presentismo
-- Esperado: Se actualiza correctamente el campo condicion
EXEC actividades.GestionarPresentismoClase
    @nombre_actividad = 'Ajedrez',
    @dni_socio = '40505050',
    @horario = 'Sábado 19:00',
    @nombre_categoria = 'Mayor',
    @fecha = '2025-02-06',
    @condicion = 'A', -- Ausente
    @operacion = 'Modificar';
GO
SELECT * FROM actividades.presentismoClase;
GO


-- ✅ PRUEBA 3: Eliminación válida de presentismo
-- Esperado: Se elimina el registro correctamente
EXEC actividades.GestionarPresentismoClase
    @nombre_actividad = 'Ajedrez',
    @dni_socio = '40505050',
    @horario = 'Sábado 19:00',
    @nombre_categoria = 'Mayor',
    @fecha = '2025-02-06',
    @operacion = 'Eliminar';
GO
SELECT * FROM actividades.presentismoClase;
GO


-- ❌ PRUEBA 4: Eliminar presentismo inexistente
-- Esperado: Error lanzado por RAISERROR
EXEC actividades.GestionarPresentismoClase
    @nombre_actividad = 'Yoga',
    @dni_socio = '99999999',
    @horario = 'Lunes 10:00',
    @nombre_categoria = 'Mayor',
    @fecha = '2025-06-08',
    @operacion = 'Eliminar';
GO


-- ❌ PRUEBA 5: Operación inválida
-- Esperado: Error lanzado por RAISERROR de operación inválida
EXEC actividades.GestionarPresentismoClase
    @nombre_actividad = 'Yoga',
    @dni_socio = '12345678',
    @horario = 'Lunes 10:00',
    @nombre_categoria = 'Mayor',
    @fecha = '2025-06-08',
    @operacion = 'Asistir'; -- operación inválida
GO

/*_____________________________________________________________________
  _____________________ PRUEBAS GestionarActividadExtra _______________
  _____________________________________________________________________*/

-- ✅ PRUEBA 1: Inserción válida
EXEC actividades.GestionarActividadExtra
@nombre = 'Pileta',
@costo = 2000.00,
@periodo = '2025-06',
@es_invitado = 'N',
@vigencia = '2025-06-01',
@operacion = 'Insertar';
-- Resultado esperado: Actividad insertada sin errores
GO
SELECT * FROM actividades.actividadExtra;


-- ✅ PRUEBA 2: Modificación válida
EXEC actividades.GestionarActividadExtra
@nombre = 'Pileta',
@costo = 2500.00,
@periodo = '2025-06',
@es_invitado = 'N',
@vigencia = '2025-06-10',
@operacion = 'Modificar';
-- Resultado esperado: Actividad modificada correctamente
GO
SELECT * FROM actividades.actividadExtra;

-- ✅ PRUEBA 3: Eliminación válida
EXEC actividades.GestionarActividadExtra
@nombre = 'Pileta',
@costo = NULL,
@periodo = '2025-06',
@es_invitado = 'N',
@vigencia = NULL,
@operacion = 'Eliminar';
-- Resultado esperado: Actividad eliminada sin errores
GO
SELECT * FROM actividades.actividadExtra;

-- ❌ PRUEBA 4: Modificación de actividad inexistente
EXEC actividades.GestionarActividadExtra
@nombre = 'Zumba',
@costo = 1000,
@periodo = '2024-01',
@es_invitado = 'N',
@vigencia = '2024-01-01',
@operacion = 'Modificar';
-- Resultado esperado: Error de no existencia
GO

-- ❌ PRUEBA 5: Operación inválida
EXEC actividades.GestionarActividadExtra
@nombre = 'Pileta',
@costo = 1000,
@periodo = '2025-06',
@es_invitado = 'N',
@vigencia = '2025-06-01',
@operacion = 'Actualizar';
-- Resultado esperado: Error de operación no válida
GO


/*_____________________________________________________________________
  ______________ PRUEBAS GestionarInscriptoActividadExtra _____________
  _____________________________________________________________________*/

-- ✅ PRUEBA 1: Inserción válida
EXEC actividades.GestionarInscriptoActividadExtra
@dni_socio = '12345678',
@nombre_actividad_extra = 'Pileta',
@fecha_inscripcion = '2025-06-01',
@operacion = 'Insertar';
-- Resultado esperado: Inscripción creada correctamente
GO

-- ✅ PRUEBA 2: Modificación válida
EXEC actividades.GestionarInscriptoActividadExtra
@dni_socio = '0012345678',
@nombre_actividad_extra = 'Pileta',
@fecha_inscripcion = '2025-06-02',
@operacion = 'Modificar';
-- Resultado esperado: Inscripción modificada
GO

-- ✅ PRUEBA 3: Eliminación válida
EXEC actividades.GestionarInscriptoActividadExtra
@dni_socio = '0012345678',
@nombre_actividad_extra = 'Pileta',
@fecha_inscripcion = NULL,
@operacion = 'Eliminar';
-- Resultado esperado: Inscripción eliminada
GO

-- ❌ PRUEBA 4: Insertar sin DNI
EXEC actividades.GestionarInscriptoActividadExtra
@dni_socio = NULL,
@nombre_actividad_extra = 'Pileta',
@fecha_inscripcion = NULL,
@operacion = 'Insertar';
-- Resultado esperado: Error por DNI obligatorio
GO

-- ❌ PRUEBA 5: Operación inválida
EXEC actividades.GestionarInscriptoActividadExtra
@dni_socio = '0012345678',
@nombre_actividad_extra = 'Pileta',
@fecha_inscripcion = NULL,
@operacion = 'Alta';
-- Resultado esperado: Error por operación inválida
GO

/*_____________________________________________________________________
  ______________ PRUEBAS GestionarPresentismoActividadExtra ___________
  _____________________________________________________________________*/

select * from administracion.Socio
select * from administracion.Persona
-- ✅ PRUEBA 1: Inserción válida
EXEC actividades.GestionarPresentismoActividadExtra
@nombre_actividad_extra = 'Pileta',
@periodo = '2025-06',
@es_invitado = 'N',
@dni_socio = '45778667',
@fecha = '2025-06-08',
@condicion = 'P',
@operacion = 'Insertar';
-- Resultado esperado: Presentismo insertado sin errores
GO
SELECT * FROM actividades.actividadExtra;
SELECT * FROM actividades.presentismoActividadExtra;


-- ✅ PRUEBA 2: Modificación válida
EXEC actividades.GestionarPresentismoActividadExtra
@nombre_actividad_extra = 'Pileta',
@periodo = '2025-06',
@es_invitado = 'N',
@dni_socio = '45778667',
@fecha = '2025-06-08',
@condicion = 'F',
@operacion = 'Modificar';
-- Resultado esperado: Presentismo modificado sin errores
GO
SELECT * FROM actividades.actividadExtra;
SELECT * FROM actividades.presentismoActividadExtra;

-- ✅ PRUEBA 3: Eliminación válida
EXEC actividades.GestionarPresentismoActividadExtra
@nombre_actividad_extra = 'Pileta',
@periodo = '2025-06',
@es_invitado = 'N',
@dni_socio = '45778667',
@fecha = '2025-06-08',
@condicion = NULL,
@operacion = 'Eliminar';
-- Resultado esperado: Presentismo eliminado sin errores
GO
SELECT * FROM actividades.actividadExtra;
SELECT * FROM actividades.presentismoActividadExtra;

-- ❌ PRUEBA 4: Insertar sin nombre de actividad
EXEC actividades.GestionarPresentismoActividadExtra
@nombre_actividad_extra = NULL,
@periodo = '2025-06',
@es_invitado = 'N',
@dni_socio = '0012345678',
@fecha = NULL,
@condicion = NULL,
@operacion = 'Insertar';
-- Resultado esperado: Error por nombre de actividad requerido
GO

-- ❌ PRUEBA 5: Operación inválida
EXEC actividades.GestionarPresentismoActividadExtra
@nombre_actividad_extra = 'Pileta',
@periodo = '2025-06',
@es_invitado = 'N',
@dni_socio = '0012345678',
@fecha = NULL,
@condicion = NULL,
@operacion = 'Registrar';
-- Resultado esperado: Error de operación inválida
GO

/*_____________________________________________________________________
  _______________________ PRUEBAS GenerarEmisorFactura ______________________
  _____________________________________________________________________*/
 EXEC facturacion.GestionarEmisorFactura
    @razon_social = 'Sol del Norte S.A.',
    @cuil = '20-12345678-4',
    @direccion = 'Av. Presidente Perón 1234',
    @pais = 'Argentina',
    @localidad = 'La Matanza',
    @codigo_postal = '1234',
    @operacion = 'Insertar'

SELECT * FROM facturacion.EmisorFactura
/*_____________________________________________________________________
  _______________________ PRUEBAS GenerarFactura ______________________
  _____________________________________________________________________*/

-- ✅ PRUEBA 1: Generación válida de factura para varias actividades

-- Carga de actividades previa [NO OLVIDAR DESCOMENTAR PARA HACER EL EJEMPLO]
/*EXEC actividades.GestionarActividad
    @nombre = 'Futsal',
    @costo = 3500.00,
    @horario = 'Martes 13:00',
    @vigencia = '2025-07-01',
    @operacion = 'Insertar';

EXEC actividades.GestionarActividad
    @nombre = 'Ajedrez',
    @costo = 3500.00,
    @horario = 'Lunes 18:00',
    @vigencia = '2025-07-01',
    @operacion = 'Insertar';
-- Resultado esperado: Actividades insertadas sin errores

EXEC actividades.GestionarClase
    @nombre_actividad = 'Futsal',
    @dni_profesor = '34567890',
    @horario = 'Martes 13:00',
    @operacion = 'Insertar';

EXEC actividades.GestionarClase
    @nombre_actividad = 'Ajedrez',
    @dni_profesor = '34567890',
    @horario = 'Lunes 18:00',
    @operacion = 'Insertar';
-- Resultado esperado: Clases insertadas sin errores

EXEC actividades.GestionarInscripcion
    @dni_socio = '40606060',
    @nombre_actividad = 'Futsal',
    @horario = 'Martes 13:00',
    @fecha_inscripcion = '2025-02-06',
    @operacion = 'Insertar';

EXEC actividades.GestionarInscripcion
    @dni_socio = '40606060',
    @nombre_actividad = 'Ajedrez',
    @horario = 'Lunes 18:00',
    @fecha_inscripcion = '2025-02-06',
    @operacion = 'Insertar';
-- Resultado esperado: Inscripciones insertadas sin errores
GO*/

EXEC facturacion.GenerarFacturaSocioMensual
@dni_socio = '33444555',
@cuil_emisor = '20-12345678-4';
-- Resultado esperado: Factura generada sin errores
GO

/*
DELETE FROM facturacion.DetalleFactura
DELETE FROM facturacion.Factura
*/

SELECT * FROM facturacion.Factura
SELECT * FROM facturacion.DetalleFactura

-- ✅ PRUEBA 2: Generación válida de factura para varias actividades y varios socios de un grupo familiar

-- Carga de actividades previa [NO OLVIDAR DESCOMENTAR PARA HACER EL EJEMPLO]
/*EXEC actividades.GestionarInscripcion
    @dni_socio = '45778667',
    @nombre_actividad = 'Futsal',
    @horario = 'Martes 13:00',
    @fecha_inscripcion = '2025-02-06',
    @operacion = 'Insertar';

EXEC actividades.GestionarInscripcion
    @dni_socio = '40505050',
    @nombre_actividad = 'Futsal',
    @horario = 'Martes 13:00',
    @fecha_inscripcion = '2025-02-06',
    @operacion = 'Insertar';

EXEC actividades.GestionarInscripcion
    @dni_socio = '40505050',
    @nombre_actividad = 'Ajedrez',
    @horario = 'Lunes 18:00',
    @fecha_inscripcion = '2025-02-06',
    @operacion = 'Insertar';
-- Resultado esperado: Inscripciones insertadas sin errores
GO*/

EXEC facturacion.GenerarFacturaSocioMensual
@dni_socio = '45778667',
@cuil_emisor = '20-12345678-4';
-- Resultado esperado: Factura generada sin errores
GO

-- ❌ PRUEBA 3: Socio no existe
EXEC facturacion.GenerarFacturaSocioMensual
@dni_socio = '99999999',
@cuil_emisor = '20-12345678-3';
-- Resultado esperado: Error lanzado por RAISERROR
GO