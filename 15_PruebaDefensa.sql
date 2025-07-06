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

-- ✅ PRUEBA 1: Inserción válida de categoría "Menor"
EXEC socios.GestionarCategoriaSocio
    @nombre_categoria  = 'Menor',
    @edad_minima = 0,
    @edad_maxima = 12,
    @costo = 10000.00,
    @vigencia = '2025-12-31',
    @operacion = 'Insertar';
-- Resultado esperado: Categoría insertada correctamente
GO

-- ✅ PRUEBA 2: Inserción válida de categoría "Cadete"
EXEC socios.GestionarCategoriaSocio
    @nombre_categoria  = 'Cadete',
    @edad_minima = 13,
    @edad_maxima = 17,
    @costo = 15000.00,
    @vigencia = '2025-12-31',
    @operacion = 'Insertar';
-- Resultado esperado: Categoría insertada correctamente
GO

-- ✅ PRUEBA 3: Inserción válida de categoría "Mayor"
EXEC socios.GestionarCategoriaSocio
    @nombre_categoria  = 'Mayor',
    @edad_minima = 18,
    @edad_maxima = 99,
    @costo = 25000.00,
    @vigencia = '2025-12-31',
    @operacion = 'Insertar';
-- Resultado esperado: Categoría insertada correctamente
GO
SELECT * FROM socios.CategoriaSocio;
GO

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


-- ✅ PRUEBA 3: Alta de menor a grupo existente (usando DNI de Julián)
EXEC socios.GestionarSocio
    @nombre = 'Valeria1',
    @apellido = 'Pérez',
    @dni = '31111223',
    @email = 'martina.perez@email.com',
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
    @apellido = 'Pérez',
    @dni = '31111224',
    @email = 'martina.perez@email.com',
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
    @apellido = 'Pérez',
    @dni = '31111225',
    @email = 'martina.perez@email.com',
    @fecha_nacimiento = '2010-07-01',
    @telefono = '3344556677',
    @telefono_emergencia = '7788990011',
    @domicilio = 'Calle del Sol 222',
    @obra_social = 'Galeno',
    @nro_os = 'G456',
    @dni_integrante_grupo = '10000000',
    @operacion = 'Insertar';
GO
-- Verificacion de las tablas
SELECT * FROM socios.Socio ORDER BY id_socio;
SELECT * FROM socios.GrupoFamiliar ORDER BY id_grupo;
SELECT * FROM socios.GrupoFamiliarSocio ORDER BY id_grupo, id_socio;
SELECT * FROM socios.Tutor ORDER BY id_grupo;
GO

EXEC facturacion.GestionarEmisorFactura 'Sol del Norte S.A.', '20-12345678-4', 'Av. Presidente Per�n 1234', 'Argentina', 'La Matanza', '1234', 'Insertar'

-- Insertar actividades base (sin horarios)
EXEC actividades.GestionarActividad 'Futsal', 25000, '2025-05-31', 'Insertar';
EXEC actividades.GestionarActividad 'Vóley', 30000, '2025-05-31', 'Insertar';
EXEC actividades.GestionarActividad 'Taekwondo', 25000, '2025-05-31', 'Insertar';
EXEC actividades.GestionarActividad 'Baile artístico', 30000, '2025-05-31', 'Insertar';
EXEC actividades.GestionarActividad 'Natación', 45000, '2025-05-31', 'Insertar';
EXEC actividades.GestionarActividad 'Ajedrez', 2000, '2025-05-31', 'Insertar';
GO

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

EXEC actividades.GestionarInscriptoClase '10000000', 'Futsal',  'Lunes 19:00',  'Mayor', '2025-06-13', 'Insertar';
EXEC actividades.GestionarInscriptoClase '31111225', 'Taekwondo',  'Miércoles 14:00',  'Cadete', '2025-06-13', 'Insertar';
EXEC actividades.GestionarInscriptoClase '31111224', 'Futsal',  'Lunes 08:00',  'Menor', '2025-06-13', 'Insertar';
EXEC actividades.GestionarInscriptoClase '31111223', 'Futsal',  'Lunes 14:00',  'Cadete', '2025-06-13', 'Insertar';
EXEC actividades.GestionarInscriptoClase '31111223', 'Taekwondo',  'Miércoles 14:00',  'Cadete', '2025-06-13', 'Insertar';

DELETE FROM facturacion.DetalleFactura
DELETE FROM facturacion.Factura
DELETE FROM facturacion.CuotaMensual

EXEC facturacion.GenerarCuotasMensualesPorFecha '2025-07-21';
GO

EXEC facturacion.GenerarFacturasMensualesPorFechaGrupoFamiliar '2025-07-21';

EXEC facturacion.GenerarFacturasMensualesPorFecha '2025-07-21';
GO

SELECT * FROM actividades.Clase
SELECT * FROM facturacion.CargoClases
SELECT * FROM facturacion.CuotaMensual

SELECT * FROM facturacion.Factura F
INNER JOIN facturacion.CuotaMensual CM ON CM.id_cuota_mensual = F.id_cuota_mensual

SELECT * FROM facturacion.CargoClases
SELECT * FROM facturacion.Factura F
WHERE MONTH(fecha_emision) = MONTH(GETDATE())
SELECT * FROM facturacion.DetalleFactura DF
INNER JOIN facturacion.Factura F ON F.id_factura =DF.id_factura
WHERE MONTH(F.fecha_emision) = MONTH(GETDATE())

SELECT * 
FROM facturacion.vwFacturaTotalGrupoFamiliar
WHERE dni_responsable = '10000000';

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

DELETE FROM cobranzas.PagoACuenta
DELETE FROM cobranzas.Pago
EXEC cobranzas.RegistrarCobranza 1, '2025-08-5', 180000, 'Visa';

SELECT * FROM cobranzas.Pago
SELECT * FROM socios.Socio
SELECT * FROM cobranzas.PagoACuenta

EXEC tarifas.GestionarTarifaPiletaVerano 'Mayor', '0', 25000, '2025-09-25', 'Insertar'

EXEC tarifas.GestionarTarifaPiletaVerano 'Mayor', '1', 30000, '2025-09-25', 'Insertar'

EXEC actividades.GestionarInscriptoPiletaVerano '10000000', NULL, NULL, NULL, NULL, NULL, NULL, '2025-07-15', 'Insertar';

EXEC actividades.GestionarInscriptoPiletaVerano '10000000', '10000001', 'InvitadoVal', 'Gonzalez', 'Mayor', 'InvitadoVal@mail.com', 'Calle Falsa 100', '2025-07-28', 'Insertar';

EXEC facturacion.GenerarFacturasActividadesExtraPorFecha '2025-07-30';
GO

DELETE FROM facturacion.DetalleFactura
WHERE id_factura IN (SELECT id_factura FROM facturacion.Factura WHERE dni_receptor = 10000001)

DELETE FROM facturacion.Factura
WHERE dni_receptor = 10000001 

SELECT * FROM facturacion.CargoActividadExtra
SELECT * FROM facturacion.Factura F
WHERE MONTH(fecha_emision) = MONTH(GETDATE())
SELECT * FROM facturacion.DetalleFactura DF
INNER JOIN facturacion.Factura F ON F.id_factura =DF.id_factura
WHERE MONTH(F.fecha_emision) = MONTH(GETDATE())

DELETE FROM facturacion.DetalleFactura
WHERE id_factura IN (SELECT id_factura FROM facturacion.Factura WHERE fecha_emision = '2025-06-30' )

DELETE FROM facturacion.Factura
WHERE fecha_emision = '2025-06-30' 

SELECT * FROM facturacion.CargoActividadExtra
SELECT * FROM facturacion.Factura F
WHERE MONTH(fecha_emision) = MONTH(GETDATE()) - 1
SELECT * FROM facturacion.DetalleFactura DF
INNER JOIN facturacion.Factura F ON F.id_factura = DF.id_factura
WHERE MONTH(F.fecha_emision) = MONTH(GETDATE()) - 1

EXEC cobranzas.RegistrarCobranza 2, '2025-08-5', 25000, 'Visa';

EXEC cobranzas.AplicarRecargoVencimiento
GO

SELECT *
FROM cobranzas.Mora;

SELECT * FROM socios.Socio

EXEC cobranzas.AplicarBloqueoVencimiento
GO

SELECT * FROM cobranzas.Mora
