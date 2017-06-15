/*  Author: marc_s
    https://dba.meta.stackexchange.com/users/807/marc-s
/*

WITH 
    LastRestores AS	(
		SELECT
		    DatabaseName = [d].[name]
		    , [d].[create_date]
		    , [d].[compatibility_level]
		    , [d].[collation_name]
		    , r.*
		    , RowNum = ROW_NUMBER() OVER (
		    	PARTITION BY d.Name ORDER BY r.[restore_date] DESC
		    )
		FROM master.sys.databases AS d
			LEFT OUTER JOIN msdb.dbo.[restorehistory] AS r
				ON r.[destination_database_name] = d.Name
	)
SELECT *
FROM [LastRestores]
WHERE [RowNum] = 1

