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

        -- 1. Cargar clima desde archivo CSV
        CREATE TABLE #clima (
            fecha VARCHAR(50),
            temperatura DECIMAL(4,2),
            lluvia_mm DECIMAL(4,2),
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

        -- 2. Días con lluvia
        SELECT DISTINCT CAST(LEFT(fecha, 10) AS DATE) AS fecha_lluvia
        INTO #DiasLluvia
        FROM #clima
        WHERE lluvia_mm > 0;

        -- 3. Inscripciones colonia afectadas
        SELECT 
            IC.id_socio,
            NULL AS id_invitado,
            IC.fecha,
            IC.monto,
            TC.periodo,
            DL.fecha_lluvia
        INTO #ColoniaAfectada
        FROM actividades.InscriptoColoniaVerano IC
        INNER JOIN tarifas.TarifaColoniaVerano TC ON IC.id_tarifa_colonia = TC.id_tarifa_colonia
        INNER JOIN #DiasLluvia DL ON IC.fecha = DL.fecha_lluvia
        WHERE MONTH(IC.fecha) = @mes AND YEAR(IC.fecha) = @año;

        -- 4.1 Inscripciones pileta afectadas - SOCIOS
        SELECT 
            IP.id_socio,
            NULL AS id_invitado,
            IP.fecha,
            IP.monto,
            NULL AS periodo,
            DL.fecha_lluvia
        INTO #PiletaAfectada
        FROM actividades.InscriptoPiletaVerano IP
        INNER JOIN tarifas.TarifaPiletaVerano TP ON IP.id_tarifa_pileta = TP.id_tarifa_pileta
        INNER JOIN #DiasLluvia DL ON IP.fecha = DL.fecha_lluvia
        WHERE IP.id_invitado IS NULL  
          AND MONTH(IP.fecha) = @mes AND YEAR(IP.fecha) = @año;

        -- 4.2 Agregar pileta afectadas - INVITADOS
        INSERT INTO #PiletaAfectada (id_socio, id_invitado, fecha, monto, periodo, fecha_lluvia)
        SELECT 
            NULL,                  
            IP.id_invitado,
            IP.fecha,
            IP.monto,
            NULL AS periodo,
            DL.fecha_lluvia
        FROM actividades.InscriptoPiletaVerano IP
        INNER JOIN tarifas.TarifaPiletaVerano TP ON IP.id_tarifa_pileta = TP.id_tarifa_pileta
        INNER JOIN #DiasLluvia DL ON IP.fecha = DL.fecha_lluvia
        WHERE IP.id_invitado IS NOT NULL  
          AND MONTH(IP.fecha) = @mes AND YEAR(IP.fecha) = @año;

        -- Antes de insertar datos, crear tabla temporal con columnas que aceptan NULLs
        IF OBJECT_ID('tempdb..#ReintegrosUnificados') IS NOT NULL
            DROP TABLE #ReintegrosUnificados;

        CREATE TABLE #ReintegrosUnificados (
            id_socio INT NULL,
            id_invitado INT NULL,
            fecha_lluvia DATE NOT NULL,
            monto DECIMAL(10,2) NOT NULL,
            periodo VARCHAR(20) NULL,
            monto_reintegro DECIMAL(10,2) NOT NULL
        );

        -- 5. Insertar inscripciones colonia con cálculo reintegro
        INSERT INTO #ReintegrosUnificados (id_socio, id_invitado, fecha_lluvia, monto, periodo, monto_reintegro)
        SELECT 
            id_socio,
            id_invitado,
            fecha_lluvia,
            monto,
            periodo,
            CASE 
                WHEN periodo IS NULL THEN monto * 0.6
                WHEN LOWER(LTRIM(RTRIM(periodo))) LIKE '%dia%' THEN monto * 0.6
                WHEN LOWER(LTRIM(RTRIM(periodo))) LIKE '%mes%' THEN (monto / 30.0) * 0.6
                WHEN LOWER(LTRIM(RTRIM(periodo))) LIKE '%temporada%' THEN (monto / 120.0) * 0.6
                ELSE 0
            END
        FROM #ColoniaAfectada;

        -- 6. Insertar inscripciones pileta (sin periodo) con reintegro fijo 60%
        INSERT INTO #ReintegrosUnificados (id_socio, id_invitado, fecha_lluvia, monto, periodo, monto_reintegro)
        SELECT
            id_socio,
            id_invitado,
            fecha_lluvia,
            monto,
            NULL AS periodo,
            monto * 0.6
        FROM #PiletaAfectada;

        -- 7. Pagos representativos por socio
        SELECT 
            S.id_socio,
            MIN(P.id_pago) AS id_pago
        INTO #PagosSocios
        FROM socios.Socio S
        INNER JOIN facturacion.Factura F ON S.dni = F.dni_receptor
        INNER JOIN cobranzas.Pago P ON F.id_factura = P.id_factura
        WHERE MONTH(F.fecha_emision) = @mes AND YEAR(F.fecha_emision) = @año
        GROUP BY S.id_socio;

        -- 8. Pagos representativos por invitado
        SELECT 
            I.id_invitado,
            MIN(P.id_pago) AS id_pago
        INTO #PagosInvitados
        FROM socios.Invitado I
        INNER JOIN facturacion.Factura F ON I.dni = F.dni_receptor
        INNER JOIN cobranzas.Pago P ON F.id_factura = P.id_factura
        WHERE MONTH(F.fecha_emision) = @mes AND YEAR(F.fecha_emision) = @año
        GROUP BY I.id_invitado;

        -- 9. Reintegro para socios (no invitados)
        INSERT INTO cobranzas.PagoACuenta (id_pago, id_socio, fecha, monto, motivo)
        SELECT 
            PS.id_pago,
            R.id_socio,
            GETDATE(),
            SUM(R.monto_reintegro),
            'Reintegro del 60% por lluvia'
        FROM #ReintegrosUnificados R
        INNER JOIN #PagosSocios PS ON R.id_socio = PS.id_socio
        WHERE R.id_invitado IS NULL
        GROUP BY PS.id_pago, R.id_socio;

        -- 10. Actualizar saldo socios
        UPDATE S
        SET S.saldo += R.total
        FROM socios.Socio S
        INNER JOIN (
            SELECT id_socio, SUM(monto_reintegro) AS total
            FROM #ReintegrosUnificados
            WHERE id_socio IS NOT NULL AND id_invitado IS NULL
            GROUP BY id_socio
        ) R ON S.id_socio = R.id_socio;

        -- 11. Reintegro para invitados (reembolso)
        INSERT INTO cobranzas.Reembolso (id_pago, fecha_emision, motivo, monto)
        SELECT 
            PI.id_pago,
            GETDATE(),
            'Reintegro del 60% por lluvia',
            SUM(R.monto_reintegro)
        FROM #ReintegrosUnificados R
        INNER JOIN #PagosInvitados PI ON R.id_invitado = PI.id_invitado
        WHERE R.id_socio IS NULL
        GROUP BY PI.id_pago;

        -- 12. Limpiar tablas temporales
        DROP TABLE #clima;
        DROP TABLE #DiasLluvia;
        DROP TABLE #ColoniaAfectada;
        DROP TABLE #PiletaAfectada;
        DROP TABLE #ReintegrosUnificados;
        DROP TABLE #PagosSocios;
        DROP TABLE #PagosInvitados;

        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO


/*____________________________________________________________________
  _________________________ GenerarReembolso _________________________
  ____________________________________________________________________*/

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
        INSERT INTO cobranzas.Reembolso (id_pago, fecha_emision, motivo, monto)
        VALUES (@id_pago, GETDATE(), @motivo, @monto);

        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO

/*____________________________________________________________________
  ____________________________ GenerarPagoACuenta __________________________
  ____________________________________________________________________*/

IF OBJECT_ID('cobranzas.GenerarPagoACuenta', 'P') IS NOT NULL
    DROP PROCEDURE cobranzas.GenerarPagoACuenta;
GO

CREATE PROCEDURE cobranzas.GenerarPagoACuenta
    @id_pago INT,
    @dni_socio CHAR(8),
    @monto DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

    DECLARE @id_socio INT;

    BEGIN TRY
        BEGIN TRAN;

        -- Validar existencia del pago
        IF NOT EXISTS (SELECT 1 FROM cobranzas.Pago WHERE id_pago = @id_pago)
        BEGIN
            RAISERROR('El pago especificado no existe.', 16, 1);
            ROLLBACK;
            RETURN;
        END

        -- Buscar socio por DNI
        SELECT @id_socio = id_socio
        FROM socios.Socio
        WHERE dni = @dni_socio AND eliminado = 0 AND activo = 1;

        IF @id_socio IS NULL
        BEGIN
            RAISERROR('El socio especificado no existe o no está activo.', 16, 1);
            ROLLBACK;
            RETURN;
        END

        -- Insertar el pago a cuenta
        INSERT INTO cobranzas.PagoACuenta (id_pago, id_socio, fecha, monto)
        VALUES (@id_pago, @id_socio, GETDATE(), @monto);

        -- Actualizar saldo del socio
        UPDATE socios.Socio
        SET saldo = saldo + @monto
        WHERE id_socio = @id_socio;

        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO

/*____________________________________________________________________
  ____________________________ AnularFactura __________________________
  ____________________________________________________________________*/

IF OBJECT_ID('facturacion.AnularFactura', 'P') IS NOT NULL
    DROP PROCEDURE facturacion.AnularFactura;
GO

CREATE PROCEDURE facturacion.AnularFactura(
    @id_factura INT,
    @motivo NVARCHAR(255)
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

    BEGIN TRY
        BEGIN TRAN;

        -- Validar existencia de la factura y obtener el monto
        DECLARE @monto DECIMAL(10,2);
        SELECT @monto = monto_total
        FROM facturacion.Factura
        WHERE id_factura = @id_factura;

        IF @monto IS NULL
        BEGIN
            RAISERROR('La factura especificada no existe.', 16, 1);
            ROLLBACK;
            RETURN;
        END

        -- Si está paga, generar reembolso
        IF EXISTS (
            SELECT 1 FROM facturacion.Factura
            WHERE id_factura = @id_factura AND estado = 'Paga'
        )
        BEGIN
            DECLARE @id_pago INT;
            SELECT TOP 1 @id_pago = id_pago
            FROM cobranzas.Pago
            WHERE id_factura = @id_factura;

            IF @id_pago IS NOT NULL
            BEGIN
                EXEC cobranzas.GenerarReembolso
                    @id_pago = @id_pago,
                    @motivo = @motivo,
                    @monto = @monto;
            END
        END

        -- Marcar la factura como anulada
        UPDATE facturacion.Factura
        SET anulada = 1
        WHERE id_factura = @id_factura;

        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO