/* =========================================================================
   Trabajo Práctico Integrador - Bases de Datos Aplicadas
   Grupo N°: 13
   Comisión: 2900
   Fecha de Entrega: 17/06/2025
   Materia: Bases de Datos Aplicadas
   Alumnos: Vignardel Francisco 45778667
            De Titto Lucia 46501934
 ========================================================================= */
USE COM2900G13;
GO

/*____________________________________________________________________
  _________________________ GestionarPersona _______________________
  ____________________________________________________________________*/

IF OBJECT_ID('administracion.GestionarPersona', 'P') IS NOT NULL
    DROP PROCEDURE administracion.GestionarPersona;
GO

CREATE PROCEDURE administracion.GestionarPersona
    @nombre VARCHAR(50),
    @apellido CHAR(50),
    @dni CHAR(10),
    @email VARCHAR(70),
    @fecha_nacimiento DATE,
	@domicilio VARCHAR(200),
    @tel_contacto CHAR(15),
    @tel_emergencia CHAR(15),
    @operacion CHAR(10)
AS
BEGIN
    SET NOCOUNT ON;
	
    -- Verificación de operaciones válidas
    IF @operacion NOT IN ('Insertar', 'Modificar', 'Eliminar')
    BEGIN
        RAISERROR('Operación inválida. Usar Insertar, Modificar o Eliminar.', 16, 1);
        RETURN;
    END

    -- CASO 1: Eliminar persona (borrado lógico)
    IF @operacion = 'Eliminar'
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM administracion.Persona WHERE dni = @dni)
        BEGIN
            RAISERROR('No existe el DNI para eliminar.', 16, 1);
            RETURN;
        END

        UPDATE administracion.Persona
        SET borrado = 1
        WHERE dni = @dni;
    END

    -- CASO 2: Modificar datos
    ELSE IF @operacion = 'Modificar'
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM administracion.Persona WHERE dni = @dni)
        BEGIN
            RAISERROR('No existe el DNI para modificar.', 16, 1);
            RETURN;
        END

        UPDATE administracion.Persona
        SET nombre = COALESCE(@nombre, nombre),
            apellido = COALESCE(@apellido, apellido),
            email = COALESCE(@email, email),
            fecha_nacimiento = COALESCE(@fecha_nacimiento, fecha_nacimiento),
			domicilio = COALESCE(@domicilio, domicilio),
            tel_contacto = COALESCE(@tel_contacto, tel_contacto),
            tel_emergencia = COALESCE(@tel_emergencia, tel_emergencia)
        WHERE dni = @dni;
    END

    -- CASO 3: Insertar persona o reactivar si ya existía borrada
    ELSE IF @operacion = 'Insertar'
    BEGIN
        IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
        BEGIN
            RAISERROR('El nombre es obligatorio.', 16, 1);
            RETURN;
        END

        IF @apellido IS NULL OR LTRIM(RTRIM(@apellido)) = ''
        BEGIN
            RAISERROR('El apellido es obligatorio.', 16, 1);
            RETURN;
        END

        IF @dni IS NULL OR LEN(LTRIM(RTRIM(@dni))) > 10
        BEGIN
            RAISERROR('El DNI debe tener hasta 10 caracteres.', 16, 1);
            RETURN;
        END

        IF @fecha_nacimiento IS NULL OR @fecha_nacimiento > GETDATE()
        BEGIN
            RAISERROR('La fecha de nacimiento es inválida.', 16, 1);
            RETURN;
        END

		IF @domicilio IS NULL OR LTRIM(RTRIM(@domicilio)) = ''
        BEGIN
            RAISERROR('El domicilio es obligatorio.', 16, 1);
            RETURN;
        END

        -- Si ya existe y está borrada, se reactiva
        IF EXISTS (SELECT 1 FROM administracion.Persona WHERE dni = @dni AND borrado = 1)
        BEGIN
            UPDATE administracion.Persona
            SET nombre = @nombre,
                apellido = @apellido,
                email = @email,
                fecha_nacimiento = @fecha_nacimiento,
				domicilio = @domicilio,
                tel_contacto = @tel_contacto,
                tel_emergencia = @tel_emergencia,
                borrado = 0
            WHERE dni = @dni;

            RETURN;
        END

        -- Inserción normal si no existía
        INSERT INTO administracion.Persona (
            nombre, apellido, dni, email, fecha_nacimiento, domicilio, tel_contacto, tel_emergencia, borrado
        )
        VALUES (
            @nombre, @apellido, @dni, @email, @fecha_nacimiento, @domicilio, @tel_contacto, @tel_emergencia, 0
        );
    END
END;
GO

/*____________________________________________________________________
  _______________________ GestionarProfesor ________________________
  ____________________________________________________________________*/

IF OBJECT_ID('administracion.GestionarProfesor', 'P') IS NOT NULL
    DROP PROCEDURE administracion.GestionarProfesor;
GO

CREATE PROCEDURE administracion.GestionarProfesor
    @nombre           VARCHAR(50),
    @apellido         CHAR(50),
    @dni              CHAR(10),
    @email            VARCHAR(70),
    @fecha_nacimiento DATE,
	@domicilio		  VARCHAR(200),
    @tel_contacto     CHAR(15),
    @tel_emergencia   CHAR(15),
    @operacion        CHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    -- 1) Verificación de operación válida
    IF @operacion NOT IN ('Insertar', 'Eliminar')
    BEGIN
        RAISERROR('Operación inválida. Usar Insertar o Eliminar.', 16, 1);
        RETURN;
    END

    DECLARE 
        @id_persona INT,
        @esta_borrada BIT;

    -- CASO 1: INSERTAR
    IF @operacion = 'Insertar'
    BEGIN
        -- 1.1) Verifico si ya existe la persona (incluso si está borrada)
        SELECT 
            @id_persona = id_persona,
            @esta_borrada = borrado
        FROM administracion.Persona
        WHERE dni = @dni;

        -- 1.2) Si existe pero estaba borrada, la "reactivo"
        IF @id_persona IS NOT NULL AND @esta_borrada = 1
        BEGIN
            UPDATE administracion.Persona
            SET borrado = 0
            WHERE id_persona = @id_persona;
        END

        -- 1.3) Si no existía, inserto la persona nueva
        IF @id_persona IS NULL
        BEGIN
            EXEC administracion.GestionarPersona
                @nombre,
                @apellido,
                @dni,
                @email,
                @fecha_nacimiento,
				@domicilio,
                @tel_contacto,
                @tel_emergencia,
                'Insertar';

            SELECT @id_persona = id_persona
            FROM administracion.Persona
            WHERE dni = @dni;
        END

        -- 1.4) Verificar que no esté ya como profesor
        IF EXISTS (
            SELECT 1 
            FROM administracion.Profesor 
            WHERE id_persona = @id_persona
        )
        BEGIN
            RAISERROR('La persona ya está registrada como profesor.', 16, 1);
            RETURN;
        END

        -- 1.5) Inserto el registro en Profesor
        INSERT INTO administracion.Profesor (id_persona)
        VALUES (@id_persona);
    END

    -- CASO 2: ELIMINAR
    ELSE IF @operacion = 'Eliminar'
    BEGIN
        -- 2.1) Obtengo la persona
        SELECT @id_persona = id_persona
        FROM administracion.Persona
        WHERE dni = @dni;

        IF @id_persona IS NULL
        BEGIN
            RAISERROR('No se encontró una persona con el DNI especificado.', 16, 1);
            RETURN;
        END

        -- 2.2) Elimino el rol de profesor
        DELETE FROM administracion.Profesor
        WHERE id_persona = @id_persona;

        -- 2.3) Marco la persona como borrada
        UPDATE administracion.Persona 
        SET borrado = 1
        WHERE id_persona = @id_persona;
    END
END;
GO
/*____________________________________________________________________
  ____________________ GestionarCategoriaSocio _____________________
  ____________________________________________________________________*/

IF OBJECT_ID('administracion.GestionarCategoriaSocio', 'P') IS NOT NULL
    DROP PROCEDURE administracion.GestionarCategoriaSocio;
GO

CREATE PROCEDURE administracion.GestionarCategoriaSocio
    @nombre VARCHAR(50),
    @edad_desde INT = NULL,
    @edad_hasta INT = NULL,
    @costo_membresia DECIMAL(10,2) = NULL,
    @vigencia DATE = NULL,
    @operacion CHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validación de operación
    IF @operacion NOT IN ('Insertar', 'Modificar', 'Eliminar')
    BEGIN
        RAISERROR('Operación inválida. Use Insertar, Modificar o Eliminar.', 16, 1);
        RETURN;
    END

    -- Insertar categoría
    IF @operacion = 'Insertar'
    BEGIN
        IF LTRIM(RTRIM(@nombre)) = ''
        BEGIN
            RAISERROR('El nombre de la categoría es obligatorio.', 16, 1);
            RETURN;
        END

        IF @edad_desde IS NULL OR @edad_hasta IS NULL
        BEGIN
            RAISERROR('Debe especificar el rango de edad (desde/hasta).', 16, 1);
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM administracion.CategoriaSocio WHERE nombre = @nombre)
        BEGIN
            RAISERROR('Ya existe una categoría con ese nombre.', 16, 1);
            RETURN;
        END

        INSERT INTO administracion.CategoriaSocio (nombre, edad_desde, edad_hasta, costo_membresia, vigencia)
        VALUES (@nombre, @edad_desde, @edad_hasta, @costo_membresia, @vigencia);
    END

    -- Modificar categoría
    ELSE IF @operacion = 'Modificar'
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM administracion.CategoriaSocio WHERE nombre = @nombre)
        BEGIN
            RAISERROR('Categoría no encontrada.', 16, 1);
            RETURN;
        END

        UPDATE administracion.CategoriaSocio
        SET 
            edad_desde = COALESCE(@edad_desde, edad_desde),
            edad_hasta = COALESCE(@edad_hasta, edad_hasta),
            costo_membresia = COALESCE(@costo_membresia, costo_membresia),
            vigencia = COALESCE(@vigencia, vigencia)
        WHERE nombre = @nombre;
    END

    -- Eliminar categoría
    ELSE IF @operacion = 'Eliminar'
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM administracion.CategoriaSocio WHERE nombre = @nombre)
        BEGIN
            RAISERROR('No se encontró una categoría con ese nombre para eliminar.', 16, 1);
            RETURN;
        END

        DELETE FROM administracion.CategoriaSocio
        WHERE nombre = @nombre;
    END
END;
GO

/*____________________________________________________________________
  _________________________ GestionarSocio ___________________________
  ____________________________________________________________________*/
IF OBJECT_ID('administracion.GestionarSocio', 'P') IS NOT NULL
    DROP PROCEDURE administracion.GestionarSocio;
GO

CREATE PROCEDURE administracion.GestionarSocio
    @nombre            VARCHAR(50)   = NULL,
    @apellido          CHAR(50)      = NULL,
    @dni               CHAR(10),
    @email             VARCHAR(70)   = NULL,
    @fecha_nacimiento  DATE          = NULL,
	@domicilio		   VARCHAR(200)	 = NULL,
    @tel_contacto      CHAR(15)      = NULL,
    @tel_emergencia    CHAR(15)      = NULL,
    @categoria         VARCHAR(50)   = NULL,
    @nro_socio         CHAR(20)      = NULL,
    @obra_social       VARCHAR(100)  = NULL,
    @nro_obra_social   VARCHAR(100)  = NULL,
    @saldo             DECIMAL(10,2) = NULL,
    @operacion         CHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    IF @operacion NOT IN ('Insertar','Eliminar')
    BEGIN
        RAISERROR('Operación inválida. Use Insertar o Eliminar.',16,1);
        RETURN;
    END

    DECLARE 
        @id_persona INT,
        @id_socio   INT,
        @activo     BIT,
        @id_categoria INT;

    -- ======== INSERTAR ========
    IF @operacion = 'Insertar'
    BEGIN
        -- 1. Obtener o crear persona
        SELECT @id_persona = id_persona
          FROM administracion.Persona
         WHERE dni = @dni;

        IF @id_persona IS NULL
        BEGIN
            EXEC administracion.GestionarPersona
                @nombre           = @nombre,
                @apellido         = @apellido,
                @dni              = @dni,
                @email            = @email,
                @fecha_nacimiento = @fecha_nacimiento,
				@domicilio		  = @domicilio,
                @tel_contacto     = @tel_contacto,
                @tel_emergencia   = @tel_emergencia,
                @operacion        = 'Insertar';

            SELECT @id_persona = id_persona
              FROM administracion.Persona
             WHERE dni = @dni;
        END
        ELSE
        BEGIN
            -- Reactivar persona si estaba borrada
            UPDATE administracion.Persona
               SET borrado = 0
             WHERE id_persona = @id_persona
               AND borrado = 1;
        END

        -- 2. Evitar duplicados de socio para la misma persona
        IF EXISTS (
            SELECT 1 
              FROM administracion.Socio
             WHERE id_persona = @id_persona
               AND activo = 1
        )
        BEGIN
            RAISERROR('Este DNI ya tiene un socio activo.',16,1);
            RETURN;
        END

        -- 3. Obtener id_categoria (con validación)
        SELECT @id_categoria = id_categoria
          FROM administracion.CategoriaSocio
         WHERE nombre = @categoria;

        IF @id_categoria IS NULL
        BEGIN
            RAISERROR('La categoría especificada no existe.',16,1);
            RETURN;
        END

        SET @activo = 1;

        INSERT INTO administracion.Socio
            (id_persona, id_categoria, nro_socio, obra_social, nro_obra_social, saldo, activo)
        VALUES
            (
             @id_persona,
             @id_categoria,
             @nro_socio,
             @obra_social,
             @nro_obra_social,
             ISNULL(@saldo,0),
             @activo
            );
    END

    -- ======== ELIMINAR ========
    ELSE IF @operacion = 'Eliminar'
    BEGIN
        SELECT 
            @id_persona = p.id_persona,
            @id_socio   = s.id_socio
          FROM administracion.Persona p
          JOIN administracion.Socio s 
            ON p.id_persona = s.id_persona
         WHERE p.dni = @dni
           AND s.activo = 1;

        IF @id_persona IS NULL OR @id_socio IS NULL
        BEGIN
            RAISERROR('No se encontró un socio activo con ese DNI.',16,1);
            RETURN;
        END

        UPDATE administracion.Persona
           SET borrado = 1
         WHERE id_persona = @id_persona;

        DELETE FROM administracion.Socio
         WHERE id_socio = @id_socio;
    END
END;
GO


/*____________________________________________________________________
  _____________________ GestionarGrupoFamiliar _____________________
  ____________________________________________________________________*/

IF OBJECT_ID('administracion.GestionarGrupoFamiliar','P') IS NOT NULL
    DROP PROCEDURE administracion.GestionarGrupoFamiliar;
GO

CREATE PROCEDURE administracion.GestionarGrupoFamiliar
    @dni_socio     CHAR(10),
    @dni_socio_rp  CHAR(10),
    @operacion     CHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    -- 1) Verificar operación válida
    IF @operacion NOT IN ('Insertar','Eliminar')
    BEGIN
        RAISERROR('Operación inválida. Use Insertar o Eliminar.',16,1);
        RETURN;
    END

    DECLARE 
        @id_socio     INT,
        @id_socio_rp  INT;

    -- ======== INSERTAR ========
    IF @operacion = 'Insertar'
    BEGIN
        -- obtener id_socio
        SELECT @id_socio = S.id_socio
          FROM administracion.Socio S
          JOIN administracion.Persona P 
            ON S.id_persona = P.id_persona
         WHERE P.dni = @dni_socio;

        -- obtener id_socio_rp
        SELECT @id_socio_rp = S.id_socio
          FROM administracion.Socio S
          JOIN administracion.Persona P 
            ON S.id_persona = P.id_persona
         WHERE P.dni = @dni_socio_rp;

        -- validar existencia de ambos
        IF @id_socio IS NULL
        BEGIN
            RAISERROR('No se encontró el socio con DNI %s.',16,1,@dni_socio);
            RETURN;
        END
        IF @id_socio_rp IS NULL
        BEGIN
            RAISERROR('No se encontró el responsable con DNI %s.',16,1,@dni_socio_rp);
            RETURN;
        END

        -- validar duplicado: un socio sólo puede tener un registro en GrupoFamiliar
        IF EXISTS (
            SELECT 1 
              FROM administracion.GrupoFamiliar
             WHERE id_socio = @id_socio
        )
        BEGIN
            RAISERROR('El socio con DNI %s ya tiene grupo familiar asignado.',16,1,@dni_socio);
            RETURN;
        END

        -- insertar
        INSERT INTO administracion.GrupoFamiliar (id_socio,id_socio_rp)
        VALUES (@id_socio,@id_socio_rp);
    END

    -- ======== ELIMINAR ========
    ELSE IF @operacion = 'Eliminar'
    BEGIN
        -- obtener id_socio
        SELECT @id_socio = S.id_socio
          FROM administracion.Socio S
          JOIN administracion.Persona P 
            ON S.id_persona = P.id_persona
         WHERE P.dni = @dni_socio;

        IF @id_socio IS NULL
        BEGIN
            RAISERROR('No se encontró el socio con DNI %s.',16,1,@dni_socio);
            RETURN;
        END

        -- eliminar todas las filas de GrupoFamiliar para ese socio
        DELETE FROM administracion.GrupoFamiliar
         WHERE id_socio = @id_socio;
    END
END;
GO

/*____________________________________________________________________
  _______________________ GestionarInvitado _______________________
  ____________________________________________________________________*/
IF OBJECT_ID('administracion.GestionarInvitado', 'P') IS NOT NULL
    DROP PROCEDURE administracion.GestionarInvitado;
GO

CREATE PROCEDURE administracion.GestionarInvitado
    @dni_socio     CHAR(10),
    @dni_invitado  CHAR(10),
	@nombre CHAR(50),
	@apellido CHAR(50),
	@email VARCHAR(70),
	@domicilio VARCHAR(200),
    @operacion     CHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    -- 1) Verificar operación válida
    IF @operacion NOT IN ('Insertar','Eliminar')
    BEGIN
        RAISERROR('Operación inválida. Use Insertar o Eliminar.',16,1);
        RETURN;
    END

    DECLARE @id_socio INT;

    -- ======== INSERTAR ========
    IF @operacion = 'Insertar'
    BEGIN
        -- (igual que antes...)
        SELECT @id_socio = S.id_socio
          FROM administracion.Socio S
          JOIN administracion.Persona P 
            ON S.id_persona = P.id_persona
         WHERE P.dni = @dni_socio;

        IF @id_socio IS NULL
        BEGIN
            RAISERROR('No se encontró un socio con ese DNI.',16,1);
            RETURN;
        END

        IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
        BEGIN
            RAISERROR('El nombre es obligatorio.', 16, 1);
            RETURN;
        END

        IF @apellido IS NULL OR LTRIM(RTRIM(@apellido)) = ''
        BEGIN
            RAISERROR('El apellido es obligatorio.', 16, 1);
            RETURN;
        END

        IF @dni_invitado IS NULL OR LEN(LTRIM(RTRIM(@dni_invitado))) > 10
        BEGIN
            RAISERROR('El DNI debe tener hasta 10 caracteres.', 16, 1);
            RETURN;
        END

		IF @domicilio IS NULL OR LTRIM(RTRIM(@domicilio)) = ''
        BEGIN
            RAISERROR('El domicilio es obligatorio.', 16, 1);
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM administracion.Persona WHERE dni = @dni_invitado)
        BEGIN
            RAISERROR('El DNI de invitado ya existe como persona.',16,1);
            RETURN;
        END

        IF EXISTS (
            SELECT 1 
              FROM administracion.Invitado
             WHERE id_socio = @id_socio
               AND dni     = @dni_invitado
        )
        BEGIN
            RAISERROR('Este invitado ya está asignado a ese socio.',16,1);
            RETURN;
        END

        INSERT INTO administracion.Invitado (id_socio, dni, nombre, apellido, email, domicilio)
        VALUES (@id_socio, @dni_invitado, @nombre, @apellido, @email, @domicilio);
    END

    -- ======== ELIMINAR ========
    ELSE IF @operacion = 'Eliminar'
    BEGIN
        -- 2) Verificar que el socio exista
        SELECT @id_socio = S.id_socio
          FROM administracion.Socio S
          JOIN administracion.Persona P 
            ON S.id_persona = P.id_persona
         WHERE P.dni = @dni_socio;

        IF @id_socio IS NULL
        BEGIN
            RAISERROR('No se encontró un socio con ese DNI.',16,1);
            RETURN;
        END

        -- 3) Verificar que ese invitado exista para ese socio
        IF NOT EXISTS (
            SELECT 1
              FROM administracion.Invitado
             WHERE id_socio = @id_socio
               AND dni      = @dni_invitado
        )
        BEGIN
            RAISERROR('No existe ese invitado para el socio indicado.',16,1);
            RETURN;
        END

        -- 4) Eliminar
        DELETE FROM administracion.Invitado
         WHERE id_socio = @id_socio
           AND dni      = @dni_invitado;
    END
END;
GO

/*____________________________________________________________________
  ____________________ VerCuotasPagasGrupoFamiliar ___________________
  ____________________________________________________________________*/

IF OBJECT_ID('administracion.VerCuotasPagasGrupoFamiliar', 'P') IS NOT NULL
    DROP PROCEDURE administracion.VerCuotasPagasGrupoFamiliar;
GO

CREATE PROCEDURE administracion.VerCuotasPagasGrupoFamiliar
    @dni_socio CHAR(10)
AS
BEGIN
    SET NOCOUNT ON;
	
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

/*____________________________________________________________________
  ______________________ AnularFacturaSocioDeBaja ____________________
  ____________________________________________________________________*/

IF OBJECT_ID('administracion.AnularFacturaSocioDeBaja', 'TR') IS NOT NULL
    DROP TRIGGER administracion.AnularFacturaSocioDeBaja;
GO

CREATE TRIGGER administracion.AnularFacturaSocioDeBaja
ON administracion.Socio
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE F
    SET F.anulada = 1
    FROM facturacion.Factura f
	INNER JOIN administracion.Socio S ON S.id_socio = F.id_socio
    INNER JOIN inserted I ON I.id_socio = S.id_socio
	WHERE I.activo = 0
END;
GO


/*______________________________________________________________________
  _____________________ ConsultarEstadoSocioyGrupo _____________________
  ____________________________________________________________________*/
  
IF OBJECT_ID('administracion.ConsultarEstadoSocioyGrupo','P') IS NOT NULL
    DROP PROCEDURE administracion.ConsultarEstadoSocioyGrupo;
GO

CREATE PROCEDURE administracion.ConsultarEstadoSocioyGrupo
    @dni VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    -- 1) Validaciones iniciales
    IF LEN(@dni) <> 8 OR ISNUMERIC(@dni) = 0
    BEGIN
        RAISERROR('El DNI debe tener exactamente 8 dígitos numéricos.',16,1);
        RETURN;
    END

    DECLARE @id_socio INT, @email VARCHAR(70);

    -- Buscar socio activo con ese DNI
    SELECT TOP 1
        @id_socio = s.id_socio,
        @email    = p.email
    FROM administracion.Socio s
    JOIN administracion.Persona p
      ON s.id_persona = p.id_persona
    WHERE p.dni = @dni AND s.activo = 1;

    IF @id_socio IS NULL
    BEGIN
        RAISERROR('No existe un socio activo con el DNI especificado.',16,1);
        RETURN;
    END

    IF CHARINDEX('@',@email) = 0 OR CHARINDEX('.',@email) = 0
    BEGIN
        RAISERROR('El correo electrónico del socio no tiene un formato válido.',16,1);
        RETURN;
    END

    -- 2) Datos del TITULAR
    SELECT
        'Titular'         AS TipoPersona,
        s.id_socio,
        p.nombre,
        p.apellido,
        p.dni,
        p.email,
        p.fecha_nacimiento,
        p.tel_contacto,
        p.tel_emergencia,
        s.nro_socio,
        s.obra_social,
        s.nro_obra_social,
        s.saldo,
        s.activo,
        cs.nombre       AS categoria,
        cs.costo_membresia,
        gf.id_grupo
    FROM administracion.Socio s
    JOIN administracion.Persona p
      ON s.id_persona = p.id_persona
    JOIN administracion.CategoriaSocio cs
      ON s.id_categoria = cs.id_categoria
    LEFT JOIN administracion.GrupoFamiliar gf
      ON gf.id_socio    = s.id_socio
     OR gf.id_socio_rp = s.id_socio
    WHERE s.id_socio = @id_socio;

    -- 3) Datos de los FAMILIARES (si existen)
    ;WITH MiGrupo AS (
        SELECT id_grupo
        FROM administracion.GrupoFamiliar
        WHERE id_socio = @id_socio
           OR id_socio_rp = @id_socio
    ),
    Familiares AS (
        SELECT gf.id_socio     AS id_fam, g.id_grupo FROM administracion.GrupoFamiliar gf JOIN MiGrupo g ON gf.id_grupo = g.id_grupo WHERE gf.id_socio     <> @id_socio
        UNION
        SELECT gf.id_socio_rp  AS id_fam, g.id_grupo FROM administracion.GrupoFamiliar gf JOIN MiGrupo g ON gf.id_grupo = g.id_grupo WHERE gf.id_socio_rp  <> @id_socio
    )
    SELECT
        'Familiar'        AS TipoPersona,
        f.id_socio,
        p2.nombre,
        p2.apellido,
        p2.dni,
        p2.email,
        p2.fecha_nacimiento,
        p2.tel_contacto,
        p2.tel_emergencia,
        f.nro_socio,
        f.obra_social,
        f.nro_obra_social,
        f.saldo,
        f.activo,
        cs2.nombre      AS categoria,
        cs2.costo_membresia,
        fam.id_grupo
    FROM Familiares fam
    JOIN administracion.Socio f
      ON f.id_socio = fam.id_fam
    JOIN administracion.Persona p2
      ON f.id_persona = p2.id_persona
    JOIN administracion.CategoriaSocio cs2
      ON f.id_categoria = cs2.id_categoria
    ORDER BY fam.id_grupo, f.id_socio;
END;
GO


/*____________________________________________________________________
  _____________________ Vista: vwSociosConCategoria __________________
  ____________________________________________________________________*/

IF OBJECT_ID('administracion.vwSociosConCategoria', 'V') IS NOT NULL
    DROP VIEW administracion.vwSociosConCategoria;
GO

CREATE VIEW administracion.vwSociosConCategoria AS
SELECT 
    P.dni,
    P.nombre,
    P.apellido,
    P.fecha_nacimiento,
    P.email,
    S.id_socio,
    C.nombre AS categoria,
    C.costo_membresia,
    C.vigencia
FROM administracion.Socio S
JOIN administracion.Persona P ON S.id_persona = P.id_persona
JOIN administracion.CategoriaSocio C ON S.id_categoria = C.id_categoria;
GO
