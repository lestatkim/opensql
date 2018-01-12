
SELECT i.object_id,
    object_name(i.object_id) AS TableName,
    i.name AS IndexName,
    i.index_id,
    i.type_desc,
    CSRowGroups.*,
    100*(ISNULL(deleted_rows,0))/total_rows AS 'Fragmentation'
FROM sys.indexes AS i
JOIN sys.dm_db_column_store_row_group_physical_stats AS CSRowGroups
    ON i.object_id = CSRowGroups.object_id AND i.index_id = CSRowGroups.index_id
-- WHERE object_name(i.object_id) = 'table_name'
ORDER BY object_name(i.object_id), i.name, row_group_id;


SELECT     OBJECT_NAME(rg.object_id)   AS TableName,
           i.name                      AS IndexName,
           i.type_desc                 AS IndexType,
           rg.partition_number,
           rg.row_group_id,
           rg.total_rows,
           rg.size_in_bytes,
           rg.deleted_rows,
           rg.[state],
           rg.state_description
FROM       sys.column_store_row_groups AS rg
INNER JOIN sys.indexes                 AS i
      ON   i.object_id                  = rg.object_id
      AND  i.index_id                   = rg.index_id
WHERE      i.name = @index_name
ORDER BY   TableName, IndexName,
           rg.partition_number, rg.row_group_id;


-- Reorganize the index
--ALTER INDEX your_index ON schema.Table REORGANIZE/REBUILD;
--GO

