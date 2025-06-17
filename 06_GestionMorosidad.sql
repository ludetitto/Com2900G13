/* =========================================================================
   Trabajo Práctico Integrador - Bases de Datos Aplicadas
   Grupo N°: 13
   Comisión: 2900
   Fecha de Entrega: 17/06/2025
   Materia: Bases de Datos Aplicadas
   Alumnos: Vignardel Francisco 45778667
            De Titto Lucia		46501934
			Borja Tomas			42353302

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
	@descripcion_recargo VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @porcentaje_recargo DECIMAL(5, 2);
	DECLARE @id_mora INT;

    -- Obtener el porcentaje del recargo
    SELECT @porcentaje_recargo = porcentaje
    FROM facturacion.Recargo
    WHERE descripcion = @descripcion_recargo
      AND vigencia > GETDATE();

    -- Verificar si se encontró el recargo
    IF @porcentaje_recargo IS NULL
    BEGIN
        RAISERROR('No se encontró un recargo válido con la descripción proporcionada.', 16, 1);
		RETURN;
    END

	/*Genera la mora a cobrar al mes siguiente*/
	INSERT INTO cobranzas.Mora (id_socio, id_factura, facturada, monto)
	SELECT
		id_socio,
		id_factura,
		0,
		monto_total * @porcentaje_recargo
	FROM facturacion.Factura
	WHERE fecha_vencimiento1 < CAST(GETDATE() AS DATE)
	AND id_socio IS NOT NULL

	SET @id_mora = SCOPE_IDENTITY();

	/*Se actualiza saldo del socio a partir de la mora*/
	UPDATE administracion.Socio
	SET saldo = - (SELECT F.monto_total * @porcentaje_recargo 
				   FROM cobranzas.Mora M
				   INNER JOIN facturacion.Factura F ON F.id_factura = M.id_factura
				   WHERE M.id_mora = @id_mora)
	WHERE id_socio IN (SELECT id_socio FROM cobranzas.Mora WHERE id_mora = @id_mora)

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
	
	/*Tabla temporal para guardar los socios a bloquear*/
    DECLARE @socios_a_bloquear TABLE (id_socio INT);

    /*Insertamos los socios con facturas vencidas y sin pago*/
    INSERT INTO @socios_a_bloquear (id_socio)
    SELECT DISTINCT S.id_socio
    FROM facturacion.Factura F
    INNER JOIN administracion.Socio S ON S.id_socio = F.id_socio
    WHERE F.fecha_vencimiento2 < GETDATE() -- vencidas, no futuras
      AND F.id_factura NOT IN (
            SELECT id_factura
            FROM cobranzas.Pago
        );

    /*Cambiamos estado de socio a inactivo*/
    UPDATE S
    SET activo = 0
    FROM administracion.Socio S
    INNER JOIN @socios_a_bloquear B ON S.id_socio = B.id_socio;

    /*Insertamos notificaciones*/
    INSERT INTO cobranzas.Notificacion (id_mora, mensaje, fecha, destinatario)
    SELECT 
        M.id_mora,
        'Usted ha sido suspendido de sus actividades y acceso al club por falta de pago.',
        GETDATE(),
        P.email
    FROM cobranzas.Mora M
    INNER JOIN @socios_a_bloquear B ON M.id_socio = B.id_socio
    INNER JOIN administracion.Socio S ON S.id_socio = M.id_socio
	INNER JOIN administracion.Persona P ON P.id_persona = S.id_persona
	WHERE M.facturada = 0;
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