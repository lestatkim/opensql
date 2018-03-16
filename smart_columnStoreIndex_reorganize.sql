/*	Autor: Dmitry Zaicev
	Decor: Lestat Kim
*/
DECLARE 
	  @schemaName sysname
	, @tableName sysname
	, @indexName sysname
	, @partition_number sysname
	, @max_partition_number sysname
	, @sql NVARCHAR(MAX)
	, @database_name sysname
	, @columnstore_indexes_count INT
;

SELECT @database_name = DB_ID()
	, @columnstore_indexes_count = 0
;

IF CAST(SUBSTRING(
		CAST(SERVERPROPERTY('productversion') AS NVARCHAR(50)), 1, 2
		) AS INT) 
	> 11
BEGIN
    SELECT
		  @schemaName = ''
		, @tableName = ''
		, @indexName = ''
		, @partition_number = ''
		, @max_partition_number = ''
		, @sql = ''
	;

    DECLARE defragCC CURSOR FOR
		SELECT '[' + sh.name + ']',
			'[' + OBJECT_NAME(i.object_id) + ']' AS TableName,
			'[' + i.name + ']' AS IndexName,
			MAX(100 * (ISNULL(deleted_rows, 0)) / total_rows) AS 'Fragmentation',
			partition_number,
			MAX(partition_number) OVER (PARTITION BY i.name),
			MAX(i.[type])
		FROM sys.indexes AS i
			JOIN sys.tables AS tbl ON i.object_id = tbl.object_id
			JOIN sys.schemas AS sh ON sh.schema_id = tbl.schema_id
			JOIN sys.dm_db_column_store_row_group_physical_stats AS CSRowGroups
				ON i.object_id = CSRowGroups.object_id
				AND i.index_id = CSRowGroups.index_id
		WHERE CSRowGroups.deleted_rows > 0 AND CSRowGroups.total_rows > 0
		GROUP BY sh.name,
			OBJECT_NAME(i.object_id),
			i.name,
			partition_number
		HAVING MAX(100 * (ISNULL(deleted_rows, 0)) / total_rows) > 20
		ORDER BY MAX(100 * (ISNULL(deleted_rows, 0)) / total_rows) DESC
	;

    OPEN defragCC;
    FETCH NEXT FROM defragCC
    INTO @schemaName,
         @tableName,
         @indexName,
         @partition_number,
         @max_partition_number

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF OBJECT_ID(@schemaName + '.' + @tableName, 'U') IS NOT NULL
        BEGIN
            BEGIN TRY
                IF @max_partition_number > 1
					BEGIN
						SELECT @sql = 
							'ALTER INDEX ' + @indexName + ' ON ' + @schemaName + '.' + @tableName
							+ ' REORGANIZE PARTITION = ' + @partition_number
							+ ' WITH (COMPRESS_ALL_ROW_GROUPS = ON);
							
							ALTER INDEX ' + @indexName + ' ON ' + @schemaName + '.' + @tableName
							+ ' REORGANIZE PARTITION = ' + @partition_number
						;
					END;
                ELSE
					BEGIN
						SELECT @sql = 
							'ALTER INDEX ' + @indexName + ' ON ' + @schemaName + '.' + @tableName
							+ ' REORGANIZE PARTITION = ALL WITH (COMPRESS_ALL_ROW_GROUPS = ON);

							ALTER INDEX ' + @indexName + ' ON ' + @schemaName + '.' + @tableName
							+ ' REORGANIZE PARTITION = ALL'
						;
					END;

                EXEC (@sql);
                SET @columnstore_indexes_count += 1;
            END TRY
            BEGIN CATCH
                PRINT (
					'INDEX - Номер ошибки ' + CAST(ERROR_NUMBER() AS NVARCHAR(50)) + ', в строке '
					+ CAST(ERROR_LINE() AS NVARCHAR(50)) + '. Сообщение об ошибке: '
					+ CAST(ERROR_MESSAGE() AS NVARCHAR(400))
					+ CONVERT(VARCHAR(32), GETDATE())
					)
				;
            END CATCH;
        END;

        FETCH NEXT FROM defragCC
        INTO @schemaName,
             @tableName,
             @indexName,
             @partition_number,
             @max_partition_number
    END;


    CLOSE defragCC;
    DEALLOCATE defragCC;
END;

PRINT 'Columnstore Indexes done - ' 
	+ CAST(@columnstore_indexes_count AS NVARCHAR(50))
;