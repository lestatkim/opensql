DECLARE @schemaName VARCHAR(250)
DECLARE @tableName VARCHAR(250) 
DECLARE @indexName VARCHAR(250)
DECLARE @defrag FLOAT
DECLARE @partition_number VARCHAR(250)
DECLARE @max_partition_number VARCHAR(250)
DECLARE @sql NVARCHAR(MAX)
DECLARE @database_name nvarchar(255)
DECLARE @columnstore_exists int
DECLARE @indexes_count int
DECLARE @columnstore_indexes_count int

SET @database_name = DB_ID()
SET @indexes_count = 0
SET @columnstore_indexes_count = 0

-- Приступаем к обновлению колоночных индексов если версия SQL Server 2014+
IF CAST(SUBSTRING(CAST(SERVERPROPERTY ('productversion') as nvarchar(50)),1,2) as int) > 11
BEGIN

DECLARE @type int

SET @schemaName = ''
SET @tableName = ''
SET @indexName = ''
SET @partition_number = ''
SET @max_partition_number = ''
SET @defrag = ''
SET @sql = ''


DECLARE defragCC CURSOR FOR

	SELECT '['+sh.name+']',   
		'['+object_name(i.object_id)+']' AS TableName,   
		'['+i.name+']' AS IndexName,   
	    MAX(100*(ISNULL(deleted_rows,0))/total_rows) AS 'Fragmentation' , 
		partition_number,
		MAX (partition_number) OVER (PARTITION BY i.name),
		MAX(i.[type])
	FROM sys.indexes AS i  
		INNER JOIN sys.tables tbl ON i.object_id = tbl.object_id
		INNER JOIN sys.schemas sh ON sh.schema_id = tbl.schema_id
		INNER JOIN sys.dm_db_column_store_row_group_physical_stats AS CSRowGroups  
		ON i.object_id = CSRowGroups.object_id AND i.index_id = CSRowGroups.index_id
		WHERE CSRowGroups.deleted_rows > 0 AND CSRowGroups.total_rows > 0
		GROUP BY sh.name,object_name(i.object_id),i.name,partition_number
		HAVING MAX(100*(ISNULL(deleted_rows,0))/total_rows) > 20
		ORDER BY MAX(100*(ISNULL(deleted_rows,0))/total_rows) DESC

OPEN defragCC
FETCH NEXT FROM defragCC INTO @schemaName,@tableName, @indexName, @defrag,@partition_number,@max_partition_number,@type
WHILE @@FETCH_STATUS=0
BEGIN

	IF OBJECT_ID(@schemaName+'.'+@tableName,'U') is not null
	BEGIN
		BEGIN TRY				
				/* -- Отключил так как даже на 2016 появляются проблемы с ONLINE = ON
				IF @type = 6 and (SELECT @@VERSION) LIKE '%Enterprise Edition%'
					IF @max_partition_number > 1
						SET @sql = 'ALTER INDEX '+@indexName+' ON '+@schemaName+'.'+@tableName+' Rebuild PARTITION = '+@partition_number+' WITH (ONLINE = ON);'
					ELSE
						SET @sql = 'ALTER INDEX '+@indexName+' ON '+@schemaName+'.'+@tableName+' Rebuild PARTITION = ALL WITH (ONLINE = ON);'
				ELSE
				BEGIN */
					IF @max_partition_number > 1
						BEGIN
							SET @sql = 'ALTER INDEX '+@indexName+' ON '+@schemaName+'.'+@tableName+' REORGANIZE PARTITION = '+@partition_number+' WITH (COMPRESS_ALL_ROW_GROUPS = ON);
							
							ALTER INDEX '+@indexName+' ON '+@schemaName+'.'+@tableName+' REORGANIZE PARTITION = '+@partition_number

						END
					ELSE 
						BEGIN

							SET @sql = 'ALTER INDEX '+@indexName+' ON '+@schemaName+'.'+@tableName+' REORGANIZE PARTITION = ALL WITH (COMPRESS_ALL_ROW_GROUPS = ON);
							
							ALTER INDEX '+@indexName+' ON '+@schemaName+'.'+@tableName+' REORGANIZE PARTITION = ALL'

						END
				--END

				--print @sql
				exec (@sql)
				
				SET @columnstore_indexes_count = @columnstore_indexes_count +1 

		END TRY
		BEGIN CATCH

				SET @database_name = DB_NAME()
				INSERT INTO master.dbo.dbmaintenance 
				VALUES (@database_name,'INDEX - Номер ошибки '+CAST(ERROR_NUMBER() as nvarchar(50)) + ', в строке ' + CAST(ERROR_LINE() as nvarchar(50)) +'. Сообщение об ошибке: ' + CAST(ERROR_MESSAGE() as nvarchar(400)),GETDATE())

		END CATCH
	END
    FETCH NEXT FROM defragCC INTO @schemaName,@tableName, @indexName, @defrag,@partition_number,@max_partition_number,@type
END
CLOSE defragCC
DEALLOCATE defragCC

END

print 'Columnstore Indexes done - '+ CAST(@columnstore_indexes_count as nvarchar(50))

