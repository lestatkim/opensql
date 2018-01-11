select cast(SERVERPROPERTY('MachineName') as nvarchar(50)) + '\' + cast(SERVERPROPERTY('InstanceName') as nvarchar(50)) as 'server'
, session_id
, command
, percent_complete
, estimated_completion_time /(60000) [минут осталось]
, total_elapsed_time/60000 [работает]
, DATEADD(minute, estimated_completion_time/60000
, CONVERT (time(0), GETDATE())) as 'время окончания'
, SUBSTRING(b.text, CHARINDEX('[', b.text) + 1, charindex(']', b.text) - CHARINDEX('[', b.text) - 1) as 'database_name'
--, b.text
from sys.dm_exec_requests
cross apply sys.dm_exec_sql_text(dm_exec_requests.sql_handle) b
where command like '%BACKUP%' or command like '%RESTOR%' or command like '%DBCC TABLE CHECK%'
