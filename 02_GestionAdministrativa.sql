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
  _________________________ P_GestionarPersonas ______________________
  ____________________________________________________________________*/

IF OBJECT_ID('administracion.P_GestionarPersonas', 'P') IS NOT NULL
    DROP PROCEDURE administracion.P_GestionarPersonas;
GO

CREATE PROCEDURE administracion.P_GestionarPersonas
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

/*____________________________________________________________________
  _________________________ P_ImportarSocios _________________________
  ____________________________________________________________________*/

IF OBJECT_ID('administracion.P_ImportarSocios', 'P') IS NOT NULL
    DROP PROCEDURE administracion.P_ImportarSocios;
GO

/*CREATE PROCEDURE administracion.P_ImportarSocios
    @RutaArchivo VARCHAR(255)
AS
BEGIN
	-- Habilitar las consultas ad hoc
	EXEC sp_configure 'show advanced options', 1;
	RECONFIGURE;
	EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
	RECONFIGURE;

	IF OBJECT_ID('tempdb.##tablaAux', 'U') IS NOT NULL
		DROP TABLE ##tablaAux;
	
	CREATE TABLE ##tablaAux ( -- Tabla temporal global para la carga temporal
		id_socio INT IDENTITY(1,1) PRIMARY KEY,
		nro_socio VARCHAR(20),
		nombre VARCHAR(50),
		apellido CHAR(50),
		dni CHAR(10),
		email VARCHAR(70),
		fecha_nacimiento DATE NOT NULL,
		tel_contacto CHAR(15),
		obra_social VARCHAR(100),
		nro_obra_social INT,
		tel_emergencia CHAR(15)
	);

	-- Construir SQL dinámico para usar OPENROWSET con variable
    DECLARE @sql NVARCHAR(MAX);

    SET @sql = N'
    INSERT INTO ##tablaAux (nro_socio, nombre, apellido, dni, email, fecha_nacimiento, tel_contacto, obra_social, nro_obra_social, tel_emergencia)
    SELECT nro_socio, nombre, apellido, dni, email, fecha_nacimiento, tel_contacto, obra_social, nro_obra_social, tel_emergencia
    FROM OPENROWSET(
        ''Microsoft.ACE.OLEDB.12.0'',
        ''Excel 12.0; Database=' + @RutaArchivo + '; HDR=YES'',
        ''SELECT * FROM [Responsables de PagoA1$]''
    );';

    EXEC sp_executesql @sql;
END;*/

IF OBJECT_ID('administracion.P_ImportarSocios', 'P') IS NOT NULL
    DROP PROCEDURE administracion.P_ImportarSocios;
GO

CREATE PROCEDURE administracion.P_ImportarSocios
    @RutaArchivo VARCHAR(255)
AS
BEGIN
	--DROP TABLE tempdb.##tablaAux;
	
	CREATE TABLE ##tablaAux ( -- Tabla temporal global para la carga temporal
		nro_socio VARCHAR(20),
		nombre VARCHAR(50),
		apellido CHAR(50),
		dni CHAR(10),
		email VARCHAR(70),
		fecha_nacimiento VARCHAR(10),
		tel_contacto CHAR(15),
		obra_social VARCHAR(100),
		nro_obra_social VARCHAR(100),
		tel_emergencia CHAR(50)
	);

    DECLARE @SQL VARCHAR(MAX);
	SET @SQL = '
	BULK INSERT ##tablaAux
	FROM ''' + @RutaArchivo + '''
	WITH (
		FIELDTERMINATOR = '';'',
		ROWTERMINATOR = ''\n'',
		FIRSTROW = 2
	);';

	EXEC (@SQL);

	-- Creacion de las personas asociadas a la membresia
	DECLARE @i INT = 1;
	DECLARE @max INT;

	SELECT @max = COUNT(*) FROM ##tablaAux; -- aprovechando que es incremental

	WHILE @i <= @max
	BEGIN
		DECLARE 
			@nombre NVARCHAR(100),
			@apellido NVARCHAR(100),
			@dni VARCHAR(20),
			@email NVARCHAR(100),
			@fecha_nacimiento DATE,
			@tel_contacto VARCHAR(20),
			@tel_emergencia VARCHAR(20);

		SELECT
			@nombre = nombre,
			@apellido = apellido,
			@dni = dni,
			@email = email,
			@fecha_nacimiento = CONVERT(DATE, fecha_nacimiento, 103),
			@tel_contacto = tel_contacto,
			@tel_emergencia = tel_emergencia
		FROM ##tablaAux
		ORDER BY nro_socio
		OFFSET @i - 1 ROWS
		FETCH NEXT 1 ROW ONLY;

		IF @nombre IS NOT NULL  -- salteamos si no hay fila
		BEGIN
			EXEC administracion.P_GestionarPersonas
				@nombre = @nombre,
				@apellido = @apellido,
				@dni = @dni,
				@email = @email,
				@fecha_nacimiento = @fecha_nacimiento,
				@tel_contacto = @tel_contacto,
				@tel_emergencia = @tel_emergencia,
				@operacion = 'Insertar';
		END

		SET @i += 1;
	END
END;