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

-- Eliminar si ya existe
IF OBJECT_ID('pagos.spRegistrarCobranza', 'P') IS NOT NULL
    DROP PROCEDURE pagos.spRegistrarCobranza;
GO

CREATE PROCEDURE pagos.spRegistrarCobranza
    @idCobranza INT,
    @idSocio INT,
    @monto DECIMAL(10, 2),
    @fecha DATETIME,
    @medioPago VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF @medioPago NOT IN (
            'Visa', 'MasterCard', 'Tarjeta',
            'Naranja', 'Pago Fácil', 'Rapipago',
            'Transferencia Mercado Pago'
        )
        BEGIN
            RAISERROR('Medio de pago no permitido. Solo se aceptan tarjetas o medios digitales.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        INSERT INTO pagos.Pago (id_pago, id_socio, id_medio, id_actividad, fecha, monto, detalle)
        VALUES (@idCobranza, @idSocio, NULL, NULL, @fecha, @monto, @medioPago);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        DECLARE @ErrMsg VARCHAR(4000), @ErrSeverity INT;
        SELECT @ErrMsg = ERROR_MESSAGE(), @ErrSeverity = ERROR_SEVERITY();
        RAISERROR(@ErrMsg, @ErrSeverity, 1);
    END CATCH
END;
GO