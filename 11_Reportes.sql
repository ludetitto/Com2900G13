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

   Consigna: Reportes.
   ========================================================================= */

USE COM2900G13
GO

/*____________________________________________________________________
  _____________________________ Reporte 1 ____________________________
  ____________________________________________________________________*/

/*Reporte 1
Reporte de los socios morosos, que hayan incumplido en más de dos oportunidades dado un
rango de fechas a ingresar. El reporte debe contener los siguientes datos:
Nombre del reporte: Morosos Recurrentes
Período: rango de fechas
Nro de socio
Nombre y apellido.
Mes incumplido
Ordenados de Mayor a menor por ranking de morosidad
El mismo debe ser desarrollado utilizando Window Functions.*/

IF OBJECT_ID('cobranzas.MorososRecurrentes', 'P') IS NOT NULL
    DROP PROCEDURE cobranzas.MorososRecurrentes;
GO

CREATE PROCEDURE cobranzas.MorososRecurrentes (
	@fecha_inicio DATE,
	@fecha_fin DATE
)
AS
BEGIN
	SET NOCOUNT ON;

	WITH CantidadIncumplimientos AS (
		SELECT
			S.nro_socio AS [Nro_de_socio],
			S.nombre + ' ' + S.apellido AS [Nombre_y_apellido],
			MONTH(F.fecha_vencimiento1) AS [Mes_incumplido],
			COUNT(M.id_mora) AS [Cantidad_de_incumplimientos]
		FROM facturacion.Factura F
		INNER JOIN cobranzas.Mora M ON M.id_factura = F.id_factura
		INNER JOIN socios.Socio S ON S.id_socio = M.id_socio
		WHERE F.fecha_vencimiento1 BETWEEN @fecha_inicio AND @fecha_fin
		GROUP BY S.nro_socio, S.nombre, S.apellido, MONTH(F.fecha_vencimiento1)
	)
	SELECT
        @fecha_inicio AS [Periodo/@Desde],
        @fecha_fin AS [Periodo/@Hasta],
        (
            SELECT
                [Nro_de_socio],
                [Nombre_y_apellido],
                [Mes_incumplido],
                [Cantidad_de_incumplimientos],
                RANK() OVER(ORDER BY [Cantidad_de_incumplimientos] DESC) AS [Ranking_de_morosidad]
            FROM CantidadIncumplimientos
            FOR XML PATH('Moroso'), TYPE
        ) AS [Morosos]
    FOR XML PATH('MorososRecurrentes'), ROOT('Reporte'), ELEMENTS;
END;
GO

EXEC cobranzas.MorososRecurrentes '2025-05-01', '2025-06-30';

/*____________________________________________________________________
  _____________________________ Reporte 2 ____________________________
  ____________________________________________________________________*/

/*Reporte 2
Reporte acumulado mensual de ingresos por actividad deportiva al momento en que se saca
el reporte tomando como inicio enero.*/

IF OBJECT_ID('cobranzas.IngresosMensualesPorActividad', 'P') IS NOT NULL
    DROP PROCEDURE cobranzas.IngresosMensualesPorActividad;
GO

CREATE PROCEDURE cobranzas.IngresosMensualesPorActividad
AS
BEGIN

	SET LANGUAGE Spanish;
	
	WITH IngresoMensualDesdeEnero AS (
		SELECT
			D.descripcion AS [Actividad],
			DATENAME(MONTH, P.fecha_emision) AS [Mes],
			D.monto AS [Ingreso]
		FROM cobranzas.Pago P
		INNER JOIN facturacion.Factura F ON F.id_factura = P.id_factura
		INNER JOIN facturacion.DetalleFactura D ON F.id_factura = D.id_factura
		WHERE P.fecha_emision <= EOMONTH(GETDATE()) AND LOWER(D.tipo_item) LIKE '%actividad%')
		
	SELECT
		Actividad,
		[Enero], [Febrero], [Marzo],
		[Abril], [Mayo], [Junio],
		[Julio], [Agosto], [Septiembre],
		[Octubre], [Noviembre], [Diciembre]
	FROM IngresoMensualDesdeEnero
	PIVOT(
		SUM(Ingreso)
		FOR Mes
		IN ([Enero], [Febrero], [Marzo],
			[Abril], [Mayo], [Junio],
			[Julio], [Agosto], [Septiembre],
			[Octubre], [Noviembre], [Diciembre])
	) AS IngresoMensual
	FOR XML PATH('IngresosMensualesPorActividad'), ROOT('Reporte'), ELEMENTS;
END;
GO

EXEC cobranzas.IngresosMensualesPorActividad;

/*____________________________________________________________________
  _____________________________ Reporte 3 ____________________________
  ____________________________________________________________________*/
/*
Reporte de la cantidad de socios que han realizado alguna actividad de forma alternada
(inasistencias) por categoría de socios y actividad, ordenado según cantidad de inasistencias
ordenadas de mayor a menor
  */

IF OBJECT_ID('cobranzas.Reporte3', 'P') IS NOT NULL
    DROP PROCEDURE cobranzas.Reporte3;
GO
CREATE OR ALTER PROCEDURE cobranzas.Reporte3
AS
BEGIN
    SET NOCOUNT ON;

    WITH AsistenciasConOrden AS (
        SELECT 
            pc.id_socio,
            c.id_actividad,
            c.id_categoria,
            pc.fecha,
            pc.estado,
            ROW_NUMBER() OVER (PARTITION BY pc.id_socio, c.id_actividad ORDER BY pc.fecha) AS orden
        FROM actividades.PresentismoClase pc
        INNER JOIN actividades.Clase c ON c.id_clase = pc.id_clase
    ),
    InasistenciasAlternadas AS (
        SELECT 
            a1.id_socio,
            a1.id_actividad,
            a1.id_categoria,
            COUNT(*) AS inasistencias_alternadas
        FROM AsistenciasConOrden a1
        JOIN AsistenciasConOrden a2 
          ON a1.id_socio = a2.id_socio 
         AND a1.id_actividad = a2.id_actividad
         AND a1.orden = a2.orden - 1
        WHERE a1.estado IN ('A', 'J') AND a2.estado = 'P'
        GROUP BY a1.id_socio, a1.id_actividad, a1.id_categoria
    )
    SELECT 
        CONCAT(s.nombre, ' ', s.apellido) AS nombre_socio,
        act.nombre AS nombre_actividad,
        cat.nombre AS nombre_categoria,
        ia.inasistencias_alternadas
    FROM InasistenciasAlternadas ia
    INNER JOIN socios.Socio s ON s.id_socio = ia.id_socio
    INNER JOIN actividades.Actividad act ON act.id_actividad = ia.id_actividad
    INNER JOIN socios.CategoriaSocio cat ON cat.id_categoria = ia.id_categoria
    ORDER BY ia.inasistencias_alternadas DESC
    FOR XML PATH('Socio'), ROOT('Socios'), ELEMENTS;
END;

EXEC cobranzas.Reporte3

SELECT * FROM actividades.presentismoClase ORDER BY id_socio, fecha;



/*____________________________________________________________________
  _____________________________ Reporte 4 ____________________________
  ____________________________________________________________________*/
/*
Reporte que contenga a los socios que no han asistido a alguna clase de la actividad que
realizan. El reporte debe contener: Nombre, Apellido, edad, categoría y la actividad
  */

/*____________________________________________________________________
  _____________________________ Reporte 4 ____________________________
  ____________________________________________________________________*/
/*
Reporte que contenga a los socios que no han asistido a alguna clase de la actividad que
realizan. El reporte debe contener: Nombre, Apellido, edad, categoría y la actividad
*/

IF OBJECT_ID('actividades.SociosConInasistencias', 'P') IS NOT NULL
    DROP PROCEDURE actividades.SociosConInasistencias;
GO

CREATE PROCEDURE actividades.SociosConInasistencias
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH Inasistencias AS (
        SELECT 
            S.id_socio,
            S.nombre,
            S.apellido,
            DATEDIFF(YEAR, S.fecha_nacimiento, GETDATE()) AS edad,
            CS.nombre AS categoria,
            A.nombre AS actividad
        FROM actividades.InscriptoClase IC
        INNER JOIN socios.Socio S ON S.id_socio = IC.id_socio
        INNER JOIN actividades.Clase C ON C.id_clase = IC.id_clase
        INNER JOIN actividades.Actividad A ON A.id_actividad = C.id_actividad
        INNER JOIN socios.CategoriaSocio CS ON CS.id_categoria = C.id_categoria
        WHERE EXISTS (
            SELECT 1
            FROM actividades.PresentismoClase PC
            WHERE PC.id_socio = S.id_socio
              AND PC.id_clase = C.id_clase
              AND PC.estado IN ('A', 'J')
        )
    )
    SELECT 
        (
            SELECT 
                nombre AS [Nombre],
                apellido AS [Apellido],
                edad AS [Edad],
                categoria AS [Categoria],
                actividad AS [Actividad]
            FROM Inasistencias
            FOR XML PATH('Socio'), TYPE
        ) AS [Socios]
    FOR XML PATH('SociosConInasistencias'), ROOT('Reporte'), ELEMENTS;
END;
GO

-- Ejecución de ejemplo:
EXEC actividades.SociosConInasistencias;
