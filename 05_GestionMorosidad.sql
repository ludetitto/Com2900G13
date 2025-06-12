/* =========================================================================
   Trabajo Práctico Integrador - Bases de Datos Aplicadas
   Grupo N°: 13
   Comisión: 2900
   Fecha de Entrega: 17/06/2025
   Materia: Bases de Datos Aplicadas
   Alumnos: Vignardel Francisco 45778667
            De Titto Lucia 46501934
========================================================================= */
USE COM2900G13
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

    -- Obtener el porcentaje del recargo
    SELECT @porcentaje_recargo = porcentaje
    FROM facturacion.Recargo
    WHERE descripcion = @descripcion_recargo
      AND vigencia > GETDATE();

    -- Verificar si se encontró el recargo
    IF @porcentaje_recargo IS NOT NULL
    BEGIN
        UPDATE facturacion.Factura
        SET monto_total = monto_total * (1 + @porcentaje_recargo)
        WHERE anulada = 0 
        AND id_factura IN (SELECT F.id_factura
						   FROM facturacion.Factura F
						   INNER JOIN facturacion.DetalleFactura D ON D.id_factura = F.id_factura
						   WHERE D.tipo_item <> 'Actividad Extra'
						   AND F.fecha_vencimiento1 < GETDATE() 
						   AND F.fecha_vencimiento2 > GETDATE()
						   );
    END
    ELSE
    BEGIN
        RAISERROR('No se encontró un recargo válido con la descripción proporcionada.', 16, 1);
    END

	/*Genera la mora a cobrar al mes siguiente*/
	INSERT INTO cobranzas.Mora (id_socio, id_factura, facturada, monto)
	SELECT
		id_socio,
		id_factura,
		0,
		monto_total * @porcentaje_recargo AS monto
	FROM facturacion.Factura
	WHERE fecha_vencimiento1 < CAST(GETDATE() AS DATE)

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
    DECLARE @SociosABloquear TABLE (id_socio INT);

    /*Insertamos los socios con facturas vencidas y sin pago*/
    INSERT INTO @SociosABloquear (id_socio)
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
    INNER JOIN @SociosABloquear B ON S.id_socio = B.id_socio;

    /*Insertamos notificaciones*/
    INSERT INTO cobranzas.Notificacion (id_mora, mensaje, fecha, destinatario)
    SELECT 
        M.id_mora,
        'Usted ha sido suspendido de sus actividades y acceso al club por falta de pago.',
        GETDATE(),
        P.email
    FROM cobranzas.Mora M
    INNER JOIN @SociosABloquear B ON M.id_socio = B.id_socio
    INNER JOIN administracion.Socio S ON S.id_socio = M.id_socio
	INNER JOIN administracion.Persona P ON P.id_persona = S.id_persona;
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