
DECLARE @index_name sysname = 'your_index_name';

-- Check the rowgroups metadata
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
GO
;


-- Reorganize the index
ALTER INDEX your_index ON schema.Table REORGANIZE;
GO
;
