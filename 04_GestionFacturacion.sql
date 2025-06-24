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
  _______________________ GestionarActividad ________________________
  ____________________________________________________________________*/
IF OBJECT_ID('actividades.GestionarActividad', 'P') IS NOT NULL
    DROP PROCEDURE actividades.GestionarActividad;
GO

CREATE PROCEDURE actividades.GestionarActividad
    @nombre    VARCHAR(100),
    @costo     DECIMAL(10,2),
    @vigencia  DATE,
    @operacion CHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar operación
    IF @operacion NOT IN ('Insertar','Modificar','Eliminar')
    BEGIN
        RAISERROR('Operación inválida. Usar Insertar, Modificar o Eliminar.', 16, 1);
        RETURN;
    END

    -- Eliminar actividad y clases asociadas
    IF @operacion = 'Eliminar'
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM actividades.Actividad WHERE descripcion = @nombre)
        BEGIN
            RAISERROR('No existe la actividad para eliminar.', 16, 1);
            RETURN;
        END

        DECLARE @id_actividad INT = (
            SELECT id_actividad FROM actividades.Actividad WHERE descripcion = @nombre
        );

        BEGIN TRY
            BEGIN TRANSACTION;

            -- Eliminar presentismo
            DELETE pc
            FROM actividades.presentismoClase AS pc
			INNER JOIN actividades.InscriptoClase ic ON ic.id_inscripcion = pc.id_inscripcion
            INNER JOIN actividades.Clase AS c ON ic.id_clase = c.id_clase
            WHERE c.id_actividad = @id_actividad;

            -- Eliminar inscripciones
            DELETE ic
            FROM actividades.InscriptoClase AS ic
            INNER JOIN actividades.Clase AS c ON ic.id_clase = c.id_clase
            WHERE c.id_actividad = @id_actividad;

            -- Eliminar clases
            DELETE FROM actividades.Clase WHERE id_actividad = @id_actividad;

            -- Eliminar actividad
            DELETE FROM actividades.Actividad WHERE id_actividad = @id_actividad;

            COMMIT TRANSACTION;
        END TRY
        BEGIN CATCH
            IF XACT_STATE() <> 0
                ROLLBACK TRANSACTION;
            THROW;
        END CATCH
        RETURN;
    END

    -- Modificar valores base
    IF @operacion = 'Modificar'
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM actividades.Actividad WHERE descripcion = @nombre)
        BEGIN
            RAISERROR('No existe la actividad para modificar.', 16, 1);
            RETURN;
        END

        UPDATE actividades.Actividad
        SET 
            costo    = COALESCE(@costo, costo),
            vigencia = COALESCE(@vigencia, vigencia)
        WHERE descripcion = @nombre;

        RETURN;
    END

    -- Insertar nueva actividad
    IF @operacion = 'Insertar'
    BEGIN
        IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
        BEGIN
            RAISERROR('El nombre es obligatorio.', 16, 1);
            RETURN;
        END

        IF @costo IS NULL OR @costo < 0
        BEGIN
            RAISERROR('El costo debe ser un número positivo.', 16, 1);
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM actividades.Actividad WHERE descripcion = @nombre)
        BEGIN
            RAISERROR('Ya existe una actividad con ese nombre.', 16, 1);
            RETURN;
        END

        INSERT INTO actividades.Actividad (descripcion, costo, vigencia)
        VALUES (@nombre, @costo, @vigencia);
        RETURN;
    END
END;
GO

/*____________________________________________________________________
  __________________________ GestionarClase __________________________
  ____________________________________________________________________*/

IF OBJECT_ID('actividades.GestionarClase', 'P') IS NOT NULL
    DROP PROCEDURE actividades.GestionarClase;
GO

CREATE PROCEDURE actividades.GestionarClase
    @nombre_actividad	VARCHAR(100),
    @nombre_profesor    VARCHAR(50),
	@apellido_profesor	VARCHAR(50),
    @horario			VARCHAR(20),
    @nombre_categoria	VARCHAR(50),
    @operacion			CHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    IF @operacion NOT IN ('Insertar','Modificar','Eliminar')
    BEGIN
        RAISERROR('Operación inválida. Usar Insertar, Modificar o Eliminar.', 16, 1);
        RETURN;
    END

    DECLARE @id_actividad INT;
    DECLARE @id_clase     INT;
    DECLARE @id_categoria INT;

    /* Obtener IDs */
    
    SET @id_categoria = (SELECT id_categoria FROM socios.CategoriaSocio WHERE descripcion = @nombre_categoria);

	SET @id_actividad = (SELECT id_actividad FROM actividades.Actividad WHERE descripcion = @nombre_actividad)

	IF @operacion = 'Insertar'
    BEGIN

		IF @id_actividad IS NULL
		BEGIN
			RAISERROR('No existe la actividad ingresada.', 16, 1);
			RETURN;
		END
		IF @nombre_profesor IS NULL OR @apellido_profesor IS NULL
		BEGIN
			RAISERROR('No existe el profesor con nombre y apellido ingresados.', 16, 1);
			RETURN;
		END
		IF @id_categoria IS NULL
		BEGIN
			RAISERROR('No existe la categoría de socio ingresada.', 16, 1);
			RETURN;
		END

        INSERT INTO actividades.Clase (id_actividad, nombre_profesor, apellido_profesor, id_categoria, horario)
        VALUES (@id_actividad, @nombre_profesor, @apellido_profesor, @id_categoria, @horario);
        RETURN;
    END

    IF @operacion = 'Modificar'
    BEGIN
        SET @id_clase = (
            SELECT C.id_clase
            FROM actividades.Clase C
            WHERE C.id_actividad = @id_actividad
              AND C.nombre_profesor = @nombre_profesor
			  AND C.apellido_profesor = @apellido_profesor
              AND C.horario = @horario
        );
        IF @id_clase IS NULL
        BEGIN
            RAISERROR('No se encontró la clase para modificar.', 16, 1);
            RETURN;
        END

        UPDATE actividades.Clase
        SET id_actividad = @id_actividad,
            nombre_profesor  = @nombre_profesor,
			apellido_profesor = @apellido_profesor,
            id_categoria = @id_categoria,
            horario      = @horario
        WHERE id_clase = @id_clase;
        RETURN;
    END

    IF @operacion = 'Eliminar'
    BEGIN
        SET @id_clase = (
            SELECT id_clase
            FROM actividades.Clase
            WHERE id_actividad = @id_actividad
              AND nombre_profesor = @nombre_profesor
			  AND apellido_profesor = @apellido_profesor
              AND horario = @horario
              AND id_categoria = @id_categoria
        );
        IF @id_clase IS NULL
        BEGIN
            RAISERROR('No se encontró la clase a eliminar.', 16, 1);
            RETURN;
        END

        DELETE FROM actividades.Clase
        WHERE id_clase = @id_clase;
        RETURN;
    END
END;
GO

/*____________________________________________________________________
  ____________________ GestionarInscriptoClase _______________________
  ____________________________________________________________________*/
IF OBJECT_ID('actividades.GestionarInscriptoClase', 'P') IS NOT NULL
    DROP PROCEDURE actividades.GestionarInscriptoClase;
GO

CREATE PROCEDURE actividades.GestionarInscriptoClase
    @dni_socio VARCHAR(10),
    @nombre_actividad VARCHAR(100),
    @horario VARCHAR(50),
    @nombre_categoria VARCHAR(50),
    @fecha_inscripcion DATE,
    @operacion CHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar operación
    IF @operacion NOT IN ('Insertar', 'Modificar', 'Eliminar')
    BEGIN
        RAISERROR('Operación inválida. Usar Insertar, Modificar o Eliminar.', 16, 1);
        RETURN;
    END

    -- Buscar ID de socio activo
    DECLARE @id_socio INT = (
        SELECT TOP 1 id_socio
        FROM socios.Socio
        WHERE dni = @dni_socio AND activo = 1 AND eliminado = 0
    );

    -- Buscar ID de clase correspondiente
    DECLARE @id_clase INT = (
        SELECT TOP 1 C.id_clase
        FROM actividades.Clase C
        JOIN actividades.Actividad A ON A.id_actividad = C.id_actividad
        JOIN socios.CategoriaSocio Ca ON Ca.id_categoria = C.id_categoria
        WHERE A.descripcion = @nombre_actividad
          AND C.horario = @horario
          AND Ca.descripcion = @nombre_categoria
    );

    -- Buscar inscripción existente
    DECLARE @id_inscripcion INT = (
        SELECT TOP 1 IC.id_inscripcion
        FROM actividades.InscriptoClase IC
        WHERE IC.id_socio = @id_socio AND IC.id_clase = @id_clase
    );

    -- === Eliminar ===
    IF @operacion = 'Eliminar'
    BEGIN
        IF @id_inscripcion IS NULL
        BEGIN
            RAISERROR('No existe la inscripción para eliminar.', 16, 1);
            RETURN;
        END

        DELETE FROM actividades.InscriptoClase WHERE id_inscripcion = @id_inscripcion;
        RETURN;
    END

    -- === Modificar ===
    IF @operacion = 'Modificar'
    BEGIN
        IF @id_inscripcion IS NULL
        BEGIN
            RAISERROR('No existe la inscripción para modificar.', 16, 1);
            RETURN;
        END

        UPDATE actividades.InscriptoClase
        SET fecha = COALESCE(@fecha_inscripcion, fecha)
        WHERE id_inscripcion = @id_inscripcion;
        RETURN;
    END

    -- === Insertar ===
    IF @operacion = 'Insertar'
    BEGIN
        IF @id_socio IS NULL
        BEGIN
            RAISERROR('El socio no existe o no está activo.', 16, 1);
            RETURN;
        END

        IF @id_clase IS NULL
        BEGIN
            RAISERROR('La clase no existe con esos parámetros.', 16, 1);
            RETURN;
        END

        IF EXISTS (
            SELECT 1
            FROM actividades.InscriptoClase
            WHERE id_socio = @id_socio AND id_clase = @id_clase
        )
        BEGIN
            RAISERROR('El socio ya está inscripto en esa clase.', 16, 1);
            RETURN;
        END

        IF @fecha_inscripcion IS NULL
            SET @fecha_inscripcion = GETDATE();

        INSERT INTO actividades.InscriptoClase (id_socio, id_clase, fecha)
        VALUES (@id_socio, @id_clase, @fecha_inscripcion);
        RETURN;
    END
END;
GO

/*____________________________________________________________________
  _____________________ GestionarPresentismoClase ____________________
  ____________________________________________________________________*/

IF OBJECT_ID('actividades.GestionarPresentismoClase', 'P') IS NOT NULL
    DROP PROCEDURE actividades.GestionarPresentismoClase;
GO

CREATE PROCEDURE actividades.GestionarPresentismoClase
    @dni_socio VARCHAR(10),
	@nombre_actividad VARCHAR(100),
    @horario VARCHAR(20),
    @nombre_categoria VARCHAR(50),
    @fecha DATE,
    @estado CHAR(1) = NULL,
    @operacion CHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @id_clase INT;
	DECLARE @id_socio INT;
	DECLARE @id_presentismo INT;
	DECLARE @id_inscripcion INT;

    -- Validación de operación
    IF @operacion NOT IN ('Insertar', 'Modificar', 'Eliminar')
    BEGIN
        RAISERROR('Operación inválida. Usar Insertar, Modificar o Eliminar.', 16, 1);
        RETURN;
    END

    -- Obtener ID de clase considerando también la categoría
    SET @id_clase = (
        SELECT C.id_clase
        FROM actividades.Clase C
        JOIN actividades.Actividad A ON A.id_actividad = C.id_actividad
        JOIN socios.CategoriaSocio Ca ON Ca.id_categoria = C.id_categoria
        WHERE A.descripcion = @nombre_actividad
          AND C.horario = @horario
          AND Ca.descripcion = @nombre_categoria
    );

    -- Obtener ID del socio
    SET @id_socio = (
        SELECT id_socio
        FROM socios.Socio
        WHERE dni = @dni_socio
    );

	-- Buscar inscripción existente
    SET @id_inscripcion = (
        SELECT TOP 1 id_inscripcion 
		FROM actividades.InscriptoClase IC
		INNER JOIN actividades.Clase C ON C.id_clase = IC.id_clase
		WHERE C.id_clase = @id_clase AND IC.id_socio = @id_socio
    );

	-- Buscar presentismo existente
    SET @id_presentismo = (
        SELECT TOP 1 id_presentismo
        FROM actividades.presentismoClase PC
		INNER JOIN actividades.InscriptoClase IC ON IC.id_inscripcion = PC.id_inscripcion
		INNER JOIN actividades.Clase C ON C.id_clase = IC.id_clase
        WHERE C.id_clase = @id_clase AND IC.id_inscripcion = @id_inscripcion AND PC.fecha = @fecha
    );

    -- === Eliminar ===
    IF @operacion = 'Eliminar'
    BEGIN
        IF @id_presentismo IS NULL
        BEGIN
            RAISERROR('No existe el presentismo para eliminar.', 16, 1);
            RETURN;
        END

        DELETE FROM actividades.presentismoClase WHERE id_presentismo = @id_presentismo;
        RETURN;
    END

    -- === Modificar ===
    IF @operacion = 'Modificar'
    BEGIN
        IF @id_presentismo IS NULL
        BEGIN
            RAISERROR('No existe el presentismo para modificar.', 16, 1);
            RETURN;
        END

        UPDATE actividades.presentismoClase
        SET id_inscripcion = COALESCE(@id_inscripcion, id_inscripcion),
            fecha = COALESCE(@fecha, fecha),
            estado = COALESCE(@estado, estado)
        WHERE id_presentismo = @id_presentismo;
        RETURN;
    END

    -- === Insertar ===
    IF @operacion = 'Insertar'
    BEGIN
        IF @id_clase IS NULL
        BEGIN
            RAISERROR('La clase especificada no existe.', 16, 1);
            RETURN;
        END

        IF @id_socio IS NULL
        BEGIN
            RAISERROR('El socio especificado no existe.', 16, 1);
            RETURN;
        END

		IF @id_socio IN (SELECT id_socio 
						 FROM socios.Socio 
						 WHERE activo = 0
						 AND eliminado = 0)
        BEGIN
            RAISERROR('El socio especificado se encuentra inactivo.', 16, 1);
            RETURN;
        END

        IF @fecha IS NULL
            SET @fecha = GETDATE();

        IF @estado IS NULL
            SET @estado = 'P';

        -- Validación: evitar duplicados exactos
        IF EXISTS (
            SELECT 1
            FROM actividades.presentismoClase PC
            INNER JOIN actividades.InscriptoClase IC ON IC.id_inscripcion = PC.id_inscripcion
			INNER JOIN actividades.Clase C ON C.id_clase = IC.id_clase
			WHERE C.id_clase = @id_clase AND IC.id_inscripcion = @id_inscripcion AND PC.fecha = @fecha
        )
        BEGIN
            RAISERROR('Ya existe un presentismo registrado para esa clase, socio y fecha.', 16, 1);
            RETURN;
        END

        INSERT INTO actividades.presentismoClase (id_inscripcion, fecha, estado)
        VALUES (
			@id_inscripcion, 
			@fecha, 
			@estado);
        RETURN;
    END
END;
GO

/*____________________________________________________________________
  __________________ GestionarTarifaColoniaFactura ___________________
  ____________________________________________________________________*/

IF OBJECT_ID('tarifas.GestionarTarifaColoniaVerano', 'P') IS NOT NULL
    DROP PROCEDURE tarifas.GestionarTarifaColoniaVerano;
GO

CREATE PROCEDURE tarifas.GestionarTarifaColoniaVerano
	@descripcion VARCHAR(100),
    @monto DECIMAL(10,2),
	@categoria VARCHAR(50),
	@periodo CHAR(10),
	@operacion CHAR(10)
AS
BEGIN

	/* Verificación de operaciones válidas */
    IF @operacion NOT IN ('Insertar', 'Modificar', 'Eliminar')
    BEGIN
        RAISERROR('Operación inválida. Usar Insertar, Modificar o Eliminar.', 16, 1);
        RETURN;
    END
	
	IF @operacion = 'Insertar'
	BEGIN

		IF @descripcion IS NULL
		BEGIN
			RAISERROR('Descripción obligatoria para insertar.', 16, 1);
			RETURN;
		END

		IF @monto IS NULL
		BEGIN
			RAISERROR('Monto obligatorio para insertar.', 16, 1);
			RETURN;
		END

		IF @categoria IS NULL
		BEGIN
			RAISERROR('Categoria obligatoria para insertar.', 16, 1);
			RETURN;
		END

		IF @categoria IS NULL
		BEGIN
			RAISERROR('Categoria obligatoria para insertar.', 16, 1);
			RETURN;
		END

		IF @periodo IS NULL
		BEGIN
			RAISERROR('Periodo obligatoria para insertar.', 16, 1);
			RETURN;
		END

		IF EXISTS (SELECT TOP 1 id_tarifa 
				   FROM tarifas.TarifaColoniaVerano 
				   WHERE descripcion = @descripcion
				   AND categoria = @categoria
				   AND periodo = @periodo)
		BEGIN
			RAISERROR('Tarifa de colonia de verano ya existente.', 16, 1);
        RETURN;
    END
	END
	ELSE IF @operacion = 'Modificar'
	BEGIN
		UPDATE tarifas.TarifaColoniaVerano
		SET monto = COALESCE(@monto, monto),
			@categoria = COALESCE(@categoria, categoria),
			@periodo = COALESCE(@periodo, periodo)
		WHERE descripcion = @descripcion
	END
	ELSE 
	BEGIN
		DELETE FROM tarifas.TarifaColoniaVerano
		WHERE descripcion = @descripcion
	END

END;
GO

/*____________________________________________________________________
  ____________________ GestionarInscriptoColonia _____________________
  ____________________________________________________________________*/
IF OBJECT_ID('actividades.GestionarInscriptoColonia', 'P') IS NOT NULL
    DROP PROCEDURE actividades.GestionarInscriptoColonia;
GO

CREATE PROCEDURE actividades.GestionarInscriptoColonia
    @dni_socio VARCHAR(10),
    @descripcion_tarifa VARCHAR(100),
	@periodo CHAR(10),
    @descripcion_categoria VARCHAR(50),
    @fecha_inscripcion DATE,
    @operacion CHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @id_socio INT;
	DECLARE @id_tarifa INT;
	DECLARE @id_inscripcion INT;

    -- Validar operación
    IF @operacion NOT IN ('Insertar', 'Modificar', 'Eliminar')
    BEGIN
        RAISERROR('Operación inválida. Usar Insertar, Modificar o Eliminar.', 16, 1);
        RETURN;
    END

    -- Buscar ID de socio activo
    SET @id_socio = (
        SELECT TOP 1 id_socio
        FROM socios.Socio
        WHERE dni = @dni_socio AND activo = 1 AND eliminado = 0
    );

    -- Buscar tarifa correspondiente
    SET @id_tarifa = (
		SELECT TOP 1 id_tarifa
		FROM tarifas.TarifaColoniaVerano
		WHERE descripcion = @descripcion_tarifa
		AND periodo = @periodo
		AND categoria = @descripcion_categoria
	)

    -- === Insertar ===
    IF @operacion = 'Insertar'
    BEGIN
        IF @id_socio IS NULL
        BEGIN
            RAISERROR('El socio no existe o no está activo.', 16, 1);
            RETURN;
        END

        IF @id_tarifa IS NULL
        BEGIN
            RAISERROR('La tarifa de colonia de verano no existe con esos parámetros.', 16, 1);
            RETURN;
        END

		IF @periodo IS NULL
        BEGIN
            RAISERROR('El periodo de colonia de verano indicado no existe.', 16, 1);
            RETURN;
        END

		IF @descripcion_tarifa IS NULL
        BEGIN
            RAISERROR('El periodo de colonia de verano indicado no existe.', 16, 1);
            RETURN;
        END

		IF @descripcion_categoria IS NULL
        BEGIN
            RAISERROR('El categoria de colonia de verano indicado no existe.', 16, 1);
            RETURN;
        END

        IF EXISTS (
            SELECT id_inscripcion
            FROM actividades.InscriptoColoniaVerano
            WHERE id_socio = @id_socio AND id_tarifa = @id_tarifa
        )
        BEGIN
            RAISERROR('El socio ya está inscripto en esa clase.', 16, 1);
            RETURN;
        END

        IF @fecha_inscripcion IS NULL
            SET @fecha_inscripcion = GETDATE();

        INSERT INTO actividades.InscriptoColoInscriptoColoniaVerano(id_socio, id_tarifa, fecha, monto)
        VALUES (
			@id_socio, 
			@id_tarifa, 
			@fecha_inscripcion, 
			(SELECT TOP 1 monto
			 FROM tarifas.TarifaColoniaVerano
			 WHERE descripcion = @descripcion_tarifa
			 AND periodo = @periodo
			 AND categoria = @descripcion_categoria));
        RETURN;
    END
	-- === Modificar ===
    ELSE IF @operacion = 'Modificar'
    BEGIN
        IF @id_inscripcion IS NULL
        BEGIN
            RAISERROR('No existe la inscripción para modificar.', 16, 1);
            RETURN;
        END

        UPDATE actividades.InscriptoColoniaVerano
        SET fecha = COALESCE(@fecha_inscripcion, fecha)
        WHERE id_inscripcion = @id_inscripcion;
        RETURN;
    END
	-- === Eliminar ===
    ELSE IF @operacion = 'Eliminar'
    BEGIN

		SET @id_inscripcion = (SELECT id_inscripcion
							   FROM actividades.InscriptoColoniaVerano
							   WHERE id_tarifa = @id_tarifa
							   AND id_socio = @id_socio)

        IF @id_inscripcion IS NULL
        BEGIN
            RAISERROR('No existe la inscripción para eliminar.', 16, 1);
            RETURN;
        END

        DELETE FROM actividades.InscriptoColoniaVerano
		WHERE id_inscripcion = @id_inscripcion;
        RETURN;
    END
END;
GO

/*____________________________________________________________________
  ____________________ GestionarTarifaReservaSum _____________________
  ____________________________________________________________________*/

IF OBJECT_ID('tarifas.GestionarTarifaReservaSum', 'P') IS NOT NULL
    DROP PROCEDURE tarifas.GestionarTarifaReservaSum;
GO

CREATE PROCEDURE tarifas.GestionarTarifaReservaSum
	@descripcion VARCHAR(100),
    @monto DECIMAL(10,2),
	@operacion CHAR(10)
AS
BEGIN

	DECLARE @id_tarifa INT;

	/* Verificación de operaciones válidas */
    IF @operacion NOT IN ('Insertar', 'Modificar', 'Eliminar')
    BEGIN
        RAISERROR('Operación inválida. Usar Insertar, Modificar o Eliminar.', 16, 1);
        RETURN;
    END

	IF @operacion = 'Insertar'
	BEGIN
		IF @descripcion IS NULL
		BEGIN
			RAISERROR('Descripción obligatoria para insertar.', 16, 1);
			RETURN;
		END

		IF @monto IS NULL
		BEGIN
			RAISERROR('Monto obligatorio para insertar.', 16, 1);
			RETURN;
		END

		IF EXISTS (SELECT TOP 1 id_tarifa 
			       FROM tarifas.TarifaReservaSum 
				   WHERE descripcion = @descripcion)
		BEGIN
			RAISERROR('Tarifa de reserva de SUM ya existente.', 16, 1);
        RETURN;
    END
	END
	ELSE IF @operacion = 'Modificar'
	BEGIN
		UPDATE tarifas.TarifaReservaSum
		SET monto = COALESCE(@monto, monto)
		WHERE descripcion = @descripcion
	END
	ELSE 
	BEGIN
		
		SET @id_tarifa = (SELECT id_tarifa
						  FROM tarifas.TarifaReservaSum
						  WHERE descripcion = @descripcion)

        IF @id_tarifa IS NULL
        BEGIN
            RAISERROR('No existe la tarifa para eliminar.', 16, 1);
            RETURN;
        END
		
		DELETE FROM tarifas.TarifaReservaSum
		WHERE descripcion = @descripcion
	END

END;
GO

/*____________________________________________________________________
  __________________ GestionarTarifaColoniaVerano ____________________
  ____________________________________________________________________*/

IF OBJECT_ID('tarifas.GestionarTarifaColoniaVerano', 'P') IS NOT NULL
    DROP PROCEDURE tarifas.GestionarTarifaColoniaVerano;
GO

CREATE PROCEDURE tarifas.GestionarTarifaColoniaVerano
	@descripcion VARCHAR(100),
    @monto DECIMAL(10,2),
	@categoria VARCHAR(50),
	@periodo CHAR(10),
	@operacion CHAR(10)
AS
BEGIN

	/* Verificación de operaciones válidas */
    IF @operacion NOT IN ('Insertar', 'Modificar', 'Eliminar')
    BEGIN
        RAISERROR('Operación inválida. Usar Insertar, Modificar o Eliminar.', 16, 1);
        RETURN;
    END
	
	IF @operacion = 'Insertar'
	BEGIN

		IF @descripcion IS NULL
		BEGIN
			RAISERROR('Descripción obligatoria para insertar.', 16, 1);
			RETURN;
		END

		IF @monto IS NULL
		BEGIN
			RAISERROR('Monto obligatorio para insertar.', 16, 1);
			RETURN;
		END

		IF @categoria IS NULL
		BEGIN
			RAISERROR('Categoria obligatoria para insertar.', 16, 1);
			RETURN;
		END

		IF @categoria IS NULL
		BEGIN
			RAISERROR('Categoria obligatoria para insertar.', 16, 1);
			RETURN;
		END

		IF @periodo IS NULL
		BEGIN
			RAISERROR('Periodo obligatoria para insertar.', 16, 1);
			RETURN;
		END

		IF EXISTS (SELECT TOP 1 id_tarifa 
				   FROM tarifas.TarifaColoniaVerano 
				   WHERE descripcion = @descripcion
				   AND categoria = @categoria
				   AND periodo = @periodo)
		BEGIN
			RAISERROR('Tarifa de colonia de verano ya existente.', 16, 1);
        RETURN;
    END
	END
	ELSE IF @operacion = 'Modificar'
	BEGIN
		UPDATE tarifas.TarifaColoniaVerano
		SET monto = COALESCE(@monto, monto),
			@categoria = COALESCE(@categoria, categoria),
			@periodo = COALESCE(@periodo, periodo)
		WHERE descripcion = @descripcion
	END
	ELSE 
	BEGIN
		DELETE FROM tarifas.TarifaColoniaVerano
		WHERE descripcion = @descripcion
	END

END;
GO

/*____________________________________________________________________
  ____________________ GestionarInscriptoPileta ______________________
  ____________________________________________________________________*/
IF OBJECT_ID('actividades.GestionarInscriptoPileta', 'P') IS NOT NULL
    DROP PROCEDURE actividades.GestionarInscriptoPileta;
GO

CREATE PROCEDURE actividades.GestionarInscriptoPileta
    @dni_socio VARCHAR(10),
    @descripcion_tarifa VARCHAR(100),
	@periodo CHAR(10),
    @descripcion_categoria VARCHAR(50),
	@es_invitado BIT,
    @fecha_inscripcion DATE,
    @operacion CHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @id_socio INT;
	DECLARE @id_tarifa INT;
	DECLARE @id_inscripcion INT;

    -- Validar operación
    IF @operacion NOT IN ('Insertar', 'Modificar', 'Eliminar')
    BEGIN
        RAISERROR('Operación inválida. Usar Insertar, Modificar o Eliminar.', 16, 1);
        RETURN;
    END

    -- Buscar ID de socio activo
    SET @id_socio = (
        SELECT TOP 1 id_socio
        FROM socios.Socio
        WHERE dni = @dni_socio AND activo = 1 AND eliminado = 0
    );

    -- Buscar tarifa correspondiente
    SET @id_tarifa = (
		SELECT TOP 1 id_tarifa
		FROM tarifas.TarifaPiletaVerano
		WHERE descripcion = @descripcion_tarifa
		AND categoria = @descripcion_categoria
	)
	-- Buscar ID de inscripcion
	SET @id_inscripcion = (SELECT id_inscripcion
						   FROM actividades.InscriptoPiletaVerano
						   WHERE id_tarifa = @id_tarifa
						   AND id_socio = @id_socio)

    -- === Insertar ===
    IF @operacion = 'Insertar'
    BEGIN

        IF @id_tarifa IS NULL
        BEGIN
            RAISERROR('La tarifa de colonia de verano no existe con esos parámetros.', 16, 1);
            RETURN;
        END

		IF @periodo IS NULL
        BEGIN
            RAISERROR('El periodo de colonia de verano indicado no existe.', 16, 1);
            RETURN;
        END

		IF @descripcion_tarifa IS NULL
        BEGIN
            RAISERROR('El periodo de colonia de verano indicado no existe.', 16, 1);
            RETURN;
        END

		IF @es_invitado IS NULL
        BEGIN
            RAISERROR('La condición de invitado indicado no existe.', 16, 1);
            RETURN;
        END

        IF EXISTS (
            SELECT id_inscripcion
            FROM actividades.InscriptoPiletaVerano
            WHERE id_socio = @id_socio AND id_tarifa = @id_tarifa
        )
        BEGIN
            RAISERROR('El socio ya está inscripto en esa clase.', 16, 1);
            RETURN;
        END

        IF @fecha_inscripcion IS NULL
            SET @fecha_inscripcion = GETDATE();

        INSERT INTO actividades.InscriptoPiletaVerano(id_socio, id_tarifa, fecha, monto)
        VALUES (
			@id_socio, 
			@id_tarifa,
			@fecha_inscripcion, 
			(SELECT TOP 1 monto
			 FROM tarifas.TarifaColoniaVerano
			 WHERE descripcion = @descripcion_tarifa
			 AND periodo = @periodo
			 AND categoria = @descripcion_categoria));
        RETURN;
    END
	-- === Modificar ===
    ELSE IF @operacion = 'Modificar'
    BEGIN
        IF @id_inscripcion IS NULL
        BEGIN
            RAISERROR('No existe la inscripción para modificar.', 16, 1);
            RETURN;
        END

        UPDATE actividades.InscriptoPiletaVerano
        SET fecha = COALESCE(@fecha_inscripcion, fecha)
        WHERE id_inscripcion = @id_inscripcion;
        RETURN;
    END
	-- === Eliminar ===
    ELSE IF @operacion = 'Eliminar'
    BEGIN
		IF @id_inscripcion IS NULL
        BEGIN
            RAISERROR('No existe la inscripción para eliminar.', 16, 1);
            RETURN;
        END

        DELETE FROM actividades.InscriptoPiletaVerano 
		WHERE id_inscripcion = @id_inscripcion;
        RETURN;
    END
END;
GO

/*____________________________________________________________________
  ___________________ GestionarTarifaPiletaVerano ____________________
  ____________________________________________________________________*/

IF OBJECT_ID('tarifas.GestionarTarifaPiletaVerano', 'P') IS NOT NULL
    DROP PROCEDURE tarifas.GestionarTarifaPiletaVerano;
GO

CREATE PROCEDURE tarifas.GestionarTarifaPiletaVerano
	@descripcion VARCHAR(100),
    @monto DECIMAL(10,2),
	@categoria VARCHAR(50),
	@es_invitado BIT,
	@operacion CHAR(10)
AS
BEGIN
	
	DECLARE @id_tarifa INT;

	/* Verificación de operaciones válidas */
	IF @operacion NOT IN ('Insertar', 'Modificar', 'Eliminar')
	BEGIN
		RAISERROR('Operación inválida. Usar Insertar, Modificar o Eliminar.', 16, 1);
		RETURN;
	END

	IF @operacion = 'Insertar'
	BEGIN

		IF @descripcion IS NULL
		BEGIN
			RAISERROR('Descripción obligatoria para insertar.', 16, 1);
			RETURN;
		END

		IF @monto IS NULL
		BEGIN
			RAISERROR('Monto obligatorio para insertar.', 16, 1);
			RETURN;
		END

		IF @categoria IS NULL
		BEGIN
			RAISERROR('Categoria obligatoria para insertar.', 16, 1);
			RETURN;
		END

		IF @es_invitado IS NULL
		BEGIN
			RAISERROR('Condicion de invitado obligatoria para insertar.', 16, 1);
			RETURN;
		END

		IF EXISTS (SELECT TOP 1 id_tarifa 
				   FROM tarifas.TarifaPiletaVerano
				   WHERE descripcion = @descripcion
				   AND @es_invitado = @es_invitado
				   AND @categoria = categoria)
		BEGIN
			RAISERROR('Tarifa de pileta de verano ya existente.', 16, 1);
        RETURN;
    END
	END
	ELSE IF @operacion = 'Modificar'
	BEGIN
		UPDATE tarifas.TarifaPiletaVerano
		SET 
			monto = COALESCE(@monto, monto),
			es_invitado = COALESCE(@es_invitado, es_invitado),
			categoria = COALESCE(@categoria, categoria)
		WHERE descripcion = @descripcion
	END
	ELSE 
	BEGIN

		SET @id_tarifa = (SELECT id_tarifa
						  FROM tarifas.TarifaPiletaVerano
						  WHERE descripcion = @descripcion
						  AND es_invitado = @es_invitado
						  AND categoria = @categoria)

        IF @id_tarifa IS NULL
        BEGIN
            RAISERROR('No existe la tarifa para eliminar.', 16, 1);
            RETURN;
        END

		DELETE FROM tarifas.TarifaPiletaVerano
		WHERE descripcion = @descripcion
	END

END;
GO

/*____________________________________________________________________
  ____________________ GestionarInscriptoReservaSum ______________________
  ____________________________________________________________________*/
IF OBJECT_ID('actividades.GestionarInscriptoReservaSum', 'P') IS NOT NULL
    DROP PROCEDURE actividades.GestionarInscriptoReservaSum;
GO

CREATE PROCEDURE actividades.GestionarInscriptoReservaSum
    @dni_socio VARCHAR(10),
    @descripcion_tarifa VARCHAR(100),
	@periodo CHAR(10),
    @fecha_inscripcion DATE,
    @operacion CHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @id_socio INT;
	DECLARE @id_tarifa INT;
	DECLARE @id_inscripcion INT;

    -- Validar operación
    IF @operacion NOT IN ('Insertar', 'Modificar', 'Eliminar')
    BEGIN
        RAISERROR('Operación inválida. Usar Insertar, Modificar o Eliminar.', 16, 1);
        RETURN;
    END

    -- Buscar ID de socio activo
    SET @id_socio = (
        SELECT TOP 1 id_socio
        FROM socios.Socio
        WHERE dni = @dni_socio AND activo = 1 AND eliminado = 0
    );

    -- Buscar tarifa correspondiente
    SET @id_tarifa = (
		SELECT TOP 1 id_tarifa
		FROM tarifas.TarifaReservaSum
		WHERE descripcion = @descripcion_tarifa
	)
	-- Buscar ID de inscripcion
	SET @id_inscripcion = (SELECT id_inscripcion
						   FROM actividades.InscriptoPiletaVerano
						   WHERE id_tarifa = @id_tarifa
						   AND id_socio = @id_socio)

    -- === Insertar ===
    IF @operacion = 'Insertar'
    BEGIN
        IF @id_socio IS NULL
        BEGIN
            RAISERROR('El socio no existe o no está activo.', 16, 1);
            RETURN;
        END

        IF @id_tarifa IS NULL
        BEGIN
            RAISERROR('La tarifa de colonia de verano no existe con esos parámetros.', 16, 1);
            RETURN;
        END

        IF EXISTS (
            SELECT id_inscripcion
            FROM actividades.InscriptoPiletaVerano
            WHERE id_socio = @id_socio AND id_tarifa = @id_tarifa
        )
        BEGIN
            RAISERROR('El socio ya está inscripto en esa clase.', 16, 1);
            RETURN;
        END

        IF @fecha_inscripcion IS NULL
            SET @fecha_inscripcion = GETDATE();

        INSERT INTO actividades.InscriptoReservaSum(id_socio, id_tarifa, fecha, monto)
        VALUES (
			@id_socio, 
			@id_tarifa,
			@fecha_inscripcion, 
			(SELECT TOP 1 monto
			 FROM tarifas.TarifaColoniaVerano
			 WHERE descripcion = @descripcion_tarifa));
        RETURN;
    END
	-- === Modificar ===
    ELSE IF @operacion = 'Modificar'
    BEGIN
        IF @id_inscripcion IS NULL
        BEGIN
            RAISERROR('No existe la inscripción para modificar.', 16, 1);
            RETURN;
        END

        UPDATE actividades.InscriptoReservaSum
        SET fecha = COALESCE(@fecha_inscripcion, fecha)
        WHERE id_inscripcion = @id_inscripcion;
        RETURN;
    END
	-- === Eliminar ===
    ELSE IF @operacion = 'Eliminar'
    BEGIN
		IF @id_inscripcion IS NULL
        BEGIN
            RAISERROR('No existe la inscripción para eliminar.', 16, 1);
            RETURN;
        END

        DELETE FROM actividades.InscriptoReservaSum 
		WHERE id_inscripcion = @id_inscripcion;
        RETURN;
    END
END;
GO

/*____________________________________________________________________
  ______________________ GestionarEmisorFactura ______________________
  ____________________________________________________________________*/

IF OBJECT_ID('facturacion.GestionarEmisorFactura', 'P') IS NOT NULL
    DROP PROCEDURE facturacion.GestionarEmisorFactura;
GO

CREATE PROCEDURE facturacion.GestionarEmisorFactura
    @razon_social VARCHAR(100),
    @cuil VARCHAR(20),
    @direccion VARCHAR(200),
    @pais VARCHAR(50),
    @localidad VARCHAR(50),
    @codigo_postal VARCHAR(50),
    @operacion CHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    /* Verificación de operaciones válidas */
    IF @operacion NOT IN ('Insertar', 'Modificar', 'Eliminar')
    BEGIN
        RAISERROR('Operación inválida. Usar Insertar, Modificar o Eliminar.', 16, 1);
        RETURN;
    END

    /* Obtener id_emisor a partir del CUIL (clave única) */
    DECLARE @id_emisor INT = (
        SELECT id_emisor 
        FROM facturacion.EmisorFactura 
        WHERE cuil = @cuil
    );

    /* CASO 1: Eliminar */
    IF @operacion = 'Eliminar'
    BEGIN
        IF @id_emisor IS NULL
        BEGIN
            RAISERROR('No se encontró emisor con ese CUIL para eliminar.', 16, 1);
            RETURN;
        END

        DELETE FROM facturacion.EmisorFactura WHERE id_emisor = @id_emisor;
    END

    /* CASO 2: Modificar */
    ELSE IF @operacion = 'Modificar'
    BEGIN
        IF @id_emisor IS NULL
        BEGIN
            RAISERROR('No se encontró emisor con ese CUIL para modificar.', 16, 1);
            RETURN;
        END

        UPDATE facturacion.EmisorFactura
        SET razon_social  = COALESCE(@razon_social, razon_social),
            direccion     = COALESCE(@direccion, direccion),
            pais          = COALESCE(@pais, pais),
            localidad     = COALESCE(@localidad, localidad),
            codigo_postal = COALESCE(@codigo_postal, codigo_postal)
        WHERE id_emisor = @id_emisor;
    END

    /* CASO 3: Insertar */
    ELSE IF @operacion = 'Insertar'
    BEGIN
        IF @cuil IS NULL OR @razon_social IS NULL
        BEGIN
            RAISERROR('CUIL y razón social son obligatorios para insertar.', 16, 1);
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM facturacion.EmisorFactura WHERE cuil = @cuil)
        BEGIN
            RAISERROR('Ya existe un emisor con ese CUIL.', 16, 1);
            RETURN;
        END

        INSERT INTO facturacion.EmisorFactura 
            (razon_social, cuil, direccion, pais, localidad, codigo_postal)
        VALUES
            (@razon_social, @cuil, @direccion, @pais, @localidad, @codigo_postal);
    END
END;
GO

/*
DROP TABLE IF EXISTS facturacion.DetalleFactura;
DROP TABLE IF EXISTS facturacion.Factura;
DROP TABLE IF EXISTS facturacion.CargoActividadExtra;
DROP TABLE IF EXISTS facturacion.CargoClases;
DROP TABLE IF EXISTS facturacion.CargoMembresias;
DROP TABLE IF EXISTS facturacion.CuotaMensual;*/

/*____________________________________________________________________
  _______________________ GenerarCargoMembresia ______________________
  ____________________________________________________________________*/

/*IF OBJECT_ID('facturacion.GenerarCargoMembresia', 'P') IS NOT NULL
    DROP PROCEDURE facturacion.GestionarEmisorFactura;
GO

CREATE PROCEDURE facturacion.GenerarCargoMembresia
    @dni_socio VARCHAR(100)
AS
BEGIN*/