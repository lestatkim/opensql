DECLARE @schemaName VARCHAR(250);
DECLARE @tableName VARCHAR(250);
DECLARE @indexName VARCHAR(250);
DECLARE @defrag FLOAT;
DECLARE @partition_number VARCHAR(250);
DECLARE @max_partition_number VARCHAR(250);
DECLARE @sql NVARCHAR(MAX);
DECLARE @database_name NVARCHAR(255);
DECLARE @columnstore_exists INT;
DECLARE @indexes_count INT;
DECLARE @columnstore_indexes_count INT;

SET @database_name = DB_ID();
SET @indexes_count = 0;
SET @columnstore_indexes_count = 0;

-- Приступаем к обновлению колоночных индексов если версия SQL Server 2014+
IF CAST(SUBSTRING(CAST(SERVERPROPERTY('productversion') AS NVARCHAR(50)), 1, 2) AS INT) > 11
BEGIN

    DECLARE @type INT;

    SET @schemaName = '';
    SET @tableName = '';
    SET @indexName = '';
    SET @partition_number = '';
    SET @max_partition_number = '';
    SET @defrag = '';
    SET @sql = '';


    DECLARE defragCC CURSOR FOR
    SELECT '[' + sh.name + ']',
           '[' + OBJECT_NAME(i.object_id) + ']' AS TableName,
           '[' + i.name + ']' AS IndexName,
           MAX(100 * (ISNULL(deleted_rows, 0)) / total_rows) AS 'Fragmentation',
           partition_number,
           MAX(partition_number) OVER (PARTITION BY i.name),
           MAX(i.[type])
    FROM sys.indexes AS i
        INNER JOIN sys.tables AS tbl
            ON i.object_id = tbl.object_id
        INNER JOIN sys.schemas AS sh
            ON sh.schema_id = tbl.schema_id
        INNER JOIN sys.dm_db_column_store_row_group_physical_stats AS CSRowGroups
            ON i.object_id = CSRowGroups.object_id
               AND i.index_id = CSRowGroups.index_id
    WHERE CSRowGroups.deleted_rows > 0
          AND CSRowGroups.total_rows > 0
    GROUP BY sh.name,
             OBJECT_NAME(i.object_id),
             i.name,
             partition_number
    HAVING MAX(100 * (ISNULL(deleted_rows, 0)) / total_rows) > 20
    ORDER BY MAX(100 * (ISNULL(deleted_rows, 0)) / total_rows) DESC;

    OPEN defragCC;
    FETCH NEXT FROM defragCC
    INTO @schemaName,
         @tableName,
         @indexName,
         @defrag,
         @partition_number,
         @max_partition_number,
         @type;
    WHILE @@FETCH_STATUS = 0
    BEGIN

        IF OBJECT_ID(@schemaName + '.' + @tableName, 'U') IS NOT NULL
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
                    SET @sql
                        = 'ALTER INDEX ' + @indexName + ' ON ' + @schemaName + '.' + @tableName
                          + ' REORGANIZE PARTITION = ' + @partition_number
                          + ' WITH (COMPRESS_ALL_ROW_GROUPS = ON);
							
							ALTER INDEX ' + @indexName + ' ON ' + @schemaName + '.' + @tableName
                          + ' REORGANIZE PARTITION = ' + @partition_number;

                END;
                ELSE
                BEGIN

                    SET @sql
                        = 'ALTER INDEX ' + @indexName + ' ON ' + @schemaName + '.' + @tableName
                          + ' REORGANIZE PARTITION = ALL WITH (COMPRESS_ALL_ROW_GROUPS = ON);
							
							ALTER INDEX ' + @indexName + ' ON ' + @schemaName + '.' + @tableName
                          + ' REORGANIZE PARTITION = ALL';

                END;
                --END

                --print @sql
                EXEC (@sql);

                SET @columnstore_indexes_count = @columnstore_indexes_count + 1;

            END TRY
            BEGIN CATCH

                SET @database_name = DB_NAME();
                INSERT INTO master.dbo.dbmaintenance
                VALUES
                (@database_name,
                 'INDEX - Номер ошибки ' + CAST(ERROR_NUMBER() AS NVARCHAR(50)) + ', в строке '
                 + CAST(ERROR_LINE() AS NVARCHAR(50)) + '. Сообщение об ошибке: '
                 + CAST(ERROR_MESSAGE() AS NVARCHAR(400)), GETDATE());

            END CATCH;
        END;
        FETCH NEXT FROM defragCC
        INTO @schemaName,
             @tableName,
             @indexName,
             @defrag,
             @partition_number,
             @max_partition_number,
             @type;
    END;
    CLOSE defragCC;
    DEALLOCATE defragCC;

END;

PRINT 'Columnstore Indexes done - ' + CAST(@columnstore_indexes_count AS NVARCHAR(50));


