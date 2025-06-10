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

        -- Si ya existe y está borrada, se reactiva
        IF EXISTS (SELECT 1 FROM administracion.Persona WHERE dni = @dni AND borrado = 1)
        BEGIN
            UPDATE administracion.Persona
            SET nombre = @nombre,
                apellido = @apellido,
                email = @email,
                fecha_nacimiento = @fecha_nacimiento,
                tel_contacto = @tel_contacto,
                tel_emergencia = @tel_emergencia,
                borrado = 0
            WHERE dni = @dni;

            RETURN;
        END

        -- Inserción normal si no existía
        INSERT INTO administracion.Persona (
            nombre, apellido, dni, email, fecha_nacimiento, tel_contacto, tel_emergencia, borrado
        )
        VALUES (
            @nombre, @apellido, @dni, @email, @fecha_nacimiento, @tel_contacto, @tel_emergencia, 0
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
    @nombre VARCHAR(50),
    @apellido CHAR(50),
    @dni CHAR(10),
    @email VARCHAR(70),
    @fecha_nacimiento DATE,
    @tel_contacto CHAR(15),
    @tel_emergencia CHAR(15),
    @operacion CHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificación de operación válida
    IF @operacion NOT IN ('Insertar', 'Eliminar')
    BEGIN
        RAISERROR('Operación inválida. Usar Insertar o Eliminar.', 16, 1);
        RETURN;
    END

    DECLARE @id_persona INT;

    -- CASO 1: INSERTAR
    IF @operacion = 'Insertar'
    BEGIN
        -- Buscar si la persona ya existe
        SELECT @id_persona = id_persona
        FROM administracion.Persona
        WHERE dni = @dni;

        -- Si no existe, se inserta la persona
        IF @id_persona IS NULL
        BEGIN
            EXEC administracion.GestionarPersona
                @nombre, 
                @apellido, 
                @dni, 
                @email, 
                @fecha_nacimiento, 
                @tel_contacto, 
                @tel_emergencia, 
                'Insertar';

            SELECT @id_persona = id_persona
            FROM administracion.Persona
            WHERE dni = @dni;
        END

        -- Validar si ya es profesor
        IF EXISTS (
            SELECT 1 
            FROM administracion.Profesor 
            WHERE id_persona = @id_persona
        )
        BEGIN
            RAISERROR('La persona ya está registrada como profesor.', 16, 1);
            RETURN;
        END

        -- Insertar nuevo profesor
        INSERT INTO administracion.Profesor (id_persona)
        VALUES (@id_persona);
    END

    -- CASO 2: ELIMINAR
    ELSE IF @operacion = 'Eliminar'
    BEGIN
        SELECT @id_persona = id_persona
        FROM administracion.Persona
        WHERE dni = @dni;

        IF @id_persona IS NULL
        BEGIN
            RAISERROR('No se encontró una persona con el DNI especificado.', 16, 1);
            RETURN;
        END

        -- Eliminar profesor
        DELETE FROM administracion.Profesor
        WHERE id_persona = @id_persona;

        -- Marcar persona como borrada
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
    @años INT = NULL,
    @costo_membresia DECIMAL(10,2) = NULL,
    @vigencia DATE = NULL,
    @operacion CHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificación de operaciones válidas
    IF @operacion NOT IN ('Insertar', 'Modificar', 'Eliminar')
    BEGIN
        RAISERROR('Operación inválida. Use Insertar, Modificar o Eliminar.', 16, 1);
        RETURN;
    END

    -- Insertar categoría
    IF @operacion = 'Insertar'
    BEGIN
        INSERT INTO administracion.CategoriaSocio (nombre, años, costo_membresia, vigencia)
        VALUES (@nombre, @años, @costo_membresia, @vigencia);
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
            años = COALESCE(@años, años),
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

    -- 1) Verificar operación válida
    IF @operacion NOT IN ('Insertar','Eliminar')
    BEGIN
        RAISERROR('Operación inválida. Use Insertar o Eliminar.',16,1);
        RETURN;
    END

    DECLARE 
        @id_persona INT,
        @id_socio   INT,
        @activo     BIT;

    -- ======== INSERTAR ========
    IF @operacion = 'Insertar'
    BEGIN
        -- 2) Obtener o crear persona
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

        -- 3) Evitar duplicados de socio para la misma persona
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

        -- 4) Insertar socio
        SET @activo = 1;

        INSERT INTO administracion.Socio
            (id_persona, id_categoria, nro_socio, obra_social, nro_obra_social, saldo, activo)
        VALUES
            (
             @id_persona,
             (SELECT id_categoria FROM administracion.CategoriaSocio WHERE nombre = @categoria),
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
        -- 5) Localizar persona y socio
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

        -- 6) Borrado lógico de persona
        UPDATE administracion.Persona
           SET borrado = 1
         WHERE id_persona = @id_persona;

        -- 7) Eliminar físicamente el socio
        DELETE FROM administracion.Socio
         WHERE id_socio = @id_socio;
    END
END;
GO

/*____________________________________________________________________
  _____________________ GestionarGrupoFamiliar _____________________
  ____________________________________________________________________*/

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

        IF @dni_invitado IS NULL
           OR LEN(@dni_invitado) <> 8
           OR @dni_invitado NOT LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
        BEGIN
            RAISERROR('DNI de invitado inválido (8 dígitos numéricos).',16,1);
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

        INSERT INTO administracion.Invitado (id_socio, dni)
        VALUES (@id_socio, @dni_invitado);
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