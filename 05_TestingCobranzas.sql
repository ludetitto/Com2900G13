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
    @operacion = 'Insertar';

	
SELECT * FROM cobranzas.MedioDePago;
GO

-- ❌ Insertar duplicado
EXEC cobranzas.GestionarMedioDePago 
    @nombre = 'Visa',
    @operacion = 'Insertar';
SELECT * FROM cobranzas.MedioDePago;
GO



-- ✅ Eliminar medio existente
EXEC cobranzas.GestionarMedioDePago 
    @nombre = 'Visa',
    @operacion = 'Eliminar';
SELECT * FROM cobranzas.MedioDePago;
GO

-- ❌ Eliminar medio inexistente
EXEC cobranzas.GestionarMedioDePago 
    @nombre = 'NoExiste',
    @operacion = 'Eliminar';
SELECT * FROM cobranzas.MedioDePago;
GO

/*_____________________________________________________________________
  ____________________ PRUEBAS RegistrarCobranza ______________________
  _____________________________________________________________________
*/

-- Ver un socio válido
SELECT id_socio, nombre, apellido, dni FROM socios.Socio WHERE activo = 1 AND eliminado = 0;

-- Ver medios de pago disponibles
SELECT * FROM cobranzas.MedioDePago;

-- Caso 1: Pago exacto de factura válida
PRINT 'Caso 1: Pago exacto de factura válida';
EXEC cobranzas.RegistrarCobranza
    @id_factura = 0,
    @fecha_pago = '2025-07-01',
    @monto = 77000.00,
    @medio_de_pago = 'Visa';
GO

-- Caso 2: Pago con excedente (genera pago a cuenta)
PRINT 'Caso 2: Pago con excedente';
EXEC cobranzas.RegistrarCobranza
    @id_factura = 1,
    @fecha_pago = '2025-07-02',
    @monto = 50000.00,
    @medio_de_pago = 'Visa';
GO

-- Caso 3: Error - factura no existe
PRINT 'Caso 3: Error esperado - factura no existe';
BEGIN TRY
    EXEC cobranzas.RegistrarCobranza
        @id_factura = 999,
        @fecha_pago = '2025-07-02',
        @monto = 10000.00,
        @medio_de_pago = 'Visa';
END TRY
BEGIN CATCH
    PRINT ERROR_MESSAGE();
END CATCH;
GO

-- Caso 4: Error - monto insuficiente
PRINT 'Caso 4: Error esperado - monto insuficiente';
BEGIN TRY
    EXEC cobranzas.RegistrarCobranza
        @id_factura = 2,
        @fecha_pago = '2025-07-02',
        @monto = 10000.00,
        @medio_de_pago = 'Visa';
END TRY
BEGIN CATCH
    PRINT ERROR_MESSAGE();
END CATCH;
GO

-- Caso 5: Error - medio de pago no válido
PRINT 'Caso 5: Error esperado - medio de pago no válido';
BEGIN TRY
    EXEC cobranzas.RegistrarCobranza
        @id_factura = 3,
        @fecha_pago = '2025-07-02',
        @monto = 50000.00,
        @medio_de_pago = 'Efvo';
END TRY
BEGIN CATCH
    PRINT ERROR_MESSAGE();
END CATCH;
GO

-- Caso 6: Error - factura ya pagada
PRINT 'Caso 6: Error esperado - factura ya pagada';
BEGIN TRY
    EXEC cobranzas.RegistrarCobranza
        @id_factura = 4,
        @fecha_pago = '2025-07-02',
        @monto = 40000.00,
        @medio_de_pago = 'Visa';

    -- Intento de volver a pagar la misma factura (debe fallar)
    EXEC cobranzas.RegistrarCobranza
        @id_factura = 4,
        @fecha_pago = '2025-07-02',
        @monto = 40000.00,
        @medio_de_pago = 'Visa';
END TRY
BEGIN CATCH
    PRINT ERROR_MESSAGE();
END CATCH;
GO

/*_____________________________________________________________________
  ________________ PRUEBAS RegistrarReintegroLluvia ___________________
  _____________________________________________________________________ */
  
  ACLARACIONES: Modificar el path a la ruta donde fue clonado el proyecto,
  o en su defecto, donde esté guardada esta solución SQL. Tenga en cuenta
  que para los procesos ETL fue creada una carpeta dentro del repo.*/

-- ✅ PRUEBA 1: Registrar reintegro por lluvia válido
EXEC cobranzas.GenerarReintegroPorLluvia
    @mes = 01,
    @año = 2025,
    @path = 'C:\Users\ldeti\Desktop\College\BDA\TP BDA\Com2900G13\ETL\open-meteo-buenosaires_2025.csv';
GO

SELECT * FROM cobranzas.Reembolso
SELECT * FROM cobranzas.PagoACuenta;
SELECT * FROM socios.vwGrupoFamiliarConCategorias ORDER BY apellido, nombre;

-- ❌ PRUEBA 2: Registrar reintegro con fecha futura inválida
EXEC cobranzas.GenerarReintegroPorLluvia
    @mes = 05,
    @año = 2027,
    @path = 'C:\Users\ldeti\Desktop\College\BDA\TP BDA\Com2900G13\ETL\open-meteo-buenosaires_2025.csv';
GO

/*_____________________________________________________________________
  ____________________ PRUEBAS RegistrarCobranza ______________________
  _____________________________________________________________________ */

-- Caso 1: Socio paga por sí mismo (sin grupo)
PRINT 'Caso 1: Socio paga por sí mismo (sin grupo)';
EXEC cobranzas.RegistrarCobranza 11, '2025-01-30', 200000, 'Visa';
GO

select * from cobranzas.PagoACuenta where id_socio = (SELECT id_socio from socios.Socio where socios.socio.dni = 40606060)
SELECT saldo, id_socio, dni  from socios.Socio where socios.socio.dni = 40606060;
select * from cobranzas.Pago
select * from facturacion.factura
