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
    AND tbl.name = 'MyTable'
