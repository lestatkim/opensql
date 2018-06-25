DBCC TRACEON (7412, -1)

	SELECT qs.*
	FROM sys.dm_exec_requests r
		CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) q
		CROSS APPLY sys.dm_exec_query_plan(r.plan_handle) p
		OUTER APPLY sys.dm_exec_query_statistics_xml(r.session_id) qs
	WHERE r.session_id = 159

DBCC TRACEOFF (7412, -1)
