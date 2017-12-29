-- Run a stored procedure or query
-- EXEC dbo.uspGetEmployeeManagers 9;

-- Find the plan handle for that query 
-- OPTION (RECOMPILE) keeps this query from going into the plan cache

SELECT cp.plan_handle
    , cp.objtype
    , cp.usecounts
    DB_NAME(st.dbid) AS [DatabaseName]
FROM sys.dm_exec_cached_plans AS cp
    CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS st 
WHERE 
    -- OBJECT_NAME (st.objectid) LIKE N'%YOUR_PROCEDURE_NAME%' 
    st.text LIKE N'%TEXT_OF_YOUR_QUERY%'
OPTION (RECOMPILE)
; 

-- Remove the specific query plan from the cache using the plan handle from the above query 
-- DBCC FREEPROCCACHE 
-- (
--     0x050011007A2CC30E204991F30200000001000000000000000000000000000000000000000000000000000000
-- );
