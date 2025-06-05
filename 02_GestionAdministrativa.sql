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
  _________________________ P_GestionarPersona _______________________
  ____________________________________________________________________*/

IF OBJECT_ID('administracion.P_GestionarPersona', 'P') IS NOT NULL
    DROP PROCEDURE administracion.P_GestionarPersona;
GO

CREATE PROCEDURE administracion.P_GestionarPersona
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

    BEGIN TRY
		
		IF @operacion NOT IN ('Insertar', 'Modificar', 'Eliminar')
		BEGIN
			RAISERROR('Operación inválida. Usar Insertar, Modificar o Eliminar.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
		END

		IF @operacion = 'Insertar'
        BEGIN
            IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
                RAISERROR('El nombre es obligatorio.', 16, 1);

            IF @apellido IS NULL OR LTRIM(RTRIM(@apellido)) = ''
                RAISERROR('El apellido es obligatorio.', 16, 1);

            IF @dni IS NULL OR LEN(LTRIM(RTRIM(@dni))) > 10
                RAISERROR('El DNI debe hasta 10 caracteres.', 16, 1);

            IF @fecha_nacimiento IS NULL OR @fecha_nacimiento > GETDATE()
                RAISERROR('La fecha de nacimiento es inválida.', 16, 1);

        END

        BEGIN TRANSACTION;
        
		IF @operacion = 'Eliminar'
        BEGIN
            UPDATE administracion.Persona
			SET borrado = 1
            WHERE dni = @dni;
        END
        ELSE IF @operacion = 'Modificar'
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM administracion.Persona WHERE dni = @dni)
            BEGIN
                RAISERROR('No existe el DNI para modificar.', 16, 1);
                ROLLBACK TRANSACTION;
                RETURN;
            END

            UPDATE administracion.Persona
            SET nombre = @nombre,
                apellido = @apellido,
                email = @email,
                fecha_nacimiento = @fecha_nacimiento,
                tel_contacto = @tel_contacto,
                tel_emergencia = @tel_emergencia
            WHERE dni = @dni;
        END
        ELSE IF @operacion = 'Insertar'
        BEGIN
            INSERT INTO administracion.Persona (nombre, apellido, dni, email, fecha_nacimiento, tel_contacto, tel_emergencia, borrado)
            VALUES (@nombre, @apellido, @dni, @email, @fecha_nacimiento, @tel_contacto, @tel_emergencia, 0);
        END

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

/*____________________________________________________________________
  _______________________ P_GestionarProfesor ________________________
  ____________________________________________________________________*/

IF OBJECT_ID('administracion.P_GestionarProfesor', 'P') IS NOT NULL
    DROP PROCEDURE administracion.P_GestionarProfesor;
GO

CREATE PROCEDURE administracion.P_GestionarProfesor
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

    BEGIN TRY
        IF @operacion NOT IN ('Insertar', 'Eliminar')
        BEGIN
            RAISERROR('Operación inválida. Usar Insertar o Eliminar.', 16, 1);
            RETURN;
        END

        BEGIN TRANSACTION;

        DECLARE @id_persona INT;

        IF @operacion = 'Insertar'
        BEGIN
            -- Verificamos si ya existe la persona
            SELECT @id_persona = id_persona
            FROM administracion.Persona
            WHERE dni = @dni;

            -- Si no existe, la insertamos
            IF @id_persona IS NULL
            BEGIN
                EXEC administracion.P_GestionarPersona
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

            -- Insertamos al profesor

            INSERT INTO administracion.Profesor (id_persona)
            VALUES (@id_persona);
        END
        ELSE IF @operacion = 'Eliminar'
        BEGIN
            -- Obtenemos el ID de persona
            SELECT @id_persona = id_persona
            FROM administracion.Persona
            WHERE dni = @dni;

            IF @id_persona IS NULL
            BEGIN
                RAISERROR('No se encontró una persona con el DNI especificado.', 16, 1);
                ROLLBACK TRANSACTION;
                RETURN;
            END

            UPDATE administracion.Persona 
			SET borrado = 1
			WHERE id_persona = @id_persona;

        END

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

/*____________________________________________________________________
  ____________________ P_GestionarCategoriaSocio _____________________
  ____________________________________________________________________*/

IF OBJECT_ID('administracion.P_GestionarCategoriaSocio', 'P') IS NOT NULL
    DROP PROCEDURE administracion.P_GestionarCategoriaSocio;
GO

CREATE PROCEDURE administracion.P_GestionarCategoriaSocio
    @id_categoria INT = NULL,
    @nombre VARCHAR(50),
    @años INT,
    @costo_membresia DECIMAL(10,2),
    @vigencia DATE,
    @operacion CHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF @operacion NOT IN ('Insertar', 'Modificar', 'Eliminar')
        BEGIN
            RAISERROR('Operación inválida.', 16, 1);
            RETURN;
        END

        BEGIN TRANSACTION;

        IF @operacion = 'Insertar'
        BEGIN
            INSERT INTO administracion.CategoriaSocio (nombre, años, costo_membresia, vigencia)
            VALUES (@nombre, @años, @costo_membresia, @vigencia);
        END
        ELSE IF @operacion = 'Modificar'
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM administracion.CategoriaSocio WHERE id_categoria = @id_categoria)
                RAISERROR('Categoría no encontrada.', 16, 1);

            UPDATE administracion.CategoriaSocio
            SET nombre = @nombre, años = @años, costo_membresia = @costo_membresia, vigencia = @vigencia
            WHERE id_categoria = @id_categoria;
        END
        ELSE IF @operacion = 'Eliminar'
        BEGIN
            DELETE FROM administracion.CategoriaSocio WHERE id_categoria = @id_categoria;
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrMsg, 16, 1);
    END CATCH
END;
GO

/*____________________________________________________________________
  _________________________ P_GestionarSocios _________________________
  ____________________________________________________________________*/

IF OBJECT_ID('administracion.P_GestionarSocio', 'P') IS NOT NULL
    DROP PROCEDURE administracion.P_GestionarSocio;
GO

CREATE PROCEDURE administracion.P_GestionarSocio
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
    @saldo DECIMAL(10,2),
    @operacion CHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF @operacion NOT IN ('Insertar', 'Eliminar')
        BEGIN
            RAISERROR('Operación inválida. Usar Insertar o Eliminar.', 16, 1);
            RETURN;
        END

        BEGIN TRANSACTION;

        DECLARE @id_persona INT;
		DECLARE @activo BIT;

        IF @operacion = 'Insertar'
        BEGIN
            -- Verificamos si ya existe la persona
            SET @id_persona = (SELECT id_persona FROM administracion.Persona WHERE dni = @dni)

            -- Si no existe, la insertamos
            IF @id_persona IS NULL
            BEGIN
                EXEC administracion.P_GestionarPersona
					 @nombre, 
					 @apellido, 
					 @dni, 
					 @email, 
					 @fecha_nacimiento, 
					 @tel_contacto, 
					 @tel_emergencia, 
					 'Insertar'
            END

			-- Asignamos estado de activo
			SET @activo = 1;

            -- Insertamos al socio
			SET @id_persona = (SELECT id_persona FROM administracion.Persona WHERE dni = @dni)

            INSERT INTO administracion.Socio (
                id_persona, id_categoria, nro_socio, obra_social, nro_obra_social, saldo, activo
            )
            VALUES (
                @id_persona, 
				(SELECT id_categoria FROM administracion.CategoriaSocio WHERE nombre = @categoria), 
				@nro_socio, 
				@obra_social, 
				@nro_obra_social, 
				@saldo, 
				@activo
            );
        END
        ELSE IF @operacion = 'Eliminar'
        BEGIN
            -- Obtenemos el ID de persona
            SET @id_persona = (SELECT id_persona FROM administracion.Persona WHERE dni = @dni)

            IF @id_persona IS NULL
            BEGIN
                RAISERROR('No se encontró una persona con el DNI especificado.', 16, 1);
                ROLLBACK TRANSACTION;
                RETURN;
            END

            UPDATE administracion.Persona 
			SET borrado = 1
			WHERE id_persona = @id_persona;
        END

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

/*____________________________________________________________________
  _____________________ P_GestionarGrupoFamiliar _____________________
  ____________________________________________________________________*/

IF OBJECT_ID('administracion.P_GestionarGrupoFamiliar', 'P') IS NOT NULL
    DROP PROCEDURE administracion.P_GestionarGrupoFamiliar;
GO

CREATE PROCEDURE administracion.P_GestionarGrupoFamiliar
    @id_grupo INT = NULL,
    @id_socio INT,
    @id_socio_rp INT,
    @operacion CHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF @operacion NOT IN ('Insertar', 'Eliminar')
        BEGIN
            RAISERROR('Operación inválida.', 16, 1);
            RETURN;
        END

        BEGIN TRANSACTION;

        IF @operacion = 'Insertar'
        BEGIN
            INSERT INTO administracion.GrupoFamiliar (id_socio, id_socio_rp)
            VALUES (@id_socio, @id_socio_rp);
        END
        ELSE IF @operacion = 'Eliminar'
        BEGIN
            DELETE FROM administracion.GrupoFamiliar WHERE id_grupo = @id_grupo;
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrMsg, 16, 1);
    END CATCH
END;
GO

/*____________________________________________________________________
  _______________________ P_GestionarInvitado _______________________
  ____________________________________________________________________*/

IF OBJECT_ID('administracion.P_GestionarInvitado', 'P') IS NOT NULL
    DROP PROCEDURE administracion.P_GestionarInvitado;
GO

CREATE PROCEDURE administracion.P_GestionarInvitado
    @id_invitado INT = NULL,
    @id_socio INT,
    @dni VARCHAR(10),
    @operacion CHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF @operacion NOT IN ('Insertar', 'Eliminar')
        BEGIN
            RAISERROR('Operación inválida.', 16, 1);
            RETURN;
        END

        IF @operacion = 'Insertar'
        BEGIN
            IF @dni IS NULL OR LEN(LTRIM(RTRIM(@dni))) <> 10 OR @dni NOT LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
                RAISERROR('DNI inválido.', 16, 1);
        END

        BEGIN TRANSACTION;

        IF @operacion = 'Insertar'
        BEGIN
            INSERT INTO administracion.Invitado (id_socio, dni)
            VALUES (@id_socio, @dni);
        END
        ELSE IF @operacion = 'Eliminar'
        BEGIN
            DELETE FROM administracion.Invitado WHERE id_invitado = @id_invitado;
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrMsg, 16, 1);
    END CATCH
END;
GO
