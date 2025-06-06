/* =========================================================================
   Trabajo Práctico Integrador - Bases de Datos Aplicadas
   Grupo N°: 13
   Comisión: 2900
   Fecha de Entrega: 17/06/2025
   Materia: Bases de Datos Aplicadas
   Alumnos: Vignardel Francisco 45778667
            De Titto Lucia 46501934
            Benvenuto Franco 44760004
========================================================================= */
USE COM2900G13
IF OBJECT_ID('cobranzas.spRegistrarCobranza', 'P') IS NOT NULL
    DROP PROCEDURE cobranzas.spRegistrarCobranza;
GO

CREATE PROCEDURE cobranzas.spRegistrarCobranza
    @idSocio INT,
    @monto DECIMAL(10, 2),
    @fecha DATE,
    @medioPago VARCHAR(50),
    @idActividadExtra INT = NULL,  -- parámetro opcional
    @idFactura INT                 -- parámetro obligatorio
AS
BEGIN
    SET NOCOUNT ON;
    SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validación del medio de pago no permitido
        IF @medioPago IN ('Efectivo', 'Cheque')
        BEGIN
            RAISERROR('No se aceptan pagos en Efectivo ni Cheque.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        -- Validación del medio de pago registrado
        DECLARE @idMedioPago INT;
        SELECT @idMedioPago = id_medio 
        FROM cobranzas.MedioDePago 
        WHERE nombre = @medioPago;

        IF @idMedioPago IS NULL
        BEGIN
            RAISERROR('Medio de pago no válido. Debe ser uno registrado.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        -- Validación del socio
        IF NOT EXISTS (
            SELECT 1 FROM administracion.Socio 
            WHERE id_socio = @idSocio AND activo = 1
        )
        BEGIN
            RAISERROR('El socio especificado no existe o no está activo.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        -- Validación de la actividad extra (opcional)
        IF @idActividadExtra IS NOT NULL AND NOT EXISTS (
            SELECT 1 
            FROM actividades.ActividadExtra 
            WHERE id_extra = @idActividadExtra
        )
        BEGIN
            RAISERROR('La actividad extra especificada no existe.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        -- Validar existencia de factura válida asociada al socio
        IF NOT EXISTS (
            SELECT 1 
            FROM facturacion.Factura 
            WHERE id_factura = @idFactura 
              AND id_socio = @idSocio 
              AND anulada = 0
        )
        BEGIN
            RAISERROR('La factura no existe, no pertenece al socio o está anulada.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        -- Insertar el pago
        INSERT INTO cobranzas.Pago (
            id_factura,
            id_medio,
            monto,
            fecha_emision,
            fecha_vencimiento,
            estado
        )
        VALUES (
            @idFactura,
            @idMedioPago,
            @monto,
            GETDATE(),
            @fecha,
            'Pagado'
        );

        -- Actualizar el saldo del socio
        UPDATE administracion.Socio
        SET saldo = saldo - @monto
        WHERE id_socio = @idSocio;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrSeverity INT = ERROR_SEVERITY();
        RAISERROR(@ErrMsg, @ErrSeverity, 1);
    END CATCH
END;
GO
