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
    IF @operacion NOT IN ('Insertar', 'Eliminar')
    BEGIN
        RAISERROR('Operación inválida. Usar Insertar o Eliminar.', 16, 1);
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
	ELSE
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
  __________________ GestionarTarifaColoniaVerano ___________________
  ____________________________________________________________________*/

IF OBJECT_ID('tarifas.GestionarTarifaColoniaVerano', 'P') IS NOT NULL
    DROP PROCEDURE tarifas.GestionarTarifaColoniaVerano;
GO
CREATE PROCEDURE tarifas.GestionarTarifaColoniaVerano
    @categoria VARCHAR(50),
    @periodo CHAR(10),
    @costo DECIMAL(10,2),
	@vigencia DATE,
    @operacion CHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    IF @operacion NOT IN ('Insertar', 'Eliminar')
    BEGIN
        RAISERROR('Operación inválida. Usar Insertar o Eliminar.', 16, 1);
        RETURN;
    END

    IF @operacion = 'Insertar'
    BEGIN
        IF @costo IS NULL
        BEGIN
            RAISERROR('Monto obligatorio para insertar.', 16, 1);
            RETURN;
        END

		IF @vigencia IS NULL
        BEGIN
            RAISERROR('La vigencia es obligatoria para insertar.', 16, 1);
            RETURN;
        END

        IF @categoria IS NULL
        BEGIN
            RAISERROR('Categoría obligatoria para insertar.', 16, 1);
            RETURN;
        END

        IF @periodo IS NULL
        BEGIN
            RAISERROR('Periodo obligatorio para insertar.', 16, 1);
            RETURN;
        END

        IF EXISTS (
            SELECT 1
            FROM tarifas.TarifaColoniaVerano
            WHERE categoria = @categoria AND periodo = @periodo)
        BEGIN
            RAISERROR('Tarifa de colonia de verano ya existente.', 16, 1);
            RETURN;
        END

        INSERT INTO tarifas.TarifaColoniaVerano (categoria, periodo, costo, vigencia)
        VALUES (@categoria, @periodo, @costo, @vigencia);
    END
    ELSE -- Eliminar
    BEGIN
        IF NOT EXISTS (
            SELECT 1 FROM tarifas.TarifaColoniaVerano
            WHERE categoria = @categoria AND periodo = @periodo)
        BEGIN
            RAISERROR('No existe tarifa para eliminar.', 16, 1);
            RETURN;
        END

        DELETE FROM tarifas.TarifaColoniaVerano
        WHERE categoria = @categoria AND periodo = @periodo;
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
    @descripcion_categoria VARCHAR(50),
    @periodo CHAR(10),
    @fecha_inscripcion DATE,
    @operacion CHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @id_socio INT;
    DECLARE @id_tarifa INT;
    DECLARE @monto DECIMAL(18,2);
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

    IF @id_socio IS NULL
    BEGIN
        RAISERROR('El socio no existe o no está activo.', 16, 1);
        RETURN;
    END

    -- Buscar tarifa vigente correspondiente
    SET @id_tarifa = (
        SELECT TOP 1 id_tarifa
        FROM tarifas.TarifaColoniaVerano
        WHERE periodo = @periodo
          AND categoria = @descripcion_categoria
          AND vigencia >= GETDATE()
        ORDER BY vigencia DESC
    );

    IF @id_tarifa IS NULL
    BEGIN
        RAISERROR('La tarifa de colonia de verano no existe con esos parámetros o no está vigente.', 16, 1);
        RETURN;
    END

    SET @monto = (
        SELECT TOP 1 costo -- o monto, según el nombre correcto en la tabla
        FROM tarifas.TarifaColoniaVerano
        WHERE id_tarifa = @id_tarifa
    );

    IF @monto IS NULL
    BEGIN
        RAISERROR('No se pudo obtener el monto de la tarifa.', 16, 1);
        RETURN;
    END

    -- Buscar inscripción existente
    SET @id_inscripcion = (
        SELECT TOP 1 id_inscripcion
        FROM actividades.InscriptoColoniaVerano
        WHERE id_socio = @id_socio AND id_tarifa = @id_tarifa
    );

    -- === Insertar ===
    IF @operacion = 'Insertar'
    BEGIN
        IF @id_inscripcion IS NOT NULL
        BEGIN
            RAISERROR('El socio ya está inscripto en esa tarifa de colonia.', 16, 1);
            RETURN;
        END

        IF @fecha_inscripcion IS NULL
            SET @fecha_inscripcion = GETDATE();

        INSERT INTO actividades.InscriptoColoniaVerano(id_socio, id_tarifa, fecha, monto)
        VALUES (@id_socio, @id_tarifa, @fecha_inscripcion, @monto);

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
	@costo DECIMAL(10,2),
	@vigencia DATE,
	@operacion CHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @id_tarifa INT;

    IF @operacion NOT IN ('Insertar', 'Modificar', 'Eliminar')
    BEGIN
        RAISERROR('Operación inválida. Usar Insertar, Modificar o Eliminar.', 16, 1);
        RETURN;
    END

	-- === INSERTAR ===
	IF @operacion = 'Insertar'
	BEGIN
		IF @costo IS NULL OR @vigencia IS NULL
		BEGIN
			RAISERROR('Costo y vigencia son obligatorios para insertar.', 16, 1);
			RETURN;
		END

		IF EXISTS (
			SELECT 1 FROM tarifas.TarifaReservaSum
			WHERE vigencia = @vigencia
		)
		BEGIN
			RAISERROR('Ya existe una tarifa con esa vigencia.', 16, 1);
			RETURN;
		END

		INSERT INTO tarifas.TarifaReservaSum (costo, vigencia)
		VALUES (@costo, @vigencia);
		RETURN;
	END

	-- === MODIFICAR ===
	ELSE IF @operacion = 'Modificar'
	BEGIN
		IF NOT EXISTS (
			SELECT 1 FROM tarifas.TarifaReservaSum
			WHERE vigencia = @vigencia
		)
		BEGIN
			RAISERROR('No existe una tarifa con esa vigencia para modificar.', 16, 1);
			RETURN;
		END

		UPDATE tarifas.TarifaReservaSum
		SET costo = COALESCE(@costo, costo)
		WHERE vigencia = @vigencia;
		RETURN;
	END

	-- === ELIMINAR ===
	ELSE
	BEGIN
		IF NOT EXISTS (
			SELECT 1 FROM tarifas.TarifaReservaSum
			WHERE vigencia = @vigencia
		)
		BEGIN
			RAISERROR('No existe una tarifa con esa vigencia para eliminar.', 16, 1);
			RETURN;
		END

		DELETE FROM tarifas.TarifaReservaSum
		WHERE vigencia = @vigencia;
		RETURN;
	END
END;
GO


/*____________________________________________________________________
  _______________________ GestionarReservaSum ________________________
  ____________________________________________________________________*/

IF OBJECT_ID('actividades.GestionarReservaSum', 'P') IS NOT NULL
    DROP PROCEDURE actividades.GestionarReservaSum;
GO

CREATE PROCEDURE actividades.GestionarReservaSum
    @dni_socio VARCHAR(10),
    @fecha_inscripcion DATE,
    @hora_inicio TIME,
    @hora_fin TIME,
    @operacion CHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @id_socio INT;
    DECLARE @id_tarifa INT;
    DECLARE @id_reserva INT;

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

    IF @id_socio IS NULL
    BEGIN
        RAISERROR('El socio no existe o no está activo.', 16, 1);
        RETURN;
    END

    -- Buscar tarifa vigente para reserva SUM
    SET @id_tarifa = (
        SELECT TOP 1 id_tarifa
        FROM tarifas.TarifaReservaSum
        WHERE vigencia > GETDATE()
        ORDER BY vigencia DESC
    );

    IF @id_tarifa IS NULL
    BEGIN
        RAISERROR('No hay una tarifa vigente para la reserva del SUM.', 16, 1);
        RETURN;
    END

    -- Buscar reserva existente para el socio, misma fecha y horario
    SET @id_reserva = (
        SELECT TOP 1 id_reserva
        FROM reservas.ReservaSum
        WHERE id_tarifa = @id_tarifa
          AND id_socio = @id_socio
          AND fecha = @fecha_inscripcion
          AND hora_inicio = @hora_inicio
          AND hora_fin = @hora_fin
    );

    -- === Insertar ===
    IF @operacion = 'Insertar'
    BEGIN
        IF @id_reserva IS NOT NULL
        BEGIN
            RAISERROR('El socio ya tiene una reserva con la tarifa vigente en esa fecha y horario.', 16, 1);
            RETURN;
        END

        IF @fecha_inscripcion IS NULL
            SET @fecha_inscripcion = GETDATE();

        IF @hora_inicio IS NULL OR @hora_fin IS NULL
        BEGIN
            RAISERROR('Debe especificar hora_inicio y hora_fin para la reserva.', 16, 1);
            RETURN;
        END

        INSERT INTO reservas.ReservaSum(id_socio, id_tarifa, fecha, hora_inicio, hora_fin)
        VALUES (
            @id_socio, 
            @id_tarifa,
            @fecha_inscripcion,
            @hora_inicio,
            @hora_fin
        );
        RETURN;
    END

    -- === Modificar ===
    ELSE IF @operacion = 'Modificar'
    BEGIN
        IF @id_reserva IS NULL
        BEGIN
            RAISERROR('No existe la reserva para modificar.', 16, 1);
            RETURN;
        END

        UPDATE reservas.ReservaSum
        SET 
            fecha = COALESCE(@fecha_inscripcion, fecha),
            hora_inicio = COALESCE(@hora_inicio, hora_inicio),
            hora_fin = COALESCE(@hora_fin, hora_fin)
        WHERE id_reserva = @id_reserva;
        RETURN;
    END

    -- === Eliminar ===
    ELSE IF @operacion = 'Eliminar'
    BEGIN
        IF @id_reserva IS NULL
        BEGIN
            RAISERROR('No existe la reserva para eliminar.', 16, 1);
            RETURN;
        END

        DELETE FROM reservas.ReservaSum 
        WHERE id_reserva = @id_reserva;
        RETURN;
    END
END;
GO

/*____________________________________________________________________
  __________________ GestionarTarifaColoniaVerano ____________________
  ____________________________________________________________________*/
/*
IF OBJECT_ID('tarifas.GestionarTarifaColoniaVerano', 'P') IS NOT NULL
    DROP PROCEDURE tarifas.GestionarTarifaColoniaVerano;
GO

CREATE PROCEDURE tarifas.GestionarTarifaColoniaVerano
	@categoria VARCHAR(50),
	@periodo CHAR(10),
	@costo DECIMAL(10,2),
	@operacion CHAR(10)
AS
BEGIN

	--Verificación de operaciones válidas
    IF @operacion NOT IN ('Insertar', 'Modificar', 'Eliminar')
    BEGIN
        RAISERROR('Operación inválida. Usar Insertar, Modificar o Eliminar.', 16, 1);
        RETURN;
    END
	
	IF @operacion = 'Insertar'
	BEGIN

		IF @costo IS NULL
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
				   WHERE categoria = @categoria
				   AND periodo = @periodo)
		BEGIN
			RAISERROR('Tarifa de colonia de verano ya existente.', 16, 1);
        RETURN;
    END
	END
	ELSE IF @operacion = 'Modificar'
	BEGIN
		UPDATE tarifas.TarifaColoniaVerano
		SET costo = COALESCE(@costo, costo)
		WHERE categoria = @categoria
		AND periodo = @periodo
	END
	ELSE 
	BEGIN
		DELETE FROM tarifas.TarifaColoniaVerano
		WHERE categoria = @categoria
		AND periodo = @periodo
	END

END;
GO
*/

/*____________________________________________________________________
  ___________________ GestionarTarifaPiletaVerano ____________________
  ____________________________________________________________________*/

IF OBJECT_ID('tarifas.GestionarTarifaPiletaVerano', 'P') IS NOT NULL
    DROP PROCEDURE tarifas.GestionarTarifaPiletaVerano;
GO

CREATE PROCEDURE tarifas.GestionarTarifaPiletaVerano
	@categoria VARCHAR(50),
	@es_invitado BIT,
	@costo DECIMAL(10,2),
	@vigencia DATE,
	@operacion CHAR(10)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @id_tarifa INT;

	IF @operacion NOT IN ('Insertar', 'Modificar', 'Eliminar')
	BEGIN
		RAISERROR('Operación inválida. Usar Insertar, Modificar o Eliminar.', 16, 1);
		RETURN;
	END

	-- === INSERTAR ===
	IF @operacion = 'Insertar'
	BEGIN
		IF @costo IS NULL
			RAISERROR('Costo obligatorio para insertar.', 16, 1);
		IF @vigencia IS NULL
			RAISERROR('La vigencia es obligatoria para insertar.', 16, 1);
		IF @categoria IS NULL
			RAISERROR('Categoría obligatoria para insertar.', 16, 1);
		IF @es_invitado IS NULL
			RAISERROR('Condición de invitado obligatoria para insertar.', 16, 1);

		IF EXISTS (
			SELECT 1
			FROM tarifas.TarifaPiletaVerano
			WHERE categoria = @categoria AND es_invitado = @es_invitado
		)
		BEGIN
			RAISERROR('Ya existe una tarifa para esa categoría y condición.', 16, 1);
			RETURN;
		END

		INSERT INTO tarifas.TarifaPiletaVerano (categoria, es_invitado, costo, vigencia)
		VALUES (@categoria, @es_invitado, @costo, @vigencia);
		RETURN;
	END

	-- === MODIFICAR ===
	ELSE IF @operacion = 'Modificar'
	BEGIN
		IF NOT EXISTS (
			SELECT 1
			FROM tarifas.TarifaPiletaVerano
			WHERE categoria = @categoria AND es_invitado = @es_invitado
		)
		BEGIN
			RAISERROR('No existe una tarifa con esa categoría y condición para modificar.', 16, 1);
			RETURN;
		END

		UPDATE tarifas.TarifaPiletaVerano
		SET costo = COALESCE(@costo, costo),
			vigencia = COALESCE(@vigencia, vigencia)
		WHERE categoria = @categoria AND es_invitado = @es_invitado;
		RETURN;
	END

	-- === ELIMINAR ===
	ELSE
	BEGIN
		SET @id_tarifa = (
			SELECT id_tarifa
			FROM tarifas.TarifaPiletaVerano
			WHERE categoria = @categoria AND es_invitado = @es_invitado
		);

		IF @id_tarifa IS NULL
		BEGIN
			RAISERROR('No existe la tarifa para eliminar.', 16, 1);
			RETURN;
		END

		DELETE FROM tarifas.TarifaPiletaVerano
		WHERE id_tarifa = @id_tarifa;
		RETURN;
	END
END;
GO



/*____________________________________________________________________
  ________________ GestionarInscriptoPiletaVerano ____________________
  ____________________________________________________________________*/

IF OBJECT_ID('actividades.GestionarInscriptoPiletaVerano', 'P') IS NOT NULL
    DROP PROCEDURE actividades.GestionarInscriptoPiletaVerano;
GO

CREATE PROCEDURE actividades.GestionarInscriptoPiletaVerano
    @dni_socio VARCHAR(10),
	@dni_invitado  CHAR(10),
	@nombre CHAR(50),
	@apellido CHAR(50),
	@categoria VARCHAR(50),
	@email VARCHAR(70),
	@domicilio VARCHAR(200),
    @fecha_inscripcion DATE,
    @operacion CHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @id_socio INT;
	DECLARE @id_invitado INT;
	DECLARE @id_inscripcion INT;
	DECLARE @id_tarifa INT;

    -- Validar operación
    IF @operacion NOT IN ('Insertar', 'Modificar', 'Eliminar')
    BEGIN
        RAISERROR('Operación inválida. Usar Insertar, Modificar o Eliminar.', 16, 1);
        RETURN;
    END

    -- Validar que venga al menos socio o invitado
    IF @dni_socio IS NULL AND @dni_invitado IS NULL
    BEGIN
        RAISERROR('Debe indicarse el DNI del socio o del invitado.', 16, 1);
        RETURN;
    END

	SET @id_socio = (
		SELECT TOP 1 id_socio
		FROM socios.Socio
		WHERE dni = @dni_socio AND activo = 1 AND eliminado = 0
	);

	IF @id_socio IS NULL
	BEGIN
		RAISERROR('No se encontró un socio válido con ese DNI.', 16, 1);
		RETURN;
	END

    -- === Caso Socio ===
	IF @dni_invitado IS NULL
	BEGIN

		SET @id_tarifa = (
			SELECT TOP 1 id_tarifa
			FROM tarifas.TarifaPiletaVerano
			WHERE categoria = (
				SELECT CASE 
							WHEN CS.descripcion IN ('Mayor', 'Cadete') THEN 'Mayor'
							ELSE CS.descripcion
					   END
				FROM socios.Socio S
				JOIN socios.CategoriaSocio CS ON S.id_categoria = CS.id_categoria
				WHERE S.id_socio = @id_socio
			)
			AND es_invitado = 0
			AND vigencia > GETDATE()
			ORDER BY vigencia DESC
		);
	END
	-- === Caso Invitado ===
	ELSE
	BEGIN
		SET @id_invitado = (
			SELECT id_invitado
			FROM socios.Invitado
			WHERE dni = @dni_invitado
		);

		IF @id_invitado IS NULL
		BEGIN
			IF @nombre IS NULL OR @apellido IS NULL OR @categoria IS NULL OR @email IS NULL OR @domicilio IS NULL
			BEGIN
				RAISERROR('Faltan datos obligatorios para registrar al invitado.', 16, 1);
				RETURN;
			END

			INSERT INTO socios.Invitado(id_socio, dni, nombre, apellido, categoria, email, domicilio)
			VALUES(@id_socio, @dni_invitado, @nombre, @apellido, @categoria, @email, @domicilio);

			SET @id_invitado = SCOPE_IDENTITY();
		END

		SET @id_tarifa = (
			SELECT TOP 1 id_tarifa
			FROM tarifas.TarifaPiletaVerano
			WHERE categoria = @categoria
			AND es_invitado = 1
			AND vigencia > GETDATE()
			ORDER BY vigencia DESC
		);
	END

	-- Validar tarifa encontrada
	IF @id_tarifa IS NULL
	BEGIN
		RAISERROR('No se encontró una tarifa válida para la categoría y condición.', 16, 1);
		RETURN;
	END

	-- Buscar inscripción existente
    SET @id_inscripcion = (
        SELECT TOP 1 id_inscripcion
        FROM actividades.InscriptoPiletaVerano
        WHERE (id_socio = @id_socio OR id_invitado = @id_invitado)
        AND fecha = @fecha_inscripcion
    );

    -- === Eliminar ===
    IF @operacion = 'Eliminar'
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

    -- === Modificar ===
    IF @operacion = 'Modificar'
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

    -- === Insertar ===
    IF @operacion = 'Insertar'
    BEGIN
        IF @id_inscripcion IS NOT NULL
        BEGIN
            RAISERROR('Ya existe una inscripción para ese día.', 16, 1);
            RETURN;
        END

        IF @fecha_inscripcion IS NULL
            SET @fecha_inscripcion = GETDATE();

        INSERT INTO actividades.InscriptoPiletaVerano(id_socio, id_invitado, id_tarifa, fecha, monto)
        VALUES (
			@id_socio,
			@id_invitado,
			@id_tarifa,
			@fecha_inscripcion,
			(SELECT costo
			 FROM tarifas.TarifaPiletaVerano
			 WHERE id_tarifa = @id_tarifa)
		);
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

IF OBJECT_ID('facturacion.GenerarCargoMembresia', 'P') IS NOT NULL
    DROP PROCEDURE facturacion.GenerarCargoMembresia;
GO

CREATE PROCEDURE facturacion.GenerarCargoMembresia
    @dni_socio VARCHAR(100),
	@fecha DATE
AS
BEGIN
	
	DECLARE @id_socio INT;
	DECLARE @id_inscripcion_categoria INT;

	-- Validar existencia de FECHA
	IF @fecha IS NULL
	BEGIN
		RAISERROR('La fecha ingresada es inválida', 16, 1);
            RETURN;
	END

	-- Se busca el SOCIOS al que se le quiere generar el cargo
	SET @id_socio = (SELECT TOP 1 id_socio
					 FROM socios.Socio
					 WHERE dni = @dni_socio
					 AND activo = 1
					 AND eliminado = 0)

	-- Validar existencia de SOCIO
	IF @id_socio IS NULL
	BEGIN
		RAISERROR('El socio no existe o no está activo.', 16, 1);
            RETURN;
	END

	-- Se busca LA INSCRIPCION al que se le quiere generar el cargo
	SET @id_inscripcion_categoria = (SELECT TOP 1 id_inscripcion
									 FROM actividades.InscriptoCategoriaSocio
									 WHERE id_socio = @id_socio
									 AND fecha <= @fecha
									 ORDER BY fecha DESC)

	-- Validar existencia de INSCRIPCION
	IF @id_inscripcion_categoria IS NULL
	BEGIN
		RAISERROR('No existe inscripción para el socio ingresado.', 16, 1);
            RETURN;
	END
	-- Validar existencia de CARGO
	IF EXISTS (SELECT TOP 1 CS.id_cargo
			   FROM facturacion.CargoMembresias CS
			   INNER JOIN actividades.InscriptoCategoriaSocio IC ON IC.id_inscripcion = CS.id_inscripcion_categoria
			   INNER JOIN socios.Socio S ON S.id_socio = IC.id_socio
			   WHERE IC.id_socio = @id_socio
			   AND IC.fecha < @fecha
			   ORDER BY IC.fecha DESC)
	BEGIN
		RAISERROR('Ya existe el cargo que se intenta generar.', 16, 1);
            RETURN;
	END

	INSERT INTO facturacion.CargoMembresias
	VALUES (
		@id_inscripcion_categoria,
		(SELECT monto
		 FROM actividades.InscriptoCategoriaSocio
		 WHERE id_inscripcion = @id_inscripcion_categoria),
		@fecha
	)

END;
GO

/*____________________________________________________________________
  _________________________ GenerarCargoClase ________________________
  ____________________________________________________________________*/

IF OBJECT_ID('facturacion.GenerarCargoClase', 'P') IS NOT NULL
    DROP PROCEDURE facturacion.GenerarCargoClase;
GO

CREATE PROCEDURE facturacion.GenerarCargoClase
    @dni_socio VARCHAR(100),
    @fecha DATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @id_socio INT;

    -- Validar existencia de FECHA
    IF @fecha IS NULL
    BEGIN
        RAISERROR('La fecha ingresada es inválida.', 16, 1);
        RETURN;
    END

    -- Buscar el socio
    SELECT @id_socio = id_socio
    FROM socios.Socio
    WHERE dni = @dni_socio AND activo = 1 AND eliminado = 0;

    IF @id_socio IS NULL
    BEGIN
        RAISERROR('El socio no existe o no está activo.', 16, 1);
        RETURN;
    END

    -- Insertar un cargo por cada clase en la que esté inscripto ese día (sin duplicados)
    INSERT INTO facturacion.CargoClases (id_inscripcion_clase, monto, fecha)
    SELECT
        IC.id_inscripcion,
        A.costo,
        @fecha
    FROM actividades.InscriptoClase IC
    INNER JOIN actividades.Clase C ON C.id_clase = IC.id_clase
    INNER JOIN actividades.Actividad A ON A.id_actividad = C.id_actividad
    WHERE IC.id_socio = @id_socio-- Buscando las clases a las cuales un socio está inscripto
      AND IC.fecha < @fecha
      AND NOT EXISTS (
          SELECT 1
          FROM facturacion.CargoClases CC
          WHERE CC.id_inscripcion_clase = IC.id_inscripcion
            AND CC.fecha <= @fecha
      );

END;
GO

/*____________________________________________________________________
  ___________________ GenerarCuotasMensualesPorFecha _________________
  ____________________________________________________________________*/

IF OBJECT_ID('facturacion.GenerarCuotasMensualesPorFecha', 'P') IS NOT NULL
    DROP PROCEDURE facturacion.GenerarCuotasMensualesPorFecha;
GO

CREATE PROCEDURE facturacion.GenerarCuotasMensualesPorFecha
    @fecha DATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar fecha
    IF @fecha IS NULL
    BEGIN
        RAISERROR('La fecha ingresada es inválida.', 16, 1);
        RETURN;
    END

    DECLARE @primer_dia_mes DATE = DATEFROMPARTS(YEAR(@fecha), MONTH(@fecha), 1);
    DECLARE @ultimo_dia_mes DATE = EOMONTH(@fecha);

    ;WITH SociosPorGrupo AS (
        SELECT GF.id_grupo, S.id_socio
        FROM socios.GrupoFamiliar GF
        INNER JOIN socios.GrupoFamiliarSocio GFS ON GFS.id_grupo = GF.id_grupo
        INNER JOIN socios.Socio S ON S.id_socio = GFS.id_socio
        WHERE S.activo = 1 AND S.eliminado = 0
    ),

    MembresiasPorGrupo AS (
        SELECT id_grupo, SUM(monto) AS monto_membresia
        FROM (
            SELECT 
                SPG.id_grupo,
                SPG.id_socio,
                MAX(CM.monto) AS monto
            FROM SociosPorGrupo SPG
            INNER JOIN actividades.InscriptoCategoriaSocio IC 
                ON IC.id_socio = SPG.id_socio
            INNER JOIN facturacion.CargoMembresias CM 
                ON CM.id_inscripcion_categoria = IC.id_inscripcion
            WHERE CM.fecha BETWEEN @primer_dia_mes AND @ultimo_dia_mes
            GROUP BY SPG.id_grupo, SPG.id_socio
        ) MembresiasPorSocio
        GROUP BY id_grupo
    ),

    ClasesPorGrupo AS (
        SELECT SPG.id_grupo, SUM(CC.monto) AS monto_actividad
        FROM SociosPorGrupo SPG
        INNER JOIN actividades.InscriptoClase IC ON IC.id_socio = SPG.id_socio
        INNER JOIN facturacion.CargoClases CC 
            ON CC.id_inscripcion_clase = IC.id_inscripcion
            AND CC.fecha BETWEEN @primer_dia_mes AND @ultimo_dia_mes
        GROUP BY SPG.id_grupo
    ),

    TotalesPorGrupo AS (
        SELECT
            GF.id_grupo,
            ISNULL(M.monto_membresia, 0) AS monto_membresia,
            ISNULL(C.monto_actividad, 0) AS monto_actividad
        FROM socios.GrupoFamiliar GF
        LEFT JOIN MembresiasPorGrupo M ON M.id_grupo = GF.id_grupo
        LEFT JOIN ClasesPorGrupo C ON C.id_grupo = GF.id_grupo
    )

    INSERT INTO facturacion.CuotaMensual (monto_membresia, monto_actividad, fecha)
    SELECT monto_membresia, monto_actividad, @ultimo_dia_mes
    FROM TotalesPorGrupo TPG
    WHERE NOT EXISTS (
        SELECT 1 FROM facturacion.CuotaMensual CM
        WHERE CM.fecha = @ultimo_dia_mes
    );

END;
GO

/*____________________________________________________________________
  ________________ GenerarCargosActividadExtraPorFecha _______________
  ____________________________________________________________________*/
IF OBJECT_ID('facturacion.GenerarCargosActividadExtraPorFecha', 'P') IS NOT NULL
    DROP PROCEDURE facturacion.GenerarCargosActividadExtraPorFecha;
GO

CREATE PROCEDURE facturacion.GenerarCargosActividadExtraPorFecha
    @fecha DATE
AS
BEGIN
    SET NOCOUNT ON;

    IF @fecha IS NULL
    BEGIN
        RAISERROR('La fecha ingresada es inválida.', 16, 1);
        RETURN;
    END

    DECLARE @primer_dia_mes DATE = DATEFROMPARTS(YEAR(@fecha), MONTH(@fecha), 1);
    DECLARE @ultimo_dia_mes DATE = EOMONTH(@fecha);

    -- Insertar cargos para Colonias (por inscripción)
    INSERT INTO facturacion.CargoActividadExtra (id_inscripcion_colonia)
    SELECT IC.id_inscripcion
    FROM actividades.InscriptoColoniaVerano IC
    WHERE IC.fecha BETWEEN @primer_dia_mes AND @ultimo_dia_mes
      AND NOT EXISTS (
          SELECT 1 FROM facturacion.CargoActividadExtra CAE
          WHERE CAE.id_inscripcion_colonia = IC.id_inscripcion
      );

    -- Insertar cargos para Pileta (por inscripción)
    INSERT INTO facturacion.CargoActividadExtra (id_inscripcion_pileta)
    SELECT IP.id_inscripcion
    FROM actividades.InscriptoPiletaVerano IP
    WHERE IP.fecha BETWEEN @primer_dia_mes AND @ultimo_dia_mes
      AND NOT EXISTS (
          SELECT 1 FROM facturacion.CargoActividadExtra CAE
          WHERE CAE.id_inscripcion_pileta = IP.id_inscripcion
      );

    -- Insertar cargos para Reserva SUM (por inscripción)
    INSERT INTO facturacion.CargoActividadExtra (id_reserva)
    SELECT R.id_reserva
    FROM reservas.ReservaSum R
    WHERE R.fecha BETWEEN @primer_dia_mes AND @ultimo_dia_mes
      AND NOT EXISTS (
          SELECT 1 FROM facturacion.CargoActividadExtra CAE
          WHERE CAE.id_reserva = R.id_reserva
      );

END;
GO

/*____________________________________________________________________
  ______________________ GenerarFacturasMensuales ____________________
  ____________________________________________________________________*/
  /*
IF OBJECT_ID('facturacion.GenerarFacturasMensuales', 'P') IS NOT NULL
    DROP PROCEDURE facturacion.GenerarFacturasMensuales;
GO

CREATE PROCEDURE facturacion.GenerarFacturasDesdeCuotasMensuales
    @fecha DATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar fecha
    IF @fecha IS NULL
    BEGIN
        RAISERROR('La fecha ingresada es inválida.', 16, 1);
        RETURN;
    END

    DECLARE @id_emisor INT;
    SELECT TOP 1 @id_emisor = id_emisor FROM facturacion.EmisorFactura;

    IF @id_emisor IS NULL
    BEGIN
        RAISERROR('No se encontró un emisor de facturas.', 16, 1);
        RETURN;
    END

    DECLARE @fecha_vto1 DATE = DATEADD(DAY, 5, @fecha);
    DECLARE @fecha_vto2 DATE = DATEADD(DAY, 10, @fecha);

    ;WITH CuotasConResponsables AS (
        SELECT
            GM.id_grupo,
            GM.id_socio_rp,
            T.id_tutor,
            CM.id_cuota,
            CM.monto_membresia,
            CM.monto_actividad,
            CM.fecha,
            ISNULL(S.saldo, 0) AS saldo_anterior
        FROM facturacion.CuotaMensual CM
        JOIN socios.GrupoFamiliar GM ON GM.id_grupo = CM.id_cuota
        LEFT JOIN socios.Socio S ON S.id_socio = GM.id_socio_rp
        LEFT JOIN socios.Tutor T ON T.id_grupo = GM.id_grupo
        WHERE CM.fecha = @fecha
    )
    INSERT INTO facturacion.Factura (
        id_emisor, id_socio, monto_total, saldo_anterior,
        fecha_emision, fecha_vencimiento1, fecha_vencimiento2,
        estado, id_cuota, id_cargo_actividad_extra
    )
    OUTPUT INSERTED.id_factura, 
           C.monto_membresia, 
           C.monto_actividad
    INTO #FacturasGeneradas (id_factura, monto_membresia, monto_actividad)
    SELECT
        @id_emisor,
        ISNULL(C.id_socio_rp, T.id_tutor), -- Prioridad responsable > tutor
        C.monto_membresia + C.monto_actividad,
        C.saldo_anterior,
        C.fecha,
        @fecha_vto1,
        @fecha_vto2,
        'Emitida',
        C.id_cuota,
        NULL
    FROM CuotasConResponsables C
    LEFT JOIN socios.Tutor T ON T.id_grupo = C.id_grupo;

    -- Insertar detalles de factura
    INSERT INTO facturacion.DetalleFactura (id_factura, concepto, monto, tipo_concepto)
    SELECT id_factura, 'Membresía mensual', monto_membresia, 'Membresía'
    FROM #FacturasGeneradas
    WHERE monto_membresia > 0

    UNION ALL

    SELECT id_factura, 'Actividades del mes', monto_actividad, 'Actividad'
    FROM #FacturasGeneradas
    WHERE monto_actividad > 0;
END;
GO
*/