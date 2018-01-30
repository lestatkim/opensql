
/*	ColumnStore index fragmentation info
	with partition number
*/
SELECT 
	[schema] = '[' + sh.name + ']',
	[TableName] = '[' + OBJECT_NAME(i.object_id) + ']',
	[IndexName] = '[' + i.name + ']',
	[Fragmentation] = MAX(100 * (ISNULL(deleted_rows, 0)) / total_rows),
	partition_number,
	MAX(partition_number) OVER (PARTITION BY i.name),
	MAX(i.[type])
FROM sys.indexes AS i
    JOIN sys.tables AS tbl ON i.object_id = tbl.object_id
    JOIN sys.schemas AS sh ON sh.schema_id = tbl.schema_id
    JOIN sys.dm_db_column_store_row_group_physical_stats AS CSRowGroups
        ON i.object_id = CSRowGroups.object_id
        AND i.index_id = CSRowGroups.index_id
WHERE CSRowGroups.deleted_rows > 0
      AND CSRowGroups.total_rows > 0
GROUP BY sh.name,
         OBJECT_NAME(i.object_id),
         i.name,
         partition_number
HAVING MAX(100 * (ISNULL(deleted_rows, 0)) / total_rows) > 20;
