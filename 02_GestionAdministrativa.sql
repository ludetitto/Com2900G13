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
	/*Verificación de operaciones válidas*/
    IF @operacion NOT IN ('Insertar', 'Eliminar')
    BEGIN
        RAISERROR('Operación inválida. Usar Insertar o Eliminar.', 16, 1);
        RETURN;
    END

	/*Se declara variable auxiliar para la gestión de id_persona*/
    DECLARE @id_persona INT;
	/*CASO 1: Insertar profesor nuevo.*/
    IF @operacion = 'Insertar'
    BEGIN
        /*Verificación de existencia de la persona*/
        SELECT @id_persona = id_persona
        FROM administracion.Persona
        WHERE dni = @dni;

        /*Si no existe, se crea*/
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
					'Insertar'
				
			SET @id_persona = (SELECT 1 FROM administracion.Persona WHERE dni = @dni)
        END

        INSERT INTO administracion.Profesor (id_persona)
        VALUES (@id_persona);
    END
	/*CASO 2: Eliminar un profesor. En este caso, se borra la persona y luego el profesor en sí como rol*/
    ELSE IF @operacion = 'Eliminar'
    BEGIN
        /*Se obtiene el id_persona correspondiente al profesor*/
        SELECT @id_persona = id_persona
        FROM administracion.Persona
        WHERE dni = @dni;
		/*Verificación de existencia de la persona*/
        IF @id_persona IS NULL
        BEGIN
            RAISERROR('No se encontró una persona con el DNI especificado.', 16, 1);
            RETURN;
        END
		/*Se borra de la tabla Persona*/
        UPDATE administracion.Persona 
		SET borrado = 1
		WHERE id_persona = @id_persona;
		/*Se borra de la tabla Profesor*/
		DELETE FROM administracion.Profesor
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
    @años INT,
    @costo_membresia DECIMAL(10,2),
    @vigencia DATE,
    @operacion CHAR(10)
AS
BEGIN
    SET NOCOUNT ON;
	/*Verificación de operaciones válidas*/
    IF @operacion NOT IN ('Insertar', 'Modificar', 'Eliminar')
    BEGIN
        RAISERROR('Operación inválida.', 16, 1);
        RETURN;
    END
	/*CASO 1: Insertar categoría de socio*/
    IF @operacion = 'Insertar'
    BEGIN
        INSERT INTO administracion.CategoriaSocio (nombre, años, costo_membresia, vigencia)
        VALUES (@nombre, @años, @costo_membresia, @vigencia);
    END
	/*CASO 2: Modificar categoría de socio. Pueden modificarse todos los campos menos ID y nombre*/
    ELSE IF @operacion = 'Modificar'
    BEGIN
		/*Verificacion de existencia de categoría*/
        IF NOT EXISTS (SELECT 1 FROM administracion.CategoriaSocio WHERE nombre = @nombre)
		BEGIN
            RAISERROR('Categoría no encontrada.', 16, 1);
			RETURN;
		END
		/*Se utiliza COALESCE para asegurar dato válido en caso de que algún usuario ingrese NULL en algún campo*/
        UPDATE administracion.CategoriaSocio
        SET 
			años = COALESCE(@años, años),
			costo_membresia = COALESCE(@costo_membresia, costo_membresia),
			vigencia = COALESCE(@vigencia, vigencia)
        WHERE nombre = @nombre;
    END
	/*CASO 3: Eliminar categoria de socio*/
    ELSE IF @operacion = 'Eliminar'
        DELETE FROM administracion.CategoriaSocio
		WHERE nombre = @nombre;
END;
GO

/*____________________________________________________________________
  _________________________ GestionarSocios _________________________
  ____________________________________________________________________*/
IF OBJECT_ID('administracion.GestionarSocio', 'P') IS NOT NULL
    DROP PROCEDURE administracion.GestionarSocio;
GO

CREATE PROCEDURE administracion.GestionarSocio
    @nombre VARCHAR(50) = NULL,
    @apellido CHAR(50) = NULL,
    @dni CHAR(10),
    @email VARCHAR(70) = NULL,
    @fecha_nacimiento DATE = NULL,
    @tel_contacto CHAR(15) = NULL,
    @tel_emergencia CHAR(15) = NULL,
    @categoria VARCHAR(50) = NULL,
    @nro_socio CHAR(20) = NULL,
    @obra_social VARCHAR(100) = NULL,
    @nro_obra_social VARCHAR(100) = NULL,
    @saldo DECIMAL(10,2) = NULL,
    @operacion CHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificación de operaciones válidas
    IF @operacion NOT IN ('Insertar', 'Eliminar')
    BEGIN
        RAISERROR('Operación inválida. Usar Insertar o Eliminar.', 16, 1);
        RETURN;
    END

    DECLARE @id_persona INT;
    DECLARE @id_socio INT;
    DECLARE @activo BIT;

    IF @operacion = 'Insertar'
    BEGIN
        -- Verificar si ya existe la persona
        SELECT @id_persona = id_persona FROM administracion.Persona WHERE dni = @dni;

        -- Si no existe, crearla
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

            -- Obtener ID de persona recién creada
            SELECT @id_persona = id_persona FROM administracion.Persona WHERE dni = @dni;
        END

        -- Activar socio
        SET @activo = 1;

        -- Insertar socio
        INSERT INTO administracion.Socio (
            id_persona, id_categoria, nro_socio, obra_social, nro_obra_social, saldo, activo
        )
        VALUES (
            @id_persona,
            (SELECT id_categoria FROM administracion.CategoriaSocio WHERE nombre = @categoria),
            @nro_socio,
            @obra_social,
            @nro_obra_social,
            ISNULL(@saldo, 0),
            @activo
        );
    END

    ELSE IF @operacion = 'Eliminar'
    BEGIN
        -- Obtener IDs relacionados
        SELECT 
            @id_persona = p.id_persona,
            @id_socio = s.id_socio
        FROM administracion.Persona p
        INNER JOIN administracion.Socio s ON p.id_persona = s.id_persona
        WHERE p.dni = @dni;

        IF @id_persona IS NULL OR @id_socio IS NULL
        BEGIN
            RAISERROR('No se encontró una persona y socio con ese DNI.', 16, 1);
            RETURN;
        END

        -- Marcar persona como borrada
        UPDATE administracion.Persona
        SET borrado = 1
        WHERE id_persona = @id_persona;

        -- Eliminar socio
        DELETE FROM administracion.Socio
        WHERE id_socio = @id_socio;
    END
END;
GO

/*____________________________________________________________________
  _____________________ GestionarGrupoFamiliar _____________________
  ____________________________________________________________________*/

IF OBJECT_ID('administracion.GestionarGrupoFamiliar', 'P') IS NOT NULL
    DROP PROCEDURE administracion.GestionarGrupoFamiliar;
GO

CREATE PROCEDURE administracion.GestionarGrupoFamiliar
    @dni_socio CHAR(10),
    @dni_socio_rp CHAR(10),
    @operacion CHAR(10)
AS
BEGIN
    SET NOCOUNT ON;
	/*Verificación de operaciones válidas*/
    IF @operacion NOT IN ('Insertar', 'Eliminar')
    BEGIN
        RAISERROR('Operación inválida.', 16, 1);
        RETURN;
    END
	/*CASO 1: Insertar grupo familiar*/
    IF @operacion = 'Insertar'
    BEGIN
        INSERT INTO administracion.GrupoFamiliar (id_socio, id_socio_rp)
        VALUES (
				/*Se obtiene el id_socio del socio con DNI correspondiente*/
				(SELECT S.id_socio
					FROM administracion.Socio S
					INNER JOIN Administracion.Persona P ON P.id_persona = S.id_persona
					WHERE P.dni = @dni_socio),
				/*Se obtiene el id_socio del socio con DNI correspondiente*/
				(SELECT S.id_socio
					FROM administracion.Socio S
					INNER JOIN Administracion.Persona P ON P.id_persona = S.id_persona
					WHERE P.dni = @dni_socio_rp));
    END
	/*CASO 2: Eliminar grupo familiar*/
    ELSE IF @operacion = 'Eliminar'
    BEGIN
		/*Se obtiene el id_grupo correspondiente a los DNIs de socios involucrados*/
        DELETE FROM administracion.GrupoFamiliar
		WHERE id_grupo IN (SELECT id_grupo 
						   FROM administracion.GrupoFamiliar 
						   WHERE id_socio = (SELECT S.id_socio
						   					 FROM administracion.Socio S
											 INNER JOIN Administracion.Persona P ON P.id_persona = S.id_persona
											 WHERE P.dni = @dni_socio)
						  );
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
    @dni_socio CHAR(10),
    @dni_invitado CHAR(10),
    @operacion CHAR(10)
AS
BEGIN
    SET NOCOUNT ON;
	/*Verificación de operaciones válidas*/
    IF @operacion NOT IN ('Insertar', 'Eliminar')
    BEGIN
        RAISERROR('Operación inválida.', 16, 1);
        RETURN;
    END
	/*CASO 1: Insertar invitado*/
    IF @operacion = 'Insertar'
    BEGIN
		/*Verificación de dni válido*/
        IF @dni_invitado IS NULL OR LEN(LTRIM(RTRIM(@dni_invitado))) > 8 OR @dni_invitado NOT LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
        BEGIN
			RAISERROR('DNI inválido.', 16, 1);
			RETURN;
		END
		/*Verificación de dni no existente*/
        IF @dni_invitado IN (SELECT dni FROM administracion.Persona)
        BEGIN
			RAISERROR('DNI existente.', 16, 1);
			RETURN;
		END
		/*Se obtiene el id_socio del socio con DNI correspondiente*/
        INSERT INTO administracion.Invitado (id_socio, dni)
        VALUES ((SELECT S.id_socio
					FROM administracion.Socio S
					INNER JOIN administracion.Persona P ON P.id_persona = S.id_persona
					WHERE P.dni = @dni_socio),
				@dni_invitado);
    END
	/*CASO 2: Eliminar invitado*/
    ELSE IF @operacion = 'Eliminar'
    BEGIN
        DELETE FROM administracion.Invitado
		WHERE dni = @dni_invitado;
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
  
-- Eliminar si ya existe
IF OBJECT_ID('socios.sp_ConsultarEstadoSocioyGrupo', 'P') IS NOT NULL
    DROP PROCEDURE socios.sp_ConsultarEstadoSocio;
GO

CREATE PROCEDURE socios.sp_ConsultarEstadoSocio
    @id_socio INT
AS
BEGIN
    SET NOCOUNT ON;

    --Validación: id_socio debe ser mayor a cero
    IF @id_socio <= 0
    BEGIN
        RAISERROR('El ID del socio debe ser mayor a cero.', 16, 1);
        RETURN;
    END;

    --Validación: existencia del socio
    IF NOT EXISTS (SELECT 1 FROM socios.Socio WHERE id_socio = @id_socio)
    BEGIN
        RAISERROR('No existe un socio con el ID especificado.', 16, 1);
        RETURN;
    END;

    --Validación de formato de DNI
    DECLARE @dni CHAR(8);
    SELECT @dni = dni FROM socios.Socio WHERE id_socio = @id_socio;

    IF LEN(@dni) != 8 OR ISNUMERIC(@dni) = 0
    BEGIN
        RAISERROR('El DNI debe tener exactamente 8 dígitos numéricos.', 16, 1);
        RETURN;
    END;

    --Validación básica de formato de email
    DECLARE @email VARCHAR(100);
    SELECT @email = email FROM socios.Socio WHERE id_socio = @id_socio;

    IF CHARINDEX('@', @email) = 0 OR CHARINDEX('.', @email) = 0
    BEGIN
        RAISERROR('El correo electrónico del socio no tiene un formato válido.', 16, 1);
        RETURN;
    END;

    --Información del socio titular
    SELECT 
        'Titular' AS TipoPersona,
        s.id_socio,
        s.nombre,
        s.apellido,
        s.dni,
        s.email,
        s.fecha_nacimiento,
        s.tel_contacto,
        s.tel_emergencia,
        s.obra_social,
        s.nro_obra_social,
        s.saldo,
        s.activo,
        cs.nombre AS categoria,
        cs.costo_membresia,
        gf.id_grupo,
        gf.descuento
    FROM socios.Socio s
    LEFT JOIN socios.CategoriaSocio cs ON s.id_categoria = cs.id_categoria
    LEFT JOIN socios.GrupoFamiliar gf ON s.id_grupo = gf.id_grupo
    WHERE s.id_socio = @id_socio;

    --Familiares del mismo grupo
    ;WITH GrupoFamiliarCTE AS (
        SELECT 
            'Familiar' AS TipoPersona,
            sf.id_socio,
            sf.nombre,
            sf.apellido,
            sf.dni,
            sf.email,
            sf.fecha_nacimiento,
            sf.tel_contacto,
            sf.tel_emergencia,
            sf.obra_social,
            sf.nro_obra_social,
            sf.saldo,
            sf.activo,
            csf.nombre AS categoria,
            csf.costo_membresia,
            sf.id_grupo
        FROM socios.Socio sf
        INNER JOIN socios.Socio titular ON titular.id_socio = @id_socio
        INNER JOIN socios.CategoriaSocio csf ON sf.id_categoria = csf.id_categoria
        WHERE sf.id_grupo = titular.id_grupo
          AND sf.id_socio != @id_socio
    )
    SELECT * FROM GrupoFamiliarCTE;
END;