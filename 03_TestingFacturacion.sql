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
  ________________________ P_GestionarActividad _______________________
  _____________________________________________________________________*/

-- ✅ PRUEBA 1: Inserción válida de actividad
-- Esperado: Se inserta el registro correctamente
EXEC actividades.GestionarActividad
    @nombre = 'Ajedrez',
    @costo = 3500.00,
    @horario = 'Lunes 18:00',
    @vigencia = '2025-07-01',
    @operacion = 'Insertar';
-- Resultado esperado: Actividad insertada sin errores
GO
SELECT * FROM actividades.Actividad

-- ✅ PRUEBA 2: Modificación válida de actividad existente
-- Esperado: Se actualizan los datos correctamente
EXEC actividades.GestionarActividad
    @nombre = 'Ajedrez',
    @costo = 4000.00,
    @horario = NULL,
    @vigencia = NULL,
    @operacion = 'Modificar';
-- Resultado esperado: Actividad modificada sin errores
GO
SELECT * FROM actividades.Actividad

-- ✅ PRUEBA 3: Eliminación válida de actividad
-- Esperado: Se elimina el registro de la actividad
EXEC actividades.GestionarActividad
    @nombre = 'Ajedrez',
    @costo = NULL,
    @horario = NULL,
    @vigencia = NULL,
    @operacion = 'Eliminar';
-- Resultado esperado: Actividad eliminada sin errores
GO
SELECT * FROM actividades.Actividad


-- ❌ PRUEBA 4: Modificar actividad inexistente
EXEC actividades.GestionarActividad
    @nombre = 'No Existe',
    @costo = 1000.00,
    @horario = 'Martes 10:00',
    @vigencia = '2025-08-01',
    @operacion = 'Modificar';
-- Resultado esperado: Error lanzado por RAISERROR
GO
SELECT * FROM actividades.Actividad

-- ❌ PRUEBA 5: Operación inválida
EXEC actividades.GestionarActividad
    @nombre = 'Ajedez',
    @costo = 1000.00,
    @horario = 'Lunes 10:00',
    @vigencia = '2025-09-01',
    @operacion = 'Actualizar';
-- Resultado esperado: Error lanzado por RAISERROR de operación inválida
GO
SELECT * FROM actividades.Actividad

/*_____________________________________________________________________
  _________________________ P_GestionarClase __________________________
  _____________________________________________________________________*/
select * from administracion.Profesor
select * from administracion.Persona

-- ✅ PRUEBA 1: Inserción válida de clase
-- Esperado: Se inserta el registro correctamente
EXEC actividades.GestionarClase
    @nombre_actividad = 'Ajedrez',
    @dni_profesor = '23456789',
    @horario = 'Miércoles 17:00',
    @operacion = 'Insertar';
-- Resultado esperado: Clase insertada sin errores
GO
SELECT * FROM actividades.Clase

-- ✅ PRUEBA 2: Modificación válida de clase
-- Esperado: Se actualizan los datos correctamente
EXEC actividades.GestionarClase
    @nombre_actividad = 'Ajedrez',
    @dni_profesor = '23456789',
    @horario = 'Miércoles 14:00',
    @operacion = 'Modificar';
-- Resultado esperado: Clase modificada sin errores
GO
SELECT * FROM actividades.Clase

-- ✅ PRUEBA 3: Eliminación válida de clase
-- Esperado: Se elimina la clase correspondiente
EXEC actividades.GestionarClase
    @nombre_actividad = 'Ajedrez',
    @dni_profesor = '23456789',
    @horario = 'Miércoles 17:00',
    @operacion = 'Eliminar';
-- Resultado esperado: Clase eliminada sin errores
GO
SELECT * FROM actividades.Clase

-- ❌ PRUEBA 4: Modificar clase inexistente
EXEC actividades.GestionarClase
    @nombre_actividad = 'Actividad Fantasma',
    @dni_profesor = '00000000',
    @horario = 'Domingo 12:00',
    @operacion = 'Modificar';
-- Resultado esperado: Error lanzado por RAISERROR
GO
SELECT * FROM actividades.Clase

-- ❌ PRUEBA 5: Operación inválida
EXEC actividades.GestionarClase
    @nombre_actividad = 'Ajedrez',
    @dni_profesor = '12345678',
    @horario = 'Miércoles 17:00',
    @operacion = 'Actualizar';
-- Resultado esperado: Error lanzado por RAISERROR de operación inválida
GO

/*_____________________________________________________________________
  _______________________ GestionarInscripcion ________________________
  _____________________________________________________________________*/

-- ✅ PRUEBA 1: Inserción válida de inscripción
-- Esperado: Se inserta la inscripción correctamente si el socio y la clase existen
EXEC actividades.GestionarInscripcion
    @dni_socio = '12345678',
    @nombre_actividad = 'Ajedrez',
    @horario = 'Miércoles 17:00',
    @fecha_inscripcion = '2025-02-06',
    @operacion = 'Insertar';
GO
SELECT * FROM actividades.InscriptoClase;
-- ✅ PRUEBA 2: Modificación válida de inscripción existente
-- Esperado: Se actualiza la fecha de inscripción
EXEC actividades.GestionarInscripcion
    @dni_socio = '0012345678',
    @nombre_actividad = 'Yoga',
    @horario = 'Lunes 10:00',
    @fecha_inscripcion = '2024-11-01',
    @operacion = 'Modificar';
GO
-- ✅ PRUEBA 3: Eliminación válida de inscripción existente
-- Esperado: Se elimina la inscripción correctamente
EXEC actividades.GestionarInscripcion
    @dni_socio = '0012345678',
    @nombre_actividad = 'Yoga',
    @horario = 'Lunes 10:00',
    @fecha_inscripcion = NULL,
    @operacion = 'Eliminar';
GO
-- ❌ PRUEBA 4: Modificar inscripción inexistente
-- Esperado: Error lanzado por RAISERROR
EXEC actividades.GestionarInscripcion
    @dni_socio = '99999999',
    @nombre_actividad = 'Yoga',
    @horario = 'Lunes 10:00',
    @fecha_inscripcion = '2025-06-08',
    @operacion = 'Modificar';
GO
-- ❌ PRUEBA 5: Operación inválida
-- Esperado: Error por operación no permitida
EXEC actividades.GestionarInscripcion
    @dni_socio = '0012345678',
    @nombre_actividad = 'Yoga',
    @horario = 'Lunes 10:00',
    @fecha_inscripcion = '2025-06-08',
    @operacion = 'Actualizar';
GO

/*_____________________________________________________________________
  ___________________ GestionarPresentismoClase _______________________
  _____________________________________________________________________*/

-- ✅ PRUEBA 1: Inserción válida de presentismo
-- Esperado: Se registra correctamente el presentismo
EXEC actividades.GestionarPresentismoClase
    @nombre_actividad = 'Ajedrez',
    @dni_socio = '12345678',
    @horario = 'Miércoles 17:00',
    @fecha = '2025-02-06',
    @condicion = 'P',
    @operacion = 'Insertar';
GO
SELECT * FROM actividades.presentismoClase;
-- ✅ PRUEBA 2: Modificación válida de presentismo
-- Esperado: Se actualiza correctamente el campo condicion
EXEC actividades.GestionarPresentismoClase
    @nombre_actividad = 'Yoga',
    @dni_socio = '0012345678',
    @horario = 'Lunes 10:00',
    @fecha = '2025-06-08',
    @condicion = 'A',
    @operacion = 'Modificar';
GO
-- ✅ PRUEBA 3: Eliminación válida de presentismo
-- Esperado: Se elimina el registro correctamente
EXEC actividades.GestionarPresentismoClase
    @nombre_actividad = 'Yoga',
    @dni_socio = '0012345678',
    @horario = 'Lunes 10:00',
    @fecha = '2025-06-08',
    @operacion = 'Eliminar';
GO
-- ❌ PRUEBA 4: Eliminar presentismo inexistente
-- Esperado: Error lanzado por RAISERROR
EXEC actividades.GestionarPresentismoClase
    @nombre_actividad = 'Yoga',
    @dni_socio = '99999999',
    @horario = 'Lunes 10:00',
    @fecha = '2025-06-08',
    @operacion = 'Eliminar';
GO
-- ❌ PRUEBA 5: Operación inválida
-- Esperado: Error lanzado por RAISERROR de operación inválida
EXEC actividades.GestionarPresentismoClase
    @nombre_actividad = 'Yoga',
    @dni_socio = '0012345678',
    @horario = 'Lunes 10:00',
    @fecha = '2025-06-08',
    @operacion = 'Asistir';
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
  ______________ PRUEBAS GestionarPresentismoActividadExtra ___________
  _____________________________________________________________________*/

-- ✅ PRUEBA 1: Inserción válida
EXEC actividades.GestionarPresentismoActividadExtra
@nombre_actividad_extra = 'Pileta',
@periodo = '2025-06',
@es_invitado = 'N',
@dni_socio = '0012345678',
@fecha = '2025-06-08',
@condicion = 'P',
@operacion = 'Insertar';
-- Resultado esperado: Presentismo insertado sin errores
GO

-- ✅ PRUEBA 2: Modificación válida
EXEC actividades.GestionarPresentismoActividadExtra
@nombre_actividad_extra = 'Pileta',
@periodo = '2025-06',
@es_invitado = 'N',
@dni_socio = '0012345678',
@fecha = '2025-06-08',
@condicion = 'F',
@operacion = 'Modificar';
-- Resultado esperado: Presentismo modificado sin errores
GO

-- ✅ PRUEBA 3: Eliminación válida
EXEC actividades.GestionarPresentismoActividadExtra
@nombre_actividad_extra = 'Pileta',
@periodo = '2025-06',
@es_invitado = 'N',
@dni_socio = '0012345678',
@fecha = '2025-06-08',
@condicion = NULL,
@operacion = 'Eliminar';
-- Resultado esperado: Presentismo eliminado sin errores
GO

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
  _______________________ PRUEBAS GenerarFactura ______________________
  _____________________________________________________________________*/

-- ✅ PRUEBA 1: Generación válida de factura
EXEC facturacion.GenerarFacturaSocioMensual
@dni_socio = '23456789',
@cuil_emisor = '30-12345678-9';
-- Resultado esperado: Factura generada sin errores
GO

EXEC administracion.VerCuotasPagasGrupoFamiliar
	@dni_socio = '12345678'
GO

SELECT * FROM administracion.GrupoFamiliar
SELECT * FROM administracion.Persona
SELECT * FROM facturacion.Factura

UPDATE administracion.Socio
SET activo = 1
WHERE id_socio = 1

UPDATE facturacion.Factura
SET estado = 'Pagada', anulada = 0
WHERE id_socio = 1

-- ❌ PRUEBA 2: Socio no existe
EXEC facturacion.GenerarFacturaSocioMensual
@dni_socio = '99999999',
@cuil_emisor = '20-12345678-3';
-- Resultado esperado: Error lanzado por RAISERROR
GO