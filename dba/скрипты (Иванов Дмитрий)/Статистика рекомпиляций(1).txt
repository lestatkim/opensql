SELECT TOP 10
qs.plan_generation_num,
qs.execution_count,
DB_NAME(st.dbid) AS DbName,
st.objectid,
st.TEXT
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(sql_handle) AS st
ORDER BY plan_generation_num DESC