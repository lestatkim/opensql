--ловим долгие процессы

use master
  go
  select
  er.session_id,
  er.blocking_session_id,
  login_name,
  [host_name],
  DB_NAME(er.database_id) as DBName,
  host_process_id,
  client_interface_name,
  es.[program_name],
  wait_time/1000 as [wait_time,s],
  last_wait_type,er.[status],wait_resource,command,
    [Individual Query] = SUBSTRING (st.text,er.statement_start_offset/2, 
     (CASE
     WHEN er.statement_end_offset = -1 THEN
  LEN(CONVERT(NVARCHAR(MAX), st.text)) * 2 
     ELSE er.statement_end_offset
      END -
  er.statement_start_offset)/2)
  ,st.objectid
  ,login_time,last_execution_time,last_request_start_time,last_request_end_time,
  cast (st.text as
  varchar(8000)) as ProcText,
  cast(pln.query_plan as xml) as [Individual Query Plan],
  er.open_transaction_count,
  execution_count as Q_execution_count,
  last_logical_reads as Q_last_logical_reads,last_logical_reads as
  Q_last_logical_reads,st.objectid,
  qp.query_plan
  ,er.percent_complete as [% выполнено]
  ,dateadd (ms, er.estimated_completion_time, getdate()) AS [Время завершения],
  creation_time as [Time plan compilation],
  qs.total_elapsed_time/1000000 as [Общее время выполнения, с],
  qs.total_worker_time/1000000 as [Общее время CPU, с],
  er.cpu_time/1000 as [CPU,s],
  er.logical_reads,
  qs.total_rows [Rows return],
  er.row_count,
  er.reads,
  er.writes,
  qs.total_logical_reads [Total logical reads],
  qs.total_physical_reads [Total physical reads],
  qs.total_logical_writes [Total logical writes],  
  qs.execution_count,
  er.transaction_isolation_level,
  er.granted_query_memory as [Grant memory page count],
  es.memory_usage as [Memory page count usage],
  CASE es.transaction_isolation_level 
  WHEN 0 THEN 'Unspecified' 
  WHEN 1 THEN 'ReadUncommitted' 
  WHEN 2 THEN 'ReadCommitted' 
  WHEN 3 THEN 'Repeatable' 
  WHEN 4 THEN 'Serializable' 
  WHEN 5 THEN 'Snapshot' END AS TRANSACTION_ISOLATION_LEVEL 
  from sys.dm_exec_requests er 
  inner join sys.dm_exec_sessions es
  on er.session_id=es.session_id 
  left join sys.dm_exec_query_stats qs
  on
  er.sql_handle=qs.sql_handle
  and er.plan_handle=qs.plan_handle
  --and qs.last_execution_time=es.last_request_start_time
  --and er.query_hash=qs.query_hash
  --and er.query_plan_hash=qs.query_plan_hash
  and er.statement_start_offset=qs.statement_start_offset
  and er.statement_end_offset=qs.statement_end_offset
  outer apply sys.dm_exec_sql_text((er.sql_handle)) st
  outer apply sys.dm_exec_query_plan((er.plan_handle)) qp
  outer APPLY sys.dm_exec_text_query_plan(er.plan_handle,
  er.statement_start_offset
  , er.statement_end_offset ) pln
  WHERE es.session_id>49 --AND es.session_id IN(160,298)
  --and last_wait_type <> 'ASYNC_NETWORK_IO'
  and last_wait_type NOT IN ('SP_SERVER_DIAGNOSTICS_SLEEP','BROKER_TASK_STOP','MISCELLANEOUS','HADR_WORK_QUEUE')
  and es.session_id<>@@spid order by start_time desc