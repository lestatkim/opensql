USE [master]
GO
/****** Object:  StoredProcedure [dbo].[git_status]    Script Date: 04.04.2018 9:24:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE git_status
AS
BEGIN
	SET NOCOUNT ON;

	WITH cte AS (
		SELECT *,
			ROW_NUMBER() OVER (
				PARTITION BY db, sch, object 
				ORDER BY date DESC
				) AS n
		FROM master.dbo.DataBaseChange
		WHERE event != 'INIT' AND [commit] IS NULL
		)
	SELECT event, db, sch, object, sql, login, date, [commit] 
	FROM cte WHERE n = 1
	;
END

