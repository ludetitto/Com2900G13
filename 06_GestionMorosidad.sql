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

CREATE PROCEDURE cobranzas.AplicarRecargoVencimiento
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @recargo DECIMAL(5,2) = 0.10;

    -- 1. Si el dni pertenece a un socio activo → aplicar mora directa
    INSERT INTO cobranzas.Mora (id_socio, id_factura, fecha_registro, motivo, facturada, monto)
    SELECT 
        s.id_socio,
        f.id_factura,
        GETDATE(),
        'Recargo por vencimiento (socio individual)',
        0,
        f.monto_total * @recargo
    FROM facturacion.Factura f
    INNER JOIN socios.Socio s ON s.dni = f.dni_receptor
    WHERE 
        f.anulada = 0
        AND GETDATE() > f.fecha_vencimiento1
        AND s.activo = 1
        AND NOT EXISTS (
            SELECT 1 
            FROM cobranzas.Mora m 
            WHERE m.id_factura = f.id_factura AND m.id_socio = s.id_socio
        );

    -- 2. Si el dni pertenece a un tutor → aplicar mora a todos los socios del grupo
    INSERT INTO cobranzas.Mora (id_socio, id_factura, fecha_registro, motivo, facturada, monto)
    SELECT 
        s.id_socio,
        f.id_factura,
        GETDATE(),
        'Recargo por vencimiento (grupo de tutor)',
        0,
        f.monto_total * @recargo
    FROM facturacion.Factura f
    INNER JOIN socios.Tutor t ON t.dni = f.dni_receptor
    INNER JOIN socios.GrupoFamiliar gf ON gf.id_grupo = t.id_grupo
    INNER JOIN socios.Socio s ON s.id_socio != gf.id_socio_rp -- evitar duplicar mora si ya se aplicó al responsable
    WHERE 
        f.anulada = 0
        AND GETDATE() > f.fecha_vencimiento1
        AND s.activo = 1
        AND NOT EXISTS (
            SELECT 1 
            FROM cobranzas.Mora m 
            WHERE m.id_factura = f.id_factura AND m.id_socio = s.id_socio
        );

    -- 3. Si el dni pertenece al socio responsable de un grupo → aplicar mora a los demás miembros del grupo
    INSERT INTO cobranzas.Mora (id_socio, id_factura, fecha_registro, motivo, facturada, monto)
    SELECT 
        s.id_socio,
        f.id_factura,
        GETDATE(),
        'Recargo por vencimiento (grupo de socio responsable)',
        0,
        f.monto_total * @recargo
    FROM facturacion.Factura f
    INNER JOIN socios.Socio srp ON srp.dni = f.dni_receptor
    INNER JOIN socios.GrupoFamiliar gf ON gf.id_socio_rp = srp.id_socio
    INNER JOIN socios.Socio s ON s.id_socio != srp.id_socio
    WHERE 
        f.anulada = 0
        AND GETDATE() > f.fecha_vencimiento1
        AND srp.activo = 1
        AND s.activo = 1
        AND NOT EXISTS (
            SELECT 1 
            FROM cobranzas.Mora m 
            WHERE m.id_factura = f.id_factura AND m.id_socio = s.id_socio
        );

    -- 4. Actualizar saldos de los socios a quienes se les generó mora hoy
    UPDATE s
    SET s.saldo = s.saldo + t.total_mora
    FROM socios.Socio s
    INNER JOIN (
        SELECT id_socio, SUM(monto) AS total_mora
        FROM cobranzas.Mora
        WHERE fecha_registro = CAST(GETDATE() AS DATE)
        GROUP BY id_socio
    ) t ON t.id_socio = s.id_socio;
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
END;
GO