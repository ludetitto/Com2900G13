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
        IF NOT EXISTS (SELECT 1 FROM actividades.Actividad WHERE nombre = @nombre)
        BEGIN
            RAISERROR('No existe la actividad para eliminar.', 16, 1);
            RETURN;
        END

        DECLARE @id_actividad INT = (
            SELECT id_actividad FROM actividades.Actividad WHERE nombre = @nombre
        );

        BEGIN TRY
            BEGIN TRANSACTION;

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
        IF NOT EXISTS (SELECT 1 FROM actividades.Actividad WHERE nombre = @nombre)
        BEGIN
            RAISERROR('No existe la actividad para modificar.', 16, 1);
            RETURN;
        END

        UPDATE actividades.Actividad
        SET 
            costo    = COALESCE(@costo, costo),
            vigencia = COALESCE(@vigencia, vigencia)
        WHERE nombre = @nombre;

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

        IF EXISTS (SELECT 1 FROM actividades.Actividad WHERE nombre = @nombre)
        BEGIN
            RAISERROR('Ya existe una actividad con ese nombre.', 16, 1);
            RETURN;
        END

        INSERT INTO actividades.Actividad (nombre, costo, vigencia)
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
    
    SET @id_categoria = (SELECT id_categoria FROM socios.CategoriaSocio WHERE nombre = @nombre_categoria);

	SET @id_actividad = (SELECT id_actividad FROM actividades.Actividad WHERE nombre = @nombre_actividad)

	IF @operacion = 'Insertar'
    BEGIN
		
		-- Validar actividad existente
		IF @id_actividad IS NULL
		BEGIN
			RAISERROR('No existe la actividad ingresada.', 16, 1);
			RETURN;
		END
		-- Validar datos de profesor
		IF @nombre_profesor IS NULL OR @apellido_profesor IS NULL
		BEGIN
			RAISERROR('No existe el profesor con nombre y apellido ingresados.', 16, 1);
			RETURN;
		END
		-- Validar categoría ingrsada
		IF @id_categoria IS NULL
		BEGIN
			RAISERROR('No existe la categoría de socio ingresada.', 16, 1);
			RETURN;
		END

		SET @id_clase = (
            SELECT C.id_clase
            FROM actividades.Clase C
            WHERE C.id_actividad = @id_actividad
              AND C.nombre_profesor = @nombre_profesor
			  AND C.apellido_profesor = @apellido_profesor
              AND C.horario = @horario
        );
		-- Validar existencia de clase
		IF @id_clase IS NOT NULL
		BEGIN
            RAISERROR('La clase ya existe.', 16, 1);
            RETURN;
        END

        INSERT INTO actividades.Clase (id_actividad, nombre_profesor, apellido_profesor, id_categoria, horario)
        VALUES (@id_actividad, @nombre_profesor, @apellido_profesor, @id_categoria, @horario);
        RETURN;
    END

    IF @operacion = 'Modificar'
    BEGIN
		SET @id_clase = (
            SELECT id_clase
            FROM actividades.Clase
            WHERE id_actividad = @id_actividad
              AND nombre_profesor = @nombre_profesor
			  AND apellido_profesor = @apellido_profesor
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
        SELECT TOP 1 S.id_socio
        FROM socios.Socio S
		INNER JOIN actividades.InscriptoCategoriaSocio ICS ON ICS.id_socio = S.id_socio
		INNER JOIN socios.CategoriaSocio CS ON CS.id_categoria = ICS.id_categoria
        WHERE S.dni = @dni_socio AND S.activo = 1 AND eliminado = 0 AND CS.nombre = @nombre_categoria
    );

    -- Buscar ID de clase correspondiente
    DECLARE @id_clase INT = (
        SELECT TOP 1 C.id_clase
        FROM actividades.Clase C
        JOIN actividades.Actividad A ON A.id_actividad = C.id_actividad
        JOIN socios.CategoriaSocio Ca ON Ca.id_categoria = C.id_categoria
        WHERE A.nombre = @nombre_actividad
          AND C.horario = @horario
          AND Ca.nombre = @nombre_categoria
    );

    -- Buscar inscripción existente
    DECLARE @id_inscripcion INT = (
        SELECT TOP 1 IC.id_inscripto_clase
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

        UPDATE actividades.InscriptoClase 
		SET activa = 0
		WHERE id_inscripto_clase = @id_inscripcion;
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
            WHERE id_socio = @id_socio AND id_clase = @id_clase AND activa = 1
        )
        BEGIN
            RAISERROR('El socio ya está inscripto en esa clase.', 16, 1);
            RETURN;
        END

        IF @fecha_inscripcion IS NULL
            SET @fecha_inscripcion = GETDATE();

        INSERT INTO actividades.InscriptoClase (id_socio, id_clase, fecha_inscripcion, activa)
        VALUES (@id_socio, @id_clase, @fecha_inscripcion, 1);
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
    SET NOCOUNT ON; -- Evita que se devuelvan recuentos de filas afectados

    -- Declaración de variables
    DECLARE @id_clase INT;
    DECLARE @id_socio INT;
    DECLARE @id_presentismo INT;
    DECLARE @id_inscripcion INT;

    -- ====================================================================
    -- 1. Validación inicial de la operación
    -- ====================================================================
    IF @operacion NOT IN ('Insertar', 'Modificar', 'Eliminar')
    BEGIN
        RAISERROR('Operación inválida. Usar Insertar, Modificar o Eliminar.', 16, 1);
        RETURN;
    END

    -- ====================================================================
    -- 2. Obtener IDs necesarios
    -- ====================================================================

    -- Obtener ID de clase (considerando actividad, horario y categoría)
    SET @id_clase = (
        SELECT C.id_clase
        FROM actividades.Clase C
        JOIN actividades.Actividad A ON A.id_actividad = C.id_actividad
        JOIN socios.CategoriaSocio Ca ON Ca.id_categoria = C.id_categoria
        WHERE A.nombre = @nombre_actividad
          AND C.horario = @horario
          AND Ca.nombre = @nombre_categoria
    );

    -- Validar si la clase existe
    IF @id_clase IS NULL
    BEGIN
        RAISERROR('La clase especificada (Actividad, Horario, Categoría) no existe.', 16, 1);
        RETURN;
    END

    -- Obtener ID del socio
    SET @id_socio = (
        SELECT id_socio
        FROM socios.Socio
        WHERE dni = @dni_socio
    );

    -- Validar si el socio existe
    IF @id_socio IS NULL
    BEGIN
        RAISERROR('El socio especificado no existe.', 16, 1);
        RETURN;
    END

    -- Validar si el socio está activo y no eliminado
    IF EXISTS (SELECT 1 FROM socios.Socio WHERE id_socio = @id_socio AND (activo = 0 OR eliminado = 1))
    BEGIN
        RAISERROR('El socio especificado se encuentra inactivo o eliminado.', 16, 1);
        RETURN;
    END

    -- ====================================================================
    -- 3. Verificar inscripción del socio a la clase (NUEVA VALIDACIÓN)
    -- ====================================================================
    SET @id_inscripcion = (
        SELECT TOP 1 id_inscripto_clase
        FROM actividades.InscriptoClase
        WHERE id_clase = @id_clase
          AND id_socio = @id_socio
        ORDER BY id_inscripto_clase DESC -- Tomar la inscripción más reciente si hay múltiples
    );

    IF @id_inscripcion IS NULL
    BEGIN
        RAISERROR('El socio no está inscripto en esta clase.', 16, 1);
        RETURN;
    END

    -- ====================================================================
    -- 4. Buscar presentismo existente para la fecha, clase y socio
    --    id_clase, id_socio, fecha es una combinacion única para presentismo)
    -- ====================================================================
    SET @id_presentismo = (
        SELECT id_presentismo
        FROM actividades.presentismoClase
        WHERE id_clase = @id_clase
          AND id_socio = @id_socio
          AND fecha = @fecha
    );

    -- ====================================================================
    -- 5. Lógica de Operación (Eliminar, Modificar, Insertar)
    -- ====================================================================

    -- === Eliminar ===
    IF @operacion = 'Eliminar'
    BEGIN
        IF @id_presentismo IS NULL
        BEGIN
            RAISERROR('No existe el presentismo para eliminar.', 16, 1);
            RETURN;
        END

        DELETE FROM actividades.presentismoClase WHERE id_presentismo = @id_presentismo;
        -- Considerar agregar un mensaje de éxito si es necesario
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

        -- Solo se actualiza el estado. id_clase y fecha son parte de la clave de identificación.
        UPDATE actividades.presentismoClase
        SET estado = COALESCE(@estado, estado) -- Si @estado es NULL, mantiene el valor actual
        WHERE id_presentismo = @id_presentismo;
        -- Considerar agregar un mensaje de éxito si es necesario
        RETURN;
    END

    -- === Insertar ===
    IF @operacion = 'Insertar'
    BEGIN
        -- Si @fecha es NULL, usa la fecha actual
        IF @fecha IS NULL
            SET @fecha = GETDATE();

        -- Si @estado es NULL, usa 'P' (Presente) como valor por defecto
        IF @estado IS NULL
            SET @estado = 'P';

        -- Validación: evitar duplicados exactos (presentismo ya cargado para la misma clase, socio y fecha)
        IF @id_presentismo IS NOT NULL
        BEGIN
            RAISERROR('Ya existe un presentismo registrado para esa clase, socio y fecha.', 16, 1);
            RETURN;
        END

        INSERT INTO actividades.presentismoClase (id_clase, id_socio, fecha, estado)
        VALUES (
            @id_clase,
            @id_socio,
            @fecha,
            @estado
        );
        -- Considerar agregar un mensaje de éxito si es necesario
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
        SELECT TOP 1 id_tarifa_colonia
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
        WHERE id_tarifa_colonia = @id_tarifa
    );

    IF @monto IS NULL
    BEGIN
        RAISERROR('No se pudo obtener el monto de la tarifa.', 16, 1);
        RETURN;
    END

    -- Buscar inscripción existente
    SET @id_inscripcion = (
        SELECT TOP 1 id_inscripto_colonia
        FROM actividades.InscriptoColoniaVerano
        WHERE id_socio = @id_socio AND id_tarifa_colonia = @id_tarifa
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

        INSERT INTO actividades.InscriptoColoniaVerano(id_socio, id_tarifa_colonia, fecha, monto)
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
        WHERE id_inscripto_colonia = @id_inscripcion;

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
        WHERE id_inscripto_colonia = @id_inscripcion;

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
        SELECT TOP 1 id_tarifa_sum
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
        SELECT TOP 1 id_reserva_sum
        FROM reservas.ReservaSum
        WHERE id_tarifa_sum = @id_tarifa
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

        INSERT INTO reservas.ReservaSum(id_socio, id_tarifa_sum, fecha, hora_inicio, hora_fin, monto)
        VALUES (
            @id_socio, 
            @id_tarifa,
            @fecha_inscripcion,
            @hora_inicio,
            @hora_fin,
			(SELECT costo FROM tarifas.tarifaReservaSum WHERE id_tarifa_sum = @id_tarifa)
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
        WHERE id_reserva_sum = @id_reserva;
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
        WHERE id_reserva_sum = @id_reserva;
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
			SELECT id_tarifa_pileta
			FROM tarifas.TarifaPiletaVerano
			WHERE categoria = @categoria AND es_invitado = @es_invitado
		);

		IF @id_tarifa IS NULL
		BEGIN
			RAISERROR('No existe la tarifa para eliminar.', 16, 1);
			RETURN;
		END

		DELETE FROM tarifas.TarifaPiletaVerano
		WHERE id_tarifa_pileta = @id_tarifa;
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
	-- Validar socio, que en ambos casos debe completarse
	IF @id_socio IS NULL
	BEGIN
		RAISERROR('No se encontró un socio válido con ese DNI.', 16, 1);
		RETURN;
	END

    -- === Caso Socio ===
	IF @dni_invitado IS NULL
	BEGIN

		SET @id_tarifa = (
			SELECT TOP 1 id_tarifa_pileta
			FROM tarifas.TarifaPiletaVerano
			WHERE categoria = (
				SELECT CASE 
							WHEN CS.nombre IN ('Mayor', 'Cadete') THEN 'Mayor'
							ELSE CS.nombre
					   END
				FROM socios.Socio S
				JOIN InscriptoCategoriaSocio ICS ON ICS.id_socio = S.id_socio
				JOIN socios.CategoriaSocio CS ON CS.id_categoria = ICS.id_categoria -- Asumiendo que es inscripción de socio
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
		-- Validar invitado
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
			SELECT TOP 1 id_tarifa_pileta
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
        SELECT TOP 1 id_inscripto_pileta
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
        WHERE id_inscripto_pileta = @id_inscripcion;
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
        WHERE id_inscripto_pileta = @id_inscripcion;
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

        INSERT INTO actividades.InscriptoPiletaVerano(id_socio, id_invitado, id_tarifa_pileta, fecha, monto)
        VALUES (
			@id_socio,
			@id_invitado,
			@id_tarifa,
			@fecha_inscripcion,
			(SELECT costo
			 FROM tarifas.TarifaPiletaVerano
			 WHERE id_tarifa_pileta = @id_tarifa)
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
        WHERE cuit_emisor = @cuil
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

        IF EXISTS (SELECT 1 FROM facturacion.EmisorFactura WHERE cuit_emisor = @cuil)
        BEGIN
            RAISERROR('Ya existe un emisor con ese CUIL.', 16, 1);
            RETURN;
        END

        INSERT INTO facturacion.EmisorFactura 
            (razon_social, cuit_emisor, direccion, pais, localidad, codigo_postal, condicion_iva_emisor)
        VALUES
            (@razon_social, @cuil, @direccion, @pais, @localidad, @codigo_postal, 'Responsable inscripto');
    END
END;
GO

/*____________________________________________________________________
  _________________________ GenerarCargoClase ________________________
  ____________________________________________________________________*/

IF OBJECT_ID('facturacion.GenerarCargoClase', 'P') IS NOT NULL
    DROP PROCEDURE facturacion.GenerarCargoClase;
GO

CREATE PROCEDURE facturacion.GenerarCargoClase
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

    -- Insertar un cargo por cada clase en la que esté inscripto ese día cada socio (sin duplicados)
    INSERT INTO facturacion.CargoClases (id_inscripto_clase, monto, fecha)
    SELECT
        IC.id_inscripto_clase,
        A.costo,
        @fecha
    FROM socios.Socio S
    INNER JOIN actividades.InscriptoClase IC ON IC.id_socio = S.id_socio
    INNER JOIN actividades.Clase C ON C.id_clase = IC.id_clase
    INNER JOIN actividades.Actividad A ON A.id_actividad = C.id_actividad
    WHERE S.activo = 1 AND S.eliminado = 0
      AND IC.fecha_inscripcion <= @fecha
	  AND NOT EXISTS (
			SELECT 1
			FROM facturacion.CargoClases CC
			WHERE CC.id_inscripto_clase = IC.id_inscripto_clase
			  AND CC.fecha = @fecha
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

	-- Generar cargos de actividades
	EXEC facturacion.GenerarCargoClase @fecha;

    -- Validar fecha
    IF @fecha IS NULL
    BEGIN
        RAISERROR('La fecha ingresada es inválida.', 16, 1);
        RETURN;
    END

    DECLARE @primer_dia_mes DATE = DATEFROMPARTS(YEAR(@fecha), MONTH(@fecha), 1);
    DECLARE @ultimo_dia_mes DATE = EOMONTH(@fecha);

	-- Uso de CTEs para la generación de cuotas basada en cargos e inscripción
    ;WITH ClasesPorSocio AS (
        SELECT S.id_socio, SUM(CC.monto) AS monto_actividad
        FROM socios.Socio S
        INNER JOIN actividades.InscriptoClase IC ON IC.id_socio = S.id_socio
        INNER JOIN facturacion.CargoClases CC
            ON CC.id_inscripto_clase = IC.id_inscripto_clase
            AND CC.fecha BETWEEN @primer_dia_mes AND @ultimo_dia_mes
        GROUP BY S.id_socio
    ),
    TotalesPorSocio AS (
        SELECT
            S.id_socio,
            ICS.id_inscripto_categoria,
            ICS.monto AS monto_membresia,
            C.monto_actividad
        FROM socios.Socio S
        LEFT JOIN actividades.InscriptoCategoriaSocio ICS ON ICS.id_socio = S.id_socio
        LEFT JOIN ClasesPorSocio C ON C.id_socio = S.id_socio
        WHERE S.activo = 1 AND S.eliminado = 0
    )

    INSERT INTO facturacion.CuotaMensual (id_inscripto_categoria, monto_membresia, monto_actividad, fecha)
    SELECT 
        id_inscripto_categoria,
        ISNULL(monto_membresia, 0),
        ISNULL(monto_actividad, 0),
        @ultimo_dia_mes
    FROM TotalesPorSocio TPS
    WHERE (ISNULL(TPS.monto_actividad, 0) > 0 OR ISNULL(TPS.monto_membresia, 0) > 0)
      AND NOT EXISTS (
          SELECT 1 FROM facturacion.CuotaMensual CM
          WHERE CM.fecha = @ultimo_dia_mes
            AND CM.id_inscripto_categoria = TPS.id_inscripto_categoria
      );
END;
GO
/*____________________________________________________________________
  __________________ GenerarFacturasMensualesPorFecha ________________
  ____________________________________________________________________*/

IF OBJECT_ID('facturacion.GenerarFacturasMensualesPorFecha', 'P') IS NOT NULL
    DROP PROCEDURE facturacion.GenerarFacturasMensualesPorFecha;
GO

CREATE PROCEDURE facturacion.GenerarFacturasMensualesPorFecha
    @fecha DATE
AS
BEGIN
    SET NOCOUNT ON;

    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    BEGIN TRAN;

    BEGIN TRY

		IF @fecha IS NULL
		BEGIN
			RAISERROR('La fecha ingresada es inválida.', 16, 1);
			ROLLBACK TRANSACTION;
			RETURN;
		END

		DECLARE @ultimo_dia_mes DATE = EOMONTH(@fecha);
		DECLARE @primer_dia_mes DATE = DATEFROMPARTS(YEAR(@fecha), MONTH(@fecha), 1);

		-- Tabla temporal para guardar los datos de facturación previos
		CREATE TABLE #FacturasGeneradas (
			id_cuota_mensual INT,
			id_socio INT,
			dni_socio CHAR(8),
			fecha_nacimiento DATE,
			monto_membresia DECIMAL(10,2),
			monto_actividad DECIMAL(10,2),
			saldo DECIMAL(10,2),
			dni_facturar VARCHAR(13),
			descuento_membresia DECIMAL(10,2),
			descuento_actividad DECIMAL(10,2)
		);

		INSERT INTO #FacturasGeneradas (
			id_cuota_mensual, id_socio, dni_socio, fecha_nacimiento,
			monto_membresia, monto_actividad, saldo,
			dni_facturar, descuento_membresia, descuento_actividad
		)
		SELECT 
			CM.id_cuota_mensual,
			ICS.id_socio,
			S.dni,
			S.fecha_nacimiento,
			CM.monto_membresia,
			CM.monto_actividad,
			S.saldo,
			COALESCE(SR.dni, T.dni, S.dni) AS dni_facturar,
			-- Descuento del 15% si el grupo tiene más de un socio activo
			CASE 
				WHEN G.num_integrantes > 1 THEN ROUND(CM.monto_membresia * 0.15, 2)
				ELSE 0
			END AS descuento_membresia,
			-- Descuento del 10% si hace más de una actividad distinta en el mes
			CASE 
				WHEN A.cantidad_actividades > 1 THEN ROUND(CM.monto_actividad * 0.10, 2)
				ELSE 0
			END AS descuento_actividad
		FROM facturacion.CuotaMensual CM
		INNER JOIN actividades.InscriptoCategoriaSocio ICS ON ICS.id_inscripto_categoria = CM.id_inscripto_categoria
		INNER JOIN socios.Socio S ON S.id_socio = ICS.id_socio
		LEFT JOIN socios.GrupoFamiliarSocio GFS ON GFS.id_socio = S.id_socio
		LEFT JOIN socios.GrupoFamiliar GF ON GF.id_grupo = GFS.id_grupo
		LEFT JOIN socios.Socio SR ON SR.id_socio = GF.id_socio_rp
		LEFT JOIN socios.Tutor T ON T.id_grupo = GF.id_grupo
		LEFT JOIN (
			SELECT id_grupo, COUNT(*) AS num_integrantes
			FROM socios.GrupoFamiliarSocio GFS
			INNER JOIN socios.Socio SS ON SS.id_socio = GFS.id_socio
			WHERE SS.activo = 1 AND SS.eliminado = 0
			GROUP BY id_grupo
		) G ON G.id_grupo = GF.id_grupo
		LEFT JOIN (
			SELECT IC.id_socio, COUNT(DISTINCT C.id_actividad) AS cantidad_actividades
			FROM actividades.InscriptoClase IC
			INNER JOIN facturacion.CargoClases CC ON CC.id_inscripto_clase = IC.id_inscripto_clase
			INNER JOIN actividades.Clase C ON C.id_clase = IC.id_clase
			INNER JOIN actividades.Actividad A ON A.id_actividad = C.id_actividad
			WHERE CC.fecha BETWEEN @primer_dia_mes AND @ultimo_dia_mes
			GROUP BY IC.id_socio
		) A ON A.id_socio = S.id_socio
		WHERE CM.fecha = @ultimo_dia_mes
		  AND NOT EXISTS (
			  SELECT 1 FROM facturacion.Factura F WHERE F.id_cuota_mensual = CM.id_cuota_mensual
		  );

		-- Insertar las facturas
		INSERT INTO facturacion.Factura (
			id_emisor,
			id_cuota_mensual,
			nro_comprobante,
			tipo_factura,
			dni_receptor,
			condicion_iva_receptor,
			cae,
			monto_total,
			fecha_emision,
			fecha_vencimiento1,
			fecha_vencimiento2,
			estado,
			saldo_anterior
		)
		SELECT
			(SELECT TOP 1 id_emisor FROM facturacion.EmisorFactura ORDER BY id_emisor DESC),
			F.id_cuota_mensual,
			CASE
				WHEN NOT EXISTS (SELECT TOP 1 nro_comprobante FROM facturacion.Factura ORDER BY nro_comprobante DESC) THEN 1
				ELSE RIGHT('00000000' + CAST((SELECT TOP 1 nro_comprobante FROM facturacion.Factura ORDER BY nro_comprobante DESC) + 1 AS VARCHAR), 8)
			END,
			'C',
			F.dni_facturar,
			'Consumidor Final',
			RIGHT('00000000000000' + CAST(ABS(CHECKSUM(NEWID())) AS VARCHAR), 14),
			F.monto_membresia + F.monto_actividad - F.descuento_actividad - F.descuento_membresia,
			@ultimo_dia_mes,
			DATEADD(DAY, 5, @ultimo_dia_mes),
			DATEADD(DAY, 10, @ultimo_dia_mes),
			'Emitida',
			F.saldo
		FROM #FacturasGeneradas F;

		-- Insertar detalles de membresía
		INSERT INTO facturacion.DetalleFactura (id_factura, descripcion, monto, tipo_item, cantidad)
		SELECT 
			FA.id_factura,
			'Membresía mensual',
			FG.monto_membresia,
			'Membresía',
			1
		FROM facturacion.Factura FA
		INNER JOIN #FacturasGeneradas FG ON FG.id_cuota_mensual = FA.id_cuota_mensual
		WHERE FG.monto_membresia > 0;

		-- Insertar detalles de actividades
		INSERT INTO facturacion.DetalleFactura (id_factura, descripcion, monto, tipo_item, cantidad)
		SELECT 
			FA.id_factura,
			A.nombre,
			FG.monto_actividad,
			'Actividad',
			1
		FROM facturacion.Factura FA
		INNER JOIN #FacturasGeneradas FG ON FG.id_cuota_mensual = FA.id_cuota_mensual
		INNER JOIN actividades.InscriptoClase IC ON IC.id_socio = FG.id_socio
		INNER JOIN actividades.Clase C ON C.id_clase = IC.id_clase
		INNER JOIN actividades.Actividad A ON A.id_actividad = C.id_actividad
		WHERE FG.monto_actividad > 0;

		-- Detalle: descuento por grupo familiar
		INSERT INTO facturacion.DetalleFactura (id_factura, descripcion, monto, tipo_item, cantidad)
		SELECT 
			FA.id_factura,
			'Descuento por grupo familiar (-15%)',
			FG.descuento_membresia,
			'Descuento',
			1
		FROM facturacion.Factura FA
		JOIN #FacturasGeneradas FG ON FG.id_cuota_mensual = FA.id_cuota_mensual
		WHERE FG.descuento_membresia > 0;

		-- Detalle: descuento por múltiples actividades
		INSERT INTO facturacion.DetalleFactura (id_factura, descripcion, monto, tipo_item, cantidad)
		SELECT 
			FA.id_factura,
			'Descuento por múltiples actividades (-10%)',
			FG.descuento_actividad,
			'Descuento',
			1
		FROM facturacion.Factura FA
		JOIN #FacturasGeneradas FG ON FG.id_cuota_mensual = FA.id_cuota_mensual
		WHERE FG.descuento_actividad > 0;

		INSERT INTO facturacion.DetalleFactura (id_factura, descripcion, monto, tipo_item, cantidad)
		SELECT 
			FA.id_factura,
			'Recargo por mora',
			M.monto,
			'Mora',
			1
		FROM cobranzas.Mora M
		LEFT JOIN facturacion.Factura FA ON M.id_factura = FA.id_factura
		LEFT JOIN #FacturasGeneradas FG ON FG.id_cuota_mensual = FA.id_cuota_mensual
		WHERE M.facturada = 0;

		-- Marcar moras como facturadas
		UPDATE M
		SET M.facturada = 1
		FROM cobranzas.Mora M
		WHERE M.facturada = 0;

		DROP TABLE #FacturasGeneradas;
		COMMIT;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        DECLARE @msg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@msg, 16, 1);
    END CATCH
END;
GO

/*____________________________________________________________________
  __________ GenerarFacturasMensualesPorFechaGrupoFamiliar ___________
  ____________________________________________________________________*/

IF OBJECT_ID('facturacion.GenerarFacturasMensualesPorFechaGrupoFamiliar', 'P') IS NOT NULL
    DROP PROCEDURE facturacion.GenerarFacturasMensualesPorFechaGrupoFamiliar;
GO

CREATE PROCEDURE facturacion.GenerarFacturasMensualesPorFechaGrupoFamiliar
    @fecha DATE
AS
BEGIN
    SET NOCOUNT ON;
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

    BEGIN TRAN;
    BEGIN TRY

        IF @fecha IS NULL
        BEGIN
            RAISERROR('La fecha ingresada es inválida.', 16, 1);
            ROLLBACK TRAN;
            RETURN;
        END

        DECLARE @primer_dia_mes DATE = DATEFROMPARTS(YEAR(@fecha), MONTH(@fecha), 1);
        DECLARE @ultimo_dia_mes DATE = EOMONTH(@fecha);

        -- CREAR TABLA TEMPORAL PARA FACTURAS GENERADAS
        CREATE TABLE #FacturasGeneradas (
            id_factura INT PRIMARY KEY,
            dni_receptor VARCHAR(13)
        );

        -- Tabla temporal con grupos que NO tienen factura para el mes
        CREATE TABLE #GruposSinFactura (
            id_grupo INT PRIMARY KEY,
            dni_facturar VARCHAR(13),
            id_socio_principal INT NULL -- Para almacenar el ID del socio cuyo DNI se usa para facturar (si es un socio)
        );

        -- TABLA TEMPORAL PARA MATERIALIZAR DatosFactura
        CREATE TABLE #DatosFacturaCalculados (
            id_grupo INT PRIMARY KEY,
            dni_facturar VARCHAR(13),
            id_socio_principal INT NULL, -- El ID del socio cuyo DNI se usa para facturar (si es un socio)
            monto_membresia_total DECIMAL(18, 2),
            monto_actividad_total DECIMAL(18, 2),
            descuento_membresia_total DECIMAL(18, 2),
            descuento_actividad_total DECIMAL(18, 2),
            mora_total DECIMAL(18, 2),
            saldo_grupo DECIMAL(18, 2)
        );

        ;WITH DnisPorGrupo AS (
			SELECT
				GF.id_grupo,
				COALESCE(SR.dni, T.dni, MN.min_dni) AS dni_facturar,
                -- Capturamos el id_socio que corresponde al DNI elegido para facturar
                CASE
                    WHEN SR.dni IS NOT NULL THEN SR.id_socio
                    WHEN T.dni IS NOT NULL THEN NULL -- Si es un tutor, no hay id_socio directo aquí
                    ELSE MN.min_id_socio -- Si es el socio con DNI mínimo
                END AS id_socio_asociado_dni_facturar
			FROM socios.GrupoFamiliar GF
			LEFT JOIN socios.Socio SR ON SR.id_socio = GF.id_socio_rp
			LEFT JOIN socios.Tutor T ON T.id_grupo = GF.id_grupo
			CROSS APPLY (
				SELECT MIN(S.dni) AS min_dni, MIN(S.id_socio) AS min_id_socio
				FROM socios.Socio S
				JOIN socios.GrupoFamiliarSocio GFS ON GFS.id_socio = S.id_socio
				WHERE GFS.id_grupo = GF.id_grupo
				  AND S.activo = 1 AND S.eliminado = 0
			) MN
		)
		INSERT INTO #GruposSinFactura (id_grupo, dni_facturar, id_socio_principal)
		SELECT DISTINCT
			DPG.id_grupo,
			DPG.dni_facturar,
            DPG.id_socio_asociado_dni_facturar -- Insertamos el ID del socio principal
		FROM DnisPorGrupo DPG
		LEFT JOIN facturacion.Factura F ON F.dni_receptor = DPG.dni_facturar
			AND F.fecha_emision BETWEEN @primer_dia_mes AND @ultimo_dia_mes
		WHERE F.id_factura IS NULL
		AND DPG.dni_facturar IS NOT NULL;

        IF NOT EXISTS (SELECT 1 FROM #GruposSinFactura)
        BEGIN
            RAISERROR('No hay grupos sin factura generada para esta fecha.', 16, 1);
            ROLLBACK TRAN;
            RETURN;
        END

        -- CTEs para calcular montos en #DatosFacturaCalculados
        ;WITH ActividadesPorSocio AS (
            SELECT IC.id_socio, COUNT(DISTINCT C.id_actividad) AS cantidad_actividades
            FROM actividades.InscriptoClase IC
            INNER JOIN actividades.Clase C ON C.id_clase = IC.id_clase
            INNER JOIN facturacion.CargoClases CC ON CC.id_inscripto_clase = IC.id_inscripto_clase
            WHERE CC.fecha BETWEEN @primer_dia_mes AND @ultimo_dia_mes
            GROUP BY IC.id_socio
        ),
        MoraPorGrupo AS (
            SELECT GFS.id_grupo, ISNULL(SUM(M.monto), 0) AS mora_total
            FROM cobranzas.Mora M
            JOIN socios.GrupoFamiliarSocio GFS ON GFS.id_socio = M.id_socio
            WHERE M.facturada = 0 AND M.fecha_registro BETWEEN @primer_dia_mes AND @ultimo_dia_mes
            GROUP BY GFS.id_grupo
        )
        -- DatosFactura en una tabla temporal
        INSERT INTO #DatosFacturaCalculados (
            id_grupo, dni_facturar, id_socio_principal, monto_membresia_total, monto_actividad_total,
            descuento_membresia_total, descuento_actividad_total, mora_total, saldo_grupo
        )
        SELECT
            G.id_grupo,
            G.dni_facturar,
            G.id_socio_principal, -- Usamos el id_socio_principal ya calculado en #GruposSinFactura
            SUM(CM.monto_membresia) AS monto_membresia_total,
            SUM(CM.monto_actividad) AS monto_actividad_total,
            CASE WHEN COUNT(DISTINCT S.id_socio) > 1 THEN ROUND(SUM(CM.monto_membresia)*0.15,2) ELSE 0 END AS descuento_membresia_total,
            SUM(CASE WHEN APS.cantidad_actividades > 1 THEN ROUND(CM.monto_actividad*0.10,2) ELSE 0 END) AS descuento_actividad_total,
            ISNULL(MG.mora_total,0) AS mora_total,
            SUM(ISNULL(S.saldo,0)) AS saldo_grupo
        FROM #GruposSinFactura G
        JOIN socios.GrupoFamiliar GF ON GF.id_grupo = G.id_grupo
        JOIN socios.GrupoFamiliarSocio GFS ON GFS.id_grupo = GF.id_grupo
        JOIN socios.Socio S ON S.id_socio = GFS.id_socio AND S.activo = 1 AND S.eliminado = 0
        JOIN actividades.InscriptoCategoriaSocio ICS ON ICS.id_socio = S.id_socio
        JOIN facturacion.CuotaMensual CM ON CM.id_inscripto_categoria = ICS.id_inscripto_categoria AND CM.fecha = @ultimo_dia_mes
        LEFT JOIN ActividadesPorSocio APS ON APS.id_socio = S.id_socio
        LEFT JOIN MoraPorGrupo MG ON MG.id_grupo = GF.id_grupo
        GROUP BY G.id_grupo, G.dni_facturar, G.id_socio_principal, ISNULL(MG.mora_total,0);

        -- Insertar facturas
        INSERT INTO facturacion.Factura (
            id_emisor, id_cuota_mensual, id_cargo_actividad_extra, nro_comprobante, tipo_factura,
            dni_receptor, condicion_iva_receptor, cae,
            monto_total, fecha_emision, fecha_vencimiento1, fecha_vencimiento2,
            estado, saldo_anterior
        )
        OUTPUT inserted.id_factura, inserted.dni_receptor INTO #FacturasGeneradas(id_factura, dni_receptor)
        SELECT
            (SELECT TOP 1 id_emisor FROM facturacion.EmisorFactura ORDER BY id_emisor DESC),
            -- Lógica para id_cuota_mensual
            (SELECT TOP 1 CM_main.id_cuota_mensual
             FROM actividades.InscriptoCategoriaSocio ICS_main
             JOIN facturacion.CuotaMensual CM_main ON CM_main.id_inscripto_categoria = ICS_main.id_inscripto_categoria
             WHERE ICS_main.id_socio = D.id_socio_principal -- Usamos el socio principal
             AND CM_main.fecha = @ultimo_dia_mes
             ORDER BY CM_main.id_cuota_mensual DESC -- Arbitrario si hay más de uno, pero para TOP 1
            ) AS id_cuota_mensual,
            -- id_cargo_actividad_extra: se deja NULL por ahora, si no hay una tabla CargoActividadExtra clara
            NULL AS id_cargo_actividad_extra, -- O puedes intentar una lógica similar para un CargoClases principal si es lo que se espera
			CASE
				WHEN NOT EXISTS (SELECT TOP 1 nro_comprobante FROM facturacion.Factura ORDER BY nro_comprobante DESC) THEN 1
				ELSE RIGHT('00000000' + CAST((SELECT TOP 1 nro_comprobante FROM facturacion.Factura ORDER BY nro_comprobante DESC) + 1 AS VARCHAR), 8)
			END,            
            'C',
            D.dni_facturar,
            'Consumidor Final',
            RIGHT('00000000000000' + CAST(ABS(CHECKSUM(NEWID())) AS VARCHAR), 14),
            D.monto_membresia_total + D.monto_actividad_total - D.descuento_membresia_total - D.descuento_actividad_total + D.mora_total,
            @ultimo_dia_mes,
            DATEADD(DAY, 5, @ultimo_dia_mes),
            DATEADD(DAY, 10, @ultimo_dia_mes),
            'Emitida',
            D.saldo_grupo
        FROM #DatosFacturaCalculados D;

        -- Detalle membresía (una línea por categoría)
		INSERT INTO facturacion.DetalleFactura (id_factura, descripcion, monto, tipo_item, cantidad)
        SELECT
            F.id_factura,
            'Categoría ' + CS.nombre,
            SUM(CM.monto_membresia),
            'Membresía',
            COUNT(*)
        FROM #FacturasGeneradas F
        -- Unimos #FacturasGeneradas por dni_receptor a #DatosFacturaCalculados para obtener id_grupo
        JOIN #DatosFacturaCalculados DFC ON DFC.dni_facturar = F.dni_receptor
        JOIN socios.GrupoFamiliarSocio GFS ON GFS.id_grupo = DFC.id_grupo
        JOIN socios.Socio S ON S.id_socio = GFS.id_socio AND S.activo = 1 AND S.eliminado = 0
        JOIN actividades.InscriptoCategoriaSocio ICS ON ICS.id_socio = S.id_socio
        JOIN socios.CategoriaSocio CS ON CS.id_categoria = ICS.id_categoria
        JOIN facturacion.CuotaMensual CM ON CM.id_inscripto_categoria = ICS.id_inscripto_categoria AND CM.fecha = @ultimo_dia_mes
        GROUP BY F.id_factura, CS.nombre
        HAVING SUM(CM.monto_membresia) > 0;

        -- Detalle actividades (una línea por actividad)
        INSERT INTO facturacion.DetalleFactura (id_factura, descripcion, monto, tipo_item, cantidad)
        SELECT
            F.id_factura,
            A.nombre,
            SUM(CC.monto),
            'Actividad',
            COUNT(*)
        FROM #FacturasGeneradas F
        -- Unimos #FacturasGeneradas por dni_receptor a #DatosFacturaCalculados para obtener id_grupo
        JOIN #DatosFacturaCalculados DFC ON DFC.dni_facturar = F.dni_receptor
        JOIN socios.GrupoFamiliarSocio GFS ON GFS.id_grupo = DFC.id_grupo
        JOIN socios.Socio S ON S.id_socio = GFS.id_socio AND S.activo = 1 AND S.eliminado = 0
        JOIN actividades.InscriptoClase IC ON IC.id_socio = S.id_socio
        JOIN actividades.Clase C ON C.id_clase = IC.id_clase
        JOIN actividades.Actividad A ON A.id_actividad = C.id_actividad
        JOIN facturacion.CargoClases CC ON CC.id_inscripto_clase = IC.id_inscripto_clase AND CC.fecha BETWEEN @primer_dia_mes AND @ultimo_dia_mes
        GROUP BY F.id_factura, A.nombre
        HAVING SUM(CC.monto) > 0;

        -- Detalles descuentos
        INSERT INTO facturacion.DetalleFactura (id_factura, descripcion, monto, tipo_item, cantidad)
        SELECT F.id_factura, 'Descuento por grupo familiar (-15%)', D.descuento_membresia_total, 'Descuento', 1
        FROM #FacturasGeneradas F
        JOIN #DatosFacturaCalculados D ON D.dni_facturar = F.dni_receptor -- Unimos por dni_receptor
        WHERE D.descuento_membresia_total > 0;

        INSERT INTO facturacion.DetalleFactura (id_factura, descripcion, monto, tipo_item, cantidad)
        SELECT F.id_factura, 'Descuento por múltiples actividades (-10%)', D.descuento_actividad_total, 'Descuento', 1
        FROM #FacturasGeneradas F
        JOIN #DatosFacturaCalculados D ON D.dni_facturar = F.dni_receptor -- Unimos por dni_receptor
        WHERE D.descuento_actividad_total > 0;

        -- Detalle mora
        INSERT INTO facturacion.DetalleFactura (id_factura, descripcion, monto, tipo_item, cantidad)
        SELECT F.id_factura, 'Recargo por mora', D.mora_total, 'Mora', 1
        FROM #FacturasGeneradas F
        JOIN #DatosFacturaCalculados D ON D.dni_facturar = F.dni_receptor -- Unimos por dni_receptor
        WHERE D.mora_total > 0;

        -- Marcar moras como facturadas
        UPDATE M
        SET M.facturada = 1
        FROM cobranzas.Mora M
        JOIN socios.GrupoFamiliarSocio GFS ON GFS.id_socio = M.id_socio
		-- Solo actualiza las moras que corresponden a los grupos que fueron facturados en esta ejecución
		JOIN #GruposSinFactura GSF ON GSF.id_grupo = GFS.id_grupo
        WHERE M.facturada = 0 AND M.fecha_registro BETWEEN @primer_dia_mes AND @ultimo_dia_mes;

        DROP TABLE #FacturasGeneradas;
        DROP TABLE #GruposSinFactura;
        DROP TABLE #DatosFacturaCalculados; -- Nueva tabla temporal para eliminar

        COMMIT;
    END TRY
    BEGIN CATCH
        -- Limpieza de tablas temporales en caso de error
        IF OBJECT_ID('tempdb..#FacturasGeneradas') IS NOT NULL
            DROP TABLE #FacturasGeneradas;
        IF OBJECT_ID('tempdb..#GruposSinFactura') IS NOT NULL
            DROP TABLE #GruposSinFactura;
        IF OBJECT_ID('tempdb..#DatosFacturaCalculados') IS NOT NULL
            DROP TABLE #DatosFacturaCalculados;

        ROLLBACK;
        DECLARE @msg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@msg, 16, 1);
    END CATCH
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
    INSERT INTO facturacion.CargoActividadExtra (id_inscripto_colonia)
    SELECT IC.id_inscripto_colonia
    FROM actividades.InscriptoColoniaVerano IC
    WHERE IC.fecha BETWEEN @primer_dia_mes AND @ultimo_dia_mes
      AND NOT EXISTS (
          SELECT 1 FROM facturacion.CargoActividadExtra CAE
          WHERE CAE.id_inscripto_colonia = IC.id_inscripto_colonia
      );

    -- Insertar cargos para Pileta (por inscripción)
    INSERT INTO facturacion.CargoActividadExtra (id_inscripto_pileta)
    SELECT IP.id_inscripto_pileta
    FROM actividades.InscriptoPiletaVerano IP
    WHERE IP.fecha BETWEEN @primer_dia_mes AND @ultimo_dia_mes
      AND NOT EXISTS (
          SELECT 1 FROM facturacion.CargoActividadExtra CAE
          WHERE CAE.id_inscripto_pileta = IP.id_inscripto_pileta
      );

    -- Insertar cargos para Reserva SUM (por inscripción)
    INSERT INTO facturacion.CargoActividadExtra (id_reserva_sum)
    SELECT R.id_reserva_sum
    FROM reservas.ReservaSum R
    WHERE R.fecha BETWEEN @primer_dia_mes AND @ultimo_dia_mes
      AND NOT EXISTS (
          SELECT 1 FROM facturacion.CargoActividadExtra CAE
          WHERE CAE.id_reserva_sum = R.id_reserva_sum
      );

END;
GO


/*____________________________________________________________________
  ______________ GenerarFacturasActividadesExtraPorFecha _____________
  ____________________________________________________________________*/

IF OBJECT_ID('facturacion.GenerarFacturasActividadesExtraPorFecha', 'P') IS NOT NULL
    DROP PROCEDURE facturacion.GenerarFacturasActividadesExtraPorFecha;
GO

CREATE PROCEDURE facturacion.GenerarFacturasActividadesExtraPorFecha
    @fecha DATE
AS
BEGIN
    SET NOCOUNT ON;

	-- Generar cargos por actividades extra
	EXEC facturacion.GenerarCargosActividadExtraPorFecha @fecha;

    IF @fecha IS NULL
    BEGIN
        RAISERROR('La fecha ingresada es inválida.', 16, 1);
		ROLLBACK TRANSACTION;
        RETURN;
    END

    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    BEGIN TRAN;

    BEGIN TRY
        DECLARE @ultimo_dia_mes DATE = EOMONTH(@fecha);

        -- Tabla temporal unificada con todos los cargos no facturados
        CREATE TABLE #CargosAFacturar (
            id_cargo INT,
            id_socio INT,
            tipo VARCHAR(30),
            descripcion VARCHAR(100),
            monto DECIMAL(10,2),
            fecha DATE,
            dni_facturar VARCHAR(13),
            saldo DECIMAL(10,2)
        );

        -- Colonia
        INSERT INTO #CargosAFacturar
        SELECT 
            CAE.id_cargo_extra,
            IC.id_socio,
            'Colonia',
            'Colonia de verano',
            ISNULL(IC.monto, 0),
            IC.fecha,
            COALESCE(SR.dni, T.dni, S.dni),
            S.saldo
        FROM facturacion.CargoActividadExtra CAE
        JOIN actividades.InscriptoColoniaVerano IC ON CAE.id_inscripto_colonia = IC.id_inscripto_colonia
        JOIN socios.Socio S ON S.id_socio = IC.id_socio
        LEFT JOIN socios.GrupoFamiliarSocio GFS ON GFS.id_socio = S.id_socio
        LEFT JOIN socios.GrupoFamiliar GF ON GF.id_grupo = GFS.id_grupo
        LEFT JOIN socios.Socio SR ON SR.id_socio = GF.id_socio_rp
        LEFT JOIN socios.Tutor T ON T.id_grupo = GF.id_grupo
        WHERE IC.fecha BETWEEN DATEFROMPARTS(YEAR(@fecha), MONTH(@fecha), 1) AND @ultimo_dia_mes
          AND NOT EXISTS (
              SELECT 1 FROM facturacion.Factura F WHERE F.id_cargo_actividad_extra = CAE.id_cargo_extra
          );

        -- Pileta
        INSERT INTO #CargosAFacturar
		SELECT 
			CAE.id_cargo_extra,
			IP.id_socio,
			'Pileta',
			'Pileta de verano',
			ISNULL(IP.monto, 0),
			IP.fecha,
			CASE 
				WHEN IP.id_invitado IS NOT NULL THEN I.dni     -- DNI invitado cuando corresponda
				ELSE COALESCE(SR.dni, T.dni, S.dni)            -- Sino socio responsable o tutor
			END AS dni_receptor,
			CASE
				WHEN IP.id_invitado IS NOT NULL THEN 0
				ELSE S.saldo
			END AS saldo
		FROM facturacion.CargoActividadExtra CAE
		JOIN actividades.InscriptoPiletaVerano IP ON CAE.id_inscripto_pileta = IP.id_inscripto_pileta
		JOIN socios.Socio S ON S.id_socio = IP.id_socio
		LEFT JOIN socios.Invitado I ON I.id_invitado = IP.id_invitado 
		LEFT JOIN socios.GrupoFamiliarSocio GFS ON GFS.id_socio = S.id_socio
		LEFT JOIN socios.GrupoFamiliar GF ON GF.id_grupo = GFS.id_grupo
		LEFT JOIN socios.Socio SR ON SR.id_socio = GF.id_socio_rp
		LEFT JOIN socios.Tutor T ON T.id_grupo = GF.id_grupo
		WHERE IP.fecha BETWEEN DATEFROMPARTS(YEAR(@fecha), MONTH(@fecha), 1) AND @ultimo_dia_mes
		  AND NOT EXISTS (
			  SELECT 1 FROM facturacion.Factura F WHERE F.id_cargo_actividad_extra = CAE.id_cargo_extra
		  );

        -- SUM
        INSERT INTO #CargosAFacturar
        SELECT 
            CAE.id_cargo_extra,
            R.id_socio,
            'Reserva SUM',
            'Reserva de SUM',
            ISNULL(R.monto, 0),
            R.fecha,
            COALESCE(SR.dni, T.dni, S.dni),
            S.saldo
        FROM facturacion.CargoActividadExtra CAE
        JOIN reservas.ReservaSum R ON CAE.id_reserva_sum = R.id_reserva_sum
        JOIN socios.Socio S ON S.id_socio = R.id_socio
        LEFT JOIN socios.GrupoFamiliarSocio GFS ON GFS.id_socio = S.id_socio
        LEFT JOIN socios.GrupoFamiliar GF ON GF.id_grupo = GFS.id_grupo
        LEFT JOIN socios.Socio SR ON SR.id_socio = GF.id_socio_rp
        LEFT JOIN socios.Tutor T ON T.id_grupo = GF.id_grupo
        WHERE R.fecha BETWEEN DATEFROMPARTS(YEAR(@fecha), MONTH(@fecha), 1) AND @ultimo_dia_mes
          AND NOT EXISTS (
              SELECT 1 FROM facturacion.Factura F WHERE F.id_cargo_actividad_extra = CAE.id_cargo_extra
          );

        -- Insertar Facturas por cada cargo extra
        INSERT INTO facturacion.Factura (
            id_emisor, id_cargo_actividad_extra, nro_comprobante, tipo_factura,
            dni_receptor, condicion_iva_receptor, cae, monto_total, fecha_emision,
            fecha_vencimiento1, fecha_vencimiento2, estado, saldo_anterior
        )
        SELECT 
            (SELECT TOP 1 id_emisor FROM facturacion.EmisorFactura ORDER BY id_emisor DESC),
            C.id_cargo,
            RIGHT('00000000' + CAST(ABS(CHECKSUM(NEWID())) AS VARCHAR), 8),
            'C',
            C.dni_facturar,
            'Consumidor Final',
            RIGHT('00000000000000' + CAST(ABS(CHECKSUM(NEWID())) AS VARCHAR), 14),
            C.monto,
            C.fecha,
            CASE
				WHEN C.dni_facturar IN (SELECT dni FROM socios.Socio) THEN DATEADD(DAY, 5, C.fecha)
				ELSE C.fecha
			END,
            CASE
				WHEN C.dni_facturar IN (SELECT dni FROM socios.Socio) THEN DATEADD(DAY, 10, C.fecha)
				ELSE C.fecha
			END,
            'Emitida',
            C.saldo
        FROM #CargosAFacturar C;

        -- Insertar detalles
        INSERT INTO facturacion.DetalleFactura (id_factura, descripcion, monto, tipo_item, cantidad)
        SELECT 
            F.id_factura,
            C.descripcion,
            C.monto,
            C.tipo,
            1
        FROM facturacion.Factura F
        JOIN #CargosAFacturar C ON C.id_cargo = F.id_cargo_actividad_extra;

        DROP TABLE #CargosAFacturar;

        COMMIT;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrMsg, 16, 1);
    END CATCH
END;
GO


/*____________________________________________________________________
  ________________ vw_FacturasDetalladasConResponsables ______________
  ____________________________________________________________________*/

CREATE OR ALTER VIEW facturacion.vw_FacturasDetalladasConResponsables AS
SELECT 
    F.id_factura,
    F.nro_comprobante,
    F.fecha_emision,
    
    -- Socio facturado
    S.dni AS dni_socio,
    S.nombre + ' ' + S.apellido AS socio_facturado,

    -- Responsable de pago (responsable o tutor)
    COALESCE(RS.nombre + ' ' + RS.apellido, T.nombre + ' ' + T.apellido, S.nombre + ' ' + S.apellido) AS responsable_pago,
    COALESCE(RS.dni, T.dni, S.dni) AS dni_responsable_pago,

    -- Detalles
    DF.descripcion,
    DF.tipo_item,
    DF.monto

FROM facturacion.Factura F
INNER JOIN facturacion.CuotaMensual CM ON CM.id_cuota_mensual = F.id_cuota_mensual
INNER JOIN actividades.InscriptoCategoriaSocio ICS ON ICS.id_inscripto_categoria = CM.id_inscripto_categoria
INNER JOIN socios.Socio S ON S.id_socio = ICS.id_socio
LEFT JOIN socios.GrupoFamiliarSocio GFS ON GFS.id_socio = S.id_socio
LEFT JOIN socios.GrupoFamiliar GF ON GF.id_grupo = GFS.id_grupo
LEFT JOIN socios.Socio RS ON RS.id_socio = GF.id_socio_rp
LEFT JOIN socios.Tutor T ON T.id_grupo = GF.id_grupo
INNER JOIN facturacion.DetalleFactura DF ON DF.id_factura = F.id_factura;
GO

CREATE OR ALTER VIEW facturacion.vwFacturaTotalGrupoFamiliar
AS
SELECT 
    RP.dni AS dni_responsable,
    RP.apellido + ', ' + RP.nombre AS responsable,
    F.fecha_emision,
    SUM(F.monto_total) AS total_facturado_grupo,
    COUNT(DISTINCT F.id_factura) AS cantidad_facturas,
    MAX(F.fecha_vencimiento1) AS vencimiento_1,
    MAX(F.fecha_vencimiento2) AS vencimiento_2
FROM socios.GrupoFamiliar GF
INNER JOIN socios.Socio RP ON RP.id_socio = GF.id_socio_rp
INNER JOIN socios.GrupoFamiliarSocio GFS ON GFS.id_grupo = GF.id_grupo
INNER JOIN socios.Socio S ON S.id_socio = GFS.id_socio
INNER JOIN actividades.InscriptoCategoriaSocio ICS ON ICS.id_socio = S.id_socio
INNER JOIN facturacion.CuotaMensual CM ON CM.id_inscripto_categoria = ICS.id_inscripto_categoria
INNER JOIN facturacion.Factura F ON F.id_cuota_mensual = CM.id_cuota_mensual
WHERE S.activo = 1 AND S.eliminado = 0
GROUP BY RP.dni, RP.apellido, RP.nombre, F.fecha_emision;