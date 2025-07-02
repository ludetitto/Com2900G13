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
    @medio_de_pago VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
 
    BEGIN TRY
        BEGIN TRAN;
 
        DECLARE @id_medio_pago INT;
        DECLARE @id_pago INT;
        DECLARE @monto_factura DECIMAL(10,2);
        DECLARE @id_socio_pago INT;
 
        -- Validar existencia de factura
        IF NOT EXISTS (SELECT 1 FROM facturacion.Factura WHERE id_factura = @id_factura)
        BEGIN
            RAISERROR('No se encontró la factura especificada.', 16, 1);
            ROLLBACK TRAN;
            RETURN;
        END
 
        -- Validar monto ingresado
        IF NOT EXISTS (SELECT 1 FROM facturacion.Factura WHERE id_factura = @id_factura AND monto_total <= @monto)
        BEGIN
            RAISERROR('Monto de pago insuficiente para la factura.', 16, 1);
            ROLLBACK TRAN;
            RETURN;
        END
 
        -- Validar medio de pago
        SET @id_medio_pago = (SELECT id_medio_pago FROM cobranzas.MedioDePago WHERE nombre = @medio_de_pago);
        IF @id_medio_pago IS NULL
        BEGIN
            RAISERROR('Medio de pago no existente.', 16, 1);
            ROLLBACK TRAN;
            RETURN;
        END
 
        IF NOT EXISTS (
            SELECT 1 FROM cobranzas.MedioDePago
            WHERE id_medio_pago = @id_medio_pago
              AND nombre IN ('Visa', 'MasterCard', 'Tarjeta Naranja', 'Pago Fácil', 'Rapipago', 'Transferencia Mercado Pago')
        )
        BEGIN
            RAISERROR('El medio de pago no está permitido.', 16, 1);
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
 
        -- Insertar el pago
        INSERT INTO cobranzas.Pago (id_factura, nro_transaccion, fecha_emision, id_medio, monto, estado)
        VALUES (
            @id_factura,
            RIGHT('00000000000000000000' + CAST(ABS(CHECKSUM(NEWID())) AS VARCHAR), 20),
            @fecha_pago,
            @id_medio_pago,
            @monto,
            'Aprobado'
        );
 
        SET @id_pago = SCOPE_IDENTITY();
 
        -- Obtener monto y socio responsable
        SELECT 
            @monto_factura = F.monto_total,
            @id_socio_pago = COALESCE(SR.id_socio, S1.id_socio, S2.id_socio, S3.id_socio)
        FROM facturacion.Factura F
        LEFT JOIN facturacion.CuotaMensual CM ON CM.id_cuota_mensual = F.id_cuota_mensual
        LEFT JOIN actividades.InscriptoCategoriaSocio ICS ON ICS.id_inscripto_categoria = CM.id_inscripto_categoria
        LEFT JOIN socios.Socio S1 ON S1.id_socio = ICS.id_socio
        LEFT JOIN socios.GrupoFamiliarSocio GFS ON GFS.id_socio = S1.id_socio
        LEFT JOIN socios.GrupoFamiliar GF ON GF.id_grupo = GFS.id_grupo
        LEFT JOIN socios.Socio SR ON SR.id_socio = GF.id_socio_rp
        LEFT JOIN facturacion.CargoActividadExtra CAE ON CAE.id_cargo_extra = F.id_cargo_actividad_extra
        LEFT JOIN actividades.InscriptoColoniaVerano IC ON IC.id_inscripto_colonia = CAE.id_inscripto_colonia
        LEFT JOIN socios.Socio S2 ON S2.id_socio = IC.id_socio
        LEFT JOIN socios.Socio S3 ON S3.dni = F.dni_receptor
        WHERE F.id_factura = @id_factura;
 
        -- Si hay excedente, registrar pago a cuenta y actualizar saldo
        IF @monto > @monto_factura AND @id_socio_pago IS NOT NULL
        BEGIN
            DECLARE @excedente DECIMAL(10,2) = @monto - @monto_factura;
 
            INSERT INTO cobranzas.PagoACuenta (id_pago, id_socio, fecha, monto, motivo)
            VALUES (@id_pago, @id_socio_pago, @fecha_pago, @excedente, 'Excedente de pago.');
 
            UPDATE socios.Socio
            SET saldo += @excedente
            WHERE id_socio = @id_socio_pago;
        END
 
        -- Marcar factura como pagada
        UPDATE facturacion.Factura
        SET estado = 'Paga'
        WHERE id_factura = @id_factura;
 
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

	BEGIN TRAN
	BEGIN TRY
		-- Verificar existencia
		IF NOT EXISTS (
			SELECT 1 FROM facturacion.Factura WHERE id_factura = @id_factura
		)
		BEGIN
			RAISERROR('La factura con el ID %d no existe.', 16, 1, @id_factura);
			ROLLBACK TRAN
			RETURN;
		END

		-- Verificar si ya está anulada
		IF EXISTS (
			SELECT 1 FROM facturacion.Factura 
			WHERE id_factura = @id_factura AND anulada = 1
		)
		BEGIN
			RAISERROR('La factura con el ID %d ya se encuentra anulada.', 16, 1, @id_factura);
			ROLLBACK TRAN
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

		COMMIT;

	END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
			ROLLBACK;
        THROW;
    END CATCH
END;
GO