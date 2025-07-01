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

   Objetivo: Optimización.
   ========================================================================= */

USE COM2900G13;
GO

/* ============================================
   INDICES - Optimización de Consultas y Claves
   Grupo 13 - COM2900G13
   ============================================ */

USE COM2900G13;
GO

/* ==========================
   SOCIOS
   ========================== */

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes 
    WHERE name = 'IX_Socio_DNI' AND object_id = OBJECT_ID('socios.Socio')
)
CREATE NONCLUSTERED INDEX IX_Socio_DNI
ON socios.Socio (dni);
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes 
    WHERE name = 'IX_Socio_NombreApellido' AND object_id = OBJECT_ID('socios.Socio')
)
CREATE NONCLUSTERED INDEX IX_Socio_NombreApellido
ON socios.Socio (apellido, nombre);
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes 
    WHERE name = 'IX_GrupoFamiliarSocio' AND object_id = OBJECT_ID('socios.GrupoFamiliarSocio')
)
CREATE NONCLUSTERED INDEX IX_GrupoFamiliarSocio
ON socios.GrupoFamiliarSocio (id_grupo, id_socio);
GO

/* ==========================
   FACTURACIÓN
   ========================== */

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes 
    WHERE name = 'IX_Factura_CargoCuota' AND object_id = OBJECT_ID('facturacion.Factura')
)
CREATE NONCLUSTERED INDEX IX_Factura_CargoCuota
ON facturacion.Factura (id_cargo_actividad_extra, id_cuota_mensual);
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes 
    WHERE name = 'IX_Factura_EstadoFecha' AND object_id = OBJECT_ID('facturacion.Factura')
)
CREATE NONCLUSTERED INDEX IX_Factura_EstadoFecha
ON facturacion.Factura (estado, fecha_emision DESC);
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes 
    WHERE name = 'IX_DetalleFactura_idFactura' AND object_id = OBJECT_ID('facturacion.DetalleFactura')
)
CREATE NONCLUSTERED INDEX IX_DetalleFactura_idFactura
ON facturacion.DetalleFactura (id_factura);
GO

/* ==========================
   COBRANZAS
   ========================== */

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes 
    WHERE name = 'IX_Pago_FacturaEstado' AND object_id = OBJECT_ID('cobranzas.Pago')
)
CREATE NONCLUSTERED INDEX IX_Pago_FacturaEstado
ON cobranzas.Pago (id_factura, estado);
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes 
    WHERE name = 'IX_Mora_SocioFactura' AND object_id = OBJECT_ID('cobranzas.Mora')
)
CREATE NONCLUSTERED INDEX IX_Mora_SocioFactura
ON cobranzas.Mora (id_socio, id_factura);
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes 
    WHERE name = 'IX_PagoACuenta_SocioFecha' AND object_id = OBJECT_ID('cobranzas.PagoACuenta')
)
CREATE NONCLUSTERED INDEX IX_PagoACuenta_SocioFecha
ON cobranzas.PagoACuenta (id_socio, fecha);
GO

/* ==========================
   ACTIVIDADES
   ========================== */

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes 
    WHERE name = 'IX_Actividad_Nombre' AND object_id = OBJECT_ID('actividades.Actividad')
)
CREATE NONCLUSTERED INDEX IX_Actividad_Nombre
ON actividades.Actividad (nombre);
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes 
    WHERE name = 'IX_Clase_ActividadCategoria' AND object_id = OBJECT_ID('actividades.Clase')
)
CREATE NONCLUSTERED INDEX IX_Clase_ActividadCategoria
ON actividades.Clase (id_actividad, id_categoria);
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes 
    WHERE name = 'IX_InscriptoClase_Socio' AND object_id = OBJECT_ID('actividades.InscriptoClase')
)
CREATE NONCLUSTERED INDEX IX_InscriptoClase_Socio
ON actividades.InscriptoClase (id_socio);
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes 
    WHERE name = 'IX_PresentismoClase_ClaseFecha' AND object_id = OBJECT_ID('actividades.PresentismoClase')
)
CREATE NONCLUSTERED INDEX IX_PresentismoClase_ClaseFecha
ON actividades.PresentismoClase (id_clase, fecha);
GO

/* ==========================
   TARIFAS & RESERVAS
   ========================== */

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes 
    WHERE name = 'IX_ReservaSum_SocioFecha' AND object_id = OBJECT_ID('reservas.ReservaSum')
)
CREATE NONCLUSTERED INDEX IX_ReservaSum_SocioFecha
ON reservas.ReservaSum (id_socio, fecha);
GO
