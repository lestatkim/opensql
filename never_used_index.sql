
-- индексы которые никогда не использовались
SELECT OBJECT_NAME(i.object_id) AS [Table Name]
    , i.name AS [Not Used Index Name]
    , s.last_user_update AS [Last Update Time]
    , s.user_updates AS [Updates]
FROM sys.dm_db_index_usage_stats AS s
    JOIN sys.indexes AS i
        ON i.object_id = s.object_id
            AND i.index_id = s.index_id
    JOIN sys.objects AS o
        ON o.object_id = s.object_id
WHERE s.database_id = DB_ID()
    AND (
        user_scans = 0
            AND user_seeks = 0
            AND user_lookups = 0
            AND last_user_scan IS NULL
            AND last_user_seek IS NULL
            AND last_user_lookup IS NULL
    )
    AND OBJECTPROPERTY(i.[object_id], 'IsSystemTable') = 0
    AND INDEXPROPERTY(i.[object_id], i.name, 'IsAutoStatistics') = 0
    AND INDEXPROPERTY(i.[object_id], i.name, 'IsHypothetical') = 0
    AND INDEXPROPERTY(i.[object_id], i.name, 'IsStatistics') = 0
    AND INDEXPROPERTY(i.[object_id], i.name, 'IsFulltextKey') = 0
    AND (
        i.index_id BETWEEN 2 AND 250
            OR (i.index_id = 1 AND OBJECTPROPERTY(i.[object_id], 'IsView') = 1)
    )
    AND o.type <> 'IT'
ORDER BY OBJECT_NAME(i.object_id);
