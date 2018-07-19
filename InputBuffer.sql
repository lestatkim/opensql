SELECT b.*, q.text, r.*
FROM sys.dm_exec_requests r
	CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) q
	CROSS APPLY sys.dm_exec_input_buffer(r.session_id, r.request_id) b
WHERE r.session_id = your_spid
