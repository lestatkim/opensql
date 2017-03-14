
use wh_data
go

alter function dbo.ivr_monitor ()

returns @t table (
	 [Name] varchar(16)
	,[all] int
	,[empty] int
	,[wait] int
	,[empty__%] float
	,[processed__%] float
)
as 
begin
--cession
	declare @cession_all  int = (select count(*) from [INFINITY].[Cx_Work].[public].[Table_5459752341])
	declare @cession_empty int = (select count(*) from [INFINITY].[Cx_Work].[public].[Table_5459752341] where [State] is null)
	declare @cession_wait int = (select count(*) from [INFINITY].[Cx_Work].[public].[Table_5459752341] where [State] in (14, 15))

--agent
	declare @agent_all  int = (select count(*) from [INFINITY].[Cx_Work].[public].[Table_5036788937])
	declare @agent_empty int = (select count(*) from [INFINITY].[Cx_Work].[public].[Table_5036788937] where [State] is null)
	declare @agent_wait int = (select count(*) from [INFINITY].[Cx_Work].[public].[Table_5036788937] where [State] in (14, 15))

--auto_collect
	declare @ac_all  int = (select count(*) from [INFINITY].[Cx_Work].[public].[Table_5197538416])
	declare @ac_empty int = (select count(*) from [INFINITY].[Cx_Work].[public].[Table_5197538416] where [State] is null)
	declare @ac_wait int = (select count(*) from [INFINITY].[Cx_Work].[public].[Table_5197538416] where [State] in (14, 15))

--projects
	declare @projects_all  int = (select count(*) from [INFINITY].[Cx_Work].[public].[Table_5253663694])
	declare @projects_empty int = (select count(*) from [INFINITY].[Cx_Work].[public].[Table_5253663694] where [State] is null)
	declare @projects_wait int = (select count(*) from [INFINITY].[Cx_Work].[public].[Table_5253663694] where [State] in (14, 15))
	
--1_3_7
	declare @multi_all  int = (select count(*) from [INFINITY].[Cx_Work].[public].[Table_5471183067])
	declare @multi_empty int = (select count(*) from [INFINITY].[Cx_Work].[public].[Table_5471183067] where [State] is null)
	declare @multi_wait int = (select count(*) from [INFINITY].[Cx_Work].[public].[Table_5471183067] where [State] in (14, 15))

	;insert into @t (
		[Name], [all], [empty], [wait], [empty__%], [processed__%]
	)
	
		select
			 'Cession' [Name]
			,@cession_all [All]
			,@cession_empty [Empty]
			,@cession_wait [Wait]
			,round(cast(@cession_empty as float) / cast(@cession_all as float) * 100.00, 2) [empty__%]
			,round(cast((cast(@cession_all as int) - cast(@cession_empty as int)) as float) / cast(@cession_all as float) * 100.00, 2) [processed__%]
	union
		
		select
			 'Agent' [Name]
			,@agent_all [All]
			,@agent_empty [Empty]
			,@agent_wait [Wait]
			,round(cast(@agent_empty as float) / cast(@agent_all as float) * 100.00, 2) [empty__%]
			,round(cast((cast(@agent_all as int) - cast(@agent_empty as int)) as float) / cast(@agent_all as float) * 100.00, 2) [processed__%]

	union
		
		select
			 'Auto collect' [Name]
			,@ac_all [All]
			,@ac_empty [Empty]
			,@ac_wait [Wait]
			,round(cast(@ac_empty as float) / cast(@ac_all as float) * 100.00, 2) [empty__%]
			,round(cast((cast(@ac_all as int) - cast(@ac_empty as int)) as float) / cast(@ac_all as float) * 100.00, 2) [processed__%]

	union
		
		select
			 'Projects' [Name]
			,@projects_all [All]
			,@projects_empty [Empty]
			,@projects_wait [Wait]
			,round(cast(@projects_empty as float) / cast(@projects_all as float) * 100.00, 2) [empty__%]
			,round(cast((cast(@projects_all as int) - cast(@projects_empty as int)) as float) / cast(@projects_all as float) * 100.00, 2) [processed__%]

	union
		
		select
			 'Multi_prom' [Name]
			,@multi_all [All]
			,@multi_empty [Empty]
			,@multi_wait [Wait]
			,round(cast(@multi_empty as float) / cast(@multi_all as float) * 100.00, 2) [empty__%]
			,round(cast((cast(@multi_all as int) - cast(@multi_empty as int)) as float) / cast(@multi_all as float) * 100.00, 2) [processed__%]


return
end
