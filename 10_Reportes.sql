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
			S.nro_socio AS [Nro de socio],
			P.nombre + ' ' + P.apellido AS [Nombre y apellido],
			MONTH(F.fecha_vencimiento1) AS [Mes incumplido],
			COUNT(M.id_mora) OVER(PARTITION BY S.id_socio) AS [Cantidad de incumplimientos]
		FROM cobranzas.Mora M
		INNER JOIN facturacion.Factura F ON M.id_factura = F.id_factura
		INNER JOIN administracion.Socio S ON M.id_socio = S.id_socio
		INNER JOIN administracion.Persona P ON S.id_persona = P.id_persona
		WHERE F.fecha_vencimiento1 BETWEEN @fecha_inicio AND @fecha_fin
	)
	SELECT DISTINCT
		[Nro de socio],
		[Nombre y apellido],
		[Mes incumplido],
		[Cantidad de incumplimientos],
		RANK() OVER(ORDER BY [Cantidad de incumplimientos] DESC) AS [Ranking de morosidad]
	FROM CantidadIncumplimientos
	FOR XML PATH(''), ROOT('MorososRecurrentes'), ELEMENTS;
END

EXEC cobranzas.MorososRecurrentes '2024-01-01', '2024-12-31';
