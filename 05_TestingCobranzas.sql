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

-- ================================================
-- TESTING: cobranzas.GestionarMedioDePago
-- ================================================

-- ✅ Insertar nuevo medio de pago válido
EXEC cobranzas.GestionarMedioDePago 
    @nombre = 'Visa',
    @debito_automatico = 1,
    @operacion = 'Insertar';
SELECT * FROM administracion.MedioDePago;
GO

-- ❌ Insertar duplicado
EXEC cobranzas.GestionarMedioDePago 
    @nombre = 'Visa',
    @debito_automatico = 1,
    @operacion = 'Insertar';
SELECT * FROM administracion.MedioDePago;
GO

-- ✅ Modificar debito_automatico a 0
EXEC cobranzas.GestionarMedioDePago 
    @nombre = 'Visa',
    @debito_automatico = 0,
    @operacion = 'Modificar';
SELECT * FROM administracion.MedioDePago;
GO

-- ❌ Modificar medio inexistente
EXEC cobranzas.GestionarMedioDePago 
    @nombre = 'NoExiste',
    @debito_automatico = 1,
    @operacion = 'Modificar';
SELECT * FROM administracion.MedioDePago;
GO

-- ✅ Eliminar medio existente
EXEC cobranzas.GestionarMedioDePago 
    @nombre = 'Visa',
    @operacion = 'Eliminar';
SELECT * FROM administracion.MedioDePago;
GO

-- ❌ Eliminar medio inexistente
EXEC cobranzas.GestionarMedioDePago 
    @nombre = 'NoExiste',
    @operacion = 'Eliminar';
SELECT * FROM administracion.MedioDePago;
GO

-- ================================================
-- TESTING: cobranzas.HabilitarDebitoAutomatico
-- ================================================

-- Agregar MasterCard y Rapipago como medios de pago de prueba
EXEC cobranzas.GestionarMedioDePago 'MasterCard', 1, 'Insertar';
EXEC cobranzas.GestionarMedioDePago 'Rapipago', 0, 'Insertar';
GO

-- ✅ Habilitar débito automático correctamente
EXEC cobranzas.HabilitarDebitoAutomatico 
    @dni_socio = '45778667',
    @nombre_medio = 'MasterCard';
SELECT * FROM socios.DebitoAutomaticoSocio;
GO

-- ❌ Medio no permite débito automático
EXEC cobranzas.HabilitarDebitoAutomatico 
    @dni_socio = '45778667',
    @nombre_medio = 'Rapipago';
SELECT * FROM socios.DebitoAutomaticoSocio;
GO

-- ❌ Socio no existe
EXEC cobranzas.HabilitarDebitoAutomatico 
    @dni_socio = '00000000',
    @nombre_medio = 'MasterCard';
SELECT * FROM socios.DebitoAutomaticoSocio;
GO

-- ================================================
-- TESTING: cobranzas.DeshabilitarDebitoAutomatico
-- ================================================

-- ✅ Deshabilitar débito automático
EXEC cobranzas.DeshabilitarDebitoAutomatico 
    @dni_socio = '45778667',
    @nombre_medio = 'MasterCard';
SELECT * FROM socios.DebitoAutomaticoSocio;
GO

-- ❌ Medio no existe
EXEC cobranzas.DeshabilitarDebitoAutomatico 
    @dni_socio = '45778667',
    @nombre_medio = 'Inexistente';
SELECT * FROM socios.DebitoAutomaticoSocio;
GO

-- ❌ Socio no tiene habilitado el medio
EXEC cobranzas.DeshabilitarDebitoAutomatico 
    @dni_socio = '45778667',
    @nombre_medio = 'Rapipago';
SELECT * FROM socios.DebitoAutomaticoSocio;
GO


/*_____________________________________________________________________
  ________________ PRUEBAS RegistrarReintegroLluvia ___________________
  _____________________________________________________________________
  
  ACLARACIONES: Modificar el path a la ruta donde fue clonado el proyecto,
  o en su defecto, donde esté guardada esta solución SQL. Tenga en cuenta
  que para los procesos ETL fue creada una carpeta dentro del repo.*/

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
    @año = '2027',
    @path = 'C:\Users\ldeti\Desktop\College\BDA\TP BDA\Com2900G13\ETL\open-meteo-buenosaires_2025.csv';
GO
