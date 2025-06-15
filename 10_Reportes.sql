/* =========================================================================
   Trabajo Pr�ctico Integrador - Bases de Datos Aplicadas
   Grupo N�: 13
   Comisi�n: 2900
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
Reporte de los socios morosos, que hayan incumplido en m�s de dos oportunidades dado un
rango de fechas a ingresar. El reporte debe contener los siguientes datos:
Nombre del reporte: Morosos Recurrentes
Per�odo: rango de fechas
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
END

EXEC cobranzas.MorososRecurrentes '2025-05-01', '2025-06-30';



/*____________________________________________________________________
  _____________________________ Reporte 2 ____________________________
  ____________________________________________________________________*/



/*____________________________________________________________________
  _____________________________ Reporte 3 ____________________________
  ____________________________________________________________________
Reporte de la cantidad de socios que han realizado alguna actividad de forma alternada
(inasistencias) por categor�a de socios y actividad, ordenado seg�n cantidad de inasistencias
ordenadas de mayor a menor
  */

IF OBJECT_ID('cobranzas.MorososRecurrentes', 'P') IS NOT NULL
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


SELECT * 
FROM actividades.presentismoClase
ORDER BY id_socio, fecha;


-- Presentismo (alternancia: A ? P ? A ? P)
INSERT INTO actividades.presentismoClase (id_clase, id_socio, fecha, condicion)
VALUES 
(3, 1, '2025-05-01', 'A'),
(3, 1, '2025-05-02', 'P'), -- alternada 1
(3, 1, '2025-05-03', 'A'),
(3, 1, '2025-05-04', 'P'), -- alternada 2
(3, 1, '2025-05-05', 'P'); -- no cuenta
INSERT INTO actividades.presentismoClase (id_clase, id_socio, fecha, condicion) VALUES
(3, 5, '2025-06-01', 'A'),
(3, 5, '2025-06-02', 'P'),  -- alternada 1
(3, 5, '2025-06-03', 'J'),
(3, 5, '2025-06-04', 'P'),  -- alternada 2
(3, 5, '2025-06-05', 'A'),
(3, 5, '2025-06-06', 'P');  -- alternada 3
INSERT INTO actividades.presentismoClase (id_clase, id_socio, fecha, condicion) VALUES
(1, 1, '2025-06-01', 'A'),
(1, 1, '2025-06-02', 'P'),  -- alternada 1
(1, 1, '2025-06-03', 'A'),
(1, 1, '2025-06-04', 'P');  -- alternada 2
INSERT INTO actividades.presentismoClase (id_clase, id_socio, fecha, condicion) VALUES
(2, 2, '2025-06-01', 'J'),
(2, 2, '2025-06-02', 'P');  -- alternada 1
INSERT INTO actividades.presentismoClase (id_clase, id_socio, fecha, condicion) VALUES
(1, 3, '2025-06-01', 'P'),
(1, 3, '2025-06-02', 'P'),
(1, 3, '2025-06-03', 'P');