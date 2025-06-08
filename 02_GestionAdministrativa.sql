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
	
	/*Verificación de operaciones válidas*/
	IF @operacion NOT IN ('Insertar', 'Modificar', 'Eliminar')
	BEGIN
		RAISERROR('Operación inválida. Usar Insertar, Modificar o Eliminar.', 16, 1);
        RETURN;
	END
    
	/*CASO 1: Eliminar persona. En este caso, se aplica un borrado lógico*/
	IF @operacion = 'Eliminar'
    BEGIN
		/*Verificaçión de existencia de persona a borrar.*/
        IF NOT EXISTS (SELECT 1 FROM administracion.Persona WHERE dni = @dni)
        BEGIN
            RAISERROR('No existe el DNI para eliminar.', 16, 1);
            RETURN;
        END

        UPDATE administracion.Persona
		SET borrado = 1
        WHERE dni = @dni;
    END
	/*CASO 2: Modificar datos de persona. Menos el ID y DNI, cualquier otro campo*/
    ELSE IF @operacion = 'Modificar'
    BEGIN
		/*Verificaçión de existencia de persona a modificar*/
        IF NOT EXISTS (SELECT 1 FROM administracion.Persona WHERE dni = @dni)
        BEGIN
            RAISERROR('No existe el DNI para modificar.', 16, 1);
            RETURN;
        END
		/*Se utiliza COALESCE para asegurar dato válido en caso de que algún usuario ingrese NULL en algún campo*/
        UPDATE administracion.Persona
        SET nombre = COALESCE(@nombre, nombre),
            apellido = COALESCE(@apellido, apellido),
            email = COALESCE(@email, email),
            fecha_nacimiento = COALESCE(@fecha_nacimiento, fecha_nacimiento),
            tel_contacto = COALESCE(@tel_contacto, tel_contacto),
            tel_emergencia = COALESCE(@tel_emergencia, tel_emergencia)
        WHERE dni = @dni;
    END
	/*CASO 3: Insertar persona*/
    ELSE IF @operacion = 'Insertar'
    BEGIN
		/*Verificación de datos no nulos necesarios para insertar persona*/
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
            RAISERROR('El DNI debe hasta 10 caracteres.', 16, 1);
			RETURN;
		END

        IF @fecha_nacimiento IS NULL OR @fecha_nacimiento > GETDATE()
		BEGIN
            RAISERROR('La fecha de nacimiento es inválida.', 16, 1);
			RETURN;
		END

        INSERT INTO administracion.Persona (nombre, apellido, dni, email, fecha_nacimiento, tel_contacto, tel_emergencia, borrado)
        VALUES (@nombre, @apellido, @dni, @email, @fecha_nacimiento, @tel_contacto, @tel_emergencia, 0);
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
    @nombre VARCHAR(50),
    @apellido CHAR(50),
    @dni CHAR(10),
    @email VARCHAR(70),
    @fecha_nacimiento DATE,
    @tel_contacto CHAR(15),
    @tel_emergencia CHAR(15),
    @categoria VARCHAR(50),
    @nro_socio CHAR(20),
    @obra_social VARCHAR(100),
    @nro_obra_social VARCHAR(100),
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
	/*Creación de variables auxiliares id_persona y activo*/
    DECLARE @id_persona INT;
	DECLARE @activo BIT;
	/*CASO 1: Insertar socio*/
    IF @operacion = 'Insertar'
    BEGIN
        /*Verificación de existencia de persona*/
        SET @id_persona = (SELECT 1 id_persona FROM administracion.Persona WHERE dni = @dni)

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
        END

		/*Se asigna estado activo por default*/
		SET @activo = 1;

        INSERT INTO administracion.Socio (id_persona, id_categoria, nro_socio, obra_social, nro_obra_social, saldo, activo)
        VALUES (
            @id_persona, 
			(SELECT 1 id_categoria FROM administracion.CategoriaSocio WHERE nombre = @categoria), 
			@nro_socio, 
			@obra_social, 
			@nro_obra_social, 
			0, 
			@activo
        );
    END
	/*CASO 2: Eliminación de socio*/
    ELSE IF @operacion = 'Eliminar'
    BEGIN
        /*Verificación de existencia de persona*/
        SET @id_persona = (SELECT 1 id_persona FROM administracion.Persona WHERE dni = @dni)

        IF @id_persona IS NULL
        BEGIN
            RAISERROR('No se encontró una persona con el DNI especificado.', 16, 1);
            RETURN;
        END
		/*Se borra de la tabla Persona*/
        UPDATE administracion.Persona 
		SET borrado = 1
		WHERE id_persona = @id_persona;
		/*Se borra de la tabla Socio*/
		DELETE FROM administracion.Socio
		WHERE id_persona = @id_persona
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
        IF @dni_invitado IS NULL OR LEN(LTRIM(RTRIM(@dni_invitado))) <> 10 OR @dni_invitado NOT LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
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
