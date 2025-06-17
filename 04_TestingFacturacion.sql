/* =========================================================================
   Trabajo Práctico Integrador - Bases de Datos Aplicadas
   Grupo N°: 13
   Comisión: 2900
   Fecha de Entrega: 17/06/2025
   Materia: Bases de Datos Aplicadas
   Alumnos: Vignardel Francisco 45778667
            De Titto Lucia		46501934
			Borja Tomas			42353302

   Consigna: Todos los SP creados deben estar acompañados de juegos de prueba. Se espera que
realicen validaciones básicas en los SP (p/e cantidad mayor a cero, CUIT válido, etc.) y que
en los juegos de prueba demuestren la correcta aplicación de las validaciones
 ========================================================================= */
USE COM2900G13;
GO


/*_____________________________________________________________________
  _____________________ PRUEBAS GestionarActividad ____________________
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
  _____________________ PRUEBAS GestionarClase ______________________
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
  ___________________ PRUEBAS GestionarInscripcion ____________________
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
  _________________ PRUEBAS GestionarPresentismoClase _________________
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
@categoria = 'Menor',
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
@categoria = 'Cadete',
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
@categoria = 'Cadete',
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
@categoria = 'Cadete',
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
@categoria = 'Mayor',
@operacion = 'Actualizar';
-- Resultado esperado: Error de operación no válida
GO

/*_____________________________________________________________________
  ______________ PRUEBAS GestionarPresentismoActividadExtra ___________
  _____________________________________________________________________*/

select * from administracion.Socio
select * from administracion.Persona
-- ✅ PRUEBA 1: Inserción válida
EXEC actividades.GestionarPresentismoActividadExtra
@nombre_actividad_extra = 'Pileta verano',
@periodo = 'Dia',
@es_invitado = 'N',
@dni = '45778667',
@fecha = '2025-06-08',
@condicion = 'P',
@operacion = 'Insertar';
-- Resultado esperado: Presentismo insertado sin errores
GO
SELECT * FROM actividades.actividadExtra;
SELECT * FROM actividades.presentismoActividadExtra;


-- ✅ PRUEBA 2: Modificación válida
EXEC actividades.GestionarPresentismoActividadExtra
@nombre_actividad_extra = 'Pileta verano',
@periodo = 'Dia',
@es_invitado = 'N',
@dni = '45778667',
@fecha = '2025-06-08',
@condicion = 'F',
@operacion = 'Modificar';
-- Resultado esperado: Presentismo modificado sin errores
GO
SELECT * FROM actividades.actividadExtra;
SELECT * FROM actividades.presentismoActividadExtra;

-- ✅ PRUEBA 3: Eliminación válida
EXEC actividades.GestionarPresentismoActividadExtra
@nombre_actividad_extra = 'Pileta verano',
@periodo = 'Dia',
@es_invitado = 'N',
@dni = '45778667',
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
@periodo = 'Dia',
@es_invitado = 'N',
@dni = '0012345678',
@fecha = NULL,
@condicion = NULL,
@operacion = 'Insertar';
-- Resultado esperado: Error por nombre de actividad requerido
GO

-- ❌ PRUEBA 5: Operación inválida
EXEC actividades.GestionarPresentismoActividadExtra
@nombre_actividad_extra = 'Pileta verano',
@periodo = 'Mes',
@es_invitado = 'N',
@dni = '0012345678',
@fecha = NULL,
@condicion = NULL,
@operacion = 'Registrar';
-- Resultado esperado: Error de operación inválida
GO

/*_____________________________________________________________________
  ___________________ PRUEBAS GenerarEmisorFactura ____________________
  _____________________________________________________________________*/
 -- ✅ PRUEBA 1: Inserción válida
 EXEC facturacion.GestionarEmisorFactura
    @razon_social = 'Sol del Norte S.A.',
    @cuil = '20-12345678-4',
    @direccion = 'Av. Presidente Perón 1234',
    @pais = 'Argentina',
    @localidad = 'La Matanza',
    @codigo_postal = '1234',
    @operacion = 'Insertar'
-- Resultado esperado: Emisor de factura insertado sin errores
GO
SELECT * FROM facturacion.EmisorFactura

-- ✅ PRUEBA 2: Modificación válida
 EXEC facturacion.GestionarEmisorFactura
    @razon_social = 'Sol del Norte S.A.',
    @cuil = '20-12345678-4',
    @direccion = 'Av. Loria 1234',
    @pais = 'Argentina',
    @localidad = 'La Matanza',
    @codigo_postal = '1234',
    @operacion = 'Modificar'
-- Resultado esperado: Emisor de factura modificado sin errores
GO
SELECT * FROM facturacion.EmisorFactura

-- ✅ PRUEBA 3: Eliminación válida
 EXEC facturacion.GestionarEmisorFactura
    @razon_social = NULL,
    @cuil = '20-12345678-4',
    @direccion = NULL,
    @pais = NULL,
    @localidad = NULL,
    @codigo_postal = NULL,
    @operacion = 'Eliminar'
-- Resultado esperado: Emisor de factura eliminado sin errores
GO
SELECT * FROM facturacion.EmisorFactura

-- ❌ PRUEBA 5: Emisor de factura inexistente
 EXEC facturacion.GestionarEmisorFactura
    @razon_social = 'Sol del Norte S.A.',
    @cuil = '20-22222222-4',
    @direccion = 'Av. Loria 1234',
    @pais = 'Argentina',
    @localidad = 'La Matanza',
    @codigo_postal = '1234',
    @operacion = 'Modificar'
-- Resultado esperado: Error de emisor de factura inválido
GO

/*_____________________________________________________________________
  _________________ PRUEBAS GenerarFacturaSocioMensual ________________
  _____________________________________________________________________*/

-- ✅ PRUEBA 1: Generación válida de factura para varias actividades

EXEC facturacion.GenerarFacturaSocioMensual
@dni_socio = '33444555',
@cuil_emisor = '20-12345678-4';
-- Resultado esperado: Factura generada sin errores
GO

SELECT * FROM facturacion.Factura
SELECT * FROM facturacion.DetalleFactura

-- ✅ PRUEBA 2: Generación válida de factura para varias actividades y varios socios de un grupo familiar

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

/*_____________________________________________________________________
  _________________ PRUEBAS GenerarFacturaInvitado ________________
  _____________________________________________________________________*/

-- ✅ PRUEBA 1: Generación válida de factura para una actividad

EXEC facturacion.GenerarFacturaInvitado
@dni_invitado = '46501934',
@cuil_emisor = '20-12345678-4',
@descripcion = 'Pileta verano',
@fecha_referencia = '2025-02-28';
-- Resultado esperado: Factura generada sin errores
GO

SELECT * FROM facturacion.Factura
SELECT * FROM facturacion.DetalleFactura

-- ❌ PRUEBA 2: Generación inválida de factura para una actividad a la que no asistió

EXEC facturacion.GenerarFacturaInvitado
@dni_invitado = '46501934',
@cuil_emisor = '20-12345678-4',
@descripcion = 'Colonia de verano',
@fecha_referencia = '2025-02-28';
-- Resultado esperado: Error lanzado por RAISERROR
GO

-- ❌ PRUEBA 3: Invitado no existe
EXEC facturacion.GenerarFacturaInvitado
@dni_invitado = '11111111',
@cuil_emisor = '20-12345678-4',
@descripcion = 'Colonia de verano',
@fecha_referencia = '2025-02-28';
-- Resultado esperado: Error lanzado por RAISERROR
GO

/*_____________________________________________________________________
  _________________ PRUEBAS GenerarFacturaSocioActExtra ________________
  _____________________________________________________________________*/

-- ✅ PRUEBA 1: Generación válida de factura para una actividad

EXEC facturacion.GenerarFacturaSocioActExtra
@dni_socio = '45778667',
@cuil_emisor = '20-12345678-4',
@descripcion = 'Pileta verano',
@fecha_referencia = '2025-02-28';
-- Resultado esperado: Factura generada sin errores
GO

SELECT * FROM facturacion.Factura
SELECT * FROM facturacion.DetalleFactura

-- ❌ PRUEBA 2: Generación inválida de factura para una actividad a la que no asistió

EXEC facturacion.GenerarFacturaSocioActExtra
@dni_socio = '40707070',
@cuil_emisor = '20-12345678-4',
@descripcion = 'Colonia de verano',
@fecha_referencia = '2025-02-28';
-- Resultado esperado: Error lanzado por RAISERROR
GO

-- ❌ PRUEBA 3: Invitado no existe
EXEC facturacion.GenerarFacturaSocioActExtra
@dni_socio = '11111111',
@cuil_emisor = '20-12345678-4',
@descripcion = 'Colonia de verano',
@fecha_referencia = '2025-02-28';
-- Resultado esperado: Error lanzado por RAISERROR
GO