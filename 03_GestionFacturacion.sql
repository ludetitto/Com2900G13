/* =========================================================================
   Trabajo Pr�ctico Integrador - Bases de Datos Aplicadas
   Grupo N�: 13
   Comisi�n: 2900
   Fecha de Entrega: 17/06/2025
   Materia: Bases de Datos Aplicadas
   Alumnos: Vignardel Francisco 45778667
            De Titto Lucia 46501934
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
    @horario   VARCHAR(50),
    @vigencia  DATE,
    @operacion CHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    -- 1) Validar operaci�n
    IF @operacion NOT IN ('Insertar','Modificar','Eliminar')
    BEGIN
        RAISERROR('Operaci�n inv�lida. Usar Insertar, Modificar o Eliminar.',16,1);
        RETURN;
    END

    -- 2) ELIMINAR
    IF @operacion = 'Eliminar'
    BEGIN
        -- Verificar existencia de la actividad
        IF NOT EXISTS (SELECT 1 FROM actividades.Actividad WHERE nombre = @nombre)
        BEGIN
            RAISERROR('No existe la actividad para eliminar.',16,1);
            RETURN;
        END

        DECLARE @id_actividad INT;
        SELECT @id_actividad = id_actividad
        FROM actividades.Actividad
        WHERE nombre = @nombre;

        BEGIN TRY
            BEGIN TRANSACTION;

            -- Primero borrar presentismos de las clases vinculadas
            DELETE pc
            FROM actividades.presentismoClase AS pc
            INNER JOIN actividades.Clase AS c
                ON pc.id_clase = c.id_clase
            WHERE c.id_actividad = @id_actividad;

            -- Luego borrar inscripciones a las clases vinculadas
            DELETE ic
            FROM actividades.InscriptoClase AS ic
            INNER JOIN actividades.Clase AS c
                ON ic.id_clase = c.id_clase
            WHERE c.id_actividad = @id_actividad;

            -- Luego borrar las clases de esa actividad
            DELETE FROM actividades.Clase
            WHERE id_actividad = @id_actividad;

            -- Finalmente borrar la actividad
            DELETE FROM actividades.Actividad
            WHERE id_actividad = @id_actividad;

            COMMIT TRANSACTION;
        END TRY
        BEGIN CATCH
            IF XACT_STATE() <> 0
                ROLLBACK TRANSACTION;
            THROW;
        END CATCH

        RETURN;
    END

    -- 3) MODIFICAR
    ELSE IF @operacion = 'Modificar'
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM actividades.Actividad WHERE nombre = @nombre)
        BEGIN
            RAISERROR('No existe la actividad para modificar.',16,1);
            RETURN;
        END

        UPDATE actividades.Actividad
        SET 
            costo    = COALESCE(@costo,    costo),
            horario  = COALESCE(@horario,  horario),
            vigencia = COALESCE(@vigencia, vigencia)
        WHERE nombre = @nombre;
        RETURN;
    END

    -- 4) INSERTAR + validaci�n de duplicados
    ELSE /* @operacion = 'Insertar' */
    BEGIN
        -- Nombre obligatorio
        IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
        BEGIN
            RAISERROR('El nombre es obligatorio.',16,1);
            RETURN;
        END
        -- Costo v�lido
        IF @costo IS NULL OR @costo < 0
        BEGIN
            RAISERROR('El costo debe ser un n�mero positivo.',16,1);
            RETURN;
        END
        -- No permitir duplicados de nombre
        IF EXISTS (SELECT 1 FROM actividades.Actividad WHERE nombre = @nombre)
        BEGIN
            RAISERROR('Ya existe una actividad con ese nombre.',16,1);
            RETURN;
        END

        INSERT INTO actividades.Actividad (nombre, costo, horario, vigencia)
        VALUES (@nombre, @costo, @horario, @vigencia);
    END
END;
GO

IF OBJECT_ID('actividades.GestionarClase', 'P') IS NOT NULL
    DROP PROCEDURE actividades.GestionarClase;
GO

CREATE PROCEDURE actividades.GestionarClase
    @nombre_actividad VARCHAR(100),
    @dni_profesor      VARCHAR(10),
    @horario           VARCHAR(20),
    @operacion         CHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    /* 1) Verificar operaci�n v�lida */
    IF @operacion NOT IN ('Insertar','Modificar','Eliminar')
    BEGIN
        RAISERROR('Operaci�n inv�lida. Usar Insertar, Modificar o Eliminar.', 16, 1);
        RETURN;
    END

    DECLARE @actividad_id INT;
    DECLARE @profesor_id   INT;
    DECLARE @id_clase       INT;

    /* === CASO: INSERTAR === */
    IF @operacion = 'Insertar'
    BEGIN
        /* Validar datos obligatorios */
        IF @nombre_actividad IS NULL OR LEN(@nombre_actividad)=0
        BEGIN
            RAISERROR('El nombre de la actividad es obligatorio.', 16, 1);
            RETURN;
        END
        IF @dni_profesor IS NULL OR LEN(@dni_profesor)=0
        BEGIN
            RAISERROR('El DNI del profesor es obligatorio.', 16, 1);
            RETURN;
        END

        /* Obtener IDs */
        SET @actividad_id = (
            SELECT id_actividad
            FROM actividades.Actividad
            WHERE nombre = @nombre_actividad
        );
        SET @profesor_id = (
            SELECT Pr.id_profesor
            FROM administracion.Profesor Pr
            JOIN administracion.Persona Pe ON Pr.id_persona = Pe.id_persona
            WHERE Pe.dni = @dni_profesor
        );

        /* Validar existencia de actividad y profesor */
        IF @actividad_id IS NULL
        BEGIN
            RAISERROR('No existe la actividad "%s".', 16, 1, @nombre_actividad);
            RETURN;
        END
        IF @profesor_id IS NULL
        BEGIN
            RAISERROR('No existe el profesor con DNI %s.', 16, 1, @dni_profesor);
            RETURN;
        END

        /* Insertar */
        INSERT INTO actividades.Clase (id_actividad, id_profesor, horario)
        VALUES (@actividad_id, @profesor_id, @horario);
        RETURN;
    END

    /* === CASO: MODIFICAR === */
    IF @operacion = 'Modificar'
    BEGIN
        /* Validar que el profesor exista */
        IF @dni_profesor IS NULL OR LEN(@dni_profesor)=0
        BEGIN
            RAISERROR('El DNI del profesor es obligatorio para modificar.', 16, 1);
            RETURN;
        END

        SET @profesor_id = (
            SELECT Pr.id_profesor
            FROM administracion.Profesor Pr
            JOIN administracion.Persona Pe ON Pr.id_persona = Pe.id_persona
            WHERE Pe.dni = @dni_profesor
        );
        IF @profesor_id IS NULL
        BEGIN
            RAISERROR('No existe el profesor con DNI %s.', 16, 1, @dni_profesor);
            RETURN;
        END

        /* Ubicar la clase por actividad + profesor */
        SET @id_clase = (
            SELECT C.id_clase
            FROM actividades.Clase C
            JOIN actividades.Actividad A ON C.id_actividad = A.id_actividad
            WHERE A.nombre = @nombre_actividad
              AND C.id_profesor = @profesor_id
        );
        IF @id_clase IS NULL
        BEGIN
            RAISERROR('No existe la clase a modificar para esa actividad y profesor.', 16, 1);
            RETURN;
        END

        /* Obtener posible nueva actividad (si cambia nombre) */
        SET @actividad_id = (
            SELECT id_actividad
            FROM actividades.Actividad
            WHERE nombre = @nombre_actividad
        );

        /* Realizar UPDATE: permite s�lo cambiar horario (o actividad/profesor si se ajusta el SP) */
        UPDATE actividades.Clase
        SET 
            id_actividad = COALESCE(@actividad_id, id_actividad),
            id_profesor  = @profesor_id,
            horario      = COALESCE(@horario, horario)
        WHERE id_clase = @id_clase;
        RETURN;
    END

    /* === CASO: ELIMINAR === */
    IF @operacion = 'Eliminar'
    BEGIN
        /* Validar datos obligatorios */
        IF @nombre_actividad IS NULL OR LEN(@nombre_actividad)=0
           OR @dni_profesor IS NULL OR LEN(@dni_profesor)=0
           OR @horario IS NULL OR LEN(@horario)=0
        BEGIN
            RAISERROR('Nombre de actividad, DNI de profesor y horario son requeridos para eliminar.', 16, 1);
            RETURN;
        END

        /* Verificar profesor */
        SET @profesor_id = (
            SELECT Pr.id_profesor
            FROM administracion.Profesor Pr
            JOIN administracion.Persona Pe ON Pr.id_persona = Pe.id_persona
            WHERE Pe.dni = @dni_profesor
        );
        IF @profesor_id IS NULL
        BEGIN
            RAISERROR('No existe el profesor con DNI %s.', 16, 1, @dni_profesor);
            RETURN;
        END

        /* Ubicar registro exacto por actividad+profesor+horario */
        SET @id_clase = (
            SELECT id_clase
            FROM actividades.Clase
            WHERE id_actividad = (
                SELECT id_actividad
                FROM actividades.Actividad
                WHERE nombre = @nombre_actividad
            )
              AND id_profesor = @profesor_id
              AND horario = @horario
        );
        IF @id_clase IS NULL
        BEGIN
            RAISERROR('No existe la clase a eliminar con esos datos.', 16, 1);
            RETURN;
        END

        DELETE FROM actividades.Clase
        WHERE id_clase = @id_clase;
        RETURN;
    END
END;
GO


/*____________________________________________________________________
  _______________________ GestionarInscripcion _______________________
  ____________________________________________________________________*/
  IF OBJECT_ID('actividades.GestionarInscripcion', 'P') IS NOT NULL
    DROP PROCEDURE actividades.GestionarInscripcion;
GO

CREATE PROCEDURE actividades.GestionarInscripcion
    @dni_socio VARCHAR(10),
    @nombre_actividad VARCHAR(100),
    @horario VARCHAR(50),
    @fecha_inscripcion DATE,
    @operacion CHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validaci�n de operaci�n
    IF @operacion NOT IN ('Insertar', 'Modificar', 'Eliminar')
    BEGIN
        RAISERROR('Operaci�n inv�lida. Usar Insertar, Modificar o Eliminar.', 16, 1);
        RETURN;
    END

    -- Normalizar DNI (elimina ceros a la izquierda)
    DECLARE @dni_normalizado VARCHAR(10) = RIGHT('00000000' + LTRIM(STR(CAST(@dni_socio AS INT))), 8);

    -- Buscar id_socio
    DECLARE @id_socio INT = (
        SELECT TOP 1 S.id_socio
        FROM administracion.Socio S
        INNER JOIN administracion.Persona P ON S.id_persona = P.id_persona
        WHERE REPLACE(P.dni, ' ', '') = @dni_normalizado AND S.activo = 1
    );

    -- Buscar id_clase
    DECLARE @id_clase INT = (
        SELECT TOP 1 C.id_clase
        FROM actividades.Clase C
        INNER JOIN actividades.Actividad A ON C.id_actividad = A.id_actividad
        WHERE A.nombre = @nombre_actividad AND C.horario = @horario
    );

    -- Buscar id_inscripto
    DECLARE @id_inscripto INT = (
        SELECT TOP 1 IC.id_inscripto
        FROM actividades.InscriptoClase IC
        WHERE IC.id_socio = @id_socio AND IC.id_clase = @id_clase
    );

    /*CASO 1: Eliminar inscripci�n*/
    IF @operacion = 'Eliminar'
    BEGIN
        IF @id_inscripto IS NULL
        BEGIN
            RAISERROR('No existe la inscripci�n para eliminar.', 16, 1);
            RETURN;
        END

        DELETE FROM actividades.InscriptoClase WHERE id_inscripto = @id_inscripto;
        RETURN;
    END

    /*CASO 2: Modificar inscripci�n*/
    ELSE IF @operacion = 'Modificar'
    BEGIN
        IF @id_inscripto IS NULL
        BEGIN
            RAISERROR('No existe la inscripci�n para modificar.', 16, 1);
            RETURN;
        END

        UPDATE actividades.InscriptoClase
        SET fecha_inscripcion = COALESCE(@fecha_inscripcion, fecha_inscripcion)
        WHERE id_inscripto = @id_inscripto;
        RETURN;
    END

    /*CASO 3: Insertar inscripci�n*/
    ELSE IF @operacion = 'Insertar'
    BEGIN
        IF @id_socio IS NULL
        BEGIN
            RAISERROR('El socio no existe o no est� activo.', 16, 1);
            RETURN;
        END

        IF @id_clase IS NULL
        BEGIN
            RAISERROR('La clase no existe.', 16, 1);
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM actividades.InscriptoClase WHERE id_socio = @id_socio AND id_clase = @id_clase)
        BEGIN
            RAISERROR('El socio ya est� inscripto en la clase.', 16, 1);
            RETURN;
        END

        IF @fecha_inscripcion IS NULL
            SET @fecha_inscripcion = GETDATE();

        INSERT INTO actividades.InscriptoClase (id_socio, id_clase, fecha_inscripcion)
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
    @nombre_actividad VARCHAR(100),
    @dni_socio VARCHAR(10),
    @horario VARCHAR(20),
    @fecha DATE,
    @condicion CHAR(1) = NULL,
    @operacion CHAR(10)
AS
BEGIN
    SET NOCOUNT ON;
	/*Verificaci�n de operaciones v�lidas*/
    IF @operacion NOT IN ('Insertar', 'Modificar', 'Eliminar')
    BEGIN
        RAISERROR('Operaci�n inv�lida. Usar Insertar, Modificar o Eliminar.', 16, 1);
        RETURN;
    END

	/*Se obtienen los identificadores necesarios*/
	DECLARE @id_clase INT = (SELECT C.id_clase
							 FROM actividades.Clase C
							 INNER JOIN actividades.Actividad A ON A.id_actividad = C.id_actividad
							 WHERE A.nombre = @nombre_actividad AND C.horario = @horario);

	DECLARE @id_socio INT = (SELECT S.id_socio
							 FROM administracion.Socio S
							 INNER JOIN administracion.Persona P ON S.id_persona = P.id_persona
							 WHERE P.dni = @dni_socio);

	DECLARE @id_presentismo INT = (SELECT id_presentismo
								   FROM actividades.presentismoClase
								   WHERE id_clase = @id_clase AND id_socio = @id_socio AND fecha = COALESCE(@fecha, CONVERT(date, GETDATE())));

	/*CASO 1: Eliminar presentismo*/
    IF @operacion = 'Eliminar'
    BEGIN
		/*Verificaci�n de existencia de presentismo a borrar.*/
        IF @id_presentismo IS NULL
        BEGIN
            RAISERROR('No existe el presentismo para eliminar.', 16, 1);
            RETURN;
        END

        DELETE FROM actividades.presentismoClase WHERE id_presentismo = @id_presentismo;
    END
	/*CASO 2: Modificar presentismo*/
    ELSE IF @operacion = 'Modificar'
    BEGIN
		/*Verificaci�n de existencia de presentismo a modificar.*/
        IF @id_presentismo IS NULL
        BEGIN
            RAISERROR('No existe el presentismo para modificar.', 16, 1);
            RETURN;
        END
		/*Se utiliza COALESCE para asegurar dato v�lido en caso de que alg�n usuario ingrese NULL en alg�n campo*/
        UPDATE actividades.presentismoClase
        SET id_clase = COALESCE(@id_clase, id_clase),
            id_socio = COALESCE(@id_socio, id_socio),
            fecha = COALESCE(@fecha, fecha),
            condicion = COALESCE(@condicion, condicion)
        WHERE id_presentismo = @id_presentismo;
    END
	/*CASO 3: Insertar presentismo*/
    ELSE IF @operacion = 'Insertar'
    BEGIN
		/*Verificaci�n de datos no nulos necesarios para insertar presentismo*/
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

        IF @fecha IS NULL
            SET @fecha = GETDATE();

        IF @condicion IS NULL
            SET @condicion = 'P'; -- Ejemplo: P=Presente

        INSERT INTO actividades.presentismoClase (id_clase, id_socio, fecha, condicion)
        VALUES (@id_clase, @id_socio, @fecha, @condicion);
    END
END;
GO

/*_________________________________________________________________________
  ____________________ GestionarActividadExtra ____________________________
  _________________________________________________________________________*/
  IF OBJECT_ID('actividades.GestionarActividadExtra', 'P') IS NOT NULL
    DROP PROCEDURE actividades.GestionarActividadExtra;
GO

CREATE PROCEDURE actividades.GestionarActividadExtra
    @nombre      VARCHAR(100),
    @costo       DECIMAL(10,2),
    @periodo     CHAR(10),
    @es_invitado CHAR(1),
    @vigencia    DATE,
    @operacion   CHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    -- 1) Verificar operaci�n v�lida
    IF @operacion NOT IN ('Insertar','Modificar','Eliminar')
    BEGIN
        RAISERROR('Operaci�n inv�lida. Usar Insertar, Modificar o Eliminar.',16,1);
        RETURN;
    END

    -- 2) Contar y preparar variable �nica para id_extra
    DECLARE 
        @count_extra INT,
        @id_extra    INT;

    SELECT @count_extra = COUNT(*)
    FROM actividades.ActividadExtra
    WHERE nombre      = @nombre
      AND periodo     = @periodo
      AND es_invitado = @es_invitado;

    -- 3) Eliminar
    IF @operacion = 'Eliminar'
    BEGIN
        IF @count_extra = 0
        BEGIN
            RAISERROR('No existe la actividad extra para eliminar.',16,1);
            RETURN;
        END
        IF @count_extra > 1
        BEGIN
            RAISERROR('Hay m�s de una fila que coincide; operaci�n ambigua.',16,1);
            RETURN;
        END

        SELECT @id_extra = id_extra
        FROM actividades.ActividadExtra
        WHERE nombre=@nombre AND periodo=@periodo AND es_invitado=@es_invitado;

        DELETE FROM actividades.ActividadExtra
        WHERE id_extra = @id_extra;
        RETURN;
    END

    -- 4) Modificar
    ELSE IF @operacion = 'Modificar'
    BEGIN
        IF @count_extra = 0
        BEGIN
            RAISERROR('No existe la actividad extra para modificar.',16,1);
            RETURN;
        END
        IF @count_extra > 1
        BEGIN
            RAISERROR('Hay m�s de una fila que coincide; operaci�n ambigua.',16,1);
            RETURN;
        END

        SELECT @id_extra = id_extra
        FROM actividades.ActividadExtra
        WHERE nombre=@nombre AND periodo=@periodo AND es_invitado=@es_invitado;

        UPDATE actividades.ActividadExtra
        SET 
            nombre      = COALESCE(@nombre,      nombre),
            costo       = COALESCE(@costo,       costo),
            periodo     = COALESCE(@periodo,     periodo),
            es_invitado = COALESCE(@es_invitado, es_invitado),
            vigencia    = COALESCE(@vigencia,    vigencia)
        WHERE id_extra = @id_extra;
        RETURN;
    END

    -- 5) Insertar + validaci�n de duplicados
    ELSE /* Insertar */
    BEGIN
        IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
        BEGIN
            RAISERROR('El nombre de la actividad extra es obligatorio.',16,1);
            RETURN;
        END
        IF @costo IS NULL OR @costo < 0
        BEGIN
            RAISERROR('El costo debe ser un n�mero positivo.',16,1);
            RETURN;
        END
        IF @count_extra > 0
        BEGIN
            RAISERROR('Ya existe una actividad extra con esos par�metros.',16,1);
            RETURN;
        END

        INSERT INTO actividades.ActividadExtra
            (nombre, costo, periodo, es_invitado, vigencia)
        VALUES
            (@nombre, @costo, @periodo, @es_invitado, @vigencia);
    END
END;
GO

/*____________________________________________________________________
  _______________ GestionarPresentismoActividadExtra _________________
  ____________________________________________________________________*/
  IF OBJECT_ID('actividades.GestionarPresentismoActividadExtra', 'P') IS NOT NULL
    DROP PROCEDURE actividades.GestionarPresentismoActividadExtra;
GO

CREATE PROCEDURE actividades.GestionarPresentismoActividadExtra
    @nombre_actividad_extra VARCHAR(100),
    @periodo CHAR(10),
    @es_invitado CHAR(1),
    @dni_socio VARCHAR(10) = NULL,
    @fecha DATE = NULL,
    @condicion CHAR(1) = NULL,
    @operacion CHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validaci�n de operaci�n
    IF @operacion NOT IN ('Insertar', 'Modificar', 'Eliminar')
    BEGIN
        RAISERROR('Operaci�n inv�lida. Usar Insertar, Modificar o Eliminar.', 16, 1);
        RETURN;
    END

    -- Normalizar es_invitado
    SET @es_invitado = UPPER(@es_invitado);

    -- Validaci�n seg�n tipo de participante e INSERT
    IF @operacion = 'Insertar'
    BEGIN
        IF @nombre_actividad_extra IS NULL
        BEGIN
            RAISERROR('El nombre de la actividad extra es obligatorio.', 16, 1);
            RETURN;
        END

        IF @es_invitado NOT IN ('N', 'S')
        BEGIN
            RAISERROR('El campo es_invitado solo puede ser N o S.', 16, 1);
            RETURN;
        END

        IF @es_invitado = 'N'
        BEGIN
            -- Socio: el dni es obligatorio y debe existir
            IF @dni_socio IS NULL OR LEN(LTRIM(RTRIM(@dni_socio))) = 0
            BEGIN
                RAISERROR('El dni del socio es obligatorio para participantes socios.', 16, 1);
                RETURN;
            END
            IF NOT EXISTS (
                SELECT 1
                FROM administracion.Persona Pe
                INNER JOIN administracion.Socio S ON Pe.id_persona = S.id_persona
                WHERE Pe.dni = @dni_socio AND S.activo = 1
            )
            BEGIN
                RAISERROR('No existe un socio activo con ese DNI.', 16, 1);
                RETURN;
            END
        END
        ELSE IF @es_invitado = 'S'
        BEGIN
            -- Invitado: puede ser con o sin socio
            IF @dni_socio IS NOT NULL AND NOT EXISTS (
                SELECT 1
                FROM administracion.Persona Pe
                INNER JOIN administracion.Socio S ON Pe.id_persona = S.id_persona
                WHERE Pe.dni = @dni_socio AND S.activo = 1
            )
            BEGIN
                RAISERROR('No existe un socio activo con ese DNI.', 16, 1);
                RETURN;
            END
        END

        IF @fecha IS NULL
            SET @fecha = GETDATE();

        IF @condicion IS NULL
            SET @condicion = 'P';

        INSERT INTO actividades.presentismoActividadExtra (id_extra, id_socio, fecha, condicion)
        VALUES (
            (SELECT id_extra
                FROM actividades.ActividadExtra
                WHERE nombre = @nombre_actividad_extra
                    AND periodo = @periodo
                    AND es_invitado = @es_invitado
            ),
            (SELECT S.id_socio
                FROM administracion.Socio S
                INNER JOIN administracion.Persona Pe ON S.id_persona = Pe.id_persona
                WHERE Pe.dni = @dni_socio),
            @fecha,
            @condicion
        );
        RETURN;
    END

    -- Buscar id_presentismo
    DECLARE @id_presentismo INT = (
        SELECT TOP 1 P.id_presentismo_extra
        FROM actividades.presentismoActividadExtra P
        INNER JOIN actividades.ActividadExtra AE ON P.id_extra = AE.id_extra
        LEFT JOIN administracion.Socio S ON P.id_socio = S.id_socio
        LEFT JOIN administracion.Persona Pe ON S.id_persona = Pe.id_persona
        WHERE AE.nombre = @nombre_actividad_extra
            AND AE.periodo = @periodo
            AND AE.es_invitado = @es_invitado
            AND (@dni_socio IS NULL OR Pe.dni = @dni_socio)
            AND P.fecha = ISNULL(@fecha, CAST(GETDATE() AS DATE))
    );

    -- CASO ELIMINAR
    IF @operacion = 'Eliminar'
    BEGIN
        IF @id_presentismo IS NULL
        BEGIN
            RAISERROR('No existe el presentismo para eliminar.', 16, 1);
            RETURN;
        END

        DELETE FROM actividades.presentismoActividadExtra WHERE id_presentismo_extra = @id_presentismo;
        RETURN;
    END

    -- CASO MODIFICAR
    IF @operacion = 'Modificar'
    BEGIN
        IF @id_presentismo IS NULL
        BEGIN
            RAISERROR('No existe el presentismo para modificar.', 16, 1);
            RETURN;
        END

        UPDATE actividades.presentismoActividadExtra
        SET
            id_extra = COALESCE((
                SELECT id_extra
                FROM actividades.ActividadExtra
                WHERE nombre = @nombre_actividad_extra
                    AND periodo = @periodo
                    AND es_invitado = @es_invitado
            ), id_extra),
            id_socio = COALESCE((
                SELECT S.id_socio
                FROM administracion.Socio S
                INNER JOIN administracion.Persona Pe ON S.id_persona = Pe.id_persona
                WHERE Pe.dni = @dni_socio
            ), id_socio),
            fecha = COALESCE(@fecha, fecha),
            condicion = COALESCE(@condicion, condicion)
        WHERE id_presentismo_extra = @id_presentismo;
        RETURN;
    END
END;
GO

/*____________________________________________________________________
  ________________ GestionarInscriptoActividadExtra _________________
  ____________________________________________________________________*/

IF OBJECT_ID('actividades.GestionarInscriptoActividadExtra', 'P') IS NOT NULL
    DROP PROCEDURE actividades.GestionarInscriptoActividadExtra;
GO

CREATE PROCEDURE actividades.GestionarInscriptoActividadExtra
    @dni_socio VARCHAR(10),
    @nombre_actividad_extra VARCHAR(100),
    @fecha_inscripcion DATE = NULL,
    @operacion CHAR(10)
AS
BEGIN
    SET NOCOUNT ON;
	/*Verificaci�n de operaciones v�lidas*/
    IF @operacion NOT IN ('Insertar', 'Modificar', 'Eliminar')
    BEGIN
        RAISERROR('Operaci�n inv�lida. Usar Insertar, Modificar o Eliminar.', 16, 1);
        RETURN;
    END
	/*Se obtiene el id_inscripto en caso de eliminar o modificar una inscripci�n*/
	DECLARE @id_inscripto INT = (SELECT PAE.id_presentismo_extra
								 FROM actividades.PresentismoActividadExtra PAE
								 INNER JOIN actividades.ActividadExtra AE ON PAE.id_extra = AE.id_extra
								 INNER JOIN administracion.Socio S ON PAE.id_socio = S.id_socio
								 INNER JOIN administracion.Persona P ON S.id_persona = P.id_persona
								 WHERE AE.nombre = @nombre_actividad_extra AND P.dni = @dni_socio)
	/*CASO 1: Eliminar inscripci�n*/
    IF @operacion = 'Eliminar'
    BEGIN
		/*Verificaci�n de existencia de inscripci�n a borrar.*/
        IF @id_inscripto IS NULL
        BEGIN
            RAISERROR('No existe la inscripci�n para eliminar.', 16, 1);
            RETURN;
        END

        DELETE FROM actividades.PresentismoActividadExtra WHERE id_presentismo_extra = @id_inscripto;
    END
	/*CASO 2: Modificar inscripci�n*/
    ELSE IF @operacion = 'Modificar'
    BEGIN
		/*Verificaci�n de existencia de inscripci�n a modificar.*/
        IF @id_inscripto IS NULL
        BEGIN
            RAISERROR('No existe la inscripci�n para modificar.', 16, 1);
            RETURN;
        END
		/*Se utiliza COALESCE para asegurar dato v�lido en caso de que alg�n usuario ingrese NULL en alg�n campo*/
        UPDATE actividades.PresentismoActividadExtra
        SET id_socio = COALESCE((SELECT S.id_socio
								 FROM administracion.Socio S
								 INNER JOIN administracion.Persona P ON S.id_persona = P.id_persona
								 WHERE P.dni = @dni_socio), id_socio),
            id_extra = COALESCE((SELECT AE.id_extra
								 FROM actividades.ActividadExtra AE
								 WHERE AE.nombre = @nombre_actividad_extra), id_extra),
            fecha = COALESCE(@fecha_inscripcion, fecha)
        WHERE id_presentismo_extra = @id_inscripto;
    END
	/*CASO 3: Insertar inscripci�n*/
    ELSE IF @operacion = 'Insertar'
    BEGIN
		/*Verificaci�n de datos no nulos necesarios para insertar inscripci�n*/
        IF @dni_socio IS NULL
        BEGIN
            RAISERROR('El dni del socio es obligatorio.', 16, 1);
            RETURN;
        END

        IF @nombre_actividad_extra IS NULL
        BEGIN
            RAISERROR('El nombre de la actividad extra es obligatorio.', 16, 1);
            RETURN;
        END

        IF @fecha_inscripcion IS NULL
            SET @fecha_inscripcion = GETDATE();

        INSERT INTO actividades.PresentismoActividadExtra(id_socio, id_extra, fecha)
        VALUES (
			(SELECT S.id_socio
			 FROM administracion.Socio S
			 INNER JOIN administracion.Persona P ON S.id_persona = P.id_persona
			 WHERE P.dni = @dni_socio),
			(SELECT AE.id_extra
			 FROM actividades.ActividadExtra AE
			 WHERE AE.nombre = @nombre_actividad_extra),
			@fecha_inscripcion);
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

    /* Verificaci�n de operaciones v�lidas */
    IF @operacion NOT IN ('Insertar', 'Modificar', 'Eliminar')
    BEGIN
        RAISERROR('Operaci�n inv�lida. Usar Insertar, Modificar o Eliminar.', 16, 1);
        RETURN;
    END

    /* Obtener id_emisor a partir del CUIL (clave �nica) */
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
            RAISERROR('No se encontr� emisor con ese CUIL para eliminar.', 16, 1);
            RETURN;
        END

        DELETE FROM facturacion.EmisorFactura WHERE id_emisor = @id_emisor;
    END

    /* CASO 2: Modificar */
    ELSE IF @operacion = 'Modificar'
    BEGIN
        IF @id_emisor IS NULL
        BEGIN
            RAISERROR('No se encontr� emisor con ese CUIL para modificar.', 16, 1);
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
            RAISERROR('CUIL y raz�n social son obligatorios para insertar.', 16, 1);
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

/*____________________________________________________________________
  ____________________________ AnularFactura __________________________
  ____________________________________________________________________*/
IF OBJECT_ID('facturacion.AnularFactura', 'P') IS NOT NULL
    DROP PROCEDURE facturacion.AnularFactura;
GO

CREATE PROCEDURE facturacion.AnularFactura(
	@id_factura INT,
    @motivo NVARCHAR(255)
)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @id_pago INT;
	DECLARE @monto DECIMAL(10, 2) = (SELECT TOP 1 monto_total FROM facturacion.Factura WHERE id_factura = @id_factura);

	IF @id_factura IN (SELECT id_factura FROM facturacion.Factura WHERE estado = 'Pagada')
	BEGIN
		SET @id_pago = (SELECT TOP 1 id_pago FROM cobranzas.Pago WHERE id_factura = @id_factura);

		EXEC cobranzas.GenerarReembolso
			@id_pago = @id_pago,
			@monto = @monto,
			@motivo = @motivo;
	END
	ELSE
		UPDATE facturacion.Factura
		SET anulada = 1
		WHERE id_factura = @id_factura
END;
GO

/*____________________________________________________________________
  __________________________ GenerarFactura ________________________
  ____________________________________________________________________*/
IF OBJECT_ID('facturacion.GenerarFacturaSocioMensual', 'P') IS NOT NULL
    DROP PROCEDURE facturacion.GenerarFacturaSocioMensual;
GO

CREATE PROCEDURE facturacion.GenerarFacturaSocioMensual
(
    @dni_socio CHAR(10),
    @cuil_emisor VARCHAR(20)
)
AS
BEGIN
    SET NOCOUNT ON;
	/*Se realiza mediante una transacci�n a fin de garantizar ACID*/
    BEGIN TRY
        BEGIN TRANSACTION;
		/*Creaci�n de variables auxiliares para id_socio e id_emisor*/
        DECLARE @id_socio INT;
        DECLARE @id_emisor INT;
		DECLARE @monto_total DECIMAL(10, 2) = 0;
		DECLARE @id_factura INT;

        /*Se obtiene el id_socio asociado a su correspondiente DNI*/
        SELECT @id_socio = id_socio 
        FROM administracion.Socio s
        INNER JOIN administracion.Persona p ON s.id_persona = p.id_persona
        WHERE p.dni = @dni_socio;

		/*Si no existe el socio, no se realiza la transacci�n*/
        IF @id_socio IS NULL
        BEGIN
            RAISERROR('No se encontr� socio responsable con ese DNI.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

		/*Si el socio no est� activo, no se genera la factura*/
        IF @id_socio IN (SELECT id_socio FROM administracion.Socio WHERE activo = 0)
        BEGIN
            RAISERROR('El socio que se est� intentando facturar se encuentra inactivo.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

		IF EXISTS (
		SELECT TOP 1 id_factura
		FROM facturacion.Factura
		WHERE id_socio = @id_socio
		  AND MONTH(fecha_emision) = MONTH(GETDATE())
		  AND YEAR(fecha_emision) = YEAR(GETDATE())
		  AND anulada = 0
		)
		BEGIN
			RAISERROR('Ya fue facturada la actividad de este grupo familiar en este mes.', 16, 1);
			ROLLBACK TRANSACTION;
			RETURN;
		END

        /*Se obtiene el id_emisor asociado a su correspondiente CUIL*/
        SELECT @id_emisor = id_emisor
        FROM facturacion.EmisorFactura
        WHERE cuil = @cuil_emisor;
		
		/*Si no existe el emisor, no se realiza la transacci�n*/
        IF @id_emisor IS NULL
        BEGIN
            RAISERROR('No se encontr� emisor con ese CUIL.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

		/*Obtener monto total a facturar*/
		SELECT @monto_total += costo_membresia
		FROM administracion.CategoriaSocio CS
		INNER JOIN administracion.Socio S ON S.id_categoria = CS.id_categoria
		WHERE S.id_socio = @id_socio;

		SELECT @monto_total += costo
		FROM actividades.Actividad A
		INNER JOIN actividades.Clase C ON C.id_actividad = A.id_actividad
		INNER JOIN actividades.InscriptoClase I ON I.id_clase = C.id_clase
		WHERE I.id_socio = @id_socio

		SELECT @monto_total += monto
		FROM cobranzas.Mora
		WHERE id_socio = @id_socio

		IF @id_socio IN (SELECT id_socio_rp FROM administracion.GrupoFamiliar)
		BEGIN
			SELECT @monto_total += CS.costo_membresia
			FROM administracion.CategoriaSocio CS
			INNER JOIN administracion.Socio S ON S.id_categoria = CS.id_categoria
			INNER JOIN administracion.GrupoFamiliar G ON G.id_socio = S.id_socio
			WHERE G.id_socio_rp = @id_socio;

			SELECT @monto_total += A.costo
			FROM actividades.Actividad A
			INNER JOIN actividades.Clase C ON C.id_actividad = A.id_actividad
			INNER JOIN actividades.InscriptoClase I ON I.id_clase = C.id_clase
			INNER JOIN administracion.GrupoFamiliar G ON G.id_socio = I.id_socio
			WHERE G.id_socio_rp = @id_socio;
		END

		/*Sumar montos*/
		/* - 1000 + 500		--> -500 y saldo 0	*/
		/* - 1000 + 0		-->	-1000 y saldo 0	*/
		/* - 1000 - 2000	--> -3000 y saldo 0 */

		/*Generar factura per s�*/
        INSERT INTO facturacion.Factura
        (id_emisor, id_socio, leyenda, monto_total, saldo_anterior, fecha_emision, fecha_vencimiento1, fecha_vencimiento2, estado, anulada)
		VALUES
        (
			@id_emisor, 
			@id_socio, 
			'Consumidor final', 
			-@monto_total, 
			(SELECT ISNULL(SUM(saldo), 0)FROM administracion.Socio WHERE id_socio = @id_socio),
			GETDATE(), 
			GETDATE() + 5, 
			GETDATE() + 10, 
			'No pagada', 
			0);

		SET @id_factura = (SELECT TOP 1 id_factura FROM facturacion.Factura ORDER BY fecha_emision DESC)

		/*Obtener todas las actividades pendientes de pago asociadas al socio*/

        /*Generar detalles de factura*/

		-- MEMBRES�A DEL SOCIO
        INSERT INTO facturacion.DetalleFactura
			(id_factura, id_categoria, tipo_item, descripcion, monto, cantidad)
		SELECT
			@id_factura,
			CS.id_categoria,
			'Membresia',
			CS.nombre,
			CS.costo_membresia,
			1
		FROM administracion.CategoriaSocio CS
		INNER JOIN administracion.Socio S ON S.id_categoria = CS.id_categoria
		WHERE S.id_socio = @id_socio;

		-- ACTIVIDADES DEL SOCIO
		INSERT INTO facturacion.DetalleFactura
			(id_factura, id_actividad, tipo_item, descripcion, monto, cantidad)
		SELECT
			@id_factura,
			A.id_actividad,
			'Actividad',
			A.nombre,
			A.costo,
			COUNT(A.id_actividad) OVER(PARTITION BY I.id_socio) AS cantidad
		FROM actividades.Actividad A
		INNER JOIN actividades.Clase C ON C.id_actividad = A.id_actividad
		INNER JOIN actividades.InscriptoClase I ON I.id_clase = C.id_clase
		WHERE I.id_socio = @id_socio

		-- MEMBRES�AS DE FAMILIARES
		IF @id_socio IN (SELECT id_socio_rp FROM administracion.GrupoFamiliar)
		BEGIN
            INSERT INTO facturacion.DetalleFactura
			(id_factura, id_categoria, tipo_item, descripcion, monto, cantidad)
			SELECT
				@id_factura,
				CS.id_categoria,
				'Membresia',
				CS.nombre,
				CS.costo_membresia,
				1
			FROM administracion.CategoriaSocio CS
			INNER JOIN administracion.Socio S ON S.id_categoria = CS.id_categoria
			INNER JOIN administracion.GrupoFamiliar G ON G.id_socio = S.id_socio
			WHERE G.id_socio_rp = @id_socio;

			-- ACTIVIDADES DE FAMILIARES
			INSERT INTO facturacion.DetalleFactura
				(id_factura, id_actividad, tipo_item, descripcion, monto, cantidad)
			SELECT
				@id_factura,
				A.id_actividad,
				'Actividad',
				A.nombre,
				A.costo,
				COUNT(A.id_actividad) OVER(PARTITION BY I.id_socio) AS cantidad
			FROM actividades.Actividad A
			INNER JOIN actividades.Clase C ON C.id_actividad = A.id_actividad
			INNER JOIN actividades.InscriptoClase I ON I.id_clase = C.id_clase
			INNER JOIN administracion.GrupoFamiliar G ON G.id_socio = I.id_socio
			WHERE G.id_socio_rp = @id_socio;
        END

		-- MORA (asumiendo que el id_socio es el del responsable)
		INSERT INTO facturacion.DetalleFactura
				(id_factura, id_extra, tipo_item, descripcion, monto, cantidad)
			SELECT
				@id_factura,
				NULL,
				'Inter�s por Mora',
				'Mora a fecha actual.',
				monto,
				1
			FROM cobranzas.Mora
			WHERE id_socio = @id_socio

		/*Confirmar transacci�n*/
        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

/*____________________________________________________________________
  ____________________ GenerarFacturaSocioActExtra ___________________
  ____________________________________________________________________*/
IF OBJECT_ID('facturacion.GenerarFacturaSocioActExtra', 'P') IS NOT NULL
    DROP PROCEDURE facturacion.GenerarFacturaSocioActExtra;
GO

CREATE PROCEDURE facturacion.GenerarFacturaSocioActExtra
(
    @dni_socio CHAR(10),
    @cuil_emisor VARCHAR(20)
)
AS
BEGIN
	SET NOCOUNT ON;
	/*Se realiza mediante una transacci�n a fin de garantizar ACID*/
    BEGIN TRY
        BEGIN TRANSACTION;
		/*Creaci�n de variables auxiliares para id_socio e id_emisor*/
		DECLARE @id_socio INT;
		DECLARE @id_emisor INT;
		DECLARE @monto_total DECIMAL(10, 2) = 0;
		DECLARE @id_factura INT;
		DECLARE @saldo DECIMAL(10, 2);
		
		/*Se obtiene el id_socio asociado a su correspondiente DNI*/
		SELECT @id_socio = id_socio 
		FROM administracion.Socio s
		INNER JOIN administracion.Persona p ON s.id_persona = p.id_persona
		WHERE p.dni = @dni_socio;

		/*Si no existe el socio o no es responsable, no se realiza la transacci�n*/
		IF @id_socio IS NULL
		BEGIN
			RAISERROR('No se encontr� socio responsable con ese DNI.', 16, 1);
			ROLLBACK TRANSACTION;
			RETURN;
		END

		IF EXISTS (
		SELECT TOP 1 id_factura
		FROM facturacion.Factura
		WHERE id_socio = @id_socio
			AND MONTH(fecha_emision) = MONTH(GETDATE())
			AND YEAR(fecha_emision) = YEAR(GETDATE())
			AND anulada = 0
		)
		BEGIN
			RAISERROR('Ya fue facturada la actividad de este grupo familiar en este mes.', 16, 1);
			ROLLBACK TRANSACTION;
			RETURN;
		END

		/*Se obtiene el id_emisor asociado a su correspondiente CUIL*/
		SELECT @id_emisor = id_emisor
		FROM facturacion.EmisorFactura
		WHERE cuil = @cuil_emisor;
		
		/*Si no existe el emisor, no se realiza la transacci�n*/
		IF @id_emisor IS NULL
		BEGIN
			RAISERROR('No se encontr� emisor con ese CUIL.', 16, 1);
			ROLLBACK TRANSACTION;
			RETURN;
		END

		/*Obtener monto total a facturar*/
		SELECT @monto_total += costo
		FROM actividades.ActividadExtra AE
		INNER JOIN actividades.PresentismoActividadExtra PAE ON PAE.id_extra = AE.id_extra
		WHERE PAE.id_socio = @id_socio;
	
		IF @id_socio IN (SELECT id_socio_rp FROM administracion.GrupoFamiliar)
			BEGIN
				SELECT @monto_total += AE.costo
				FROM actividades.ActividadExtra AE
				INNER JOIN actividades.PresentismoActividadExtra PAE ON PAE.id_extra = AE.id_extra
				INNER JOIN administracion.GrupoFamiliar G ON G.id_socio = PAE.id_socio
				WHERE G.id_socio_rp = @id_socio;
			END

		/*Generar factura per s�*/
		INSERT INTO facturacion.Factura
		(id_emisor, id_socio, leyenda, monto_total, saldo_anterior, fecha_emision, fecha_vencimiento1, fecha_vencimiento2, estado, anulada)
		VALUES
		(
			@id_emisor, 
			@id_socio, 
			'Consumidor final', 
			@monto_total, 
			(SELECT ISNULL(SUM(saldo), 0)FROM administracion.Socio WHERE id_socio = @id_socio),
			GETDATE(), 
			GETDATE() + 5, 
			GETDATE() + 10, 
			'No pagada', 
			0);

		SET @id_factura = (SELECT TOP 1 id_factura FROM facturacion.Factura ORDER BY fecha_emision DESC)

		-- ACTIVIDADES EXTRA
		INSERT INTO facturacion.DetalleFactura
			(id_factura, id_extra, tipo_item, descripcion, monto, cantidad)
		SELECT
			@id_factura,
			AE.id_extra,
			'Actividad extra',
			AE.nombre,
			AE.costo,
			COUNT(PAE.id_extra) OVER(PARTITION BY PAE.id_socio) AS cantidad
		FROM actividades.ActividadExtra AE
		INNER JOIN actividades.PresentismoActividadExtra PAE ON PAE.id_extra = AE.id_extra
		WHERE PAE.id_socio = @id_socio;

		IF @id_socio IN (SELECT id_socio_rp FROM administracion.GrupoFamiliar)
		BEGIN
			-- ACTIVIDADES EXTRA DE FAMILIARES
			INSERT INTO facturacion.DetalleFactura
				(id_factura, id_extra, tipo_item, descripcion, monto, cantidad)
			SELECT
				@id_factura,
				AE.id_extra,
				'Actividad extra',
				AE.nombre,
				AE.costo,
				COUNT(PAE.id_extra) OVER(PARTITION BY PAE.id_socio) AS cantidad
			FROM actividades.ActividadExtra AE
			INNER JOIN actividades.PresentismoActividadExtra PAE ON PAE.id_extra = AE.id_extra
			INNER JOIN administracion.GrupoFamiliar G ON G.id_socio = PAE.id_socio
			WHERE G.id_socio_rp = @id_socio;
		END
		/*Confirmar transacci�n*/
        COMMIT TRANSACTION;

	END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

/*____________________________________________________________________
  ______________________ GenerarFacturaInvitado ______________________
  ____________________________________________________________________*/

IF OBJECT_ID('facturacion.GenerarFacturaInvitado', 'P') IS NOT NULL
    DROP PROCEDURE facturacion.GenerarFacturaInvitado;
GO

CREATE PROCEDURE facturacion.GenerarFacturaInvitado
(
    @dni_invitado CHAR(10),
    @cuil_emisor VARCHAR(20),
    @descripcion VARCHAR(255)
)
AS
BEGIN
    SET NOCOUNT ON;
	/*Se realiza mediante una transacci�n a fin de garantizar ACID*/
    BEGIN TRY
        BEGIN TRANSACTION;
		/*Creaci�n de variables auxiliares para id_invitado e id_emisor*/
        DECLARE @id_invitado INT;
        DECLARE @id_emisor INT;
		DECLARE @id_factura INT;

        /*Se obtiene el id_invitado asociado a su correspondiente DNI*/
        SELECT @id_invitado = id_invitado
        FROM administracion.Invitado
        WHERE dni = @dni_invitado;

		/*Si no existe el invitado, no se realiza la transacci�n.*/
        IF @id_invitado IS NULL
        BEGIN
            RAISERROR('No se encontr� invitado con ese DNI.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

		/*Verificar si ya existe una factura emitida hoy para este invitado con esa actividad*/
		IF EXISTS (SELECT TOP 1  id_factura = @id_factura
					FROM facturacion.Factura F
					INNER JOIN facturacion.DetalleFactura D ON F.id_factura = D.id_factura
					WHERE F.id_socio IS NULL
					AND F.fecha_emision = GETDATE()
					AND D.descripcion = @descripcion
					AND F.anulada = 0)
		BEGIN
			RAISERROR('Ya se gener� una factura hoy para este invitado con esa actividad.', 16, 1);
			ROLLBACK TRANSACTION;
			RETURN;
		END

        /*Se obtiene el id_emisor asociado a su correspondiente CUIL*/
        SELECT @id_emisor = id_emisor
        FROM facturacion.EmisorFactura
        WHERE cuil = @cuil_emisor;

		/*Si no existe el emisor, no se realiza la transacci�n*/
        IF @id_emisor IS NULL
        BEGIN
            RAISERROR('No se encontr� emisor con ese CUIL.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        SET @id_factura = (SELECT TOP 1 id_factura FROM facturacion.Factura WHERE fecha_emision <= GETDATE() ORDER BY fecha_emision DESC);

         /*Generar detalle de factura*/
        INSERT INTO facturacion.DetalleFactura
        (id_factura, tipo_item, descripcion, monto, cantidad)
        VALUES(
			@id_factura, 
			'Actividad extra', 
			(SELECT TOP 1 nombre FROM actividades.ActividadExtra WHERE nombre = @descripcion AND vigencia < GETDATE() ORDER BY vigencia DESC), 
			(SELECT TOP 1 costo FROM actividades.ActividadExtra WHERE nombre = @descripcion AND vigencia < GETDATE() ORDER BY vigencia DESC),
			1);

		INSERT INTO facturacion.Factura
			(id_emisor, id_socio, leyenda, monto_total, saldo_anterior, fecha_emision, fecha_vencimiento1, fecha_vencimiento2, estado, anulada)
			VALUES(
				@id_emisor, 
				NULL, 
				'Consumidor final', 
				(SELECT TOP 1 costo FROM actividades.ActividadExtra WHERE nombre = @descripcion  AND vigencia < GETDATE() ORDER BY vigencia DESC),
				0,
				GETDATE(), 
				GETDATE(), 
				GETDATE(), 
				'Sin pago', 
				0
			);

        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO