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
END

EXEC cobranzas.MorososRecurrentes '2025-05-01', '2025-06-30';
