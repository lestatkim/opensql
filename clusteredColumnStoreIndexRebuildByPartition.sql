
CREATE OR ALTER PROC dbo.sp_ccsiRebuild 
	@schema_name SYSNAME
	, @table_name SYSNAME
AS
BEGIN
SET NOCOUNT ON;
	
	/*	Author: Lestat
		Create date: 20.06.2018
		Destination: rebuild ccsi by section
		Description: just add code below for index rebuilding 
			after your DML instruction
		Example: sp_ccsiRebuild 'sap', 'AccDocumentExt';
		Parameters: 
			@schema_name - schema name of destination table
			@schema_name - name of your table 
	*/
	DECLARE @max INT
		, @iter INT = 1
		, @prtn_number INT
		, @ix_name SYSNAME
		, @query VARCHAR(256)
	;


	/*	extracting fragmentation info for each partition 
		and saving result to temp table */
	DROP TABLE  IF EXISTS #main;
		SELECT i.name AS ix
			, MAX(100 * (ISNULL(rg.deleted_rows, 0)) / rg.total_rows) AS frag
			, rg.partition_number AS prtn
			, ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
		INTO #main
		FROM sys.indexes AS i
			JOIN sys.tables AS tbl ON i.object_id = tbl.object_id
			JOIN sys.schemas AS sh ON tbl.schema_id = sh.schema_id
			JOIN sys.dm_db_column_store_row_group_physical_stats AS rg
				ON i.object_id = rg.object_id
				AND i.index_id = rg.index_id
		WHERE sh.name = @schema_name
			AND tbl.name = @table_name
			AND rg.deleted_rows > 0
			AND rg.total_rows > 0
			AND i.type_desc = 'CLUSTERED COLUMNSTORE'
		GROUP BY sh.name,
			OBJECT_NAME(i.object_id),
			i.name,
			partition_number
		HAVING MAX(100 * (ISNULL(deleted_rows, 0)) / total_rows) > 20
	;


	SELECT @max     = MAX(n) 
		 , @ix_name = MAX(ix)
	FROM #main
	;

	/*	rebuild index for each partition number by loop */
	WHILE @iter < @max
	BEGIN

		SELECT @prtn_number = prtn 
		FROM #main 
		WHERE n = @iter
		;

	    SET @query = 'ALTER INDEX ' + @ix_name 
			+ ' ON ' + @schema_name + '.' + @table_name
			+ ' REBUILD PARTITION = ' + CONVERT(VARCHAR(4), @prtn_number)
		;
		
		BEGIN TRY
			EXEC(@query);
			SET @iter += 1;
		END TRY
		BEGIN CATCH
			RAISERROR('master.dbo.sp_ccsiRebuild EXEC(@query) Error', 16, 1);
			RETURN;
		END CATCH;

	END
	;


	DROP TABLE #main;

END
