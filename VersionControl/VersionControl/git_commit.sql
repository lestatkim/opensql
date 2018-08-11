USE [master]
GO
/****** Object:  StoredProcedure [dbo].[git_commit]    Script Date: 04.04.2018 9:24:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[git_commit] 
	@db sysname, 
	@sch sysname,
	@obj sysname,
	@commit NVARCHAR(256)
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
		WHERE db = @db
			AND sch = @sch
			AND object = @obj 
			AND login = SUSER_NAME() AND event != 'INIT'
		)
	UPDATE cte
	SET [commit] = @commit
	WHERE n = 1;
END

