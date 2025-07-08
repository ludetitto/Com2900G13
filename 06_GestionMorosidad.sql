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

     Consigna: Genere store procedures para manejar la inserción, modificado, borrado (si corresponde,
también debe decidir si determinadas entidades solo admitirán borrado lógico) de cada tabla.
Los nombres de los store procedures NO deben comenzar con “SP”
========================================================================= */
USE COM2900G13
GO

IF OBJECT_ID('cobranzas.AplicarRecargoVencimiento', 'P') IS NOT NULL
    DROP PROCEDURE cobranzas.AplicarRecargoVencimiento;
GO

CREATE PROCEDURE cobranzas.AplicarRecargoVencimiento
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @recargo DECIMAL(5,2) = 0.10;

    -- Crear tabla temporal para capturar moras generadas
    IF OBJECT_ID('tempdb..#MorasGeneradas') IS NOT NULL DROP TABLE #MorasGeneradas;

    CREATE TABLE #MorasGeneradas (
        id_mora INT PRIMARY KEY
    );

    -- Insertar moras y guardar los IDs insertados
    INSERT INTO cobranzas.Mora (id_socio, id_factura, fecha_registro, motivo, facturada, monto)
    OUTPUT INSERTED.id_mora INTO #MorasGeneradas(id_mora)
    SELECT 
        COALESCE(S.id_socio, ICV.id_socio, IPV.id_socio, RS.id_socio),
        F.id_factura,
        DATEADD(DAY, 1, F.fecha_vencimiento1),
        'Recargo por vencimiento de cuota mensual o actividad extra',
        0,
        F.monto_total * @recargo
    FROM facturacion.Factura F
    LEFT JOIN facturacion.CuotaMensual CM ON CM.id_cuota_mensual = F.id_cuota_mensual
    LEFT JOIN actividades.InscriptoCategoriaSocio ICS ON ICS.id_inscripto_categoria = CM.id_inscripto_categoria
    LEFT JOIN socios.Socio S ON ICS.id_socio = S.id_socio

    LEFT JOIN facturacion.CargoActividadExtra CAE ON CAE.id_cargo_extra = F.id_cargo_actividad_extra
    LEFT JOIN actividades.InscriptoColoniaVerano ICV ON ICV.id_inscripto_colonia = CAE.id_inscripto_colonia
    LEFT JOIN actividades.InscriptoPiletaVerano IPV ON IPV.id_inscripto_pileta = CAE.id_inscripto_pileta
    LEFT JOIN reservas.ReservaSum RS ON RS.id_reserva_sum = CAE.id_reserva_sum

    WHERE 
        F.anulada = 0
        AND GETDATE() > F.fecha_vencimiento1
        AND COALESCE(S.id_socio, ICV.id_socio, IPV.id_socio, RS.id_socio) IS NOT NULL
        AND NOT EXISTS (
            SELECT 1 
            FROM cobranzas.Mora M
            WHERE M.id_factura = F.id_factura
              AND M.id_socio = COALESCE(S.id_socio, ICV.id_socio, IPV.id_socio, RS.id_socio)
        );

	-- Actualizar estado de la factura
	UPDATE facturacion.Factura
	SET estado = 'Vencida'
	WHERE anulada = 0 AND GETDATE() > fecha_vencimiento1
END;
GO

/*____________________________________________________________________
  ____________________ AplicarBloqueoVencimiento _____________________
  ____________________________________________________________________*/

IF OBJECT_ID('cobranzas.AplicarBloqueoVencimiento', 'P') IS NOT NULL
    DROP PROCEDURE cobranzas.AplicarBloqueoVencimiento;
GO

CREATE PROCEDURE cobranzas.AplicarBloqueoVencimiento
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @hoy DATE = CAST(GETDATE() AS DATE);

    -- 1. Caso: dni pertenece a un socio responsable
    UPDATE s
    SET s.activo = 0
    FROM socios.Socio s
    INNER JOIN socios.GrupoFamiliarSocio gfs ON gfs.id_socio = s.id_socio
    WHERE gfs.id_grupo IN (
        SELECT gf.id_grupo
        FROM facturacion.Factura f
        JOIN socios.Socio sr ON sr.dni = f.dni_receptor
        JOIN socios.GrupoFamiliar gf ON gf.id_socio_rp = sr.id_socio
        WHERE f.anulada = 0 AND f.fecha_vencimiento2 < @hoy
    )
    AND s.activo = 1;

    -- 2. Caso: dni pertenece a un tutor
    UPDATE s
    SET s.activo = 0
    FROM socios.Socio s
    INNER JOIN socios.GrupoFamiliarSocio gfs ON gfs.id_socio = s.id_socio
    WHERE gfs.id_grupo IN (
        SELECT t.id_grupo
        FROM facturacion.Factura f
        JOIN socios.Tutor t ON t.dni = f.dni_receptor
        WHERE f.anulada = 0 AND f.fecha_vencimiento2 < @hoy
    )
    AND s.activo = 1;

    -- 3. Caso: dni pertenece a un socio individual (no tutor ni responsable)
    UPDATE s
    SET s.activo = 0
    FROM socios.Socio s
    WHERE s.dni IN (
        SELECT f.dni_receptor
        FROM facturacion.Factura f
        WHERE 
            f.anulada = 0 AND f.fecha_vencimiento2 < @hoy
            AND f.dni_receptor NOT IN (
                SELECT sr.dni
                FROM socios.Socio sr
                JOIN socios.GrupoFamiliar gf ON gf.id_socio_rp = sr.id_socio
            )
            AND f.dni_receptor NOT IN (
                SELECT t.dni FROM socios.Tutor t
            )
    )
    AND s.activo = 1;
END;