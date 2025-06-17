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

/*____________________________________________________________________
  ____________________ PRUEBAS GestionarRecargo ______________________
  ____________________________________________________________________*/

/* ✅ PRUEBA 1: Insertar un nuevo medio de pago */
EXEC cobranzas.GestionarRecargo 
    @porcentaje = 0.1,
	@descripcion = 'Mora',
	@vigencia = '2025-10-01',
    @operacion = 'Insertar';
-- Resultado esperado: Inserta correctamente el recargo.
SELECT * FROM facturacion.Recargo;
GO

/* ❌ PRUEBA 2: Recargo inválido */
EXEC cobranzas.GestionarRecargo 
    @porcentaje = NULL,
	@descripcion = 'Mora',
	@vigencia = NULL,
    @operacion = 'Insertar';
-- Resultado esperado: 'La vigencia del recargo ingresada es inválida.'

/*____________________________________________________________________
  ________________ PRUEBAS AplicarRecargoVencimiento _________________
  ____________________________________________________________________*/

/* ✅ PRUEBA 1: Aplicar recargo a los socios con facturas vencidas */
EXEC cobranzas.AplicarRecargoVencimiento 
    @descripcion_recargo = 'Mora'
-- Resultado esperado: Inserta correctamente las moras a las facturas correspondientes.
SELECT * FROM cobranzas.Mora;
GO

/* ❌ PRUEBA 2: Recargo inválido */
EXEC cobranzas.AplicarRecargoVencimiento 
    @descripcion_recargo = 'Morosidad'
-- Resultado esperado: 'No se encontró un recargo válido con la descripción proporcionada.'.
SELECT * FROM cobranzas.Mora;
GO

/*____________________________________________________________________
  ________________ PRUEBAS AplicarBloqueoVencimiento _________________
  ____________________________________________________________________*/

/* ✅ PRUEBA 1: Bloquear socios con facturas vencidas a la 2da fecha. */
EXEC cobranzas.AplicarBloqueoVencimiento
-- Resultado esperado: Socios modificados, campo 'activo' = 0.
SELECT * FROM administracion.Socio;
GO
