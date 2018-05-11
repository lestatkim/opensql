SELECT last_execution_time, so.name
FROM master.sys.dm_exec_query_stats qs
    CROSS APPLY sys.dm_exec_sql_text(sql_handle) st
    INNER JOIN dbo.sysobjects so
        ON so.id = st.objectid
        AND so.name = 'SaleOrder_merge';
