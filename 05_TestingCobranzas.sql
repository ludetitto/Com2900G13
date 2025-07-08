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
/* 
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


/*_____________________________________________________________________
  _____________________ PRUEBAS GestionarTarjeta ______________________
  _____________________________________________________________________ */

-- 🔄 LIMPIEZA PARA NO DUPLICAR PRUEBAS
DELETE FROM cobranzas.Pago WHERE nro_transaccion LIKE 'TK-%';
DELETE FROM cobranzas.TarjetaDeCredito WHERE id_socio = 1;

-- 🔍 Confirmar socio responsable
SELECT id_socio, dni, nro_socio FROM socios.Socio WHERE dni = '10000000';

-- ✅ Registrar tarjeta con débito automático habilitado
EXEC cobranzas.GestionarTarjeta
    @nro_socio = 'SN-4001',
    @nro_tarjeta = '4111111111111111',
    @titular = 'Valeria De Rosa',
    @fecha_desde = '2025-01-01',
    @fecha_hasta = '2027-12-31',
    @cod_seguridad = '321',
    @debito_automatico = 1,
    @operacion = 'Insertar';
GO

SELECT * FROM cobranzas.TarjetaDeCredito;
GO

-- ✅ Modificar titular y fecha_hasta de la tarjeta con ID 1
EXEC cobranzas.GestionarTarjeta
    @id_tarjeta = 1,
    @titular = 'Valeria De Rosa',
    @fecha_hasta = '2028-01-01',
    @operacion = 'Modificar';
GO

SELECT * FROM cobranzas.TarjetaDeCredito;
GO

-- ❌ Modificar sin ID (error esperado)
EXEC cobranzas.GestionarTarjeta
    @titular = 'Sin ID',
    @operacion = 'Modificar';


-- ❌ Insertar con campos faltantes (error esperado)
EXEC cobranzas.GestionarTarjeta
    @id_socio = 1,
    @nro_tarjeta = NULL,
    @titular = NULL,
    @fecha_desde = NULL,
    @fecha_hasta = NULL,
    @cod_seguridad = NULL,
    @debito_automatico = 0,
    @operacion = 'Insertar';


-- ✅ Eliminar tarjeta con ID 1
EXEC cobranzas.GestionarTarjeta
    @id_tarjeta = 1,
    @operacion = 'Eliminar';
GO

SELECT * FROM cobranzas.TarjetaDeCredito;
GO

-- ❌ Eliminar sin ID (error esperado)
EXEC cobranzas.GestionarTarjeta
    @operacion = 'Eliminar';



/*_____________________________________________________________________
  ____________ Generar cuotas, facturas y probar débito _______________
  _____________________________________________________________________*/
 EXEC cobranzas.GestionarMedioDePago 'Tarjeta de débito', 'Insertar';
GO
EXEC cobranzas.GestionarMedioDePago 'Visa', 'Insertar';
GO
EXEC cobranzas.GestionarMedioDePago 'MasterCard', 'Insertar';
GO
EXEC cobranzas.GestionarMedioDePago 'Tarjeta Naranja', 'Insertar';
GO
EXEC cobranzas.GestionarMedioDePago 'Pago Fácil', 'Insertar'
GO
EXEC cobranzas.GestionarMedioDePago 'Rapipago', 'Insertar';
GO
EXEC cobranzas.GestionarMedioDePago 'Transferencia Mercado Pago', 'Insertar';


-- Insertar actividades base (sin horarios)
EXEC actividades.GestionarActividad 'Futsal', 25000, '2025-05-31', 'Insertar';
EXEC actividades.GestionarActividad 'Vóley', 30000, '2025-05-31', 'Insertar';
EXEC actividades.GestionarActividad 'Taekwondo', 25000, '2025-05-31', 'Insertar';
EXEC actividades.GestionarActividad 'Baile artístico', 30000, '2025-05-31', 'Insertar';
EXEC actividades.GestionarActividad 'Natación', 45000, '2025-05-31', 'Insertar';
EXEC actividades.GestionarActividad 'Ajedrez', 2000, '2025-05-31', 'Insertar';
GO

EXEC actividades.GestionarClase 'Futsal', 'Gabriel', 'Mirabelli', 'Lunes 08:00', 'Menor', 'Insertar';
EXEC actividades.GestionarClase 'Futsal', 'Jair', 'Hnatiuk', 'Lunes 14:00', 'Cadete', 'Insertar';
EXEC actividades.GestionarClase 'Futsal', 'Valeria', 'De Rosa', 'Lunes 19:00', 'Mayor', 'Insertar';
GO
EXEC actividades.GestionarClase 'Vóley', 'Nestor', 'Pan', 'Martes 08:00', 'Menor', 'Insertar';
EXEC actividades.GestionarClase 'Vóley', 'Matias', 'Mendoza', 'Martes 14:00', 'Cadete', 'Insertar';
EXEC actividades.GestionarClase 'Vóley', 'Nestor', 'Pan', 'Martes 19:00', 'Mayor', 'Insertar';
GO
EXEC actividades.GestionarClase 'Taekwondo', 'Gabriel', 'Mirabelli', 'Miércoles 08:00', 'Menor', 'Insertar';
EXEC actividades.GestionarClase 'Taekwondo', 'Nestor', 'Pan', 'Miércoles 14:00', 'Cadete', 'Insertar';
EXEC actividades.GestionarClase 'Taekwondo', 'Nestor', 'Pan', 'Miércoles 19:00', 'Mayor', 'Insertar';
GO
EXEC actividades.GestionarClase 'Baile artístico', 'Valeria', 'De Rosa', 'Jueves 08:00', 'Menor', 'Insertar';
EXEC actividades.GestionarClase 'Baile artístico', 'Valeria', 'De Rosa', 'Jueves 14:00', 'Cadete', 'Insertar';
EXEC actividades.GestionarClase 'Baile artístico', 'Valeria', 'De Rosa', 'Jueves 19:00', 'Mayor', 'Insertar';
GO
EXEC actividades.GestionarClase 'Natación', 'Matias', 'Mendoza', 'Viernes 08:00', 'Menor', 'Insertar';
EXEC actividades.GestionarClase 'Natación', 'Jair', 'Hnatiuk', 'Viernes 14:00', 'Cadete', 'Insertar';
EXEC actividades.GestionarClase 'Natación', 'Matias', 'Mendoza', 'Viernes 19:00', 'Mayor', 'Insertar';
GO
EXEC actividades.GestionarClase 'Ajedrez', 'Jair', 'Hnatiuk', 'Sábado 08:00', 'Menor', 'Insertar';
EXEC actividades.GestionarClase 'Ajedrez', 'Matias', 'Mendoza', 'Sábado 14:00', 'Cadete', 'Insertar';
EXEC actividades.GestionarClase 'Ajedrez', 'Gabriel', 'Mirabelli', 'Sábado 19:00', 'Mayor', 'Insertar';
GO

EXEC actividades.GestionarInscriptoClase '10000000', 'Futsal',  'Lunes 19:00',  'Mayor', '2025-06-13', 'Insertar';
EXEC actividades.GestionarInscriptoClase '31111225', 'Taekwondo',  'Miércoles 14:00',  'Cadete', '2025-06-13', 'Insertar';
EXEC actividades.GestionarInscriptoClase '31111224', 'Futsal',  'Lunes 08:00',  'Menor', '2025-06-13', 'Insertar';
EXEC actividades.GestionarInscriptoClase '31111223', 'Futsal',  'Lunes 14:00',  'Cadete', '2025-06-13', 'Insertar';
EXEC actividades.GestionarInscriptoClase '31111223', 'Taekwondo',  'Miércoles 14:00',  'Cadete', '2025-06-13', 'Insertar';

EXEC facturacion.GenerarCargoClase '10000000', '2025-07-13';
EXEC facturacion.GenerarCargoClase '31111225', '2025-07-13';
EXEC facturacion.GenerarCargoClase '31111224', '2025-07-13';
EXEC facturacion.GenerarCargoClase '31111223', '2025-07-13'; 

EXEC facturacion.GestionarEmisorFactura 'Sol del Norte S.A.', '20-12345678-4', 'Av. Presidente Per�n 1234', 'Argentina', 'La Matanza', '1234', 'Insertar'

DELETE FROM facturacion.DetalleFactura
DELETE FROM facturacion.Factura
DELETE FROM facturacion.CuotaMensual

EXEC facturacion.GenerarCuotasMensualesPorFecha '2025-07-21';
GO

EXEC facturacion.GenerarFacturasMensualesPorFechaGrupoFamiliar '2025-07-21';
GO


-- 🔍 4. Verificar facturas emitidas este mes (cuotas mensuales)
SELECT f.id_factura, f.dni_receptor, s.nro_socio, f.monto_total, f.fecha_emision
FROM facturacion.Factura f
JOIN socios.Socio s ON f.dni_receptor = s.dni

SELECT * FROM actividades.Clase
SELECT * FROM facturacion.CargoClases
SELECT * FROM facturacion.CuotaMensual


SELECT * FROM facturacion.CargoClases
SELECT * FROM facturacion.Factura F
WHERE MONTH(fecha_emision) = MONTH(GETDATE())
SELECT * FROM facturacion.DetalleFactura DF
INNER JOIN facturacion.Factura F ON F.id_factura =DF.id_factura
WHERE MONTH(F.fecha_emision) = MONTH(GETDATE())


SELECT * FROM cobranzas.TarjetaDeCredito
WHERE debito_automatico = 1;

SELECT * FROM facturacion.Factura
WHERE dni_receptor = '10000000'
  AND MONTH(fecha_emision) = MONTH(GETDATE())
  AND YEAR(fecha_emision) = YEAR(GETDATE());


SELECT * FROM facturacion.Factura
WHERE dni_receptor = '10000000'
  AND MONTH(fecha_emision) = MONTH(GETDATE())
  AND id_cuota_mensual IS NOT NULL;

/*_____________________________________________________________________
  ____________________ PRUEBAS EjecutarDebitoAutomatico ________________
  _____________________________________________________________________ */

-- 🔄 Ejecutar débito automático
EXEC cobranzas.EjecutarDebitoAutomatico '2025-07-07';
GO

SELECT * FROM cobranzas.MedioDePago;

SELECT * FROM facturacion.Factura

-- 🔍 Ver pagos generados hoy
SELECT id_pago, id_factura, nro_transaccion, monto, estado, fecha_emision
FROM cobranzas.Pago
WHERE fecha_emision = CAST(GETDATE() AS DATE)
ORDER BY id_pago DESC;

