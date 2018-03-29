CREATE TABLE #TempRebuildTable (
  database_id smallint,
  table_name sysname,
  index_id int,
  index_name sysname,
  avg_frag_percent float,
  fill_factor int
)

INSERT INTO #TempTable (
    database_id, 
    table_name, 
    index_id, 
    index_name, 
    avg_frag_percent,
    fill_factor) 
SELECT 
    dm.database_id, 
    '['+tbl.name+']', 
    dm.index_id, 
    '['+idx.name+']', 
    dm.avg_fragmentation_in_percent,   
    idx.fill_factor
FROM sys.dm_db_index_physical_stats(DB_ID(), null, null, null, 'LIMITED') dm
    INNER JOIN sys.tables tbl ON dm.object_id = tbl.object_id
    INNER JOIN sys.indexes idx ON dm.object_id = idx.object_id AND dm.index_id = idx.index_id
WHERE page_count > 1000
    AND avg_fragmentation_in_percent > 15
    AND dm.index_id > 0 
    AND idx.is_disabled = 0

    --тут указываем таблицу, в которой хотим перестроить индексы
    AND tbl.name = 'MyTable'
    
—см описание таблицы
DECLARE @index_id INT
DECLARE @tableName VARCHAR(250) 
DECLARE @indexName VARCHAR(250)
DECLARE @defrag FLOAT
DECLARE @fill_factor int
--Сам запрос, который мы будем выполнять, я поставил MAX, потому как иногда меняю такие скрипты,
--и забываю поправить размер данной переменной, в результате получаю ошибку.
DECLARE @sql NVARCHAR(MAX)

— Далее объявляем курсор
DECLARE defragCur CURSOR FOR
    SELECT 
        index_id, 
        table_name, 
        index_name, 
        avg_frag_percent,
        fill_factor
        
    FROM #TempTable

OPEN defragCur
FETCH NEXT FROM defragCur INTO @index_id, @tableName, @indexName, @defrag,@fill_factor
WHILE @@FETCH_STATUS=0
BEGIN
  IF OBJECT_ID(''+@tableName+'','U') is not null
  BEGIN
    SET @sql = N'ALTER INDEX ' + @indexName + ' ON ' + @tableName
    
    BEGIN TRY

      /*  В моем случае, важно держать неможко пустого места на страницах,
          потому что вставка в тоже таблицы имеете место,
          и не хочеться тратить драгоценное время пользователей на разбиение страниц
      */
      IF (@fill_factor != 90)
      BEGIN
        SET @sql = @sql + N' REBUILD PARTITION = ALL WITH (FILLFACTOR = 90, PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, ONLINE = OFF, SORT_IN_TEMPDB = ON )'
      END
      ELSE
      BEGIN -- Тут все просто, действуем по рекомендации MS
        IF (@defrag > 30) --Если фрагментация больше 30%, делаем REBUILD
        BEGIN
          SET @sql = @sql + N' REBUILD PARTITION = ALL WITH ( PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, ONLINE = OFF, SORT_IN_TEMPDB = ON )'
        END
        ELSE -- В противном случае REORGINIZE
        BEGIN
          SET @sql = @sql + N' REORGANIZE'
        END
      END
         
      exec (@sql) -- Выполнить запрос
      print @sql --смотрим индексы

    END TRY
    
    BEGIN CATCH
       SELECT '***Filed*** ' + ERROR_MESSAGE()  
    END CATCH
    
  END
    FETCH NEXT FROM defragCur INTO @index_id, @tableName, @indexName, @defrag,@fill_factor
END
CLOSE defragCur
DEALLOCATE defragCur

DROP TABLE #TempRebuildTable





