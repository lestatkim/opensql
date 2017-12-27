SELECT DISTINCT 
	'kill '+ CAST(session_id AS VARCHAR(20)) + ';'AS 'KILL HIM =D'
	, session_id
	, qs.status
	, wait_type
	, command
	, last_wait_type
	, percent_complete
	, qt.text
	, s.[program_name]
	, s.hostname
	, s.blocked
	, total_elapsed_time / 1000 AS [total_elapsed_time, сек]
	, wait_time / 1000 AS [wait_time, сек]
    , loginame 
FROM sys.dm_exec_requests AS qs 
	LEFT JOIN sys.sysprocesses AS s ON qs.session_id = s.spid
	CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS qt
WHERE session_id >= 1 
	AND session_id != @@spid --and s.status <> 'sleeping'
	AND loginame != ''
ORDER BY [total_elapsed_time, сек] DESC

