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
  _________________________ GestionarMedioDePago ________________________
  ____________________________________________________________________*/
IF OBJECT_ID('cobranzas.GestionarMedioDePago', 'P') IS NOT NULL
    DROP PROCEDURE cobranzas.GestionarMedioDePago;
GO

CREATE PROCEDURE cobranzas.GestionarMedioDePago
    @nombre VARCHAR(50),
    @operacion VARCHAR(10) -- 'Insertar' o 'Eliminar'
AS
BEGIN
    SET NOCOUNT ON;
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

    BEGIN TRY
        BEGIN TRAN;

        IF @operacion = 'Insertar'
        BEGIN
            IF EXISTS (SELECT id_medio_pago FROM cobranzas.MedioDePago WHERE nombre = @nombre)
            BEGIN
                RAISERROR('Ya existe un medio de pago con ese nombre.', 16, 1);
                ROLLBACK;
                RETURN;
            END

            INSERT INTO cobranzas.MedioDePago (nombre)
            VALUES (@nombre);
        END

        ELSE IF @operacion = 'Eliminar'
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM cobranzas.MedioDePago WHERE nombre = @nombre)
            BEGIN
                RAISERROR('No se encontró el medio de pago para eliminar.', 16, 1);
                ROLLBACK;
                RETURN;
            END

            DELETE FROM cobranzas.MedioDePago
            WHERE nombre = @nombre;
        END

        ELSE
        BEGIN
            RAISERROR('Operación no válida. Usar Insertar, Modificar o Eliminar.', 16, 1);
            ROLLBACK;
            RETURN;
        END

        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO


/*____________________________________________________________________
  _________________________ RegistrarCobranza ________________________
  ____________________________________________________________________*/
IF OBJECT_ID('cobranzas.RegistrarCobranza', 'P') IS NOT NULL
    DROP PROCEDURE cobranzas.RegistrarCobranza;
GO

CREATE PROCEDURE cobranzas.RegistrarCobranza
    @id_factura INT,
    @fecha_pago DATE,
    @monto DECIMAL(10,2),
    @id_medio_pago INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

    BEGIN TRY

		BEGIN TRAN;

		-- Validar existencia de factura
        IF NOT EXISTS (SELECT 1 FROM facturacion.Factura WHERE id_factura = @id_factura)
        BEGIN
            RAISERROR('No se encontró la factura especificada.', 16, 1);
			ROLLBACK TRAN;
            RETURN;
        END

		-- Validar monto ingresado
        IF NOT EXISTS (SELECT id_factura FROM facturacion.Factura WHERE monto_total <= @monto)
        BEGIN
            RAISERROR('Monto de pago insuficiente para la factura.', 16, 1);
			ROLLBACK TRAN;
            RETURN;
        END

        -- Validar si ya fue pagada
        IF EXISTS (SELECT 1 FROM cobranzas.Pago WHERE id_factura = @id_factura)
        BEGIN
            RAISERROR('La factura ya fue pagada.', 16, 1);
			ROLLBACK TRAN;
            RETURN;
        END

        -- Validar medio de pago permitido
        IF NOT EXISTS (SELECT 1 FROM cobranzas.MedioDePago WHERE id_medio_pago = @id_medio_pago)
        BEGIN
            RAISERROR('Medio de pago no permitido.', 16, 1);
			ROLLBACK TRAN;
            RETURN;
        END

        -- Insertar el pago
        INSERT INTO cobranzas.Pago (id_factura, nro_transaccion, fecha_emision, id_medio, monto, estado)
        VALUES (@id_factura, RIGHT('00000000000000000000' + CAST(ABS(CHECKSUM(NEWID())) AS VARCHAR), 20), @fecha_pago, @id_medio_pago, @monto, 'Aprobado');

        DECLARE @id_pago INT = SCOPE_IDENTITY();

        -- Marcar factura como paga
        UPDATE facturacion.Factura
        SET estado = 'Paga'
        WHERE id_factura = @id_factura;

        DECLARE 
            @monto_factura DECIMAL(10,2),
            @id_socio INT;

        -- Obtener monto total y socio si aplica
        SELECT 
            @monto_factura = F.monto_total,
            @id_socio = COALESCE(S1.id_socio, S2.id_socio)
        FROM facturacion.Factura F
        LEFT JOIN facturacion.CuotaMensual CM ON F.id_cuota_mensual = CM.id_cuota_mensual
        LEFT JOIN actividades.InscriptoCategoriaSocio ICS ON ICS.id_inscripto_categoria = CM.id_inscripto_categoria
        LEFT JOIN socios.Socio S1 ON S1.id_socio = ICS.id_socio
        LEFT JOIN facturacion.CargoActividadExtra CAE ON F.id_cargo_actividad_extra = CAE.id_cargo_extra
        LEFT JOIN actividades.InscriptoColoniaVerano IC ON CAE.id_inscripto_colonia = IC.id_inscripto_colonia
        LEFT JOIN socios.Socio S2 ON S2.id_socio = IC.id_socio
        WHERE F.id_factura = @id_factura;

        -- Si hay excedente y es socio → registrar en PagoACuenta y actualizar saldo
		--¿Y SI EL QUE ESTA PAGANDO ES UN TUTOR, COMO SABE A DONDE TIENE QUE GUARDAR EL EXCEDENTE?
		--¿Y SI EL QUE ESTA PAGANDO ES UN SOCIO RESPONSABLE? --> se guarda en su saldo, funciona
        IF @monto > @monto_factura AND @id_socio IS NOT NULL
        BEGIN
            DECLARE @excedente DECIMAL(10,2) = @monto - @monto_factura;

            INSERT INTO cobranzas.PagoACuenta (id_pago, id_socio, fecha, monto)
            VALUES (@id_pago, @id_socio, @fecha_pago, @excedente);

            UPDATE socios.Socio
            SET saldo += @excedente
            WHERE id_socio = @id_socio;
        END

        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO




/*____________________________________________________________________
  ______________________ GenerarReintegroPorLluvia ___________________
  ____________________________________________________________________*/
/*
IF OBJECT_ID('cobranzas.GenerarReintegroPorLluvia', 'P') IS NOT NULL
    DROP PROCEDURE cobranzas.GenerarReintegroPorLluvia;
GO

CREATE PROCEDURE cobranzas.GenerarReintegroPorLluvia
    @mes INT,
    @año INT,
    @path NVARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRAN;

        -- Tabla temporal con datos climáticos
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

        -- Tabla variable con facturas a reintegrar
        DECLARE @Facturas TABLE (
            id_factura INT PRIMARY KEY,
            id_socio INT NULL,
            monto_reintegro DECIMAL(10,2),
            fecha_emision DATE
        );

        -- Cargar facturas de actividades extra en días lluviosos
        INSERT INTO @Facturas (id_factura, id_socio, monto_reintegro, fecha_emision)
        SELECT 
            F.id_factura,
            F.id_socio,
            F.monto_total * 0.6,
            F.fecha_emision
        FROM facturacion.Factura F
        INNER JOIN (
            SELECT DISTINCT CAST(LEFT(fecha, 10) AS DATE) AS fecha_lluvia
            FROM #clima
            WHERE lluvia_mm > 0
        ) LLU ON F.fecha_emision = LLU.fecha_lluvia
        INNER JOIN facturacion.DetalleFactura DF ON F.id_factura = DF.id_factura
        INNER JOIN cobranzas.Pago P ON F.id_factura = P.id_factura
        WHERE F.anulada = 0
        AND DF.tipo_item LIKE '%actividad extra%'
        AND F.fecha_emision BETWEEN DATEFROMPARTS(@año, @mes, 1)
                                AND EOMONTH(DATEFROMPARTS(@año, @mes, 1));

        -- Reintegros para socios → Pago a cuenta + actualizar saldo
        INSERT INTO cobranzas.PagoACuenta (id_pago, id_socio, fecha, monto)
        SELECT 
            P.id_pago,
            F.id_socio,
            GETDATE(),
            F.monto_reintegro
        FROM @Facturas F
        INNER JOIN cobranzas.Pago P ON F.id_factura = P.id_factura
        WHERE F.id_socio IS NOT NULL;

        UPDATE S
        SET S.saldo += F.monto_reintegro
        FROM socios.Socio S
        INNER JOIN @Facturas F ON S.id_socio = F.id_socio;

        -- Reintegros para invitados → Reembolso
        INSERT INTO cobranzas.Reembolso (id_pago, fecha, motivo, monto)
        SELECT 
            P.id_pago,
            GETDATE(),
            'Reintegro del 60% por lluvia',
            F.monto_reintegro
        FROM @Facturas F
        INNER JOIN cobranzas.Pago P ON F.id_factura = P.id_factura
        WHERE F.id_socio IS NULL;

        DROP TABLE #clima;

        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO
*/

/*____________________________________________________________________
  _________________________ GenerarReembolso _________________________
  ____________________________________________________________________*/
  /*
IF OBJECT_ID('cobranzas.GenerarReembolso', 'P') IS NOT NULL
    DROP PROCEDURE cobranzas.GenerarReembolso;
GO

CREATE PROCEDURE cobranzas.GenerarReembolso
    @id_pago INT,
    @motivo VARCHAR(100),
    @monto DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

    BEGIN TRY
        BEGIN TRAN;

        -- Validar que el pago exista
        IF NOT EXISTS (SELECT 1 FROM cobranzas.Pago WHERE id_pago = @id_pago)
        BEGIN
            RAISERROR('El pago especificado no existe.', 16, 1);
            ROLLBACK;
            RETURN;
        END

        DECLARE @monto_pagado DECIMAL(10,2);
        SELECT @monto_pagado = monto FROM cobranzas.Pago WHERE id_pago = @id_pago;

        IF @monto > @monto_pagado
        BEGIN
            RAISERROR('El monto del reembolso no puede ser mayor al pago original.', 16, 1);
            ROLLBACK;
            RETURN;
        END

        -- Insertar reembolso
        INSERT INTO cobranzas.Reembolso (id_pago, fecha, motivo, monto)
        VALUES (@id_pago, GETDATE(), @motivo, @monto);

        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO
*/

/*____________________________________________________________________
  ____________________________ GenerarPagoACuenta __________________________
  ____________________________________________________________________*/

IF OBJECT_ID('cobranzas.GenerarPagoACuenta', 'P') IS NOT NULL
    DROP PROCEDURE cobranzas.GenerarPagoACuenta;
GO
-- UN PAGO A CUENTA PUEDE SER SIN UNA FACTURA
-- ¿POR QUE EL PAGO A CUENTA NECESITA EL ID_PAGO, Y SI PRIMERO VIENE EL PAGO A CUENTA Y EL SP GENERA UNA TUPLA EN LA TABLA PAGO?
CREATE OR ALTER PROCEDURE cobranzas.RegistrarPagoACuenta
    @id_pago INT,
    @dni_pagador CHAR(13),
    @dni_destinatario CHAR(13),
    @monto DECIMAL(10,2),
    @motivo VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- 1. Validar monto positivo
        IF @monto <= 0
        BEGIN
            RAISERROR('El monto debe ser mayor a cero.', 16, 1);
            ROLLBACK;
            RETURN;
        END

        -- 2. Validar que el pago exista y NO esté asociado a factura
        IF NOT EXISTS (SELECT 1 FROM cobranzas.Pago WHERE id_pago = @id_pago)
        BEGIN
            RAISERROR('El ID de pago proporcionado no existe.', 16, 1);
            ROLLBACK;
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM cobranzas.Pago WHERE id_pago = @id_pago AND id_factura IS NOT NULL)
        BEGIN
            RAISERROR('El pago ya está asociado a una factura. No puede utilizarse como pago a cuenta.', 16, 1);
            ROLLBACK;
            RETURN;
        END

        -- 3. Buscar socio destinatario
        DECLARE @id_socio_dest INT;
        SELECT @id_socio_dest = id_socio FROM socios.Socio WHERE dni = @dni_destinatario;

        IF @id_socio_dest IS NULL
        BEGIN
            RAISERROR('El DNI destinatario no corresponde a un socio registrado.', 16, 1);
            ROLLBACK;
            RETURN;
        END

        -- 4. Buscar grupo del destinatario (si tiene)
        DECLARE @id_grupo_dest INT;
        SELECT @id_grupo_dest = id_grupo FROM socios.GrupoFamiliarSocio WHERE id_socio = @id_socio_dest;

        -- 5. Verificar si el pagador es socio
        IF EXISTS (SELECT 1 FROM socios.Socio WHERE dni = @dni_pagador)
        BEGIN
            -- Si el destinatario no tiene grupo, solo puede pagarse a sí mismo
            IF @id_grupo_dest IS NULL AND @dni_pagador <> @dni_destinatario
            BEGIN
                RAISERROR('Un socio solo puede pagar por sí mismo si el destinatario no tiene grupo.', 16, 1);
                ROLLBACK;
                RETURN;
            END

            -- Si tiene grupo, verificar si el pagador es el responsable
            IF @id_grupo_dest IS NOT NULL
            BEGIN
                IF NOT EXISTS (
                    SELECT 1
                    FROM socios.GrupoFamiliar gf
                    JOIN socios.Socio s ON gf.id_socio_rp = s.id_socio
                    WHERE gf.id_grupo = @id_grupo_dest AND s.dni = @dni_pagador
                )
                BEGIN
                    RAISERROR('El socio no es responsable del grupo del destinatario.', 16, 1);
                    ROLLBACK;
                    RETURN;
                END
            END
        END

        -- 6. O verificar si el pagador es tutor del grupo del destinatario
        ELSE IF EXISTS (SELECT 1 FROM socios.Tutor WHERE dni = @dni_pagador)
        BEGIN
            DECLARE @id_grupo_tutor INT;
            SELECT @id_grupo_tutor = id_grupo FROM socios.Tutor WHERE dni = @dni_pagador;

            IF @id_grupo_tutor IS NULL OR @id_grupo_tutor <> @id_grupo_dest
            BEGIN
                RAISERROR('El tutor no tiene a cargo al socio destinatario.', 16, 1);
                ROLLBACK;
                RETURN;
            END
        END
        ELSE
        BEGIN
            RAISERROR('El DNI pagador no corresponde a un socio ni tutor registrado.', 16, 1);
            ROLLBACK;
            RETURN;
        END

        -- 7. Registrar pago a cuenta
        INSERT INTO cobranzas.PagoACuenta (id_pago, id_socio, fecha, monto, motivo)
        SELECT @id_pago, @id_socio_dest, GETDATE(), @monto, @motivo;

        -- 8. Actualizar saldo del socio
        UPDATE socios.Socio
        SET saldo = saldo + @monto
        WHERE id_socio = @id_socio_dest;

        COMMIT;
        PRINT 'Pago a cuenta registrado correctamente.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH
END;
select * from cobranzas.Pago, cobranzas.PagoACuenta;
GO

/*____________________________________________________________________
  ____________________________ AnularFactura __________________________
  ____________________________________________________________________*/
  
CREATE PROCEDURE facturacion.AnularFactura
    @id_factura INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar existencia
    IF NOT EXISTS (
        SELECT 1 FROM facturacion.Factura WHERE id_factura = @id_factura
    )
    BEGIN
        RAISERROR('La factura con el ID %d no existe.', 16, 1, @id_factura);
        RETURN;
    END

    -- Verificar si ya está anulada
    IF EXISTS (
        SELECT 1 FROM facturacion.Factura 
        WHERE id_factura = @id_factura AND anulada = 1
    )
    BEGIN
        RAISERROR('La factura con el ID %d ya se encuentra anulada.', 16, 1, @id_factura);
        RETURN;
    END

    -------------------------
    -- 1. Reversión de mora
    -------------------------
    IF EXISTS (
        SELECT 1 FROM cobranzas.Mora WHERE id_factura = @id_factura
    )
    BEGIN
        -- Revertir saldo de mora
        UPDATE s
        SET s.saldo = s.saldo - m.monto
        FROM socios.Socio s
        INNER JOIN cobranzas.Mora m ON m.id_socio = s.id_socio
        WHERE m.id_factura = @id_factura;

        -- Eliminar mora
        DELETE FROM cobranzas.Mora
        WHERE id_factura = @id_factura;
    END


    -------------------------
    -- 2. Reversión de pago
    -------------------------
    -- Suponemos que si la factura está pagada, el saldo del socio bajó
    -- Entonces lo devolvemos al socio sumando el monto_total
    DECLARE @dni CHAR(13);
    DECLARE @monto_total DECIMAL(10,2);

    SELECT 
        @dni = dni_receptor,
        @monto_total = monto_total
    FROM facturacion.Factura
    WHERE id_factura = @id_factura;

    IF EXISTS (
        SELECT 1
        FROM socios.Socio
        WHERE dni = @dni
    )
    BEGIN
        UPDATE s
        SET s.saldo = s.saldo + @monto_total
        FROM socios.Socio s
        WHERE s.dni = @dni;
    END

    -------------------------
    -- 3. Marcar como anulada
    -------------------------
    UPDATE facturacion.Factura
    SET anulada = 1
    WHERE id_factura = @id_factura;

    PRINT 'Factura anulada y movimientos revertidos correctamente.';
END;