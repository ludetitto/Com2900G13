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
 ========================================================================= */
USE COM2900G13;
GO


/*____________________________________________________________________
  ____________________ GestionarCategoriaSocio _____________________
  ____________________________________________________________________*/
IF OBJECT_ID('socios.GestionarCategoriaSocio', 'P') IS NOT NULL
    DROP PROCEDURE socios.GestionarCategoriaSocio;
GO

CREATE PROCEDURE socios.GestionarCategoriaSocio
    @descripcion     VARCHAR(50),
    @edad_minima     INT = NULL,
    @edad_maxima     INT = NULL,
    @costo           DECIMAL(10,2) = NULL,
    @vigencia        DATE = NULL,
    @operacion       CHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    IF @operacion NOT IN ('Insertar', 'Modificar', 'Eliminar')
    BEGIN
        RAISERROR('Operación inválida. Use Insertar, Modificar o Eliminar.', 16, 1);
        RETURN;
    END

    IF @operacion = 'Insertar'
    BEGIN
        IF LTRIM(RTRIM(@descripcion)) = ''
        BEGIN
            RAISERROR('La descripción es obligatoria.', 16, 1);
            RETURN;
        END

        IF @edad_minima IS NULL OR @edad_maxima IS NULL OR @edad_minima > @edad_maxima
        BEGIN
            RAISERROR('El rango de edad es inválido.', 16, 1);
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM socios.CategoriaSocio WHERE descripcion = @descripcion)
        BEGIN
            RAISERROR('Ya existe una categoría con esa descripción.', 16, 1);
            RETURN;
        END

        INSERT INTO socios.CategoriaSocio (descripcion, edad_minima, edad_maxima, costo, vigencia)
        VALUES (@descripcion, @edad_minima, @edad_maxima, @costo, @vigencia);
    END

    ELSE IF @operacion = 'Modificar'
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM socios.CategoriaSocio WHERE descripcion = @descripcion)
        BEGIN
            RAISERROR('Categoría no encontrada.', 16, 1);
            RETURN;
        END

        UPDATE socios.CategoriaSocio
        SET 
            edad_minima = COALESCE(@edad_minima, edad_minima),
            edad_maxima = COALESCE(@edad_maxima, edad_maxima),
            costo       = COALESCE(@costo, costo),
            vigencia    = COALESCE(@vigencia, vigencia)
        WHERE descripcion = @descripcion;
    END

    ELSE IF @operacion = 'Eliminar'
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM socios.CategoriaSocio WHERE descripcion = @descripcion)
        BEGIN
            RAISERROR('No se encontró una categoría con esa descripción para eliminar.', 16, 1);
            RETURN;
        END

        DELETE FROM socios.CategoriaSocio
        WHERE descripcion = @descripcion;
    END
END;
GO

/*____________________________________________________________________
  _________________________ GestionarSocio ___________________________
  ____________________________________________________________________*/
IF OBJECT_ID('socios.GestionarSocio', 'P') IS NOT NULL
    DROP PROCEDURE socios.GestionarSocio;
GO

CREATE PROCEDURE socios.GestionarSocio
    @nombre              VARCHAR(50) = NULL,
    @apellido            VARCHAR(50) = NULL,
    @dni                 CHAR(8),
    @email               VARCHAR(100) = NULL,
    @fecha_nacimiento    DATE = NULL,
    @telefono            VARCHAR(20) = NULL,
    @telefono_emergencia VARCHAR(20) = NULL,
    @direccion           VARCHAR(150) = NULL,
    @obra_social         VARCHAR(100) = NULL,
    @nro_os              VARCHAR(50) = NULL,
    @dni_integrante_grupo CHAR(8) = NULL,
    @nombre_tutor        VARCHAR(50) = NULL,
    @apellido_tutor      VARCHAR(50) = NULL,
    @dni_tutor           CHAR(8) = NULL,
    @email_tutor         VARCHAR(100) = NULL,
    @fecha_nac_tutor     DATE = NULL,
    @telefono_tutor      VARCHAR(20) = NULL,
    @relacion_tutor      VARCHAR(50) = NULL,
    @domicilio_tutor     VARCHAR(150) = NULL,
    @es_responsable      BIT = NULL,
    @operacion           CHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    IF @operacion NOT IN ('Insertar', 'Eliminar')
    BEGIN
        RAISERROR('Operación inválida. Use Insertar o Eliminar.', 16, 1);
        RETURN;
    END

    DECLARE 
        @edad INT,
        @id_categoria INT,
        @id_socio INT,
        @id_socio_ref INT,
        @id_grupo_ref INT,
        @id_grupo_nuevo INT;

    IF @operacion = 'Insertar'
    BEGIN
        IF @fecha_nacimiento IS NULL
        BEGIN
            RAISERROR('La fecha de nacimiento es obligatoria para insertar.', 16, 1);
            RETURN;
        END

        SET @edad = DATEDIFF(YEAR, @fecha_nacimiento, GETDATE());

        SELECT TOP 1 @id_categoria = id_categoria
        FROM socios.CategoriaSocio
        WHERE @edad BETWEEN edad_minima AND edad_maxima
        ORDER BY edad_minima;

        IF @id_categoria IS NULL
        BEGIN
            RAISERROR('No existe categoría para la edad especificada.', 16, 1);
            RETURN;
        END

        SELECT @id_socio = id_socio
        FROM socios.Socio
        WHERE dni = @dni;

        IF @id_socio IS NOT NULL
        BEGIN
            DECLARE @ya_eliminado BIT;
            SELECT @ya_eliminado = eliminado FROM socios.Socio WHERE id_socio = @id_socio;

            IF @ya_eliminado = 1
            BEGIN
                UPDATE socios.Socio
                SET 
                    nombre = @nombre,
                    apellido = @apellido,
                    email = @email,
                    fecha_nacimiento = @fecha_nacimiento,
                    telefono = @telefono,
                    telefono_emergencia = @telefono_emergencia,
                    direccion = @direccion,
                    obra_social = @obra_social,
                    nro_os = @nro_os,
                    id_categoria = @id_categoria,
                    activo = 1,
                    eliminado = 0,
                    saldo = 0
                WHERE id_socio = @id_socio;
            END
            ELSE
            BEGIN
                RAISERROR('Ya existe un socio con ese DNI.', 16, 1);
                RETURN;
            END
        END
        ELSE
        BEGIN
            INSERT INTO socios.Socio (
                nombre, apellido, dni, email, fecha_nacimiento,
                telefono, telefono_emergencia, direccion,
                obra_social, nro_os, id_categoria,
                activo, eliminado, saldo
            )
            VALUES (
                @nombre, @apellido, @dni, @email, @fecha_nacimiento,
                @telefono, @telefono_emergencia, @direccion,
                @obra_social, @nro_os, @id_categoria,
                1, 0, 0
            );

            SELECT @id_socio = SCOPE_IDENTITY();
        END

        -- Vinculación a grupo (nuevo o existente)
        IF @dni_integrante_grupo IS NOT NULL
        BEGIN
            SELECT @id_socio_ref = id_socio FROM socios.Socio WHERE dni = @dni_integrante_grupo;

            IF @id_socio_ref IS NULL
            BEGIN
                RAISERROR('No se encontró el socio indicado como referencia de grupo.', 16, 1);
                RETURN;
            END

            SELECT TOP 1 @id_grupo_ref = gf.id_grupo
            FROM socios.GrupoFamiliar gf
            JOIN socios.GrupoFamiliarSocio gfs ON gf.id_grupo = gfs.id_grupo
            WHERE gfs.id_socio = @id_socio_ref;

            IF @id_grupo_ref IS NULL
            BEGIN
                RAISERROR('El socio indicado no pertenece a ningún grupo familiar.', 16, 1);
                RETURN;
            END

            IF NOT EXISTS (
                SELECT 1 FROM socios.GrupoFamiliarSocio 
                WHERE id_grupo = @id_grupo_ref AND id_socio = @id_socio
            )
            BEGIN
                INSERT INTO socios.GrupoFamiliarSocio (id_grupo, id_socio)
                VALUES (@id_grupo_ref, @id_socio);
            END

            IF @edad >= 18 AND @es_responsable = 1
            BEGIN
                UPDATE socios.GrupoFamiliar
                SET id_socio_rp = @id_socio
                WHERE id_grupo = @id_grupo_ref;
            END
        END
        ELSE
        BEGIN
            -- Crear grupo nuevo
            INSERT INTO socios.GrupoFamiliar (id_socio_rp)
            VALUES (CASE WHEN @edad >= 18 THEN @id_socio ELSE NULL END);

            SELECT @id_grupo_nuevo = SCOPE_IDENTITY();

            INSERT INTO socios.GrupoFamiliarSocio (id_grupo, id_socio)
            VALUES (@id_grupo_nuevo, @id_socio);

            IF @edad < 18
            BEGIN
                IF @dni_tutor IS NULL OR @nombre_tutor IS NULL OR @email_tutor IS NULL OR @domicilio_tutor IS NULL
                BEGIN
                    RAISERROR('Los datos del tutor son obligatorios para menores sin grupo.', 16, 1);
                    RETURN;
                END

                INSERT INTO socios.Tutor (
                    id_grupo, dni, nombre, apellido, domicilio, email
                )
                VALUES (
                    @id_grupo_nuevo, @dni_tutor, @nombre_tutor, @apellido_tutor, @domicilio_tutor, @email_tutor
                );
            END
        END
    END

    ELSE IF @operacion = 'Eliminar'
    BEGIN
        SELECT @id_socio = id_socio FROM socios.Socio WHERE dni = @dni;

        IF @id_socio IS NULL
        BEGIN
            RAISERROR('No se encontró un socio con ese DNI.', 16, 1);
            RETURN;
        END

        SELECT @id_grupo_ref = id_grupo
        FROM socios.GrupoFamiliar
        WHERE id_socio_rp = @id_socio;

        IF @id_grupo_ref IS NOT NULL
        BEGIN
            INSERT INTO socios.Tutor (id_grupo, dni, nombre, apellido, domicilio, email)
            SELECT TOP 1
                GF.id_grupo,
                S.dni,
                S.nombre,
                S.apellido,
                S.direccion,
                S.email
            FROM socios.Socio S
            JOIN socios.GrupoFamiliar GF ON GF.id_socio_rp = S.id_socio
            WHERE S.id_socio = @id_socio;

            UPDATE socios.GrupoFamiliar
            SET id_socio_rp = NULL
            WHERE id_grupo = @id_grupo_ref;
        END

        UPDATE socios.Socio
        SET activo = 0,
            eliminado = 1
        WHERE id_socio = @id_socio;

        DELETE FROM socios.GrupoFamiliarSocio WHERE id_socio = @id_socio;
    END
END;
GO



/*____________________________________________________________________
  ______________ GestionarResponsableGrupoFamiliar ___________________
  ____________________________________________________________________*/
IF OBJECT_ID('socios.GestionarResponsableGrupoFamiliar', 'P') IS NOT NULL
    DROP PROCEDURE socios.GestionarResponsableGrupoFamiliar;
GO

CREATE PROCEDURE socios.GestionarResponsableGrupoFamiliar
    @dni_grupo          CHAR(8),       -- DNI de un socio del grupo (para ubicar el grupo)
    @nuevo_dni_resp     VARCHAR(20),   -- DNI del nuevo responsable (socio o tutor)
    @tipo_responsable   VARCHAR(10),   -- 'socio' o 'tutor'
    @nombre             VARCHAR(50) = NULL,
    @apellido           VARCHAR(50) = NULL,
    @domicilio          VARCHAR(200) = NULL,
    @email              VARCHAR(70) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @tipo_responsable NOT IN ('socio', 'tutor')
    BEGIN
        RAISERROR('Tipo de responsable inválido. Use "socio" o "tutor".', 16, 1);
        RETURN;
    END

    DECLARE @id_grupo INT, @id_nuevo INT;

    -- Obtener grupo al que pertenece el socio
    SELECT TOP 1 @id_grupo = gfs.id_grupo
    FROM socios.GrupoFamiliarSocio gfs
    JOIN socios.Socio s ON gfs.id_socio = s.id_socio
    WHERE s.dni = @dni_grupo;

    IF @id_grupo IS NULL
    BEGIN
        RAISERROR('No se encontró el grupo familiar del socio indicado.', 16, 1);
        RETURN;
    END

    IF @tipo_responsable = 'socio'
    BEGIN
        SELECT @id_nuevo = id_socio
        FROM socios.Socio
        WHERE dni = @nuevo_dni_resp;

        IF @id_nuevo IS NULL
        BEGIN
            RAISERROR('No se encontró el socio indicado como nuevo responsable.', 16, 1);
            RETURN;
        END

        IF NOT EXISTS (
            SELECT 1
            FROM socios.GrupoFamiliarSocio
            WHERE id_grupo = @id_grupo AND id_socio = @id_nuevo
        )
        BEGIN
            RAISERROR('El nuevo socio responsable no pertenece al grupo.', 16, 1);
            RETURN;
        END

        -- Asignar como responsable
        UPDATE socios.GrupoFamiliar
        SET id_socio_rp = @id_nuevo
        WHERE id_grupo = @id_grupo;

        -- Eliminar tutor si lo hay
        DELETE FROM socios.Tutor
        WHERE id_grupo = @id_grupo;
    END
    ELSE IF @tipo_responsable = 'tutor'
    BEGIN
        IF @nombre IS NULL OR @apellido IS NULL OR @domicilio IS NULL OR @email IS NULL
        BEGIN
            RAISERROR('Faltan datos obligatorios del tutor.', 16, 1);
            RETURN;
        END

        -- ⚠ Validación crítica corregida con RTRIM
        IF EXISTS (
            SELECT 1 FROM socios.Tutor
            WHERE RTRIM(dni) = RTRIM(@nuevo_dni_resp) AND id_grupo <> @id_grupo
        )
        BEGIN
            RAISERROR('Ese tutor ya está asignado a otro grupo familiar.', 16, 1);
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM socios.Tutor WHERE id_grupo = @id_grupo)
        BEGIN
            UPDATE socios.Tutor
            SET dni = @nuevo_dni_resp,
                nombre = @nombre,
                apellido = @apellido,
                domicilio = @domicilio,
                email = @email
            WHERE id_grupo = @id_grupo;
        END
        ELSE
        BEGIN
            INSERT INTO socios.Tutor (id_grupo, dni, nombre, apellido, domicilio, email)
            VALUES (@id_grupo, @nuevo_dni_resp, @nombre, @apellido, @domicilio, @email);
        END

        -- Quitar responsable si lo había
        UPDATE socios.GrupoFamiliar
        SET id_socio_rp = NULL
        WHERE id_grupo = @id_grupo;
    END
END;
GO


/*____________________________________________________________________
  ____________________ vwGrupoFamiliarConCategorias ___________________
  ____________________________________________________________________*/
IF OBJECT_ID('socios.vwGrupoFamiliarConCategorias', 'V') IS NOT NULL
    DROP VIEW socios.vwGrupoFamiliarConCategorias;
GO

CREATE VIEW socios.vwGrupoFamiliarConCategorias AS
SELECT 
    GF.id_grupo,
    S.id_socio,
    S.dni,
    S.nombre,
    S.apellido,
    S.fecha_nacimiento,
    S.email,
    S.telefono,
    S.telefono_emergencia,
    S.direccion,
    S.obra_social,
    S.nro_os,
    CS.descripcion AS categoria,
    CS.costo AS costo_membresia,
    CASE 
        WHEN S.id_socio = GF.id_socio_rp THEN 1
        ELSE 0 
    END AS es_responsable
FROM socios.GrupoFamiliar GF
INNER JOIN socios.GrupoFamiliarSocio GFS ON GF.id_grupo = GFS.id_grupo
INNER JOIN socios.Socio S ON GFS.id_socio = S.id_socio
INNER JOIN socios.CategoriaSocio CS ON S.id_categoria = CS.id_categoria
WHERE S.eliminado = 0;
GO


/*____________________________________________________________________
  ____________________ VerCuotasPagasGrupoFamiliar ___________________
  ____________________________________________________________________*/
/*
IF OBJECT_ID('administracion.VerCuotasPagasGrupoFamiliar', 'P') IS NOT NULL
    DROP PROCEDURE administracion.VerCuotasPagasGrupoFamiliar;
GO

CREATE PROCEDURE administracion.VerCuotasPagasGrupoFamiliar
    @dni_socio CHAR(10)
AS
BEGIN
    SET NOCOUNT ON;
	-- Se almacenan mediante CTE las cuotas pagas para el socio ingresado y sus familiares.
	WITH CuotasPagas AS
	(
		SELECT
			MONTH(F.fecha_emision) AS [Mes],
			P.nombre AS Nombre,
			P.apellido AS Apellido,
			C.nombre AS Categoria,
			F.monto_total AS Total
		FROM facturacion.Factura F
		INNER JOIN administracion.Socio S ON S.id_socio = F.id_socio
		INNER JOIN administracion.CategoriaSocio C ON C.id_categoria = S.id_categoria
		INNER JOIN administracion.Persona P ON P.id_persona = S.id_persona
		WHERE F.estado = 'Pagada' AND P.dni = @dni_socio AND F.anulada = 0

		UNION

		SELECT
			MONTH(F.fecha_emision) AS [Mes],
			P.nombre AS Nombre,
			P.apellido AS Apellido,
			C.nombre AS Categoria,
			F.monto_total AS Total
		FROM facturacion.Factura F
		INNER JOIN administracion.GrupoFamiliar G ON  F.id_socio = G.id_socio
		INNER JOIN administracion.Socio S ON G.id_socio = S.id_socio
		INNER JOIN administracion.CategoriaSocio C ON C.id_categoria = S.id_categoria
		INNER JOIN administracion.Persona P ON P.id_persona = S.id_persona
		WHERE G.id_socio_rp = (SELECT S.id_socio
							   FROM administracion.Persona P 
							   INNER JOIN administracion.Socio S ON S.id_persona = P.id_persona
							   WHERE P.dni = '12345678') AND F.estado = 'Pagada' AND F.anulada = 0
	)
	SELECT TOP 10 *
	FROM CuotasPagas

END;
GO
*/

/*____________________________________________________________________
  ______________________ AnularFacturaSocioDeBaja ____________________
  ____________________________________________________________________*/
/*
IF OBJECT_ID('administracion.AnularFacturaSocioDeBaja', 'TR') IS NOT NULL
    DROP TRIGGER administracion.AnularFacturaSocioDeBaja;
GO

CREATE TRIGGER administracion.AnularFacturaSocioDeBaja
ON administracion.Socio
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
	-- Al darse de baja un socio, automáticamente las facturas pendientes se anulan.
    UPDATE F
    SET F.anulada = 1
    FROM facturacion.Factura f
	INNER JOIN administracion.Socio S ON S.id_socio = F.id_socio
    INNER JOIN inserted I ON I.id_socio = S.id_socio
	WHERE I.activo = 0
END;
GO
*/

/*______________________________________________________________________
  _____________________ ConsultarEstadoSocioyGrupo _____________________
  ____________________________________________________________________*/
  
