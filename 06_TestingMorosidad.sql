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
  ________________ PRUEBAS AplicarRecargoVencimiento _________________
  ____________________________________________________________________*/

/* ✅ PRUEBA 1: Aplicar recargo a los socios con facturas vencidas */
EXEC cobranzas.AplicarRecargoVencimiento
-- Resultado esperado: Inserta correctamente las moras a las facturas correspondientes.
SELECT * FROM cobranzas.Mora;
GO

/*____________________________________________________________________
  ________________ PRUEBAS AplicarBloqueoVencimiento _________________
  ____________________________________________________________________*/

/* ✅ PRUEBA 1: Bloquear socios con facturas vencidas a la 2da fecha. */
EXEC cobranzas.AplicarBloqueoVencimiento
-- Resultado esperado: Socios modificados, campo 'activo' = 0.
SELECT * FROM socios.Socio;
GO
