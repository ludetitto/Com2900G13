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

/*____________________________________________________________________
  ________________________ GestionarRecargo __________________________
  ____________________________________________________________________*/

IF OBJECT_ID('cobranzas.GestionarRecargo', 'P') IS NOT NULL
    DROP PROCEDURE cobranzas.GestionarRecargo;
GO

CREATE PROCEDURE cobranzas.GestionarRecargo
    @porcentaje		DECIMAL(5,2),
	@descripcion	VARCHAR(50),
	@vigencia				DATE,
    @operacion			 CHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar operación
    IF @operacion NOT IN ('Insertar', 'Modificar', 'Eliminar')
    BEGIN
        RAISERROR('Operación no válida. Debe ser Insertar, Modificar o Eliminar.', 16, 1);
        RETURN;
    END

    -- Validación de la descripción
    IF @descripcion IS NULL OR LTRIM(RTRIM(@descripcion)) = ''
    BEGIN
        RAISERROR('La descripción del recargo no puede ser nulo ni vacío.', 16, 1);
        RETURN;
    END

	 -- Validación de la vigencia
    IF @vigencia IS NULL OR @vigencia < GETDATE()
    BEGIN
        RAISERROR('La vigencia del recargo ingresada es inválida.', 16, 1);
        RETURN;
    END

    -- INSERTAR
    IF @operacion = 'Insertar'
    BEGIN
        IF EXISTS (SELECT 1 FROM facturacion.Recargo WHERE descripcion = @descripcion AND vigencia = @vigencia)
        BEGIN
            RAISERROR('Ya existe un recargo con esa descripción.', 16, 1);
            RETURN;
        END

        INSERT INTO facturacion.Recargo(porcentaje, descripcion, vigencia)
        VALUES (@porcentaje, @descripcion, @vigencia);
    END

    -- MODIFICAR
    IF @operacion = 'Modificar'
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM facturacion.Recargo  WHERE descripcion = @descripcion AND vigencia = @vigencia)
        BEGIN
            RAISERROR('El medio de pago que intenta modificar no existe.', 16, 1);
            RETURN;
        END

        UPDATE facturacion.Recargo
        SET porcentaje = @porcentaje
        WHERE descripcion = @descripcion;

        PRINT 'Recargo modificado correctamente.';
        RETURN;
    END

    -- ELIMINAR
    IF @operacion = 'Eliminar'
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM facturacion.Recargo  WHERE descripcion = @descripcion AND vigencia = @vigencia)
        BEGIN
            RAISERROR('El recargo que intenta eliminar no existe.', 16, 1);
            RETURN;
        END

        DELETE FROM facturacion.Recargo
        WHERE descripcion = @descripcion;

        PRINT 'Recargo eliminado correctamente.';
        RETURN;
    END
END;
GO

/*____________________________________________________________________
  ____________________ AplicarRecargoVencimiento _____________________
  ____________________________________________________________________*/

IF OBJECT_ID('cobranzas.AplicarRecargoVencimiento', 'P') IS NOT NULL
    DROP PROCEDURE cobranzas.AplicarRecargoVencimiento;
GO
CREATE OR ALTER PROCEDURE cobranzas.AplicarRecargoVencimiento
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @recargo DECIMAL(5,2) = 0.10;

    -- Generar mora por recargo si: 
    -- - la factura no fue anulada,
    -- - ya venció (fecha_vencimiento1),
    -- - no fue pagada,
    -- - no existe ya una mora asociada.

    INSERT INTO cobranzas.Mora (id_socio, id_factura, fecha_registro, motivo, facturada, monto)
    SELECT 
        id_socio_final,
        F.id_factura,
        GETDATE(),
        'Recargo por vencimiento de cuota mensual o actividad extra',
        0,
        F.monto_total * @recargo
    FROM facturacion.Factura F
    OUTER APPLY (
        SELECT ICS.id_socio AS id_socio_final
        FROM facturacion.CuotaMensual CM
        JOIN actividades.InscriptoCategoriaSocio ICS ON ICS.id_inscripto_categoria = CM.id_inscripto_categoria
        WHERE F.id_cuota_mensual = CM.id_cuota_mensual

        UNION ALL

        SELECT ICV.id_socio
        FROM facturacion.CargoActividadExtra CAE
        JOIN actividades.InscriptoColoniaVerano ICV ON CAE.id_inscripto_colonia = ICV.id_inscripto_colonia
        WHERE F.id_cargo_actividad_extra = CAE.id_cargo_extra

        UNION ALL

        SELECT IPV.id_socio
        FROM facturacion.CargoActividadExtra CAE
        JOIN actividades.InscriptoPiletaVerano IPV ON CAE.id_inscripto_pileta = IPV.id_inscripto_pileta
        WHERE F.id_cargo_actividad_extra = CAE.id_cargo_extra

        UNION ALL

        SELECT RS.id_socio
        FROM facturacion.CargoActividadExtra CAE
        JOIN reservas.ReservaSum RS ON RS.id_reserva_sum = CAE.id_reserva_sum
        WHERE F.id_cargo_actividad_extra = CAE.id_cargo_extra
    ) AS fuente
    WHERE 
        F.anulada = 0
        AND GETDATE() > F.fecha_vencimiento1 AND GETDATE() < F.fecha_vencimiento2
        AND fuente.id_socio_final IS NOT NULL
        AND NOT EXISTS (
            SELECT 1 FROM cobranzas.Mora M
            WHERE M.id_factura = F.id_factura AND M.id_socio = fuente.id_socio_final
        )
        AND NOT EXISTS (
            SELECT 1 FROM cobranzas.Pago P
            WHERE P.id_factura = F.id_factura
        );

    -- Actualizar saldo de socios a quienes se les generó mora hoy
    UPDATE s
    SET s.saldo = s.saldo - t.total_mora
    FROM socios.Socio s
    INNER JOIN (
        SELECT id_socio, SUM(monto) AS total_mora
        FROM cobranzas.Mora
        WHERE CAST(fecha_registro AS DATE) = CAST(GETDATE() AS DATE)
        GROUP BY id_socio
    ) t ON s.id_socio = t.id_socio;
END;
GO
/*____________________________________________________________________
  ____________________ AplicarBloqueoVencimiento _____________________
  ____________________________________________________________________*/

IF OBJECT_ID('cobranzas.AplicarBloqueoVencimiento', 'P') IS NOT NULL
    DROP PROCEDURE cobranzas.AplicarBloqueoVencimiento;
GO

CREATE OR ALTER PROCEDURE cobranzas.AplicarBloqueoVencimiento
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @hoy DATE = CAST(GETDATE() AS DATE);

    -- Caso 1: Factura vencida de socio responsable
    UPDATE s
    SET s.activo = 0
    FROM socios.Socio s
    INNER JOIN socios.GrupoFamiliarSocio gfs ON s.id_socio = gfs.id_socio
    WHERE gfs.id_grupo IN (
        SELECT gf.id_grupo
        FROM facturacion.Factura f
        JOIN socios.Socio sr ON sr.dni = f.dni_receptor
        JOIN socios.GrupoFamiliar gf ON gf.id_socio_rp = sr.id_socio
        WHERE f.anulada = 0 AND f.fecha_vencimiento2 < @hoy
    )
    AND s.activo = 1;

    -- Caso 2: Factura vencida de tutor
    UPDATE s
    SET s.activo = 0
    FROM socios.Socio s
    INNER JOIN socios.GrupoFamiliarSocio gfs ON s.id_socio = gfs.id_socio
    WHERE gfs.id_grupo IN (
        SELECT t.id_grupo
        FROM facturacion.Factura f
        JOIN socios.Tutor t ON t.dni = f.dni_receptor
        WHERE f.anulada = 0 AND f.fecha_vencimiento2 < @hoy
    )
    AND s.activo = 1;

    -- Caso 3: Factura vencida de socio individual (no tutor, no responsable)
    UPDATE socios.Socio
    SET socios.Socio.activo = 0
    WHERE socios.Socio.activo = 1
    AND socios.Socio.dni IN (
        SELECT f.dni_receptor
        FROM facturacion.Factura f
        WHERE 
            f.anulada = 0
            AND f.fecha_vencimiento2 < @hoy
            AND f.dni_receptor NOT IN (
                SELECT sr.dni
                FROM socios.Socio sr
                JOIN socios.GrupoFamiliar gf ON gf.id_socio_rp = sr.id_socio
            )
            AND f.dni_receptor NOT IN (
                SELECT t.dni FROM socios.Tutor t
            )
    );
END;
GO
/*____________________________________________________________________
  _______________________ ActualizarSaldoPorMora _____________________
  ____________________________________________________________________*/

IF OBJECT_ID('cobranzas.ActualizarSaldoPorMora', 'TR') IS NOT NULL
    DROP TRIGGER cobranzas.ActualizarSaldoPorMora;
GO

CREATE TRIGGER cobranzas.ActualizarSaldoPorMora
ON cobranzas.Mora
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    /* Se actualiza la factura cuyo id_factura está en la tabla inserted (puede ser más de uno)*/
    UPDATE S
    SET S.saldo -= I.monto
    FROM administracion.Socio S
    INNER JOIN inserted I ON S.id_socio = I.id_socio;
=======
    );
>>>>>>> Stashed changes
END;
GO