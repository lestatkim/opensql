
DECLARE @schema nvarchar(255), @table nvarchar(255), @statistic nvarchar(255), @query  nvarchar(4000)

DECLARE CursUpdateStatistic CURSOR FOR
select  DISTINCT SCHEMA_NAME(uid) as gerg, 
    object_name (i.id)as objectname,    
    i.name as indexname
    from sysindexes i INNER JOIN dbo.sysobjects o ON i.id = o.id AND object_name(i.id) = 'MyTable' AND i.name NOT IN('','')
    LEFT JOIN sysindexes si ON si.id = i.id AND si.rows > 0 
    AND i.name not like 'sys%'


OPEN CursUpdateStatistic

FETCH NEXT FROM CursUpdateStatistic INTO @schema,@table,@statistic

WHILE @@FETCH_STATUS = 0
  BEGIN
  
    SET @query= 'UPDATE STATISTICS ['+ @schema+'].[' + @table+ '] [' + @statistic +'] WITH FULLSCAN'
    exec(@query)    
  
    FETCH NEXT FROM CursUpdateStatistic INTO @schema,@table,@statistic
  END
  
CLOSE CursUpdateStatistic
DEALLOCATE CursUpdateStatistic

/*  Димооон), [12.01.17 16:41]
    Измени AND object_name(i.id) = 'MyTable' AND i.name NOT IN('','')

    Укажи свою таблицу, а в NOT IN укажи все индексы, которые перестроились ранее
*/