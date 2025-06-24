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
IF OBJECT_ID('cobranzas.RegistrarCobranza', 'P') IS NOT NULL
    DROP PROCEDURE cobranzas.RegistrarCobranza;
GO

CREATE PROCEDURE cobranzas.RegistrarCobranza
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

--STORE PROCEDURE HABILITAR DEBITO AUTOMATICO

IF OBJECT_ID('cobranzas.HabilitarDebitoAutomatico', 'P') IS NOT NULL
    DROP PROCEDURE cobranzas.HabilitarDebitoAutomatico;
GO

CREATE PROCEDURE cobranzas.HabilitarDebitoAutomatico
    @nombreMedio VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar existencia del medio de pago
    IF NOT EXISTS (
        SELECT 1 FROM cobranzas.MedioDePago WHERE nombre = @nombreMedio
    )
    BEGIN
        RAISERROR('El medio de pago especificado no existe.', 16, 1);
        RETURN;
    END

    -- Actualizar el campo debito_automatico a 1
    UPDATE cobranzas.MedioDePago
    SET debito_automatico = 1
    WHERE nombre = @nombreMedio;

    PRINT 'Débito automático habilitado correctamente para el medio de pago especificado.';
END;
GO

--STORE PROCEDURE DESHABILITAR DEBITO AUTOMATICO

IF OBJECT_ID('cobranzas.DeshabilitarDebitoAutomatico', 'P') IS NOT NULL
    DROP PROCEDURE cobranzas.DeshabilitarDebitoAutomatico;
GO

CREATE PROCEDURE cobranzas.DeshabilitarDebitoAutomatico
    @nombreMedio VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar existencia del medio de pago
    IF NOT EXISTS (
        SELECT 1 FROM cobranzas.MedioDePago WHERE nombre = @nombreMedio
    )
    BEGIN
        RAISERROR('El medio de pago especificado no existe.', 16, 1);
        RETURN;
    END

    -- Actualizar el campo debito_automatico a 0
    UPDATE cobranzas.MedioDePago
    SET debito_automatico = 0
    WHERE nombre = @nombreMedio;

    PRINT 'Débito automático deshabilitado correctamente para el medio de pago especificado.';
END;
GO


-- SP GENERAR REEMBOLSO
IF OBJECT_ID('cobranzas.GenerarReembolso', 'P') IS NOT NULL
    DROP PROCEDURE cobranzas.GenerarReembolso;
GO

CREATE PROCEDURE cobranzas.GenerarReembolso
    @idPago INT,
    @monto DECIMAL(10,2),
    @motivo NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar existencia del pago
        IF NOT EXISTS (
            SELECT 1 FROM cobranzas.Pago WHERE id_pago = @idPago
        )
        BEGIN
            RAISERROR('No existe un pago con el ID especificado.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        DECLARE @idSocio INT = (
            SELECT f.id_socio
            FROM cobranzas.Pago p
            JOIN facturacion.Factura f ON f.id_factura = p.id_factura
            WHERE p.id_pago = @idPago
        );

        -- Insertar nota de crédito (reembolso)
        INSERT INTO cobranzas.NotaDeCredito (
            id_pago, monto, fecha_emision, estado, motivo
        ) VALUES (
            @idPago, @monto, GETDATE(), 'Emitida', @motivo
        );

        -- Aumentar el saldo del socio
        UPDATE administracion.Socio
        SET saldo = saldo + @monto
        WHERE id_socio = @idSocio;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
		IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
		DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
		DECLARE @ErrSeverity INT = ERROR_SEVERITY();
		RAISERROR(@ErrMsg, @ErrSeverity, 1);
	END CATCH
END;
GO


-- SP GENERAR PAGO A CUENTA
IF OBJECT_ID('cobranzas.RegistrarPagoACuenta', 'P') IS NOT NULL
    DROP PROCEDURE cobranzas.RegistrarPagoACuenta;
GO

CREATE PROCEDURE cobranzas.RegistrarPagoACuenta
    @idSocio INT,
    @monto DECIMAL(10,2),
    @fecha DATE,
    @medioPago VARCHAR(50),
    @motivo VARCHAR(100) = 'Pago a cuenta sin factura'
AS
BEGIN
    SET NOCOUNT ON;
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar socio activo
        IF NOT EXISTS (
            SELECT 1 FROM administracion.Socio WHERE id_socio = @idSocio AND activo = 1
        )
        BEGIN
            RAISERROR('El socio no existe o no está activo.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        -- Validar medio de pago
        DECLARE @idMedio INT;
        SELECT @idMedio = id_medio FROM cobranzas.MedioDePago WHERE nombre = @medioPago;

        IF @idMedio IS NULL
        BEGIN
            RAISERROR('Medio de pago inválido o no registrado.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        -- Insertar en tabla Pago (sin factura)
        INSERT INTO cobranzas.Pago (
            id_factura, id_medio, monto, fecha_emision, fecha_vencimiento, estado
        ) VALUES (
            NULL, @idMedio, @monto, GETDATE(), @fecha, 'ACuenta'
        );

        DECLARE @idPagoGenerado INT = SCOPE_IDENTITY();

        -- Insertar en PagoACuenta
        INSERT INTO cobranzas.PagoACuenta (
            id_pago, id_socio, monto, fecha, motivo
        ) VALUES (
            @idPagoGenerado, @idSocio, @monto, @fecha, @motivo
        );

        -- Acreditar monto al saldo del socio
        UPDATE administracion.Socio
        SET saldo = saldo + @monto
        WHERE id_socio = @idSocio;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrSeverity INT = ERROR_SEVERITY();
        RAISERROR(@ErrMsg, @ErrSeverity, 1);
    END CATCH
END;
GO

/*____________________________________________________________________
  _______________________ ActualizarFacturaAPaga _____________________
  ____________________________________________________________________*/

IF OBJECT_ID('cobranzas.ActualizarFacturaAPaga', 'TR') IS NOT NULL
    DROP TRIGGER cobranzas.ActualizarFacturaAPaga;
GO

CREATE TRIGGER cobranzas.ActualizarFacturaAPaga
ON cobranzas.Pago
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    /* Se actualiza la factura cuyo id_factura está en la tabla inserted (puede ser más de uno)*/
    UPDATE F
    SET F.estado = 'Pagada'
    FROM facturacion.Factura f
    INNER JOIN inserted i ON f.id_factura = i.id_factura;
END;
GO

/*____________________________________________________________________
  _______________________ RegistrarNotaDeCredito _____________________
  ____________________________________________________________________*/

IF OBJECT_ID('cobranzas.RegistrarNotaDeCredito', 'P') IS NOT NULL
    DROP PROCEDURE cobranzas.RegistrarNotaDeCredito;
GO

CREATE PROCEDURE cobranzas.RegistrarNotaDeCredito
    @monto DECIMAL(10,2),
    @fecha_emision DATETIME,
    @estado CHAR(20),
    @motivo VARCHAR(100),
    @id_pago INT = NULL -- opcional
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        INSERT INTO cobranzas.NotaDeCredito (
            id_pago, monto, fecha_emision, estado, motivo
        )
        VALUES (
            @id_pago, @monto, @fecha_emision, @estado, @motivo
        );
    END TRY
    BEGIN CATCH
        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrSeverity INT = ERROR_SEVERITY();
        RAISERROR(@ErrMsg, @ErrSeverity, 1);
    END CATCH
END;
GO

/*____________________________________________________________________
  ____________________ RegistrarReintegroPorLluvia ___________________
  ____________________________________________________________________*/

IF OBJECT_ID('cobranzas.RegistrarReintegroPorLluvia', 'P') IS NOT NULL
    DROP PROCEDURE cobranzas.RegistrarReintegroPorLluvia;
GO

CREATE PROCEDURE cobranzas.RegistrarReintegroPorLluvia
    @id_factura INT,
	@id_socio INT,
    @monto DECIMAL(10,2),
    @fecha DATE,
    @medio_pago VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        IF @id_socio <> NULL
        BEGIN
            EXEC cobranzas.RegistrarPagoACuenta
                @idSocio = @id_socio,
                @monto = @monto,
                @fecha = @fecha,
                @medioPago = @medio_pago,
                @motivo = 'Reintegro por lluvia';
        END
        ELSE
        BEGIN
			DECLARE @id_pago INT = (SELECT TOP 1 id_pago 
									FROM cobranzas.Pago 
									WHERE id_factura = @id_Factura)

            EXEC cobranzas.RegistrarNotaDeCredito
                @monto = @monto,
                @fecha_emision = @fecha,
				@estado = 'A cobrar',
                @motivo = 'Reintegro por lluvia',
				@id_pago = @id_pago;
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

/*____________________________________________________________________
  ______________________ GenerarReintegroPorLluvia ___________________
  ____________________________________________________________________*/
IF OBJECT_ID('cobranzas.GenerarReintegroPorLluvia', 'P') IS NOT NULL
    DROP PROCEDURE cobranzas.GenerarReintegroPorLluvia;
GO

CREATE PROCEDURE cobranzas.GenerarReintegroPorLluvia
    @mes VARCHAR(20),
    @año VARCHAR(20),
    @path VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

    BEGIN TRY
        BEGIN TRANSACTION;

        /* Tabla temporal para la condición climática */
        CREATE TABLE #clima (
            fecha VARCHAR(50),
            temperatura DECIMAL(4,2),
            lluvia_mm  DECIMAL(4,2),
            altura INT,
            velocidad_viento DECIMAL(4,2)
        );

        DECLARE @sql NVARCHAR(MAX);
        SET @sql = N'
            BULK INSERT #clima
            FROM ''' + @path + '''
            WITH (
                FIELDTERMINATOR = '','',
                ROWTERMINATOR = ''\n'',
                FIRSTROW = 5,
				CODEPAGE = ''65001''
            );';
        EXEC sp_executesql @sql;

		SELECT * FROM #clima

        /* Tabla variable para las facturas con reintegro */
        DECLARE @Facturas TABLE (
            id_factura INT PRIMARY KEY,
            id_socio INT,
            monto_reintegro DECIMAL(10,2),
            fecha_emision DATE
        );

        /* Insertamos datos a la tabla variable */
        INSERT INTO @Facturas (id_factura, id_socio, monto_reintegro, fecha_emision)
        SELECT 
            F.id_factura,
            F.id_socio,
            ROUND(F.monto_total * 0.6, 2) AS monto_reintegro,
            F.fecha_emision
        FROM facturacion.Factura F
        INNER JOIN (
            SELECT DISTINCT CAST(LEFT(fecha, 10) AS DATE) AS fecha
            FROM #clima
            WHERE lluvia_mm > 0
        ) DiasLluviosos ON F.fecha_emision = DiasLluviosos.fecha
        WHERE F.anulada = 0
          AND F.fecha_emision BETWEEN CAST(@año + '-' + @mes + '-01' AS DATE)
                                  AND EOMONTH(CAST(@año + '-' + @mes + '-01' AS DATE));

        DECLARE @i INT = 1;
        DECLARE @max INT = (SELECT COUNT(*) FROM @Facturas);

        DECLARE @id_factura INT;
        DECLARE @id_socio INT;
        DECLARE @monto_reintegro DECIMAL(10,2);
        DECLARE @fecha_emision DATE;
        DECLARE @medio_pago VARCHAR(50) = 'Sistema'; -- ajustar según corresponda

        WHILE @i <= @max
        BEGIN
            SELECT 
                @id_factura = id_factura,
                @id_socio = id_socio,
                @monto_reintegro = monto_reintegro,
                @fecha_emision = fecha_emision
            FROM (
                SELECT ROW_NUMBER() OVER (ORDER BY id_factura) AS rn, * FROM @Facturas
            ) AS F
            WHERE rn = @i;

            BEGIN TRY
                EXEC cobranzas.RegistrarReintegroPorLluvia 
                    @id_factura = @id_factura,
                    @id_socio = @id_socio,
                    @monto = @monto_reintegro,
                    @fecha = @fecha_emision,
                    @medio_pago = @medio_pago;
            END TRY
            BEGIN CATCH
                -- Opcional: manejar error individual y seguir con el próximo
                PRINT 'Error al registrar reintegro para factura ' + CAST(@id_factura AS VARCHAR);
            END CATCH

            SET @i = @i + 1;
        END

        DROP TABLE #clima;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
