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
  ______________________ RegistrarCobranza ____________________________
  _____________________________________________________________________*/
  USE COM2900G13;
GO

-- Ver socios y facturas para testear
SELECT s.id_socio, p.dni, s.activo, s.saldo 
FROM administracion.Socio s
JOIN administracion.Persona p ON s.id_persona = p.id_persona;

SELECT * FROM facturacion.Factura;
SELECT * FROM cobranzas.MedioDePago;
GO

/* ✅ PRUEBA 1: Registro válido de cobranza */
EXEC cobranzas.RegistrarCobranza
    @dniSocio = '12345678',
    @monto = 5000,
    @fecha = '2025-06-15',
    @medioPago = 'Visa',
    @idActividadExtra = NULL,
    @idFactura = 1;
-- Resultado esperado: Inserta correctamente el pago y actualiza el saldo del socio.
GO

/* ❌ PRUEBA 2: Medio de pago no permitido (Efectivo) */
EXEC cobranzas.RegistrarCobranza
    @dniSocio = '12345678',
    @monto = 5000,
    @fecha = '2025-06-15',
    @medioPago = 'Efectivo',
    @idActividadExtra = NULL,
    @idFactura = 1;
-- Resultado esperado: Error 'No se aceptan pagos en Efectivo ni Cheque.'
GO

/* ❌ PRUEBA 3: Medio de pago inválido (no registrado) */
EXEC cobranzas.RegistrarCobranza
    @dniSocio = '12345678',
    @monto = 5000,
    @fecha = '2025-06-15',
    @medioPago = 'Paypal',
    @idActividadExtra = NULL,
    @idFactura = 1;
-- Resultado esperado: Error 'Medio de pago no válido. Debe ser uno registrado.'
GO

/* ❌ PRUEBA 4: DNI de socio no existe */
EXEC cobranzas.RegistrarCobranza
    @dniSocio = '00000000',
    @monto = 5000,
    @fecha = '2025-06-15',
    @medioPago = 'Visa',
    @idActividadExtra = NULL,
    @idFactura = 1;
-- Resultado esperado: Error 'El socio especificado no existe o no está activo.'
GO

/* ❌ PRUEBA 5: Socio inactivo */
-- Asegurar que exista un socio inactivo con DNI '88888888'
EXEC cobranzas.RegistrarCobranza
    @dniSocio = '88888888',
    @monto = 5000,
    @fecha = '2025-06-15',
    @medioPago = 'Visa',
    @idActividadExtra = NULL,
    @idFactura = 1;
-- Resultado esperado: Error 'El socio especificado no existe o no está activo.'
GO

/* ❌ PRUEBA 6: Actividad extra no existente */
EXEC cobranzas.RegistrarCobranza
    @dniSocio = '12345678',
    @monto = 5000,
    @fecha = '2025-06-15',
    @medioPago = 'Visa',
    @idActividadExtra = 9999,
    @idFactura = 1;
-- Resultado esperado: Error 'La actividad extra especificada no existe.'
GO

/* ❌ PRUEBA 7: Factura anulada o no válida */
EXEC cobranzas.RegistrarCobranza
    @dniSocio = '12345678',
    @monto = 5000,
    @fecha = '2025-06-15',
    @medioPago = 'Visa',
    @idActividadExtra = NULL,
    @idFactura = 9999;
-- Resultado esperado: Error 'La factura no existe, no pertenece al socio o está anulada.'
GO

/* ✅ PRUEBA 8: Registro con actividad extra válida */
-- Asegurarse que exista idActividadExtra = 1
EXEC cobranzas.RegistrarCobranza
    @dniSocio = '12345678',
    @monto = 2000,
    @fecha = '2025-06-20',
    @medioPago = 'Visa',
    @idActividadExtra = 1,
    @idFactura = 2;
-- Resultado esperado: Inserción válida
GO



/*_____________________________________________________________________
  ________________ HabilitarDebitoAutomatico __________________________
  _____________________________________________________________________*/

/*_____________________________________________________________________
  ________________ DeshabilitarDebitoAutomatico _______________________
  _____________________________________________________________________*/


/*_____________________________________________________________________
  ___________________ RegistrarPagoCuenta _____________________________
  _____________________________________________________________________*/


/*_____________________________________________________________________
  ____________________ GenerarReembolso _______________________________
  _____________________________________________________________________*/


/*_____________________________________________________________________
  ________________ RegistrarReintegroLluvia ___________________________
  _____________________________________________________________________*/

-- ✅ PRUEBA 1: Registrar reintegro por lluvia válido
EXEC cobranzas.GenerarReintegroPorLluvia
    @mes = '06',
    @año = '2024',
    @path = 'C:\Users\ldeti\Desktop\College\BDA\TP BDA\Com2900G13\ETL\open-meteo-buenosaires_2024.csv';
GO

SELECT * FROM cobranzas.NotaDeCredito;

-- ❌ PRUEBA 2: Registrar reintegro con fecha futura inválida
EXEC cobranzas.GenerarReintegroPorLluvia
    @mes = '05',
    @año = '2000',
    @path = 'C:\Users\ldeti\Desktop\College\BDA\TP BDA\Com2900G13\ETL\open-meteo-buenosaires_2024.csv';
GO
