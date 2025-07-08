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

    BEGIN TRANSACTION;

    BEGIN TRY
        -- Tabla temporal para almacenar los socios que deben ser bloqueados
        CREATE TABLE #SociosABloquear (
            id_socio INT PRIMARY KEY
        );

        -- Paso 1: Identificar a todos los socios activos que deben ser bloqueados
        INSERT INTO #SociosABloquear (id_socio)
        SELECT DISTINCT s.id_socio
        FROM socios.Socio S
        WHERE S.activo = 1 
          AND (
                -- CASO A: El propio DNI del socio es el receptor de una factura vencida
                EXISTS (
                    SELECT 1
                    FROM facturacion.Factura F
                    WHERE F.dni_receptor = S.dni
                      AND F.estado NOT IN ('Paga', 'Anulada')
                      AND F.fecha_vencimiento2 < @hoy -- Factura con segunda fecha de vencimiento pasada
                )
                OR
                -- Caso B: El socio pertenece a un grupo cuyo Socio Responsable tiene una factura vencida
                EXISTS (
                    SELECT 1
                    FROM socios.GrupoFamiliarSocio GFS -- Miembros del grupo
                    JOIN socios.GrupoFamiliar GF ON GFS.id_grupo = GF.id_grupo
                    JOIN socios.Socio S ON GF.id_socio_rp = S.id_socio -- Socio Responsable del grupo
                    JOIN facturacion.Factura F ON F.dni_receptor = S.dni -- Factura a nombre del Socio Responsable
                    WHERE GFS.id_socio = S.id_socio -- Vincula al socio actual 's' con el grupo
                      AND F.estado NOT IN ('Paga', 'Anulada')
                      AND F.fecha_vencimiento2 < @hoy
                )
                OR
                -- Caso C: El socio pertenece a un grupo cuyo Tutor tiene una factura vencida
                EXISTS (
                    SELECT 1
                    FROM socios.GrupoFamiliarSocio GFS -- Miembros del grupo
                    JOIN socios.GrupoFamiliar GF ON GFS.id_grupo = GF.id_grupo
                    JOIN socios.Tutor T ON T.id_grupo = GF.id_grupo -- Tutor del grupo
                    JOIN facturacion.Factura F ON F.dni_receptor = T.dni -- Factura a nombre del Tutor
                    WHERE GFS.id_socio = S.id_socio -- Vincula al socio actual 's' con el grupo
                      AND F.estado NOT IN ('Paga', 'Anulada')
                      AND F.fecha_vencimiento2 < @hoy
                )
              );

        -- Paso 2: Desactivar a los socios identificados en la tabla socios.Socio
        UPDATE S
        SET S.activo = 0
        FROM socios.Socio S
        JOIN #SociosABloquear SB ON S.id_socio = SB.id_socio
        WHERE S.activo = 1;

		-- Paso 3: Desactivar inscripciones de dichos socios
		UPDATE ICS
        SET activo = 0
        FROM actividades.InscriptoCategoriaSocio ICS
        JOIN #SociosABloquear S ON ICS.id_socio = S.id_socio
        WHERE ICS.activo = 1;

        UPDATE IC
        SET activa = 0
        FROM actividades.InscriptoClase IC
        JOIN #SociosABloquear S ON IC.id_socio = S.id_socio
        WHERE IC.activa = 1;

        -- Eliminar la tabla temporal
        DROP TABLE #SociosABloquear;

        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrState INT = ERROR_STATE();
        RAISERROR(@ErrMsg, @ErrSeverity, @ErrState);
    END CATCH
END;
GO