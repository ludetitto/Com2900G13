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
  _______________________ GestionarActividad ________________________
  ____________________________________________________________________*/

IF OBJECT_ID('actividades.GestionarActividad', 'P') IS NOT NULL
    DROP PROCEDURE actividades.GestionarActividad;
GO

CREATE PROCEDURE actividades.GestionarActividad
    @nombre VARCHAR(100),
    @costo DECIMAL(10,2),
    @horario VARCHAR(50),
    @vigencia DATE,
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
	/*CASO 1: Eliminar actividad*/
    IF @operacion = 'Eliminar'
    BEGIN
		/*Verificaçión de existencia de actividad a borrar.*/
        IF NOT EXISTS (SELECT 1 FROM actividades.Actividad WHERE nombre = @nombre)
        BEGIN
            RAISERROR('No existe la actividad para eliminar.', 16, 1);
            RETURN;
        END

        DELETE FROM actividades.Actividad WHERE nombre = @nombre;
    END
	/*CASO 2: Modificar datos de actividad. Menos el ID, cualquier otro campo*/
    ELSE IF @operacion = 'Modificar'
    BEGIN
		/*Verificaçión de existencia de actividad a modificar.*/
        IF NOT EXISTS (SELECT 1 FROM actividades.Actividad WHERE nombre = @nombre)
        BEGIN
            RAISERROR('No existe la actividad para modificar.', 16, 1);
            RETURN;
        END
		/*Se utiliza COALESCE para asegurar dato válido en caso de que algún usuario ingrese NULL en algún campo*/
        UPDATE actividades.Actividad
        SET 
			costo = COALESCE(@costo, costo),
            horario = COALESCE(@horario, horario),
            vigencia = COALESCE(@vigencia, vigencia)
        WHERE nombre = @nombre;
    END
	/*CASO 3: Insertar actividad*/
    ELSE IF @operacion = 'Insertar'
    BEGIN
		/*Verificación de datos no nulos necesarios para insertar actividad*/
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

        INSERT INTO actividades.Actividad (nombre, costo, horario, vigencia)
        VALUES (@nombre, @costo, @horario, @vigencia);
    END
END;
GO

/*____________________________________________________________________
  _________________________ GestionarClase ___________________________
  ____________________________________________________________________*/

IF OBJECT_ID('actividades.GestionarClase', 'P') IS NOT NULL
    DROP PROCEDURE actividades.GestionarClase;
GO

CREATE PROCEDURE actividades.GestionarClase
    @nombre_actividad VARCHAR(100),
    @dni_profesor VARCHAR(10),
    @horario VARCHAR(20),
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
	/*Se obtiene el id_clase en caso de eliminar o modificar una clase*/
	DECLARE @id_clase INT = (SELECT C.id_clase
							 FROM actividades.Clase C
							 INNER JOIN actividades.Actividad A ON A.id_actividad = C.id_actividad
							 WHERE A.nombre = @nombre_actividad AND C.horario = @horario)
	/*CASO 1: Eliminar clase*/
    IF @operacion = 'Eliminar'
    BEGIN
		/*Verificaçión de existencia de clase a borrar.*/
        IF @id_clase = NULL
        BEGIN
            RAISERROR('No existe la clase para eliminar.', 16, 1);
            RETURN;
        END

        DELETE FROM actividades.Clase WHERE id_clase = @id_clase;
    END
	/*CASO 2: Modificar clase*/
    ELSE IF @operacion = 'Modificar'
    BEGIN
		/*Verificaçión de existencia de clase a modificar.*/
        IF @id_clase = NULL
        BEGIN
            RAISERROR('No existe la clase para modificar.', 16, 1);
            RETURN;
        END
		/*Se utiliza COALESCE para asegurar dato válido en caso de que algún usuario ingrese NULL en algún campo*/
        UPDATE actividades.Clase
        SET id_actividad = COALESCE((SELECT id_actividad
									 FROM actividades.Actividad
									 WHERE nombre = @nombre_actividad), id_actividad),
            id_profesor = COALESCE((SELECT Pr.id_profesor
									FROM administracion.Profesor Pr
									INNER JOIN administracion.Persona Pe ON Pr.id_persona = Pe.id_persona
									WHERE Pe.dni = @dni_profesor), id_profesor),
            horario = COALESCE(@horario, horario)
        WHERE id_clase = @id_clase;
    END
	/*CASO 2: Insertar clase*/
    ELSE IF @operacion = 'Insertar'
    BEGIN
		/*Verificación de datos no nulos necesarios para insertar clase*/
        IF @nombre_actividad IS NULL
        BEGIN
            RAISERROR('El nombre de la actividad es obligatorio.', 16, 1);
            RETURN;
        END

        IF @dni_profesor IS NULL
        BEGIN
            RAISERROR('El dni del profesor es obligatorio.', 16, 1);
            RETURN;
        END

        INSERT INTO actividades.Clase (id_actividad, id_profesor, horario)
        VALUES (
			(SELECT id_actividad
			 FROM actividades.Actividad
			 WHERE nombre = @nombre_actividad),
			(SELECT Pr.id_profesor
			 FROM administracion.Profesor Pr
			 INNER JOIN administracion.Persona Pe ON Pr.id_persona = Pe.id_persona
			 WHERE Pe.dni = @dni_profesor),
			@horario);
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
	/*Verificación de operaciones válidas*/
    IF @operacion NOT IN ('Insertar', 'Modificar', 'Eliminar')
    BEGIN
        RAISERROR('Operación inválida. Usar Insertar, Modificar o Eliminar.', 16, 1);
        RETURN;
    END
	/*Se obtiene el id_inscripto si corresponde*/
    DECLARE @id_inscripto INT = (SELECT IC.id_inscripto
									FROM actividades.InscriptoClase IC
									INNER JOIN actividades.Clase C ON IC.id_clase = C.id_clase
									INNER JOIN actividades.Actividad A ON C.id_actividad = A.id_actividad
									INNER JOIN administracion.Socio S ON IC.id_socio = S.id_socio
									INNER JOIN administracion.Persona P ON S.id_persona = P.id_persona
									WHERE A.nombre = @nombre_actividad AND C.horario = @horario AND P.dni = @dni_socio)
	/*CASO 1: Eliminar inscripción*/
    IF @operacion = 'Eliminar'
    BEGIN
		/*Verificación de existencia de inscripción a eliminar*/
        IF @id_inscripto IS NULL
        BEGIN
            RAISERROR('No existe la inscripción para eliminar.', 16, 1);
            RETURN;
        END

        DELETE FROM actividades.InscriptoClase WHERE id_inscripto = @id_inscripto;
    END
	/*CASO 2: Modificar inscripción*/
    ELSE IF @operacion = 'Modificar'
    BEGIN
		/*Verificación de existencia de inscripción a modificar*/
        IF @id_inscripto IS NULL
        BEGIN
            RAISERROR('No existe la inscripción para modificar.', 16, 1);
            RETURN;
        END

        UPDATE actividades.InscriptoClase
        SET fecha_inscripcion = COALESCE(@fecha_inscripcion, fecha_inscripcion)
        WHERE id_inscripto = @id_inscripto;
    END
	/*CASO 3: Insertar inscripción*/
    ELSE IF @operacion = 'Insertar'
    BEGIN
		/*Obtención de claves necesarias*/
        DECLARE @id_socio INT = (SELECT S.id_socio
								 FROM administracion.Socio S
								 INNER JOIN administracion.Persona P ON S.id_persona = P.id_persona
								 WHERE P.dni = @dni_socio);

        DECLARE @id_clase INT = (SELECT C.id_clase
								 FROM actividades.Clase C
								 INNER JOIN actividades.Actividad A ON C.id_actividad = A.id_actividad
								 WHERE A.nombre = @nombre_actividad AND C.horario = @horario);

		/*Verificación de existencia de socio y clase*/
        IF @id_socio IS NULL
        BEGIN
            RAISERROR('El socio no existe.', 16, 1);
            RETURN;
        END

        IF @id_clase IS NULL
        BEGIN
            RAISERROR('La clase no existe.', 16, 1);
            RETURN;
        END

        IF @fecha_inscripcion IS NULL
            SET @fecha_inscripcion = GETDATE();

        INSERT INTO actividades.InscriptoClase (id_socio, id_clase, fecha_inscripcion)
        VALUES (@id_socio, @id_clase, @fecha_inscripcion);
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
	/*Verificación de operaciones válidas*/
    IF @operacion NOT IN ('Insertar', 'Modificar', 'Eliminar')
    BEGIN
        RAISERROR('Operación inválida. Usar Insertar, Modificar o Eliminar.', 16, 1);
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
		/*Verificación de existencia de presentismo a borrar.*/
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
		/*Verificación de existencia de presentismo a modificar.*/
        IF @id_presentismo IS NULL
        BEGIN
            RAISERROR('No existe el presentismo para modificar.', 16, 1);
            RETURN;
        END
		/*Se utiliza COALESCE para asegurar dato válido en caso de que algún usuario ingrese NULL en algún campo*/
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
		/*Verificación de datos no nulos necesarios para insertar presentismo*/
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

/*____________________________________________________________________
  ______________________ GestionarActividadExtra _____________________
  ____________________________________________________________________*/

IF OBJECT_ID('actividades.GestionarActividadExtra', 'P') IS NOT NULL
    DROP PROCEDURE actividades.GestionarActividadExtra;
GO

CREATE PROCEDURE actividades.GestionarActividadExtra
    @nombre VARCHAR(100),
    @costo DECIMAL(10,2),
    @periodo CHAR(10),
    @es_invitado CHAR(1),
    @vigencia DATE,
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
	/*Se obtiene el id_extra en caso de eliminar o modificar una actividad extra*/
	DECLARE @id_extra INT = (SELECT id_extra
							 FROM actividades.ActividadExtra
							 WHERE nombre = @nombre AND periodo = @periodo AND es_invitado = @es_invitado)
	/*CASO 1: Eliminar actividad extra*/
    IF @operacion = 'Eliminar'
    BEGIN
		/*Verificaçión de existencia de actividad extra a borrar.*/
        IF @id_extra IS NULL
        BEGIN
            RAISERROR('No existe la actividad extra para eliminar.', 16, 1);
            RETURN;
        END

        DELETE FROM actividades.ActividadExtra WHERE id_extra = @id_extra;
    END
	/*CASO 2: Modificar actividad extra*/
    ELSE IF @operacion = 'Modificar'
    BEGIN
		/*Verificaçión de existencia de actividad extra a modificar.*/
        IF @id_extra IS NULL
        BEGIN
            RAISERROR('No existe la actividad extra para modificar.', 16, 1);
            RETURN;
        END
		/*Se utiliza COALESCE para asegurar dato válido en caso de que algún usuario ingrese NULL en algún campo*/
        UPDATE actividades.ActividadExtra
        SET nombre = COALESCE(@nombre, nombre),
            costo = COALESCE(@costo, costo),
            periodo = COALESCE(@periodo, periodo),
            es_invitado = COALESCE(@es_invitado, es_invitado),
            vigencia = COALESCE(@vigencia, vigencia)
        WHERE id_extra = @id_extra;
    END
	/*CASO 3: Insertar actividad extra*/
    ELSE IF @operacion = 'Insertar'
    BEGIN
		/*Verificación de datos no nulos necesarios para insertar actividad extra*/
        IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
        BEGIN
            RAISERROR('El nombre de la actividad extra es obligatorio.', 16, 1);
            RETURN;
        END

        IF @costo IS NULL OR @costo < 0
        BEGIN
            RAISERROR('El costo debe ser un número positivo.', 16, 1);
            RETURN;
        END

        INSERT INTO actividades.ActividadExtra (nombre, costo, periodo, es_invitado, vigencia)
        VALUES (@nombre, @costo, @periodo, @es_invitado, @vigencia);
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
    @dni_socio VARCHAR(10),
    @fecha DATE = NULL,
    @condicion CHAR(1) = NULL,
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
	/*Se obtiene el id_presentismo en caso de eliminar o modificar un presentismo*/
	DECLARE @id_presentismo INT = (
		SELECT P.id_presentismo_extra
		FROM actividades.presentismoActividadExtra P
		INNER JOIN actividades.ActividadExtra AE ON P.id_extra = AE.id_extra
		INNER JOIN administracion.Socio S ON P.id_socio = S.id_socio
		INNER JOIN administracion.Persona Pe ON S.id_persona = Pe.id_persona
		WHERE AE.nombre = @nombre_actividad_extra
		  AND AE.periodo = @periodo
		  AND AE.es_invitado = @es_invitado
		  AND Pe.dni = @dni_socio
		  AND P.fecha = ISNULL(@fecha, CAST(GETDATE() AS DATE))
	)
	/*CASO 1: Eliminar presentismo*/
    IF @operacion = 'Eliminar'
    BEGIN
		/*Verificaçión de existencia de presentismo a borrar.*/
        IF @id_presentismo IS NULL
        BEGIN
            RAISERROR('No existe el presentismo para eliminar.', 16, 1);
            RETURN;
        END

        DELETE FROM actividades.presentismoActividadExtra WHERE id_presentismo_extra = @id_presentismo;
    END
	/*CASO 2: Modificar presentismo*/
    ELSE IF @operacion = 'Modificar'
    BEGIN
		/*Verificaçión de existencia de presentismo a modificar.*/
        IF @id_presentismo IS NULL
        BEGIN
            RAISERROR('No existe el presentismo para modificar.', 16, 1);
            RETURN;
        END
		/*Se utiliza COALESCE para asegurar dato válido en caso de que algún usuario ingrese NULL en algún campo*/
        UPDATE actividades.presentismoActividadExtra
        SET id_extra = COALESCE((
									SELECT id_extra
									FROM actividades.ActividadExtra
									WHERE nombre = @nombre_actividad_extra
									  AND periodo = @periodo
									  AND es_invitado = @es_invitado
								), id_extra),
            id_socio = COALESCE((
									SELECT S.id_socio
									FROM socios.Socio S
									INNER JOIN administracion.Persona Pe ON S.id_persona = Pe.id_persona
									WHERE Pe.dni = @dni_socio
								), id_socio),
            fecha = COALESCE(@fecha, fecha),
            condicion = COALESCE(@condicion, condicion)
        WHERE id_presentismo_extra = @id_presentismo;
    END
	/*CASO 3: Insertar presentismo*/
    ELSE IF @operacion = 'Insertar'
    BEGIN
		/*Verificación de datos no nulos necesarios para insertar presentismo*/
        IF @nombre_actividad_extra IS NULL
        BEGIN
            RAISERROR('El nombre de la actividad extra es obligatorio.', 16, 1);
            RETURN;
        END

        IF @dni_socio IS NULL
        BEGIN
            RAISERROR('El dni del socio es obligatorio.', 16, 1);
            RETURN;
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
			   AND es_invitado = @es_invitado),
			(SELECT S.id_socio
			 FROM administracion.Socio S
			 INNER JOIN administracion.Persona Pe ON S.id_persona = Pe.id_persona
			 WHERE Pe.dni = @dni_socio),
			@fecha,
			@condicion);
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
	/*Verificación de operaciones válidas*/
    IF @operacion NOT IN ('Insertar', 'Modificar', 'Eliminar')
    BEGIN
        RAISERROR('Operación inválida. Usar Insertar, Modificar o Eliminar.', 16, 1);
        RETURN;
    END
	/*Se obtiene el id_inscripto en caso de eliminar o modificar una inscripción*/
	DECLARE @id_inscripto INT = (SELECT PAE.id_presentismo_extra
								 FROM actividades.PresentismoActividadExtra PAE
								 INNER JOIN actividades.ActividadExtra AE ON PAE.id_extra = AE.id_extra
								 INNER JOIN administracion.Socio S ON PAE.id_socio = S.id_socio
								 INNER JOIN administracion.Persona P ON S.id_persona = P.id_persona
								 WHERE AE.nombre = @nombre_actividad_extra AND P.dni = @dni_socio)
	/*CASO 1: Eliminar inscripción*/
    IF @operacion = 'Eliminar'
    BEGIN
		/*Verificación de existencia de inscripción a borrar.*/
        IF @id_inscripto IS NULL
        BEGIN
            RAISERROR('No existe la inscripción para eliminar.', 16, 1);
            RETURN;
        END

        DELETE FROM actividades.PresentismoActividadExtra WHERE id_presentismo_extra = @id_inscripto;
    END
	/*CASO 2: Modificar inscripción*/
    ELSE IF @operacion = 'Modificar'
    BEGIN
		/*Verificación de existencia de inscripción a modificar.*/
        IF @id_inscripto IS NULL
        BEGIN
            RAISERROR('No existe la inscripción para modificar.', 16, 1);
            RETURN;
        END
		/*Se utiliza COALESCE para asegurar dato válido en caso de que algún usuario ingrese NULL en algún campo*/
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
	/*CASO 3: Insertar inscripción*/
    ELSE IF @operacion = 'Insertar'
    BEGIN
		/*Verificación de datos no nulos necesarios para insertar inscripción*/
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
			(SELECT TOP 1 S.id_socio
			 FROM administracion.Socio S
			 INNER JOIN administracion.Persona P ON S.id_persona = P.id_persona
			 WHERE P.dni = @dni_socio),
			(SELECT TOP 1 AE.id_extra
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
  ____________________ GenerarFacturaSocioMensual ____________________
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

        /*Se obtiene el id_socio asociado a su correspondiente DNI*/
        SELECT @id_socio = S.id_socio 
        FROM administracion.Socio S
        INNER JOIN administracion.Persona P ON S.id_persona = P.id_persona
        WHERE p.dni = @dni_socio;
		/*Si no existe el socio, no se realiza la transacción.*/
        IF @id_socio IS NULL
        BEGIN
            RAISERROR('No se encontró socio con ese DNI.', 16, 1);
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

		/*Obtener todas las actividades pendientes de pago asociadas al socio*/
		
        /*Generar factura per sé*/
        INSERT INTO facturacion.Factura
        (id_emisor, id_socio, leyenda, monto_total, fecha_emision, fecha_vencimiento1, fecha_vencimiento2, estado, anulada)
		VALUES
        (@id_emisor, @id_socio, 'Consumidor final', 0, GETDATE(), GETDATE() + 5, GETDATE() + 10, 'Sin pago', 0);
		
		DECLARE @id_factura INT = SCOPE_IDENTITY();

        /*Generar detalles de factura*/
		-- MEMBRESÍA
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

		-- ACTIVIDADES
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

        /*Actualizar monto_total*/
        UPDATE facturacion.Factura
        SET monto_total = (SELECT SUM(monto * cantidad) FROM facturacion.DetalleFactura WHERE id_factura = @id_factura)
        WHERE id_factura = @id_factura;
		/*Confirmar transacción*/
        COMMIT TRANSACTION;

        SELECT @id_factura AS id_factura;

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
	/*Se realiza mediante una transacción a fin de garantizar ACID*/
    BEGIN TRY
        BEGIN TRANSACTION;
		/*Creación de variables auxiliares para id_invitado e id_emisor*/
        DECLARE @id_invitado INT;
        DECLARE @id_emisor INT;

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

        /*Generar factura con pago inmediato (fecha_vencimiento = hoy, estado = 'Pagada')*/
        INSERT INTO facturacion.Factura
        (id_emisor, id_socio, leyenda, monto_total, fecha_emision, fecha_vencimiento1, fecha_vencimiento2, estado, anulada)
        VALUES(
			@id_emisor, 
			NULL, 
			'Consumidor final', 
			(SELECT TOP 1 costo FROM actividades.ActividadExtra WHERE nombre = @descripcion  AND vigencia < GETDATE() ORDER BY vigencia DESC), 
			GETDATE(), 
			GETDATE(), 
			GETDATE(), 
			'Pagada', 
			0
		);

        DECLARE @id_factura INT = SCOPE_IDENTITY();

         /*Generar detalle de factura*/
        INSERT INTO facturacion.DetalleFactura
        (id_factura, tipo_item, descripcion, monto, cantidad)
        VALUES(
			@id_factura, 
			'Actividad extra', 
			(SELECT TOP 1 nombre FROM actividades.ActividadExtra WHERE nombre = @descripcion AND vigencia < GETDATE() ORDER BY vigencia DESC), 
			(SELECT TOP 1 costo FROM actividades.ActividadExtra WHERE nombre = @descripcion AND vigencia < GETDATE() ORDER BY vigencia DESC),
			1);

        COMMIT TRANSACTION;

        SELECT @id_factura AS id_factura;

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

/*____________________________________________________________________
  ____________________________ AnularFactura __________________________
  ____________________________________________________________________*/
IF OBJECT_ID('facturacion.AnularFactura', 'P') IS NOT NULL
    DROP PROCEDURE facturacion.AnularFactura;
GO

CREATE PROCEDURE facturacion.AnularFactura
(@id_factura INT)
AS
BEGIN
    SET NOCOUNT ON;
	/*Borrado lógico de la factura generada*/
    UPDATE facturacion.Factura
    SET anulada = 1,
        estado = 'Anulada'
    WHERE id_factura = @id_factura;
END;
GO