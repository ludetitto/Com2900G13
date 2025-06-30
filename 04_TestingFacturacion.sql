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

-- ✅ PRUEBA 1: Inserción válida de clase
EXEC actividades.GestionarClase
    @nombre_actividad = 'Ajedrez',
    @nombre_profesor = 'Gabriel',
	@apellido_profesor = 'Mirabelli',
    @horario = 'Miércoles 17:00',
    @nombre_categoria = 'Mayor',
    @operacion = 'Insertar';
GO
SELECT * FROM actividades.Clase;

-- ✅ PRUEBA 2: Modificación válida de clase
EXEC actividades.GestionarClase
    @nombre_actividad = 'Ajedrez',
    @nombre_profesor = 'Gabriel',
	@apellido_profesor = 'Mirabelli',
    @horario = 'Miércoles 15:00',
    @nombre_categoria = 'Mayor',
    @operacion = 'Modificar';
GO
SELECT * FROM actividades.Clase;

-- ✅ PRUEBA 3: Eliminación válida de clase
EXEC actividades.GestionarClase
    @nombre_actividad = 'Ajedrez',
    @nombre_profesor = 'Gabriel',
	@apellido_profesor = 'Mirabelli',
    @horario = 'Miércoles 15:00',
    @nombre_categoria = 'Mayor',
    @operacion = 'Eliminar';
GO
SELECT * FROM actividades.Clase;

-- ❌ PRUEBA 4: Modificar clase inexistente
EXEC actividades.GestionarClase
    @nombre_actividad = 'Actividad Fantasma',
    @nombre_profesor = 'Juan',
	@apellido_profesor = 'Pepito',
    @horario = 'Domingo 12:00',
    @nombre_categoria = 'Mayor',
    @operacion = 'Modificar';
GO

-- ❌ PRUEBA 5: Operación inválida
EXEC actividades.GestionarClase
    @nombre_actividad = 'Ajedrez',
    @nombre_profesor = 'Juan',
	@apellido_profesor = 'Pepito',
    @horario = 'Miércoles 17:00',
    @nombre_categoria = 'Mayor',
    @operacion = 'Actualizar';
GO

/*_____________________________________________________________________
  _________________ PRUEBAS GestionarInscriptoClase ___________________
  _____________________________________________________________________*/

-- ✅ Francisco (Mayor) se inscribe a Ajedrez
EXEC actividades.GestionarInscriptoClase
    @dni_socio = '45778667',
    @nombre_actividad = 'Ajedrez',
    @horario = 'Sábado 19:00',
    @nombre_categoria = 'Mayor',
    @fecha_inscripcion = '2025-06-12',
    @operacion = 'Insertar';

select * from actividades.InscriptoClase

-- ✅ Mariana (Menor) se inscribe a Natación
EXEC actividades.GestionarInscriptoClase
    @dni_socio = '40505050',
    @nombre_actividad = 'Natación',
    @horario = 'Viernes 08:00',
    @nombre_categoria = 'Menor',
    @fecha_inscripcion = '2025-06-12',
    @operacion = 'Insertar';

select * from actividades.InscriptoClase

-- ✅ Camila (Menor) se inscribe a Vóley
EXEC actividades.GestionarInscriptoClase
    @dni_socio = '40606060',
    @nombre_actividad = 'Vóley',
    @horario = 'Martes 08:00',
    @nombre_categoria = 'Menor',
    @fecha_inscripcion = '2025-06-12',
    @operacion = 'Insertar';

select * from actividades.InscriptoClase


-- ✅ Luciano (Mayor) se inscribe a Futsal
EXEC actividades.GestionarInscriptoClase
    @dni_socio = '40707070',
    @nombre_actividad = 'Futsal',
    @horario = 'Lunes 19:00',
    @nombre_categoria = 'Mayor',
    @fecha_inscripcion = '2025-06-12',
    @operacion = 'Insertar';

select * from actividades.InscriptoClase


-- ✅ Juan Perez (Mayor) se inscribe a Baile artístico
EXEC actividades.GestionarInscriptoClase
    @dni_socio = '33444555',
    @nombre_actividad = 'Baile artístico',
    @horario = 'Jueves 14:00',
    @nombre_categoria = 'Cadete',
    @fecha_inscripcion = '2025-06-12',
    @operacion = 'Insertar';

	select * from actividades.InscriptoClase


-- ❌ Error esperado: José intenta inscribirse a clase inexistente
EXEC actividades.GestionarInscriptoClase
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
    @estado= 'P',
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
    @estado = 'A', -- Ausente
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
	@estado = NULL,
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
	@estado = NULL,
    @operacion = 'Asistir'; -- operación inválida
GO

/*_____________________________________________________________________
  _________________ PRUEBAS GenerarCargoMembresia ____________________
  _____________________________________________________________________*/

-- ✅ PRUEBA 1: Inserción válida del cargo
-- Esperado: Se registra correctamente el cargo
EXEC facturacion.GenerarCargoMembresia
    @dni_socio = '45778667',
	@fecha = '2025-06-25';
GO

-- Verificar inserción
SELECT * FROM facturacion.CargoMembresias;
GO

-- ❌ PRUEBA 2: Cargo ya existente
-- Esperado: Error lanzado por RAISERROR indicando existencia previa
EXEC facturacion.GenerarCargoMembresia
    @dni_socio = '87654321',
	@fecha = '2025-06-25';
GO

-- ❌ PRUEBA 3: Socio inexistente
-- Esperado: Error lanzado por RAISERROR indicando socio no existe
EXEC facturacion.GenerarCargoMembresia
    @dni_socio = '99999999',
	@fecha = '2025-06-25';
GO

-- ❌ PRUEBA 4: Socio inactivo
-- Esperado: Error lanzado por RAISERROR indicando socio inactivo
EXEC facturacion.GenerarCargoMembresia
    @dni_socio = '11111111', --hay q cambiar
	@fecha = '2025-06-25';
GO

-- ❌ PRUEBA 5: Socio sin inscripción en categoría
-- Esperado: Error lanzado por RAISERROR indicando falta de inscripción
EXEC facturacion.GenerarCargoMembresia
    @dni_socio = '22222222', --hay q cambiar
	@fecha = '2025-06-25';
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
  _____________ PRUEBAS GestionarInscriptoPiletaVerano ________________
  _____________________________________________________________________*/


-- ✅ PRUEBA 1: Inserción válida de socio categoría Mayor
-- Esperado: Se registra correctamente con tarifa de "Mayor"
EXEC actividades.GestionarInscriptoPiletaVerano
    @dni_socio = '30111222',
    @dni_invitado = NULL,
    @nombre = NULL,
    @apellido = NULL,
    @categoria = NULL,
    @email = NULL,
    @domicilio = NULL,
    @fecha_inscripcion = '2025-12-01',
    @operacion = 'Insertar';
GO

SELECT * FROM actividades.InscriptoPiletaVerano;
GO


-- ✅ PRUEBA 2: Inserción válida de socio categoría Cadete
-- Esperado: Se registra correctamente con tarifa de "Mayor"
EXEC actividades.GestionarInscriptoPiletaVerano
    @dni_socio = '30444555',
    @dni_invitado = NULL,
    @nombre = NULL,
    @apellido = NULL,
    @categoria = NULL,
    @email = NULL,
    @domicilio = NULL,
    @fecha_inscripcion = '2025-12-02',
    @operacion = 'Insertar';
GO

SELECT * FROM actividades.InscriptoPiletaVerano;
GO


-- ✅ PRUEBA 3: Inserción válida de invitado nuevo
-- Esperado: Se registra nuevo invitado y se lo inscribe
EXEC actividades.GestionarInscriptoPiletaVerano
    @dni_socio = NULL,
    @dni_invitado = '40999888',
    @nombre = 'Ana',
    @apellido = 'González',
    @categoria = 'Menor',
    @email = 'ana@example.com',
    @domicilio = 'Calle Falsa 123',
    @fecha_inscripcion = '2025-12-03',
    @operacion = 'Insertar';
GO

SELECT * FROM socios.Invitado;
SELECT * FROM actividades.InscriptoPiletaVerano;
GO


-- ✅ PRUEBA 4: Inserción de invitado existente (sin duplicar)
-- Esperado: Se utiliza el invitado ya existente
EXEC actividades.GestionarInscriptoPiletaVerano
    @dni_socio = NULL,
    @dni_invitado = '40999888',
    @nombre = NULL,
    @apellido = NULL,
    @categoria = 'Menor',
    @email = NULL,
    @domicilio = NULL,
    @fecha_inscripcion = '2025-12-04',
    @operacion = 'Insertar';
GO

SELECT * FROM actividades.InscriptoPiletaVerano;
GO


-- ❌ PRUEBA 5: Operación inválida
-- Esperado: Error lanzado por RAISERROR de operación inválida
EXEC actividades.GestionarInscriptoPiletaVerano
    @dni_socio = '30111222',
    @dni_invitado = NULL,
    @nombre = NULL,
    @apellido = NULL,
    @categoria = NULL,
    @email = NULL,
    @domicilio = NULL,
    @fecha_inscripcion = '2025-12-01',
    @operacion = 'Registrar';
GO


-- ❌ PRUEBA 6: Invitado sin datos suficientes
-- Esperado: Error lanzado por RAISERROR por datos incompletos
EXEC actividades.GestionarInscriptoPiletaVerano
    @dni_socio = NULL,
    @dni_invitado = '50111222',
    @nombre = NULL,
    @apellido = NULL,
    @categoria = NULL,
    @email = NULL,
    @domicilio = NULL,
    @fecha_inscripcion = '2025-12-05',
    @operacion = 'Insertar';
GO


-- ❌ PRUEBA 7: Eliminar inscripción inexistente
-- Esperado: Error lanzado por RAISERROR
EXEC actividades.GestionarInscriptoPiletaVerano
    @dni_socio = '30111222',
    @dni_invitado = NULL,
    @nombre = NULL,
    @apellido = NULL,
    @categoria = NULL,
    @email = NULL,
    @domicilio = NULL,
    @fecha_inscripcion = '2030-01-01',
    @operacion = 'Eliminar';
GO


-- ❌ PRUEBA 8: Modificar inscripción inexistente
-- Esperado: Error lanzado por RAISERROR
EXEC actividades.GestionarInscriptoPiletaVerano
    @dni_socio = '30444555',
    @dni_invitado = NULL,
    @nombre = NULL,
    @apellido = NULL,
    @categoria = NULL,
    @email = NULL,
    @domicilio = NULL,
    @fecha_inscripcion = '2030-01-01',
    @operacion = 'Modificar';
GO


-- ❌ PRUEBA 9: Intento de inserción duplicada
-- Esperado: Error lanzado por RAISERROR
EXEC actividades.GestionarInscriptoPiletaVerano
    @dni_socio = '30111222',
    @dni_invitado = NULL,
    @nombre = NULL,
    @apellido = NULL,
    @categoria = NULL,
    @email = NULL,
    @domicilio = NULL,
    @fecha_inscripcion = '2025-12-01',
    @operacion = 'Insertar';
GO


-- ✅ PRUEBA 10: Eliminación válida de inscripción
-- Esperado: Se elimina correctamente
EXEC actividades.GestionarInscriptoPiletaVerano
    @dni_socio = '30444555',
    @dni_invitado = NULL,
    @nombre = NULL,
    @apellido = NULL,
    @categoria = NULL,
    @email = NULL,
    @domicilio = NULL,
    @fecha_inscripcion = '2025-12-02',
    @operacion = 'Eliminar';
GO

SELECT * FROM actividades.InscriptoPiletaVerano;
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



