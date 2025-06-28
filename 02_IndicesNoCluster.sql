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
   12_IndicesNoCluster.sql - Índices de mejora
   Con verificación de existencia antes de crear
   ============================================ */

/* ==========================
   ADMINISTRACIÓN
   ========================== */

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes 
    WHERE name = 'IX_Persona_DNI' AND object_id = OBJECT_ID('administracion.Persona')
)
CREATE NONCLUSTERED INDEX IX_Persona_DNI
ON administracion.Persona (dni);
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes 
    WHERE name = 'IX_Socio_idPersona_idCategoria' AND object_id = OBJECT_ID('administracion.Socio')
)
CREATE NONCLUSTERED INDEX IX_Socio_idPersona_idCategoria
ON administracion.Socio (id_persona, id_categoria);
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes 
    WHERE name = 'IX_GrupoFamiliar_idSocio' AND object_id = OBJECT_ID('administracion.GrupoFamiliar')
)
CREATE NONCLUSTERED INDEX IX_GrupoFamiliar_idSocio
ON administracion.GrupoFamiliar (id_socio);
GO


/* ==========================
   FACTURACIÓN
   ========================== */

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes 
    WHERE name = 'IX_Factura_idSocio_Fecha' AND object_id = OBJECT_ID('facturacion.Factura')
)
CREATE NONCLUSTERED INDEX IX_Factura_idSocio_Fecha
ON facturacion.Factura (id_socio, fecha_emision DESC);
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes 
    WHERE name = 'IX_Factura_EstadoVencimiento' AND object_id = OBJECT_ID('facturacion.Factura')
)
CREATE NONCLUSTERED INDEX IX_Factura_EstadoVencimiento
ON facturacion.Factura (estado, fecha_vencimiento1, fecha_vencimiento2);
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
    WHERE name = 'IX_Pago_FacturaMedio' AND object_id = OBJECT_ID('cobranzas.Pago')
)
CREATE NONCLUSTERED INDEX IX_Pago_FacturaMedio
ON cobranzas.Pago (id_factura, id_medio);
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes 
    WHERE name = 'IX_Mora_idFactura' AND object_id = OBJECT_ID('cobranzas.Mora')
)
CREATE NONCLUSTERED INDEX IX_Mora_idFactura
ON cobranzas.Mora (id_factura);
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes 
    WHERE name = 'IX_Notificacion_FechaDestinatario' AND object_id = OBJECT_ID('cobranzas.Notificacion')
)
CREATE NONCLUSTERED INDEX IX_Notificacion_FechaDestinatario
ON cobranzas.Notificacion (fecha, destinatario);
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
    WHERE name = 'IX_PresentismoClase_ClaseFecha' AND object_id = OBJECT_ID('actividades.presentismoClase')
)
CREATE NONCLUSTERED INDEX IX_PresentismoClase_ClaseFecha
ON actividades.presentismoClase (id_clase, fecha);
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes 
    WHERE name = 'IX_InscriptoClase_SocioClase' AND object_id = OBJECT_ID('actividades.InscriptoClase')
)
CREATE NONCLUSTERED INDEX IX_InscriptoClase_SocioClase
ON actividades.InscriptoClase (id_socio, id_clase);
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes 
    WHERE name = 'IX_PresentismoActividadExtra_Socio_Fecha' AND object_id = OBJECT_ID('actividades.presentismoActividadExtra')
)
CREATE NONCLUSTERED INDEX IX_PresentismoActividadExtra_Socio_Fecha
ON actividades.presentismoActividadExtra (id_socio, fecha);
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes 
    WHERE name = 'IX_Clase_ActividadCategoria' AND object_id = OBJECT_ID('actividades.Clase')
)
CREATE NONCLUSTERED INDEX IX_Clase_ActividadCategoria
ON actividades.Clase (id_actividad, id_categoria);
GO
