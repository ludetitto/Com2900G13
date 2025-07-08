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
   
   Objetivo: Testing en bloque.
 ========================================================================= */

USE COM2900G13;
GO
SET NOCOUNT ON;
GO

-- Inserción de categorias
EXEC socios.GestionarCategoriaSocio 'Menor', 0, 12, 10000.00, '2025-12-31', 'Insertar';
EXEC socios.GestionarCategoriaSocio 'Cadete', 13, 17, 15000.00, '2025-12-31', 'Insertar';
EXEC socios.GestionarCategoriaSocio 'Mayor', 18, 99, 25000.00, '2025-12-31', 'Insertar';

SELECT * FROM socios.CategoriaSocio;
GO
--BIEN

-- Alta de socios
EXEC socios.GestionarSocio
    @nombre = 'Valeria',
    @apellido = 'De Rosa',
    @dni = '10000000',
    @email = 'valeria.derosa@email.com',
    @fecha_nacimiento = '1990-05-10',
    @telefono = '1111222233',
    @telefono_emergencia = '1133445566',
    @domicilio = 'Calle Mayor 123',
    @obra_social = 'OSDE',
    @nro_os = 'OS123456',
    @operacion = 'Insertar';
GO

EXEC socios.GestionarSocio
    @nombre = 'Valeria1',
    @apellido = 'De Rosa',
    @dni = '31111223',
    @email = 'valeria.derosa1@email.com',
    @fecha_nacimiento = '2010-07-01',
    @telefono = '3344556677',
    @telefono_emergencia = '7788990011',
    @domicilio = 'Calle del Sol 222',
    @obra_social = 'Galeno',
    @nro_os = 'G456',
    @dni_integrante_grupo = '10000000',
    @operacion = 'Insertar';
GO

EXEC socios.GestionarSocio
    @nombre = 'Valeria2',
    @apellido = 'De Rosa',
    @dni = '31111224',
    @email = 'valeria.derosa2@email.com',
    @fecha_nacimiento = '2015-07-01',
    @telefono = '3344556677',
    @telefono_emergencia = '7788990011',
    @domicilio = 'Calle del Sol 222',
    @obra_social = 'Galeno',
    @nro_os = 'G456',
    @dni_integrante_grupo = '10000000',
    @operacion = 'Insertar';
GO

EXEC socios.GestionarSocio
    @nombre = 'Valeria3',
    @apellido = 'De Rosa',
    @dni = '31111225',
    @email = 'valeria.derosa3@email.com',
    @fecha_nacimiento = '2010-07-01',
    @telefono = '3344556677',
    @telefono_emergencia = '7788990011',
    @domicilio = 'Calle del Sol 222',
    @obra_social = 'Galeno',
    @nro_os = 'G456',
    @dni_integrante_grupo = '10000000',
    @operacion = 'Insertar';
GO

SELECT * FROM socios.Socio ORDER BY id_socio;
SELECT * FROM socios.Socio where dni = 10000000  ORDER BY id_socio;
SELECT * FROM socios.GrupoFamiliar ORDER BY id_grupo;
SELECT * FROM socios.GrupoFamiliarSocio ORDER BY id_grupo, id_socio;
SELECT * FROM socios.Tutor ORDER BY id_grupo;
GO
--BIEN, PERO FALTA TUTOR OJO

-- Inserción de emisor factura
EXEC facturacion.GestionarEmisorFactura 'Sol del Norte S.A.', '20-12345678-4', 'Av. Presidente Per�n 1234', 'Argentina', 'La Matanza', '1234', 'Insertar'
--BIEN 

-- Inserción de actividades base (sin horarios)
EXEC actividades.GestionarActividad 'Futsal', 25000, '2025-05-31', 'Insertar';
EXEC actividades.GestionarActividad 'Vóley', 30000, '2025-05-31', 'Insertar';
EXEC actividades.GestionarActividad 'Taekwondo', 25000, '2025-05-31', 'Insertar';
EXEC actividades.GestionarActividad 'Baile artístico', 30000, '2025-05-31', 'Insertar';
EXEC actividades.GestionarActividad 'Natación', 45000, '2025-05-31', 'Insertar';
EXEC actividades.GestionarActividad 'Ajedrez', 2000, '2025-05-31', 'Insertar';

SELECT* FROM actividades.Actividad
--BIEN
GO

-- Inserción de clases
-- FUTSAL - Lunes
EXEC actividades.GestionarClase 'Futsal', 'Gabriel', 'Mirabelli', 'Lunes 08:00', 'Menor', 'Insertar';
EXEC actividades.GestionarClase 'Futsal', 'Jair', 'Hnatiuk', 'Lunes 14:00', 'Cadete', 'Insertar';
EXEC actividades.GestionarClase 'Futsal', 'Valeria', 'De Rosa', 'Lunes 19:00', 'Mayor', 'Insertar';
GO
-- Vóley - Martes
EXEC actividades.GestionarClase 'Vóley', 'Nestor', 'Pan', 'Martes 08:00', 'Menor', 'Insertar';
EXEC actividades.GestionarClase 'Vóley', 'Matias', 'Mendoza', 'Martes 14:00', 'Cadete', 'Insertar';
EXEC actividades.GestionarClase 'Vóley', 'Nestor', 'Pan', 'Martes 19:00', 'Mayor', 'Insertar';
GO
-- TAEKWONDO - Miércoles
EXEC actividades.GestionarClase 'Taekwondo', 'Gabriel', 'Mirabelli', 'Miércoles 08:00', 'Menor', 'Insertar';
EXEC actividades.GestionarClase 'Taekwondo', 'Nestor', 'Pan', 'Miércoles 14:00', 'Cadete', 'Insertar';
EXEC actividades.GestionarClase 'Taekwondo', 'Nestor', 'Pan', 'Miércoles 19:00', 'Mayor', 'Insertar';
GO
-- BAILE artístico - Jueves
EXEC actividades.GestionarClase 'Baile artístico', 'Valeria', 'De Rosa', 'Jueves 08:00', 'Menor', 'Insertar';
EXEC actividades.GestionarClase 'Baile artístico', 'Valeria', 'De Rosa', 'Jueves 14:00', 'Cadete', 'Insertar';
EXEC actividades.GestionarClase 'Baile artístico', 'Valeria', 'De Rosa', 'Jueves 19:00', 'Mayor', 'Insertar';
GO
-- Natación - Viernes
EXEC actividades.GestionarClase 'Natación', 'Matias', 'Mendoza', 'Viernes 08:00', 'Menor', 'Insertar';
EXEC actividades.GestionarClase 'Natación', 'Jair', 'Hnatiuk', 'Viernes 14:00', 'Cadete', 'Insertar';
EXEC actividades.GestionarClase 'Natación', 'Matias', 'Mendoza', 'Viernes 19:00', 'Mayor', 'Insertar';
GO
-- AJEDREZ - Sábado
EXEC actividades.GestionarClase 'Ajedrez', 'Jair', 'Hnatiuk', 'Sábado 08:00', 'Menor', 'Insertar';
EXEC actividades.GestionarClase 'Ajedrez', 'Matias', 'Mendoza', 'Sábado 14:00', 'Cadete', 'Insertar';
EXEC actividades.GestionarClase 'Ajedrez', 'Gabriel', 'Mirabelli', 'Sábado 19:00', 'Mayor', 'Insertar';
GO

SELECT * FROM actividades.Clase;
--BIEN
EXEC actividades.GestionarInscriptoClase '10000000', 'Futsal',  'Lunes 19:00',  'Mayor', '2025-05-13', 'Insertar';
EXEC actividades.GestionarInscriptoClase '31111225', 'Taekwondo',  'Miércoles 14:00',  'Cadete', '2025-05-13', 'Insertar';
EXEC actividades.GestionarInscriptoClase '31111224', 'Futsal',  'Lunes 08:00',  'Menor', '2025-05-13', 'Insertar';
EXEC actividades.GestionarInscriptoClase '31111223', 'Futsal',  'Lunes 14:00',  'Cadete', '2025-05-13', 'Insertar';
EXEC actividades.GestionarInscriptoClase '31111223', 'Taekwondo',  'Miércoles 14:00',  'Cadete', '2025-05-13', 'Insertar';

SELECT * FROM actividades.InscriptoClase;

--BIEN
-- Generación de cuotas; solo socios individuales
EXEC facturacion.GenerarCuotasMensualesPorFecha '2025-07-21';
GO
SELECT * FROM facturacion.CuotaMensual 

-- Generación de facturas grupales
EXEC facturacion.GenerarFacturasMensualesPorFechaGrupoFamiliar '2025-07-21';
GO

-- Generación de facturas individuales
EXEC facturacion.GenerarFacturasMensualesPorFecha '2025-07-21';
GO

SELECT * FROM actividades.Clase
SELECT * FROM facturacion.CargoClases
SELECT * FROM actividades.InscriptoClase
SELECT * FROM facturacion.CuotaMensual

SELECT * FROM facturacion.Factura F
INNER JOIN facturacion.CuotaMensual CM ON CM.id_cuota_mensual = F.id_cuota_mensual

SELECT * FROM facturacion.CargoClases

-- Se testea con el grupo familiar del responsable SN-4005 con socio a cargo SN-4144
SELECT * FROM facturacion.Factura
WHERE MONTH(fecha_emision) = MONTH(GETDATE())
 AND dni_receptor = 292632869; -- Cuyo menor a cargo es 47258764

SELECT * FROM facturacion.DetalleFactura DF
INNER JOIN facturacion.Factura F ON F.id_factura = DF.id_factura
WHERE MONTH(F.fecha_emision) = MONTH(GETDATE())
 AND F.dni_receptor = 292632869
ORDER BY DF.id_factura;

SELECT * 
FROM facturacion.vwFacturaTotalGrupoFamiliar
WHERE dni_responsable = 292632869;

-- Inserción de medios de pago
EXEC cobranzas.GestionarMedioDePago 'Tarjeta de débito', 'Insertar';
EXEC cobranzas.GestionarMedioDePago 'Visa', 'Insertar';
EXEC cobranzas.GestionarMedioDePago 'MasterCard', 'Insertar';
EXEC cobranzas.GestionarMedioDePago 'Tarjeta Naranja', 'Insertar';
EXEC cobranzas.GestionarMedioDePago 'Pago Fácil', 'Insertar'
EXEC cobranzas.GestionarMedioDePago 'Rapipago', 'Insertar';
EXEC cobranzas.GestionarMedioDePago 'Transferencia Mercado Pago', 'Insertar';
GO

SELECT * FROM cobranzas.MedioDePago

-- Registrar pago
EXEC cobranzas.RegistrarCobranza 1, '2025-08-5', 180000, 'Visa';

SELECT * FROM cobranzas.Pago
SELECT * FROM socios.Socio
SELECT * FROM cobranzas.PagoACuenta

-- Inserción de tarifas de pileta de verano
EXEC tarifas.GestionarTarifaPiletaVerano 'Mayor', '0', 25000, '2025-09-25', 'Insertar'
EXEC tarifas.GestionarTarifaPiletaVerano 'Mayor', '1', 30000, '2025-09-25', 'Insertar'
GO

EXEC actividades.GestionarInscriptoPiletaVerano '10000000', NULL, NULL, NULL, NULL, NULL, NULL, '2025-07-15', 'Insertar';

EXEC actividades.GestionarInscriptoPiletaVerano '10000000', '10000001', 'InvitadoVal', 'Gonzalez', 'Mayor', 'InvitadoVal@mail.com', 'Calle Falsa 100', '2025-07-28', 'Insertar';

EXEC facturacion.GenerarFacturasActividadesExtraPorFecha '2025-07-30';
GO

SELECT * FROM facturacion.CargoActividadExtra
SELECT * FROM facturacion.Factura F
WHERE MONTH(fecha_emision) = MONTH(GETDATE())
SELECT * FROM facturacion.DetalleFactura DF
INNER JOIN facturacion.Factura F ON F.id_factura =DF.id_factura
WHERE MONTH(F.fecha_emision) = MONTH(GETDATE())

--ERROR: LA FECHA DE PAGO ES ANTERIOR A LA EMISION DE LA FACTURA
EXEC cobranzas.RegistrarCobranza 4, '2025-07-28', 33000, 'Visa';

--CASO VALIDO, en este caso, se usa el saldo a favor que tenia el socio
SELECT nombre, apellido, saldo FROM socios.Socio where dni = 10000000     

EXEC cobranzas.RegistrarCobranza 4, '2025-07-31', 33000, 'Visa';
SELECT * FROM facturacion.Factura where id_factura = 4
SELECT nombre, apellido, saldo FROM socios.Socio where dni = 10000000     


-- Se modifica manualmente la inscripción para probar módulo de morosidad
UPDATE actividades.InscriptoCategoriaSocio
SET fecha = '2025-05-01'
WHERE id_socio IN (SELECT GFS.id_socio 
				   FROM socios.GrupoFamiliarSocio GFS
				   INNER JOIN socios.GrupoFamiliar GF ON GF.id_grupo = GFS.id_grupo
				   INNER JOIN socios.Socio S ON S.id_socio = GF.id_socio_rp
				   WHERE S.dni = 10000000);

SELECT * FROM actividades.InscriptoCategoriaSocio

-- Generación de cuotas
EXEC facturacion.GenerarCuotasMensualesPorFecha '2025-05-21';
GO

SELECT * FROM facturacion.CuotaMensual;

-- Generación de facturas grupales (vencidas)
EXEC facturacion.GenerarFacturasMensualesPorFechaGrupoFamiliar '2025-05-21';
GO
/* ELIMINACION DE LAS FACTURAS PARA EL MES 5
DELETE FROM facturacion.DetalleFactura
WHERE id_factura IN (SELECT id_factura
					 FROM facturacion.Factura
					 WHERE MONTH(fecha_emision) = 5)


DELETE FROM facturacion.Factura
WHERE MONTH(fecha_emision) = 5
*/
SELECT * FROM facturacion.Factura F
WHERE MONTH(fecha_emision) = 5
SELECT * FROM facturacion.DetalleFactura DF
INNER JOIN facturacion.Factura F ON F.id_factura =DF.id_factura
WHERE MONTH(F.fecha_emision) = 5


EXEC cobranzas.AplicarRecargoVencimiento
GO

SELECT * FROM cobranzas.Mora;

SELECT * FROM socios.Socio

-- Se modifica manualmente la inscripción para probar módulo de morosidad
UPDATE actividades.InscriptoCategoriaSocio
SET fecha = '2025-06-01'
WHERE id_socio IN (SELECT GFS.id_socio 
				   FROM socios.GrupoFamiliarSocio GFS
				   INNER JOIN socios.GrupoFamiliar GF ON GF.id_grupo = GFS.id_grupo
				   INNER JOIN socios.Socio S ON S.id_socio = GF.id_socio_rp
				   WHERE S.dni = 10000000);

SELECT * FROM actividades.InscriptoCategoriaSocio

-- Generación de cuotas
EXEC facturacion.GenerarCuotasMensualesPorFecha '2025-06-21';
GO

SELECT * FROM facturacion.CuotaMensual;

-- Generación de facturas grupales (vencidas)
EXEC facturacion.GenerarFacturasMensualesPorFechaGrupoFamiliar '2025-06-21';
GO

SELECT * FROM facturacion.Factura F
WHERE MONTH(fecha_emision) = 6
SELECT * FROM facturacion.DetalleFactura DF
INNER JOIN facturacion.Factura F ON F.id_factura =DF.id_factura
WHERE MONTH(F.fecha_emision) = 6

--PODEMOS HACER QUE LA FACTURA BUSQUE SI EL ID DE LA FACTURA TIENE UNA TUPLA EN MORA --> SI LA TIENE SUMAR
--MEJOR OPCION SERIA USAR EL SALDO_ANTERIOR DEL SOCIO PORQUE --> 1- SI EL SALDO ES NEGATIVO, ES PORQUE DEBE Y FacturasMensualesPorFecha LE SUMA ESE MONTO A LA FACTURA;
															 --  2- SI EL SALDO ES POSITIVO? EL SP FacturasMensualesPorFecha SE FIJA SI HAY SALDO Y LE SACA AL MONTO TOTAL DE LA FACTURA
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

-- Registrar pago mediante débito automático
EXEC cobranzas.EjecutarDebitoAutomatico '2025-07-07';
GO

SELECT * FROM cobranzas.MedioDePago;

SELECT * FROM facturacion.Factura

SELECT id_pago, id_factura, nro_transaccion, monto, estado, fecha_emision
FROM cobranzas.Pago
WHERE fecha_emision = CAST(GETDATE() AS DATE)
ORDER BY id_pago DESC;

-- Generación de cuotas
EXEC facturacion.GenerarCuotasMensualesPorFecha '2025-01-21';
GO

SELECT * FROM facturacion.CuotaMensual;

-- Generación de facturas grupales (vencidas)
EXEC facturacion.GenerarFacturasMensualesPorFechaGrupoFamiliar '2025-01-21';
GO

SELECT * FROM facturacion.Factura F
WHERE MONTH(fecha_emision) = 1
SELECT * FROM facturacion.DetalleFactura DF
INNER JOIN facturacion.Factura F ON F.id_factura =DF.id_factura
WHERE MONTH(F.fecha_emision) = 1

-- Generar reintegros por lluvia
EXEC cobranzas.GenerarReintegroPorLluvia
    @mes = 01,
    @año = 2025,
    @path = 'C:\Users\ldeti\Desktop\College\BDA\TP BDA\Com2900G13\ETL\open-meteo-buenosaires_2025.csv';
GO

SELECT * FROM cobranzas.Reembolso
SELECT * FROM cobranzas.PagoACuenta;
SELECT * FROM socios.vwGrupoFamiliarConCategorias ORDER BY apellido, nombre;

-- Aplicar bloqueo
EXEC cobranzas.AplicarBloqueoVencimiento
GO

SELECT * FROM socios.Socio
