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

/*_________________________ GESTIONAR PERSONAS _________________________*/
IF OBJECT_ID('administracion.spGestionarPersonas', 'P') IS NOT NULL
    DROP PROCEDURE administracion.spGestionarPersonas;
GO

CREATE PROCEDURE administracion.spGestionarPersonas
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
        ELSE
        BEGIN
            RAISERROR('Operación inválida. Usar Insertar, Modificar o Eliminar.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
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

/*_________________________ GESTIONAR AREAS _________________________*/
IF OBJECT_ID('administracion.spGestionarAreas', 'P') IS NOT NULL
    DROP PROCEDURE administracion.spGestionarAreas;
GO

CREATE PROCEDURE administracion.spGestionarAreas
    @nombre VARCHAR(100),
    @descripcion VARCHAR(200),
	@operacion CHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF @operacion = 'Eliminar'
        BEGIN
            DELETE FROM administracion.Area
            WHERE nombre = @nombre;
        END
        ELSE IF @operacion = 'Modificar'
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM administracion.Area WHERE nombre = @nombre)
            BEGIN
                RAISERROR('No existe el área para modificar.', 16, 1);
                ROLLBACK TRANSACTION;
                RETURN;
            END

            UPDATE administracion.Area
            SET descripcion = @descripcion
            WHERE nombre = @nombre;
        END
        ELSE IF @operacion = 'Insertar'
        BEGIN
            INSERT INTO administracion.Area (nombre, descripcion)
            VALUES (@nombre, @descripcion);
        END
        ELSE
        BEGIN
            RAISERROR('Operación inválida. Usar Insertar, Modificar o Eliminar.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
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

/*_________________________ GESTIONAR ROLES _________________________*/
IF OBJECT_ID('administracion.spGestionarAreas', 'P') IS NOT NULL
    DROP PROCEDURE administracion.spGestionarRoles;
GO

CREATE PROCEDURE administracion.spGestionarRoles
    @nombre VARCHAR(100),
    @descripcion VARCHAR(200),
	@id_area INT,
	@operacion CHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF @operacion = 'Eliminar'
        BEGIN
            DELETE FROM administracion.Rol
            WHERE nombre = @nombre AND id_area = @id_area;
        END
        ELSE IF @operacion = 'Modificar'
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM administracion.Rol WHERE nombre = @nombre)
            BEGIN
                RAISERROR('No existe el rol en el área indicada para modificar.', 16, 1);
                ROLLBACK TRANSACTION;
                RETURN;
            END

            UPDATE administracion.Rol
            SET descripcion = @descripcion
            WHERE nombre = @nombre AND id_area = @id_area;
        END
        ELSE IF @operacion = 'Insertar'
        BEGIN
            INSERT INTO administracion.Rol (nombre, descripcion, id_area)
            VALUES (@nombre, @descripcion, @id_area);
        END
        ELSE
        BEGIN
            RAISERROR('Operación inválida. Usar Insertar, Modificar o Eliminar.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
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