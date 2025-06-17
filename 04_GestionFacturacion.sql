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

            -- Eliminar presentismo
            DELETE pc
            FROM actividades.presentismoClase AS pc
            INNER JOIN actividades.Clase AS c ON pc.id_clase = c.id_clase
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
  _______________________ GestionarClase ________________________
  ____________________________________________________________________*/

IF OBJECT_ID('actividades.GestionarClase', 'P') IS NOT NULL
    DROP PROCEDURE actividades.GestionarClase;
GO

CREATE PROCEDURE actividades.GestionarClase
    @nombre_actividad  VARCHAR(100),
    @dni_profesor      VARCHAR(10),
    @horario           VARCHAR(20),
    @nombre_categoria  VARCHAR(50),
    @operacion         CHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    IF @operacion NOT IN ('Insertar','Modificar','Eliminar')
    BEGIN
        RAISERROR('Operación inválida. Usar Insertar, Modificar o Eliminar.', 16, 1);
        RETURN;
    END

    DECLARE @actividad_id INT;
    DECLARE @profesor_id  INT;
    DECLARE @id_clase     INT;
    DECLARE @id_categoria INT;

    /* Obtener IDs */
    SET @actividad_id = (SELECT id_actividad FROM actividades.Actividad WHERE nombre = @nombre_actividad);
    SET @profesor_id = (
        SELECT Pr.id_profesor
        FROM administracion.Profesor Pr
        JOIN administracion.Persona Pe ON Pr.id_persona = Pe.id_persona
        WHERE Pe.dni = @dni_profesor
    );
    SET @id_categoria = (SELECT id_categoria FROM administracion.CategoriaSocio WHERE nombre = @nombre_categoria);

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
    IF @id_categoria IS NULL
    BEGIN
        RAISERROR('No existe la categoría de socio "%s".', 16, 1, @nombre_categoria);
        RETURN;
    END

    IF @operacion = 'Insertar'
    BEGIN
        INSERT INTO actividades.Clase (id_actividad, id_profesor, id_categoria, horario)
        VALUES (@actividad_id, @profesor_id, @id_categoria, @horario);
        RETURN;
    END

    IF @operacion = 'Modificar'
    BEGIN
        SET @id_clase = (
            SELECT C.id_clase
            FROM actividades.Clase C
            WHERE C.id_actividad = @actividad_id
              AND C.id_profesor = @profesor_id
              AND C.horario = @horario
        );
        IF @id_clase IS NULL
        BEGIN
            RAISERROR('No se encontró la clase para modificar.', 16, 1);
            RETURN;
        END

        UPDATE actividades.Clase
        SET id_actividad = @actividad_id,
            id_profesor  = @profesor_id,
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
            WHERE id_actividad = @actividad_id
              AND id_profesor = @profesor_id
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
  _______________________ GestionarInscripcion _______________________
  ____________________________________________________________________*/
IF OBJECT_ID('actividades.GestionarInscripcion', 'P') IS NOT NULL
    DROP PROCEDURE actividades.GestionarInscripcion;
GO

CREATE PROCEDURE actividades.GestionarInscripcion
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
        SELECT TOP 1 S.id_socio
        FROM administracion.Socio S
        JOIN administracion.Persona P ON S.id_persona = P.id_persona
        WHERE P.dni = @dni_socio AND S.activo = 1
    );

    -- Buscar ID de clase correspondiente
    DECLARE @id_clase INT = (
        SELECT TOP 1 C.id_clase
        FROM actividades.Clase C
        JOIN actividades.Actividad A ON A.id_actividad = C.id_actividad
        JOIN administracion.CategoriaSocio Cat ON Cat.id_categoria = C.id_categoria
        WHERE A.nombre = @nombre_actividad
          AND C.horario = @horario
          AND Cat.nombre = @nombre_categoria
    );

    -- Buscar inscripción existente
    DECLARE @id_inscripto INT = (
        SELECT TOP 1 IC.id_inscripto
        FROM actividades.InscriptoClase IC
        WHERE IC.id_socio = @id_socio AND IC.id_clase = @id_clase
    );

    -- === Eliminar ===
    IF @operacion = 'Eliminar'
    BEGIN
        IF @id_inscripto IS NULL
        BEGIN
            RAISERROR('No existe la inscripción para eliminar.', 16, 1);
            RETURN;
        END

        DELETE FROM actividades.InscriptoClase WHERE id_inscripto = @id_inscripto;
        RETURN;
    END

    -- === Modificar ===
    IF @operacion = 'Modificar'
    BEGIN
        IF @id_inscripto IS NULL
        BEGIN
            RAISERROR('No existe la inscripción para modificar.', 16, 1);
            RETURN;
        END

        UPDATE actividades.InscriptoClase
        SET fecha_inscripcion = COALESCE(@fecha_inscripcion, fecha_inscripcion)
        WHERE id_inscripto = @id_inscripto;
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
    @nombre_categoria VARCHAR(50),
    @fecha DATE,
    @condicion CHAR(1) = NULL,
    @operacion CHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @id_clase INT;
	DECLARE @id_socio INT;
	DECLARE @id_presentismo INT;

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
        JOIN administracion.CategoriaSocio Cat ON Cat.id_categoria = C.id_categoria
        WHERE A.nombre = @nombre_actividad
          AND C.horario = @horario
          AND Cat.nombre = @nombre_categoria
    );

    -- Obtener ID del socio
    SET @id_socio = (
        SELECT S.id_socio
        FROM administracion.Socio S
        JOIN administracion.Persona P ON S.id_persona = P.id_persona
        WHERE P.dni = @dni_socio
    );

    -- Buscar presentismo existente
    SET @id_presentismo = (
        SELECT TOP 1 id_presentismo
        FROM actividades.presentismoClase
        WHERE id_clase = @id_clase AND id_socio = @id_socio AND fecha = COALESCE(@fecha, CONVERT(date, GETDATE()))
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
        SET id_clase = COALESCE(@id_clase, id_clase),
            id_socio = COALESCE(@id_socio, id_socio),
            fecha = COALESCE(@fecha, fecha),
            condicion = COALESCE(@condicion, condicion)
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

		IF @id_socio IN (SELECT id_socio FROM administracion.Socio WHERE activo = 0)
        BEGIN
            RAISERROR('El socio especificado se encuentra inactivo.', 16, 1);
            RETURN;
        END

        IF @fecha IS NULL
            SET @fecha = GETDATE();

        IF @condicion IS NULL
            SET @condicion = 'P';

        -- Validación: evitar duplicados exactos
        IF EXISTS (
            SELECT 1
            FROM actividades.presentismoClase
            WHERE id_clase = @id_clase AND id_socio = @id_socio AND fecha = @fecha
        )
        BEGIN
            RAISERROR('Ya existe un presentismo registrado para esa clase, socio y fecha.', 16, 1);
            RETURN;
        END

        INSERT INTO actividades.presentismoClase (id_clase, id_socio, fecha, condicion)
        VALUES (@id_clase, @id_socio, @fecha, @condicion);
        RETURN;
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
	@categoria	 VARCHAR(50),
    @operacion   CHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    -- 1) Verificar operación válida
    IF @operacion NOT IN ('Insertar','Modificar','Eliminar')
    BEGIN
        RAISERROR('Operación inválida. Usar Insertar, Modificar o Eliminar.',16,1);
        RETURN;
    END

    -- 2) Contar y preparar variable única para id_extra
    DECLARE 
        @count_extra INT,
        @id_extra    INT;

    SELECT @count_extra = COUNT(*)
    FROM actividades.ActividadExtra
    WHERE nombre      = @nombre
      AND periodo     = @periodo
	  AND categoria	  = @categoria
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
            RAISERROR('Hay más de una fila que coincide; operación ambigua.',16,1);
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
            RAISERROR('Hay más de una fila que coincide; operación ambigua.',16,1);
            RETURN;
        END

        SELECT @id_extra = id_extra
        FROM actividades.ActividadExtra
        WHERE nombre=@nombre AND periodo=@periodo AND es_invitado = @es_invitado;

        UPDATE actividades.ActividadExtra
        SET 
            nombre      = COALESCE(@nombre,      nombre),
            costo       = COALESCE(@costo,       costo),
            periodo     = COALESCE(@periodo,     periodo),
			categoria	= COALESCE(@categoria,	 categoria),
            es_invitado = COALESCE(@es_invitado, es_invitado),
            vigencia    = COALESCE(@vigencia,    vigencia)
        WHERE id_extra = @id_extra;
        RETURN;
    END

    -- 5) Insertar + validación de duplicados
    ELSE /* Insertar */
    BEGIN
        IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
        BEGIN
            RAISERROR('El nombre de la actividad extra es obligatorio.',16,1);
            RETURN;
        END
        IF @costo IS NULL OR @costo < 0
        BEGIN
            RAISERROR('El costo debe ser un número positivo.',16,1);
            RETURN;
        END
        IF @count_extra > 0
        BEGIN
            RAISERROR('Ya existe una actividad extra con esos parámetros.',16,1);
            RETURN;
        END

        INSERT INTO actividades.ActividadExtra
            (nombre, costo, periodo, categoria, es_invitado, vigencia)
        VALUES
            (@nombre, @costo, @periodo, @categoria, @es_invitado, @vigencia);
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
    @dni VARCHAR(10) = NULL,
    @fecha DATE = NULL,
    @condicion CHAR(1) = NULL,
    @operacion CHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @id_presentismo INT;
    DECLARE @categoria VARCHAR(50);
    DECLARE @id_socio INT;
    DECLARE @id_invitado INT;
    DECLARE @id_extra INT;

    -- Validar operación
    IF @operacion NOT IN ('Insertar', 'Modificar', 'Eliminar')
    BEGIN
        RAISERROR('Operación inválida. Usar Insertar, Modificar o Eliminar.', 16, 1);
        RETURN;
    END

    SET @es_invitado = UPPER(@es_invitado);
    IF @es_invitado NOT IN ('S', 'N')
    BEGIN
        RAISERROR('El campo es_invitado solo puede ser S o N.', 16, 1);
        RETURN;
    END

    IF @fecha IS NULL
        SET @fecha = CAST(GETDATE() AS DATE);
    IF @condicion IS NULL
        SET @condicion = 'P';

    -- Obtener datos del participante
    IF @es_invitado = 'N'
    BEGIN
        -- SOCIO
        IF @dni IS NULL OR LTRIM(RTRIM(@dni)) = ''
        BEGIN
            RAISERROR('El DNI del socio es obligatorio.', 16, 1);
            RETURN;
        END

        SELECT 
            @id_socio = S.id_socio,
            @categoria = C.nombre
        FROM administracion.Socio S
        INNER JOIN administracion.Persona P ON P.id_persona = S.id_persona
        INNER JOIN administracion.CategoriaSocio C ON C.id_categoria = S.id_categoria
        WHERE P.dni = @dni AND S.activo = 1;

        IF @id_socio IS NULL OR @categoria IS NULL
        BEGIN
            RAISERROR('No se encontró un socio activo con ese DNI.', 16, 1);
            RETURN;
        END
    END
    ELSE
    BEGIN
        -- INVITADO
        IF @dni IS NOT NULL
        BEGIN
            SELECT 
                @id_invitado = id_invitado,
                @categoria = categoria
            FROM administracion.Invitado
            WHERE dni = @dni;

            IF @id_invitado IS NULL
            BEGIN
                RAISERROR('No existe un invitado con ese DNI.', 16, 1);
                RETURN;
            END
        END
    END

    -- Obtener ID de la actividad extra
    SELECT TOP 1 @id_extra = id_extra
    FROM actividades.ActividadExtra
    WHERE nombre = @nombre_actividad_extra
        AND periodo = @periodo
        AND categoria = @categoria
        AND es_invitado = @es_invitado
    ORDER BY vigencia DESC;

    IF @id_extra IS NULL
    BEGIN
        RAISERROR('No existe una actividad extra para los datos proporcionados.', 16, 1);
        RETURN;
    END

    -- Verificar existencia del presentismo
    SELECT TOP 1 @id_presentismo = P.id_presentismo_extra
    FROM actividades.presentismoActividadExtra P
    WHERE P.id_extra = @id_extra
        AND P.fecha = @fecha
        AND (
            (@es_invitado = 'N' AND P.id_socio = @id_socio)
            OR (@es_invitado = 'S' AND P.id_invitado = @id_invitado)
        );

    -- OPERACIÓN: INSERTAR
    IF @operacion = 'Insertar'
    BEGIN
        IF @id_presentismo IS NOT NULL
        BEGIN
            RAISERROR('Ya se registró el presentismo para ese participante en esa fecha.', 16, 1);
            RETURN;
        END

        INSERT INTO actividades.presentismoActividadExtra (id_extra, id_socio, id_invitado, fecha, condicion)
        VALUES (@id_extra, @id_socio, @id_invitado, @fecha, @condicion);
        RETURN;
    END

    -- OPERACIÓN: ELIMINAR
    IF @operacion = 'Eliminar'
    BEGIN
        IF @id_presentismo IS NULL
        BEGIN
            RAISERROR('No se encontró el presentismo para eliminar.', 16, 1);
            RETURN;
        END

        DELETE FROM actividades.presentismoActividadExtra
        WHERE id_presentismo_extra = @id_presentismo;
        RETURN;
    END

    -- OPERACIÓN: MODIFICAR
    IF @operacion = 'Modificar'
    BEGIN
        IF @id_presentismo IS NULL
        BEGIN
            RAISERROR('No se encontró el presentismo para modificar.', 16, 1);
            RETURN;
        END

        UPDATE actividades.presentismoActividadExtra
        SET
            id_extra = @id_extra,
            id_socio = @id_socio,
            id_invitado = @id_invitado,
            fecha = @fecha,
            condicion = @condicion
        WHERE id_presentismo_extra = @id_presentismo;
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

/*____________________________________________________________________
  ______________________ GenerarFacturaSocioMensual ___________________
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
	/*Se realiza mediante una transacción a fin de garantizar ACID*/
    BEGIN TRY
        BEGIN TRANSACTION;
		/*Creación de variables auxiliares para id_socio e id_emisor*/
        DECLARE @id_socio INT;
        DECLARE @id_emisor INT;
		DECLARE @monto_total DECIMAL(10, 2) = 0;
		DECLARE @descuentoMembresias DECIMAL(10,2) = 0;
		DECLARE @descuentoActividades DECIMAL(10,2) = 0;
		DECLARE @id_factura INT;

        /*Se obtiene el id_socio asociado a su correspondiente DNI*/
        SELECT @id_socio = id_socio 
        FROM administracion.Socio s
        INNER JOIN administracion.Persona p ON s.id_persona = p.id_persona
        WHERE p.dni = @dni_socio;

		/*Si no existe el socio, no se realiza la transacción*/
        IF @id_socio IS NULL OR @id_socio IN (SELECT id_socio FROM administracion.GrupoFamiliar)
        BEGIN
            RAISERROR('No se encontró socio responsable con ese DNI.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

		/*Si el socio no está activo, no se genera la factura*/
        IF @id_socio IN (SELECT id_socio FROM administracion.Socio WHERE activo = 0)
        BEGIN
            RAISERROR('El socio que se está intentando facturar se encuentra inactivo.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
		-- Si la actividad/membresía ya fue facturada, no se genera un duplicado
		IF EXISTS (
		SELECT TOP 1 id_factura
		FROM facturacion.Factura
		WHERE id_socio = @id_socio
		  AND MONTH(fecha_emision) = MONTH(CONVERT(DATE, '2025-02-27')) --PARA TESTING 
		  AND YEAR(fecha_emision) = YEAR(CONVERT(DATE, '2025-02-27')) --PARA TESTING 
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
		
		/*Si no existe el emisor, no se realiza la transacción*/
        IF @id_emisor IS NULL
        BEGIN
            RAISERROR('No se encontró emisor con ese CUIL.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;

		/*Obtener monto total a facturar*/
		WITH subtotalMembresias AS (
			SELECT CS.costo_membresia * COUNT(*) AS subtotal
			FROM administracion.Socio S
			INNER JOIN administracion.CategoriaSocio CS ON S.id_categoria = CS.id_categoria
			WHERE S.id_socio = @id_socio
			   OR S.id_socio IN (SELECT id_socio FROM administracion.GrupoFamiliar WHERE id_socio_rp = @id_socio)
			GROUP BY CS.costo_membresia
		)
		SELECT	@descuentoMembresias = ISNULL(SUM(subtotal) * 0.15, 0),
				@monto_total += ISNULL(SUM(subtotal), 0)
		FROM subtotalMembresias;

		-- Calcular descuento si corresponde (15%)
		IF EXISTS (	SELECT 1
					FROM administracion.GrupoFamiliar G
					INNER JOIN administracion.Socio S ON S.id_socio = G.id_socio
					WHERE G.id_socio_rp = @id_socio AND S.activo = 1)
		BEGIN
			SET @monto_total -= @descuentoMembresias;
		END;

		WITH subtotalActividades AS (
		SELECT A.costo * COUNT(*) AS subtotal
		FROM actividades.Actividad A
		INNER JOIN actividades.Clase C ON A.id_actividad = C.id_actividad
		INNER JOIN actividades.InscriptoClase I ON I.id_clase = C.id_clase
		INNER JOIN administracion.Socio S ON I.id_socio = S.id_socio
		WHERE S.id_socio = @id_socio 
		   OR S.id_socio IN (SELECT id_socio FROM administracion.GrupoFamiliar WHERE id_socio_rp = @id_socio)
		GROUP BY A.id_actividad, A.costo
		)

		SELECT  @descuentoActividades = ISNULL(SUM(subtotal) * 0.10, 0),
				@monto_total += ISNULL(SUM(subtotal), 0)
		FROM subtotalActividades;

		-- Aplicar descuento 10% si hay más de una actividad
		IF (SELECT COUNT(DISTINCT A.id_actividad)
			FROM actividades.Actividad A
			INNER JOIN actividades.Clase C ON A.id_actividad = C.id_actividad
			INNER JOIN actividades.InscriptoClase I ON I.id_clase = C.id_clase
			INNER JOIN administracion.Socio S ON I.id_socio = S.id_socio
			WHERE S.id_socio = @id_socio 
			OR S.id_socio IN (SELECT id_socio FROM administracion.GrupoFamiliar WHERE id_socio_rp = @id_socio)) > 1
		BEGIN
			SET @monto_total -= @descuentoActividades;
		END

		SELECT @monto_total += ISNULL(SUM(monto), 0)
		FROM cobranzas.Mora
		WHERE id_socio = @id_socio

		/*Generar factura per sé*/
        INSERT INTO facturacion.Factura
        (id_emisor, id_socio, leyenda, monto_total, saldo_anterior, fecha_emision, fecha_vencimiento1, fecha_vencimiento2, estado, anulada)
		VALUES
        (
			@id_emisor, 
			@id_socio, 
			'Consumidor final', 
			@monto_total, 
			(SELECT ISNULL(SUM(saldo), 0)FROM administracion.Socio WHERE id_socio = @id_socio),
			GETDATE() - 6, 
			DATEADD(DAY, -1, GETDATE()), 
			DATEADD(DAY, 4, GETDATE()), 
			'No pagada', 
			0);

		SET @id_factura = SCOPE_IDENTITY();

		/*Obtener todas las actividades pendientes de pago asociadas al socio*/

        /*Generar detalles de factura*/

		-- MEMBRESÍA DEL SOCIO Y FAMILIARES
        INSERT INTO facturacion.DetalleFactura
			(id_factura, id_categoria, tipo_item, descripcion, monto, cantidad)
		SELECT
			@id_factura,
			CS.id_categoria,
			'Membresia',
			CS.nombre,
			CS.costo_membresia,
			COUNT(S.id_categoria) AS cantidad
		FROM administracion.Socio S
		INNER JOIN administracion.CategoriaSocio CS ON S.id_categoria = CS.id_categoria
		WHERE S.id_socio = @id_socio OR S.id_socio IN (SELECT id_socio FROM administracion.GrupoFamiliar WHERE id_socio_rp = @id_socio)
		GROUP BY CS.id_categoria, CS.nombre, CS.costo_membresia;

		-- ACTIVIDADES DEL SOCIO Y FAMILIARES
		INSERT INTO facturacion.DetalleFactura
			(id_factura, id_actividad, tipo_item, descripcion, monto, cantidad)
		SELECT
			@id_factura,
			C.id_actividad,
			'Actividad',
			A.nombre,
			A.costo,
			COUNT(A.id_actividad) AS cantidad
		FROM administracion.Socio S
		INNER JOIN actividades.InscriptoClase I ON I.id_socio = S.id_socio
		INNER JOIN actividades.Clase C ON I.id_clase = C.id_clase
		INNER JOIN actividades.Actividad A ON C.id_actividad = A.id_actividad
		WHERE S.id_socio = @id_socio OR S.id_socio IN (SELECT id_socio FROM administracion.GrupoFamiliar WHERE id_socio_rp = @id_socio)
		GROUP BY C.id_actividad, A.nombre, A.costo;

		-- DESCUENTO POR GRUPO FAMILIAR (15%) > 1 MIEMBRO ACTIVO
		IF EXISTS (
			SELECT S.id_socio
			FROM administracion.GrupoFamiliar G
			INNER JOIN administracion.Socio S ON S.id_socio = G.id_socio
			WHERE id_socio_rp = @id_socio AND S.activo = 1
		)
		BEGIN
			INSERT INTO facturacion.DetalleFactura (id_factura, tipo_item, descripcion, monto, cantidad)
			SELECT DISTINCT
				@id_factura,
				'Descuento',
				'Descuento por grupo familiar (15%)',
				@descuentoMembresias,
				1
			FROM administracion.GrupoFamiliar G
			INNER JOIN administracion.Socio S ON S.id_socio = G.id_socio
			WHERE id_socio_rp = @id_socio AND S.activo = 1
		END

		-- DESCUENTO POR MÚLTIPLES ACTIVIDADES DEPORTIVAS (10%)
		IF (
			SELECT COUNT(*)
			FROM facturacion.DetalleFactura D
			INNER JOIN facturacion.Factura F ON F.id_factura = D.id_factura
			INNER JOIN administracion.Socio S ON S.id_socio = F.id_socio
			WHERE F.id_factura = @id_factura
			AND D.tipo_item = 'Actividad'
			AND (S.id_socio = @id_socio OR S.id_socio IN (SELECT id_socio FROM administracion.GrupoFamiliar WHERE id_socio_rp = @id_socio)
		)) > 1
		BEGIN
			INSERT INTO facturacion.DetalleFactura (id_factura, tipo_item, descripcion, monto, cantidad)
			SELECT DISTINCT 
				@id_factura,
				'Descuento',
				'Descuento por múltiples actividades deportivas (10%)',
				@descuentoActividades,
				1
				FROM facturacion.DetalleFactura D
				INNER JOIN facturacion.Factura F ON F.id_factura = D.id_factura
				INNER JOIN administracion.Socio S ON S.id_socio = F.id_socio
				WHERE F.id_factura = @id_factura
				AND D.tipo_item = 'Actividad'
				AND (S.id_socio = @id_socio OR S.id_socio IN (SELECT id_socio FROM administracion.GrupoFamiliar WHERE id_socio_rp = @id_socio))
		END;

		-- MORA (asumiendo que el id_socio es el del responsable)
		INSERT INTO facturacion.DetalleFactura
				(id_factura, id_extra, tipo_item, descripcion, monto, cantidad)
		SELECT
			@id_factura,
			NULL,
			'Interés por Mora',
			'Mora a fecha actual.',
			monto,
			1
		FROM cobranzas.Mora
		WHERE id_socio = @id_socio AND facturada = 0;

		/*Se actualiza la mora a facturada*/
		UPDATE cobranzas.Mora
		SET facturada = 1
		WHERE id_socio = @id_socio

		/*Confirmar transacción*/
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
	@cuil_emisor VARCHAR(20),
    @descripcion VARCHAR(255),
	@fecha_referencia DATE
)
AS
BEGIN
	SET NOCOUNT ON;
	/*Se realiza mediante una transacción a fin de garantizar ACID*/
    BEGIN TRY
        BEGIN TRANSACTION;
		/*Creación de variables auxiliares para id_socio e id_emisor*/
		DECLARE @id_socio INT;
		DECLARE @id_socio_origen INT;
		DECLARE @id_emisor INT;
		DECLARE @monto_total DECIMAL(10, 2) = 0;
		DECLARE @id_factura INT;
		DECLARE @saldo DECIMAL(10, 2);
		DECLARE @periodo VARCHAR(20);
		DECLARE @fecha_vencimiento1 DATE = @fecha_referencia;
		DECLARE @fecha_vencimiento2 DATE = @fecha_referencia;
		
		/*Se obtiene el id_socio asociado a su correspondiente DNI*/
		SELECT @id_socio_origen = S.id_socio
		FROM administracion.Socio S
		INNER JOIN administracion.Persona P ON S.id_persona = P.id_persona
		WHERE P.dni = @dni_socio;
		
		SELECT @id_socio = G.id_socio_rp 
		FROM administracion.GrupoFamiliar G
		INNER JOIN administracion.Socio S ON S.id_socio = G.id_socio
		INNER JOIN administracion.Persona P ON S.id_persona = P.id_persona
		WHERE P.dni = @dni_socio;

		/*Si no existe el socio, no se realiza la transacción*/
		IF @id_socio IS NULL
		BEGIN
			SET @id_socio = @id_socio_origen

			IF @id_socio IS NULL
			BEGIN
				RAISERROR('No se encontró socio responsable con ese DNI.', 16, 1);
				ROLLBACK TRANSACTION;
				RETURN;
			END
		END;
		-- Si la actividad/membresía ya fue facturada, no se genera un duplicado
		IF EXISTS (
		SELECT TOP 1 F.id_factura
		FROM facturacion.Factura F
		INNER JOIN facturacion.DetalleFactura D ON D.id_factura = F.id_factura
		WHERE F.id_socio = @id_socio
			AND MONTH(fecha_emision) = MONTH(@fecha_referencia)
			AND YEAR(fecha_emision) = YEAR(@fecha_referencia)
			AND anulada = 0
			AND D.descripcion = @descripcion
		)
		BEGIN
			RAISERROR('Ya fue facturada la actividad.', 16, 1);
			ROLLBACK TRANSACTION;
			RETURN;
		END
		-- Si el socio no asisitó a la actividad, no se genera la factura
		ELSE IF NOT EXISTS (SELECT TOP 1 PAE.id_socio
							FROM actividades.presentismoActividadExtra PAE
							INNER JOIN actividades.ActividadExtra AE ON AE.id_extra = PAE.id_extra
							WHERE (PAE.id_socio = @id_socio_origen OR PAE.id_socio IN (SELECT id_socio FROM administracion.GrupoFamiliar WHERE id_socio_rp = @id_socio))
							AND AE.nombre = @descripcion
							AND MONTH(PAE.fecha) = MONTH(@fecha_referencia) 
							AND YEAR(PAE.fecha) = YEAR(@fecha_referencia)
							AND AE.categoria = (SELECT TOP 1 categoria FROM administracion.Socio WHERE id_socio = @id_socio_origen)
							AND AE.nombre = @descripcion
							AND AE.es_invitado = 'N')
		BEGIN
			RAISERROR('El socio no ha asistido a la actividad descripta.', 16, 1);
			ROLLBACK TRANSACTION;
			RETURN;
		END;

		/*Se obtiene el id_emisor asociado a su correspondiente CUIL*/
		SELECT @id_emisor = id_emisor
		FROM facturacion.EmisorFactura
		WHERE cuil = @cuil_emisor;
		
		/*Si no existe el emisor, no se realiza la transacción*/
		IF @id_emisor IS NULL
		BEGIN
			RAISERROR('No se encontró emisor con ese CUIL.', 16, 1);
			ROLLBACK TRANSACTION;
			RETURN;
		END

		/*Se calcula el vencimiento de las facturas en base al periodo escogido*/
		SET @periodo = (SELECT TOP 1 AE.periodo 
						FROM actividades.ActividadExtra AE
						INNER JOIN actividades.presentismoActividadExtra PAE ON AE.id_extra = PAE.id_extra
						WHERE (PAE.id_socio = @id_socio_origen OR PAE.id_socio IN (SELECT id_socio FROM administracion.GrupoFamiliar WHERE id_socio_rp = @id_socio))
						AND MONTH(PAE.fecha) = MONTH(@fecha_referencia)
						AND YEAR(PAE.fecha) = YEAR(@fecha_referencia)
						AND AE.categoria = (SELECT TOP 1 categoria FROM administracion.Socio WHERE id_socio = @id_socio_origen)
						AND AE.nombre = @descripcion
						AND AE.es_invitado = 'N');
		
		-- En caso de ser diaria, se propone el vencimiento al mismo dia
		IF @periodo NOT LIKE 'Dia'
		BEGIN
			SET @fecha_vencimiento1 = DATEADD(DAY, 5, @fecha_vencimiento1);
			SET @fecha_vencimiento2 = DATEADD(DAY, 5, @fecha_vencimiento1);
		END

		/*Obtener monto total a facturar*/
		SELECT TOP 1 @monto_total = AE.costo
		FROM actividades.PresentismoActividadExtra PAE
		INNER JOIN actividades.ActividadExtra AE ON PAE.id_extra = AE.id_extra
		WHERE (PAE.id_socio = @id_socio_origen OR PAE.id_socio IN (SELECT id_socio FROM administracion.GrupoFamiliar WHERE id_socio_rp = @id_socio))
		AND MONTH(PAE.fecha) = MONTH(@fecha_referencia)
		AND YEAR(PAE.fecha) = YEAR(@fecha_referencia)
		AND AE.nombre = @descripcion
		AND AE.categoria = (SELECT TOP 1 categoria FROM administracion.Socio WHERE id_socio = @id_socio_origen)
		AND AE.es_invitado = 'N'
		AND AE.periodo = @periodo
		ORDER BY AE.vigencia DESC;

		/*Generar factura per sé*/
		INSERT INTO facturacion.Factura
		(id_emisor, id_socio, leyenda, monto_total, saldo_anterior, fecha_emision, fecha_vencimiento1, fecha_vencimiento2, estado, anulada)
		VALUES
		(
			@id_emisor, 
			@id_socio, 
			'Consumidor final', 
			@monto_total, 
			(SELECT ISNULL(SUM(saldo), 0)FROM administracion.Socio WHERE id_socio = @id_socio),
			@fecha_referencia,
			@fecha_vencimiento1, 
			@fecha_vencimiento2,
			'No pagada', 
			0);

		SET @id_factura = SCOPE_IDENTITY();

		-- ACTIVIDADES EXTRA
		INSERT INTO facturacion.DetalleFactura
		(id_factura, id_extra, tipo_item, descripcion, monto, cantidad)
		SELECT TOP 1
			@id_factura,
			AE.id_extra,
			LEFT('Actividad extra - Periodo ' + AE.periodo, 50),
			AE.nombre,
			AE.costo,
			1
		FROM actividades.PresentismoActividadExtra PAE
		INNER JOIN actividades.ActividadExtra AE ON PAE.id_extra = AE.id_extra
		WHERE (PAE.id_socio = @id_socio_origen OR PAE.id_socio IN (SELECT id_socio FROM administracion.GrupoFamiliar WHERE id_socio_rp = @id_socio))
		AND MONTH(PAE.fecha) = MONTH(@fecha_referencia) 
		AND YEAR(PAE.fecha) = YEAR(@fecha_referencia) 
		AND AE.nombre = @descripcion
		AND AE.categoria = (SELECT TOP 1 categoria FROM administracion.Socio WHERE id_socio = @id_socio_origen)
		AND AE.es_invitado = 'N'
		AND AE.periodo = @periodo
		ORDER BY AE.vigencia DESC;

		/*Confirmar transacción*/
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
    @descripcion VARCHAR(255),
	@fecha_referencia DATE
)
AS
BEGIN
    SET NOCOUNT ON;
	/*Se realiza mediante una transacción a fin de garantizar ACID*/
    BEGIN TRY
        BEGIN TRANSACTION;
		/*Creación de variables auxiliares para id_invitado e id_emisor*/
        DECLARE @id_invitado INT;
        DECLARE @id_emisor INT;
		DECLARE @id_factura INT;
		DECLARE @categoria VARCHAR(50);

        /*Se obtiene el id_invitado asociado a su correspondiente DNI*/
        SELECT @id_invitado = id_invitado
        FROM administracion.Invitado
        WHERE dni = @dni_invitado;

		/*Si no existe el invitado, no se realiza la transacción.*/
        IF @id_invitado IS NULL
        BEGIN
            RAISERROR('No se encontró invitado con ese DNI.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

		IF NOT EXISTS (SELECT PAE.id_extra
					   FROM actividades.PresentismoActividadExtra PAE
					   INNER JOIN actividades.ActividadExtra AE ON PAE.id_extra = AE.id_extra
					   WHERE PAE.id_invitado = @id_invitado 
					   AND AE.periodo LIKE 'Dia' 
					   AND AE.es_invitado = 'S' 
					   AND AE.nombre = @descripcion
					   AND MONTH(PAE.fecha) = MONTH(@fecha_referencia)
					   AND YEAR(PAE.fecha) = YEAR(@fecha_referencia)) 
		BEGIN
            RAISERROR('El invitado ingresado no asistió a la actividad descripta.', 16, 1);
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
					AND F.anulada = 0
					AND MONTH(F.fecha_emision) = MONTH(@fecha_referencia)
					AND YEAR(F.fecha_emision) = YEAR(@fecha_referencia)) 
		BEGIN
			RAISERROR('Ya se generó una factura hoy para este invitado con esa actividad.', 16, 1);
			ROLLBACK TRANSACTION;
			RETURN;
		END

        /*Se obtiene el id_emisor asociado a su correspondiente CUIL*/
        SELECT @id_emisor = id_emisor
        FROM facturacion.EmisorFactura
        WHERE cuil = @cuil_emisor;

		/*Si no existe el emisor, no se realiza la transacción*/
        IF @id_emisor IS NULL
        BEGIN
            RAISERROR('No se encontró emisor con ese CUIL.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

		INSERT INTO facturacion.Factura
			(id_emisor, id_invitado, leyenda, monto_total, saldo_anterior, fecha_emision, fecha_vencimiento1, fecha_vencimiento2, estado, anulada)
			VALUES(
				@id_emisor, 
				@id_invitado, 
				'Consumidor final', 
				(SELECT TOP 1 costo 
				 FROM actividades.ActividadExtra 
				 WHERE nombre = @descripcion 
				 AND es_invitado = 'S' 
				 AND categoria = (SELECT TOP 1 categoria FROM administracion.Invitado WHERE id_invitado = @id_invitado)
				 AND vigencia > GETDATE() 
				 ORDER BY vigencia DESC),
				0,
				@fecha_referencia, 
				@fecha_referencia, 
				@fecha_referencia, 
				'No pagada', 
				0
			);

        SET @id_factura = SCOPE_IDENTITY();

         -- ACTIVIDADES EXTRA
		INSERT INTO facturacion.DetalleFactura
			(id_factura, id_extra, tipo_item, descripcion, monto, cantidad)
		SELECT
			@id_factura,
			AE.id_extra,
			'Actividad extra - Periodo ' + AE.periodo,
			AE.nombre,
			AE.costo,
			1
		FROM actividades.PresentismoActividadExtra PAE
		INNER JOIN actividades.ActividadExtra AE ON PAE.id_extra = AE.id_extra
		WHERE PAE.id_invitado = @id_invitado 
		AND AE.periodo LIKE 'Dia' 
		AND AE.es_invitado = 'S'
		AND AE.categoria = (SELECT TOP 1 categoria FROM administracion.Invitado WHERE id_invitado = @id_invitado)
		AND AE.nombre = @descripcion
		AND MONTH(PAE.fecha) = MONTH(@fecha_referencia)
		AND YEAR(PAE.fecha) = YEAR(@fecha_referencia)

        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO


CREATE OR ALTER VIEW facturacion.vwResponsablesDeFactura AS
SELECT
    f.id_factura,
    f.id_socio                           AS socio_facturado,
    COALESCE(gf.id_socio_rp, f.id_socio) AS id_socio_responsable,
    p_res.dni                            AS dni_responsable,
    p_res.nombre                         AS nombre_responsable,
    p_res.apellido                       AS apellido_responsable,
    f.monto_total,
    f.estado,
    f.fecha_emision,
    f.fecha_vencimiento1,
    f.fecha_vencimiento2
FROM facturacion.Factura f
JOIN administracion.Socio s_f ON s_f.id_socio = f.id_socio
LEFT JOIN administracion.GrupoFamiliar gf ON gf.id_socio = f.id_socio
LEFT JOIN administracion.Socio s_res ON s_res.id_socio = COALESCE(gf.id_socio_rp, f.id_socio)
LEFT JOIN administracion.Persona p_res ON p_res.id_persona = s_res.id_persona;
GO