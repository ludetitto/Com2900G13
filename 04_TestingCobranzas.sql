/* =========================================================================
   Trabajo Práctico Integrador - Bases de Datos Aplicadas
   Grupo N°: 13
   Comisión: 2900
   Fecha de Entrega: 17/06/2025
   Materia: Bases de Datos Aplicadas
   Alumnos: Vignardel Francisco 45778667
            De Titto Lucia		46501934
			Borja Tomas			42353302
 ========================================================================= */
USE COM2900G13;
GO

/*_____________________________________________________________________
  ______________________ test gestionarMedioDePago ____________________________
  _____________________________________________________________________*/

-- Insertar un nuevo medio de pago
EXEC cobranzas.GestionarMedioDePago 
    @nombre = 'Tarjeta Naranja',
    @debito_automatico = 1,
    @operacion = 'Insertar';

SELECT * FROM cobranzas.MedioDePago;
GO

-- Modificar debito_automatico a 0
EXEC cobranzas.GestionarMedioDePago 
    @nombre = 'Tarjeta Naranja',
    @debito_automatico = 0,
    @operacion = 'Modificar';

SELECT * FROM cobranzas.MedioDePago;
GO

-- Eliminar el medio de pago
EXEC cobranzas.GestionarMedioDePago 
    @nombre = 'Tarjeta Naranja',
    @operacion = 'Eliminar';

SELECT * FROM cobranzas.MedioDePago;
GO

/*_____________________________________________________________________
  ______________________ test RegistrarCobranza ________________________
  _____________________________________________________________________*/

USE COM2900G13;
GO

-- Ver socios y facturas para testeo
SELECT s.id_socio, p.dni, s.activo, s.saldo 
FROM administracion.Socio s
JOIN administracion.Persona p ON s.id_persona = p.id_persona;

SELECT * FROM facturacion.Factura;
SELECT * FROM cobranzas.MedioDePago;
GO

/* ✅ PRUEBA 1: Registro válido de cobranza */
EXEC cobranzas.RegistrarCobranza
    @dni_socio = '45778667',
    @monto = 5000,
    @fecha = '2025-06-15',
    @medio_pago = 'Visa',
    @nombre_actividad_extra = NULL,
    @id_factura = 1;
-- Resultado esperado: Inserta correctamente el pago y actualiza el saldo del socio.
GO

/* ❌ PRUEBA 2: Medio de pago no permitido (Efectivo) */
EXEC cobranzas.RegistrarCobranza
    @dni_socio = '45778667',
    @monto = 5000,
    @fecha = '2025-06-15',
    @medio_pago = 'Efectivo',
    @nombre_actividad_extra = NULL,
    @id_factura = 1;
-- Resultado esperado: Error 'No se aceptan pagos en Efectivo ni Cheque.'
GO

/* ❌ PRUEBA 3: Medio de pago inválido (no registrado) */
EXEC cobranzas.RegistrarCobranza
    @dni_socio = '45778667',
    @monto = 5000,
    @fecha = '2025-06-15',
    @medio_pago = 'Paypal',
    @nombre_actividad_extra = NULL,
    @id_factura = 1;
-- Resultado esperado: Error 'Medio de pago inválido. Solo se aceptan Visa...'
GO

/* ❌ PRUEBA 4: DNI de socio no existe */
EXEC cobranzas.RegistrarCobranza
    @dni_socio = '00000000',
    @monto = 5000,
    @fecha = '2025-06-15',
    @medio_pago = 'Visa',
    @nombre_actividad_extra = NULL,
    @id_factura = 1;
-- Resultado esperado: Error 'El socio especificado no existe o no está activo.'
GO

/* ❌ PRUEBA 5: Socio inactivo */
-- Precondición: tener socio con dni = '88888888' y activo = 0
EXEC cobranzas.RegistrarCobranza
    @dni_socio = '88888888',
    @monto = 5000,
    @fecha = '2025-06-15',
    @medio_pago = 'Visa',
    @nombre_actividad_extra = NULL,
    @id_factura = 1;
-- Resultado esperado: Error 'El socio especificado no existe o no está activo.'
GO

/* ❌ PRUEBA 6: Actividad extra no existente */
EXEC cobranzas.RegistrarCobranza
    @dni_socio = '45778667',
    @monto = 5000,
    @fecha = '2025-06-15',
    @medio_pago = 'Visa',
    @nombre_actividad_extra = 9999,
    @id_factura = 1;
-- Resultado esperado: Error 'La actividad extra especificada no existe.'
GO

/* ❌ PRUEBA 7: Factura anulada o inexistente */
EXEC cobranzas.RegistrarCobranza
    @dni_socio = '45778667',
    @monto = 5000,
    @fecha = '2025-06-15',
    @medio_pago = 'Visa',
    @nombre_actividad_extra = NULL,
    @id_factura = 9999;
-- Resultado esperado: Error 'La factura no existe, no pertenece al socio o está anulada.'
GO

/* ✅ PRUEBA 8: Registro con actividad extra válida */
-- Precondición: actividad extra con id = 1 y factura válida con id = 2
EXEC cobranzas.RegistrarCobranza
    @dni_socio = '45778667',
    @monto = 2000,
    @fecha = '2025-06-20',
    @medio_pago = 'Visa',
    @nombre_actividad_extra = 1,
    @id_factura = 2;
-- Resultado esperado: Inserción válida
GO

-- Verificar resultados
SELECT * FROM cobranzas.Pago ORDER BY id_pago DESC;
SELECT saldo FROM administracion.Socio WHERE id_persona IN (
    SELECT id_persona FROM administracion.Persona WHERE dni = '45778667'
);
GO

/*_____________________________________________________________________
  ________________ HabilitarDebitoAutomatico __________________________
  _____________________________________________________________________*/
  
-- Precondición: Tener socio activo con DNI = '45778667'
-- Precondición: Tener medio de pago 'Visa' con debito_automatico = 1
SELECT * FROM cobranzas.MedioDePago;
SELECT * FROM administracion.Persona;
SELECT * FROM administracion.Socio;
GO

-- ✅ PRUEBA 1: Habilitar débito automático correctamente
EXEC cobranzas.HabilitarDebitoAutomatico 
    @dni_socio = '45778667',
    @nombre_medio = 'Visa';
-- Esperado: Registro insertado o actualizado como habilitado
GO

-- Verificar resultado
SELECT * FROM cobranzas.DebitoAutomaticoSocio;
GO

-- ❌ PRUEBA 2: Medio no admite débito automático
-- Precondición: 'Rapipago' tiene debito_automatico = 0
EXEC cobranzas.HabilitarDebitoAutomatico 
    @dni_socio = '45778667',
    @nombre_medio = 'Rapipago';
-- Esperado: Error 'El medio de pago especificado no permite débito automático.'
GO

-- ❌ PRUEBA 3: Socio inexistente
EXEC cobranzas.HabilitarDebitoAutomatico 
    @dni_socio = '00000000',
    @nombre_medio = 'Visa';
-- Esperado: Error 'El socio especificado no existe o no está activo.'
GO
/*_____________________________________________________________________
  ________________ DeshabilitarDebitoAutomatico _______________________
  _____________________________________________________________________*/

  
-- ✅ PRUEBA 4: Deshabilitar débito automático correctamente
EXEC cobranzas.DeshabilitarDebitoAutomatico 
    @dni_socio = '45778667',
    @nombre_medio = 'Visa';
-- Esperado: Se actualiza habilitado = 0
GO

-- Verificar resultado
SELECT * FROM cobranzas.DebitoAutomaticoSocio;
GO

-- ❌ PRUEBA 5: Medio no existe
EXEC cobranzas.DeshabilitarDebitoAutomatico 
    @dni_socio = '45778667',
    @nombre_medio = 'Tarjeta Imaginaria';
-- Esperado: Error 'El medio de pago especificado no existe.'
GO

-- ❌ PRUEBA 6: El socio no tiene habilitado ese medio
EXEC cobranzas.DeshabilitarDebitoAutomatico 
    @dni_socio = '45778667',
    @nombre_medio = 'Visa';
-- Esperado: Error 'El socio no tiene habilitado el débito automático con ese medio de pago.'
GO
  
--Preset datos

select * from facturacion.Factura

EXEC cobranzas.RegistrarCobranza
    @dni_socio = '33444555',          -- DNI de Juan Pérez
    @monto = 90300,                   -- Monto total de la factura
    @fecha = '2025-06-15',            -- Fecha actual de pago
    @medio_pago = 'Visa',            -- Medio válido (asegurate de que existe)
    @nombre_actividad_extra = NULL,  -- No es actividad extra
    @id_factura = 2;                 -- ID de la factura
GO

SELECT * FROM cobranzas.Pago 


/*_____________________________________________________________________
  ____________________ GenerarReembolso _______________________________
  _____________________________________________________________________*/
EXEC cobranzas.GenerarReembolsoPorPago
    @id_pago = 3,
    @motivo = 'Suspensión de actividades por mantenimiento';
GO

select * from cobranzas.NotaDeCredito

select * from cobranzas.vwNotasConMedioDePago

/*_____________________________________________________________________
  ___________________ GenerarPagoCuenta _____________________________
  _____________________________________________________________________*/

  EXEC cobranzas.GenerarPagoACuentaPorReembolso
    @id_pago = 3,
    @motivo = 'Primer Mes de Regalo se carga en su cuenta el saldo equivalente';
GO

-- Verificar el registro del pago a cuenta
SELECT * FROM cobranzas.PagoACuenta WHERE id_pago = 3;

-- Verificar el nuevo saldo del socio
SELECT s.id_socio, p.dni, p.nombre, p.apellido, s.saldo
FROM administracion.Socio s
JOIN administracion.Persona p ON s.id_persona = p.id_persona
WHERE p.dni = '33444555';
GO

/*_____________________________________________________________________
  ________________ RegistrarReintegroLluvia ___________________________
  _____________________________________________________________________*/

-- ✅ PRUEBA 1: Registrar reintegro por lluvia válido
EXEC cobranzas.GenerarReintegroPorLluvia
    @mes = '02',
    @año = '2025',
    @path = 'C:\Users\ldeti\Desktop\College\BDA\TP BDA\Com2900G13\ETL\open-meteo-buenosaires_2025.csv';
GO

SELECT * FROM cobranzas.PagoACuenta;
SELECT * FROM administracion.vwSociosConCategoria ORDER BY apellido, nombre;

-- ❌ PRUEBA 2: Registrar reintegro con fecha futura inválida
EXEC cobranzas.GenerarReintegroPorLluvia
    @mes = '05',
    @año = '2000',
    @path = 'C:\Users\ldeti\Desktop\College\BDA\TP BDA\Com2900G13\ETL\open-meteo-buenosaires_2024.csv';
GO
