-- Тяжелые запросы по CPU и тд.
SELECT TOP 10 SUBSTRING(qt.TEXT, (qs.statement_start_offset/2)+1,
	((CASE qs.statement_end_offset
	WHEN -1 THEN DATALENGTH(qt.TEXT)
	ELSE qs.statement_end_offset
	END - qs.statement_start_offset)/2)+1),
	qs.total_elapsed_time/1000 total_elapsed_time_ms,
	qs.last_elapsed_time/1000 last_elapsed_time_ms,
	qs.max_elapsed_time/1000 max_elapsed_time_ms,
	qs.min_elapsed_time/1000 max_elapsed_time_ms,
	qs.max_worker_time,
	qs.min_worker_time,
	qs.last_worker_time,
	qs.total_worker_time,
	qs.execution_count,
	qs.total_logical_reads, qs.last_logical_reads,
	qs.total_logical_writes, qs.last_logical_writes,
	qs.total_elapsed_time/1000000 total_elapsed_time_in_S,
	qs.last_elapsed_time/1000000 last_elapsed_time_in_S,
	qs.last_execution_time,
	CAST(qp.query_plan as XML),	
	qt.[objectid] -- по данному id можно вычислить что за объект SELECT name FROM sys.objects WHERE [object_id] = 238623893
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
WHERE qp.objectid IS NOT NULL
ORDER BY (qs.total_logical_reads + qs.total_logical_writes) / qs.execution_count DESC -- по-умолчанию
-- WHERE qs.last_ideal_grant_kb > total_grant_kb -- Найти запросы которым не хватило памяти
-- ORDER BY qs.total_logical_writes DESC -- logical writes
-- ORDER BY qs.total_worker_time DESC -- CPU time
-- ORDER BY total_elapsed_time_ms DESC -- Общее время выполнения
-- ORDER BY total_grant_kb DESC  -- по Memory
-- ORDER BY last_grant_kb * last_dop DESC -- Дорогие запросы учитывая параллелизм
