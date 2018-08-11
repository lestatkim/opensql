USE [master]
GO
/****** Object:  StoredProcedure [dbo].[git]    Script Date: 04.04.2018 9:24:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE git
	@db sysname = '%', @sch sysname = '%', @obj sysname = '%'
AS
BEGIN
	SET NOCOUNT ON;

	SELECT *
	FROM master.dbo.DatabaseChange
	WHERE   db LIKE @db
		AND sch LIKE @sch
		AND object LIKE @obj
	ORDER BY date DESC
	OPTION (OPTIMIZE FOR UNKNOWN);
END

