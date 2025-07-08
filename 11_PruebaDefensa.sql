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

/*	_______________________________________________
	______________ Gestión de Socios ______________
	_______________________________________________ */

-- Inserción de categorias
-- OPCIONAL: Solo si es la primera carga de datos
EXEC socios.GestionarCategoriaSocio 'Menor', 0, 12, 10000.00, '2025-12-31', 'Insertar';
EXEC socios.GestionarCategoriaSocio 'Cadete', 13, 17, 15000.00, '2025-12-31', 'Insertar';
EXEC socios.GestionarCategoriaSocio 'Mayor', 18, 99, 25000.00, '2025-12-31', 'Insertar';

SELECT * FROM socios.CategoriaSocio;
GO

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
SELECT * FROM socios.GrupoFamiliar ORDER BY id_grupo;
SELECT * FROM socios.GrupoFamiliarSocio ORDER BY id_grupo, id_socio;
SELECT * FROM socios.Tutor ORDER BY id_grupo;
GO

-- Faltan casos:
-- 1. Tutor
-- 2. Socio solo
-- 3. Dar de baja, dar de alta, aunq conviene hacerlo mas adelante

/*	____________________________________________________
	______________ Gestión de Actividades ______________
	____________________________________________________ */

-- Inserción de actividades base (sin horarios)
-- OPCIONAL: Solo si es la primera carga de datos
EXEC actividades.GestionarActividad 'Futsal', 25000, '2025-05-31', 'Insertar';
EXEC actividades.GestionarActividad 'Vóley', 30000, '2025-05-31', 'Insertar';
EXEC actividades.GestionarActividad 'Taekwondo', 25000, '2025-05-31', 'Insertar';
EXEC actividades.GestionarActividad 'Baile artístico', 30000, '2025-05-31', 'Insertar';
EXEC actividades.GestionarActividad 'Natación', 45000, '2025-05-31', 'Insertar';
EXEC actividades.GestionarActividad 'Ajedrez', 2000, '2025-05-31', 'Insertar';
GO

SELECT* FROM actividades.Actividad;

-- Inserción de clases
-- OPCIONAL: Solo si es la primera carga de datos

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

-- Inserción de inscripciones
EXEC actividades.GestionarInscriptoClase '10000000', 'Futsal',  'Lunes 19:00',  'Mayor', '2025-05-13', 'Insertar';
EXEC actividades.GestionarInscriptoClase '31111225', 'Taekwondo',  'Miércoles 14:00',  'Cadete', '2025-05-13', 'Insertar';
EXEC actividades.GestionarInscriptoClase '31111224', 'Futsal',  'Lunes 08:00',  'Menor', '2025-05-13', 'Insertar';
EXEC actividades.GestionarInscriptoClase '31111223', 'Futsal',  'Lunes 14:00',  'Cadete', '2025-05-13', 'Insertar';
EXEC actividades.GestionarInscriptoClase '31111223', 'Taekwondo',  'Miércoles 14:00',  'Cadete', '2025-05-13', 'Insertar';

SELECT * FROM actividades.InscriptoClase;

/*	________________________________________________________________
	______________ Gestión de Facturación y Cobranzas ______________
	________________________________________________________________ */

-- Inserción de emisor factura
EXEC facturacion.GestionarEmisorFactura 'Sol del Norte S.A.', '20-12345678-4', 'Av. Presidente Per�n 1234', 'Argentina', 'La Matanza', '1234', 'Insertar';

-- Inserción de medios de pago
EXEC cobranzas.GestionarMedioDePago 'Tarjeta de débito', 'Insertar';
EXEC cobranzas.GestionarMedioDePago 'Visa', 'Insertar';
EXEC cobranzas.GestionarMedioDePago 'MasterCard', 'Insertar';
EXEC cobranzas.GestionarMedioDePago 'Tarjeta Naranja', 'Insertar';
EXEC cobranzas.GestionarMedioDePago 'Pago Fácil', 'Insertar'
EXEC cobranzas.GestionarMedioDePago 'Rapipago', 'Insertar';
EXEC cobranzas.GestionarMedioDePago 'Transferencia Mercado Pago', 'Insertar';
GO

SELECT * FROM cobranzas.MedioDePago;

-- CASO 1: Factura abonada con medio de pago Visa
-- Generación de cuotas; solo socios individuales
EXEC facturacion.GenerarCuotasMensualesPorFecha '2025-07-21'
GO

SELECT * FROM actividades.Clase;
SELECT * FROM facturacion.CargoClases;
SELECT * FROM actividades.InscriptoClase;
SELECT * FROM facturacion.CargoClases;
SELECT * FROM facturacion.CuotaMensual;

-- Generación de facturas grupales
EXEC facturacion.GenerarFacturasMensualesPorFechaGrupoFamiliar '2025-07-21';
GO

-- Generación de facturas individuales
EXEC facturacion.GenerarFacturasMensualesPorFecha '2025-07-21';
GO

-- Se testea con el grupo familiar del responsable SN-4005 con socio a cargo SN-4144
SELECT 
    nombre_responsable,
    nro_comprobante,
    monto_total,
    fecha_emision,
    fecha_vencimiento1,
    estado_calculado 
FROM 
    facturacion.vwFacturasPendientesPorGrupoFamiliar
WHERE 
    dni_responsable = '10000000';

-- Vista de factura total al mes actual del grupo familiar indicado
SELECT * 
FROM facturacion.vwFacturaTotalGrupoFamiliar
WHERE dni_responsable = 292632869;

-- Registrar pago a la cuota del mes de julio del repsonsable 292632869
-- IMPORTANTE: Revisar numero de factura antes de ejecutar
EXEC cobranzas.RegistrarCobranza 245, '2025-08-01', 112000, 'Visa';

SELECT 
    nombre_responsable,
    nro_comprobante,
    monto_total,
    fecha_emision,
    fecha_vencimiento1,
    estado_calculado 
FROM 
    facturacion.vwFacturasPendientesPorGrupoFamiliar
WHERE 
    dni_responsable = '10000000';

SELECT * FROM cobranzas.Pago
SELECT * FROM socios.Socio WHERE dni = 292632869

-- CASO 2: Factura abonada con medio de pago débito automático
-- Generación de cuotas; solo socios individuales
EXEC facturacion.GenerarCuotasMensualesPorFecha '2025-08-21'
GO

-- Generación de facturas grupales
EXEC facturacion.GenerarFacturasMensualesPorFechaGrupoFamiliar '2025-08-21';
GO

-- Generación de facturas individuales
EXEC facturacion.GenerarFacturasMensualesPorFecha '2025-08-21';
GO

-- Se testea con el grupo familiar del responsable SN-4005 con socio a cargo SN-4144
SELECT 
    nombre_responsable,
    nro_comprobante,
    monto_total,
    fecha_emision,
    fecha_vencimiento1,
    estado_calculado 
FROM 
    facturacion.vwFacturasPendientesPorGrupoFamiliar
WHERE 
    dni_responsable = '10000000';

-- Inserción de tarjeta de crédito para débito automático
EXEC cobranzas.GestionarTarjeta
    @nro_socio = 'SN-4155',
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
-- IMPORTANTE: Se ejecuta al mes siguiente de las facturas generadas ya que
-- se rige por la 1ra fecha de vencimiento
EXEC cobranzas.EjecutarDebitoAutomatico '2025-09-04';
GO

SELECT * FROM cobranzas.MedioDePago;

-- Se testea con el grupo familiar del responsable SN-4155 con socios a cargo SN-4156, SN-4157 y SN-4158
SELECT 
    nombre_responsable,
    nro_comprobante,
    monto_total,
    fecha_emision,
    fecha_vencimiento1,
    estado_calculado 
FROM 
    facturacion.vwFacturasPendientesPorGrupoFamiliar
WHERE 
    dni_responsable = '10000000';

SELECT id_pago, id_factura, nro_transaccion, monto, estado, fecha_emision
FROM cobranzas.Pago
ORDER BY id_pago DESC;

/*	____________________________________________________
	______________ Gestión de Morosidad ________________
	____________________________________________________ */

-- Generación de cuotas; solo socios individuales
EXEC facturacion.GenerarCuotasMensualesPorFecha '2025-05-21';
GO

SELECT * FROM facturacion.CuotaMensual;

-- Generación de facturas grupales (vencidas)
EXEC facturacion.GenerarFacturasMensualesPorFechaGrupoFamiliar '2025-05-21';
GO

SELECT 
    nombre_responsable,
    nro_comprobante,
    monto_total,
    fecha_emision,
    fecha_vencimiento1,
    estado_calculado 
FROM 
    facturacion.vwFacturasPendientesPorGrupoFamiliar
WHERE 
    dni_responsable = '10000000';

-- Aplicación del recargo en caso de superar la 1ra fecha de vencimiento
EXEC cobranzas.AplicarRecargoVencimiento
GO

SELECT * FROM cobranzas.Mora;
SELECT * FROM facturacion.Factura;
SELECT * FROM socios.Socio;

-- CASO: Se genera cuota y factura del mes siguiente a la mora para asegurar cobro de la misma
-- Generación de cuotas; solo socios individuales
EXEC facturacion.GenerarCuotasMensualesPorFecha '2025-06-21';
GO

SELECT * FROM facturacion.CuotaMensual;

-- Generación de facturas grupales (vencidas)
EXEC facturacion.GenerarFacturasMensualesPorFechaGrupoFamiliar '2025-06-21';
GO

SELECT 
    nombre_responsable,
    nro_comprobante,
    monto_total,
    fecha_emision,
    fecha_vencimiento1,
    estado_calculado 
FROM 
    facturacion.vwFacturasPendientesPorGrupoFamiliar
WHERE 
    dni_responsable = '10000000';

-- Registrar pago a la cuota del mes de julio del repsonsable 292632869
-- IMPORTANTE: Revisar numero de factura antes de ejecutar
EXEC cobranzas.RegistrarCobranza 605, '2025-07-01', 140000, 'MasterCard';


-- CASO: Se generan inscripciones a actividades extra en una fecha en el que hubieron lluvias
-- Inserción de tarifas de pileta de verano
EXEC tarifas.GestionarTarifaPiletaVerano 'Mayor', '0', 25000, '2025-09-25', 'Insertar'
EXEC tarifas.GestionarTarifaPiletaVerano 'Mayor', '1', 30000, '2025-09-25', 'Insertar'
GO

EXEC actividades.GestionarInscriptoPiletaVerano 292632869, NULL, NULL, NULL, NULL, NULL, NULL, '2025-02-15', 'Insertar';
EXEC actividades.GestionarInscriptoPiletaVerano 292632869, 12345678, 'InvitadoVal', 'Gonzalez', 'Mayor', 'InvitadoVal@mail.com', 'Calle Falsa 100', '2025-02-28', 'Insertar';
GO

EXEC facturacion.GenerarFacturasActividadesExtraPorFecha '2025-02-15';
EXEC facturacion.GenerarFacturasActividadesExtraPorFecha '2025-02-28';
GO

SELECT 
    nombre_responsable,
    nro_comprobante,
    monto_total,
    fecha_emision,
    fecha_vencimiento1,
    estado_calculado 
FROM 
    facturacion.vwFacturasPendientesPorGrupoFamiliar
WHERE 
    dni_responsable = '292632869';

EXEC cobranzas.RegistrarCobranza 49211465, '2025-02-15', 33000, 'Visa';
EXEC cobranzas.RegistrarCobranza 24567535, '2025-02-28', 30000, 'Visa';

SELECT * FROM facturacion.Factura where id_factura = 4
SELECT nombre, apellido, saldo FROM socios.Socio where dni = 10000000    

-- Generar reintegros por lluvia
EXEC cobranzas.GenerarReintegroPorLluvia
    @mes = 02,
    @año = 2025,
    @path = 'C:\Users\ldeti\Desktop\College\BDA\TP BDA\Com2900G13\ETL\open-meteo-buenosaires_2025.csv';
GO

SELECT 
    nombre_responsable,
    nro_comprobante,
    monto_total,
    fecha_emision,
    fecha_vencimiento1,
    estado_calculado 
FROM 
    facturacion.vwFacturasPendientesPorGrupoFamiliar
WHERE 
    dni_responsable = '292632869';

SELECT * FROM cobranzas.Reembolso
SELECT * FROM cobranzas.PagoACuenta;
SELECT * FROM socios.vwGrupoFamiliarConCategorias ORDER BY apellido, nombre;

-- Dar de baja al socio 10000000
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
	@dni_nuevo_rp = '292632869',
    @operacion = 'Eliminar';
GO

SELECT * FROM socios.Socio;
SELECT * FROM socios.GrupoFamiliar;
SELECT * FROM socios.GrupoFamiliarSocio;
SELECT * FROM facturacion.Factura;

-- Dar de alta a socio 10000000
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
	@dni_integrante_grupo = '31111223',
    @operacion = 'Insertar';
GO

SELECT * FROM socios.Socio;
SELECT * FROM socios.GrupoFamiliar;
SELECT * FROM socios.GrupoFamiliarSocio;
SELECT * FROM facturacion.Factura;

-- Generación de cuotas; solo socios individuales
EXEC facturacion.GenerarCuotasMensualesPorFecha '2025-04-21'
GO

-- Generación de facturas grupales
EXEC facturacion.GenerarFacturasMensualesPorFechaGrupoFamiliar '2025-04-21';
GO

-- Aplicación del bloqueo en caso de superar la 2da fecha de vencimiento
EXEC cobranzas.AplicarBloqueoVencimiento
GO

SELECT * FROM actividades.InscriptoCategoriaSocio;
SELECT * FROM actividades.InscriptoClase;
SELECT * FROM socios.Socio;
