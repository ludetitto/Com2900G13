/* =========================================================================
   Trabajo Práctico Integrador - Bases de Datos Aplicadas
   Grupo N°: 13
   Comisión: 2900
   Fecha de Entrega: 17/06/2025
   Materia: Bases de Datos Aplicadas
   Alumnos: Vignardel Francisco 45778667
            De Titto Lucia 46501934
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
			P.nombre + ' ' + P.apellido AS [Nombre_y_apellido],
			MONTH(F.fecha_vencimiento1) AS [Mes_incumplido],
			COUNT(F.id_factura) AS [Cantidad_de_incumplimientos]
		FROM facturacion.Factura F
		INNER JOIN administracion.Socio S ON F.id_socio = S.id_socio
		INNER JOIN administracion.Persona P ON S.id_persona = P.id_persona
		WHERE F.fecha_vencimiento1 BETWEEN @fecha_inicio AND @fecha_fin
		AND estado = 'No pagada'
		GROUP BY S.nro_socio, P.nombre, P.apellido, MONTH(F.fecha_vencimiento1)
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
			A.nombre AS [Actividad],
			DATENAME(MONTH, P.fecha_emision) AS [Mes],
			D.monto AS [Ingreso]
		FROM cobranzas.Pago P
		INNER JOIN facturacion.Factura F ON F.id_factura = P.id_factura
		INNER JOIN facturacion.DetalleFactura D ON F.id_factura = D.id_factura
		INNER JOIN actividades.Actividad A ON A.id_actividad = D.id_actividad
		WHERE P.fecha_emision <= EOMONTH(GETDATE()))
		
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
  _____________________________ Reporte 2 ____________________________
  ____________________________________________________________________*/



/*____________________________________________________________________
  _____________________________ Reporte 3 ____________________________
  ____________________________________________________________________
Reporte de la cantidad de socios que han realizado alguna actividad de forma alternada
(inasistencias) por categoría de socios y actividad, ordenado según cantidad de inasistencias
ordenadas de mayor a menor
  */

IF OBJECT_ID('cobranzas.Reporte3', 'P') IS NOT NULL
    DROP PROCEDURE cobranzas.Reporte3;
GO
CREATE or ALTER PROCEDURE  cobranzas.Reporte3 AS
begin
WITH AsistenciasConRanking AS (
    SELECT 
        pc.id_socio,
        c.id_actividad,
        s.id_categoria,
        pc.fecha,
        pc.condicion,
        ROW_NUMBER() OVER (PARTITION BY pc.id_socio, c.id_actividad ORDER BY pc.fecha) AS orden
    FROM actividades.presentismoClase pc
    INNER JOIN actividades.Clase c ON c.id_clase = pc.id_clase
    INNER JOIN administracion.Socio s ON s.id_socio = pc.id_socio
),
PatronesAlternados AS (
    SELECT 
        a1.id_socio,
        a1.id_actividad,
        a1.id_categoria,
        COUNT(*) AS inasistencias_alternadas
    FROM AsistenciasConRanking a1
    JOIN AsistenciasConRanking a2 
      ON a1.id_socio = a2.id_socio 
     AND a1.id_actividad = a2.id_actividad 
     AND a1.orden = a2.orden - 1
    WHERE a1.condicion IN ('A', 'J') AND a2.condicion = 'P'
    GROUP BY a1.id_socio, a1.id_actividad, a1.id_categoria
)
SELECT 
    CONCAT(p.nombre, ' ', p.apellido) AS nombre_socio,
    a.nombre AS nombre_actividad,
    c.nombre AS nombre_categoria,
    pa.inasistencias_alternadas
FROM PatronesAlternados pa
INNER JOIN administracion.Socio s ON s.id_socio = pa.id_socio
INNER JOIN administracion.Persona p ON p.id_persona = s.id_persona
INNER JOIN actividades.Actividad a ON a.id_actividad = pa.id_actividad
INNER JOIN administracion.CategoriaSocio c ON c.id_categoria = pa.id_categoria
ORDER BY pa.inasistencias_alternadas DESC
FOR XML PATH('Socio'), ROOT('Socios');
END

EXEC cobranzas.Reporte3

select * from administracion.Socio
select * from administracion.Persona
SELECT * 
FROM actividades.presentismoClase
ORDER BY id_socio, fecha;

