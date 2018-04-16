DECLARE @index_name sysname = 'index_name'
SELECT '['+sh.name+']',   
    '['+object_name(i.object_id)+']' AS TableName,   
    '['+i.name+']' AS IndexName,   
    partition_number,
    total_rows,
    deleted_rows,*
    FROM sys.indexes AS i  
		JOIN sys.tables tbl ON i.object_id = tbl.object_id
		JOIN sys.schemas sh ON sh.schema_id = tbl.schema_id
		JOIN sys.dm_db_column_store_row_group_physical_stats AS rg  
			ON i.object_id = rg.object_id 
			AND i.index_id = rg.index_id
WHERE i.name = @index_name
	AND deleted_rows > 0 AND  total_rows > 0
	
