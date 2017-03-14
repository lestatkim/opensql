USE [wh_data]
GO
/****** Object:  StoredProcedure [dbo].[cession_stream_proc]    Script Date: 25.10.2016 12:09:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[cession_stream_proc] as
begin 

	declare @gd date = getdate()
	declare @cnt int, @a int, @b int
	declare @money int = 1000

	;if object_id(N'tempdb..#main_cession', 'U') is not null
		drop table #main_cession

	;if object_id(N'tempdb..#phone_cession', 'U') is not null
		drop table #phone_cession

	;if object_id(N'tempdb..#wt_cession', 'U') is not null
		drop table #wt_cession

	;if object_id(N'tempdb..#dp_cession', 'U') is not null
		drop table #dp_cession 

	;if object_id(N'tempdb..#dc_cession', 'U') is not null
		drop table #dc_cession	

	;if exists(select 1 from wh_data.dbo.cession_stream)
		delete from wh_data.dbo.cession_stream

	;if exists(select 1 from wh_data.dbo.cession_stream_2)
		delete from wh_data.dbo.cession_stream_2

-------------------------CTE START-------------------------
	--Main
		;with 
			b as (select id from i_collect.dbo.bank )
			,p as (select parent_id, id, name from i_collect.dbo.portfolio where [status] = 2)
			,d as (
				select id, r_portfolio_id rid, parent_id, currency, debt_sum
					  ,cast(isnull(iif(gmt-4 < 0, 0, gmt-4), 0) as varchar) tz
				from i_collect.dbo.debt
				where status not in (6,7,8,9,10,12,14,17)
			)
			,per as (select id from i_collect.dbo.person where typ != 2)
			,main as (
				select 
					b.id bid ,p.id pid ,d.id i ,per.id perid ,d.currency currency ,d.debt_sum debt_sum ,d.tz tz ,p.name name
				from b inner join p on p.parent_id = b.id
					 inner join d on d.rid = p.id
					 inner join per on per.id = d.parent_id
			)
		--insert General for Cession
			select * into #main_cession from main
	--Phone
		;with 
			ph as (
				select parent_id i, cast(number2 as varchar) n
				from i_collect.dbo.phone
				where
					block_flag = 0 and typ in (1, 2) and len(number2) = 11
					and substring(number2, 1, 1) in ('7', '8') and substring(number2, 2, 3) != '800'
			)
		select * into #phone_cession from ph
	--Users
		;with
			u as (
				select w.r_debt_id i
				from i_collect.dbo.work_task as w
					 left join i_collect.dbo.users as u on w.r_user_id = u.id
					 left join i_collect.dbo.department as dep on u.r_department_id = dep.dep
				where
					u.id not in (2979, 2980)
					and (
						dep.r_dep in (8, 57,59, 3, 89) or dep.name like '%Хард%' or dep.name like 'Межрегиональное взыскание'
						or dep.name = 'Управление колл-центр' or u.id in (1618, 1604,-1, 2923) or u.id is null
					)
			)
		select * into #wt_cession from u
	--Promise
		;with
			dp as (
				select parent_id i, cast(prom_date as date) dt
				from i_collect.dbo.debt_promise
				where id in (select max(id) from i_collect.dbo.debt_promise group by parent_id)
			)
		select * into #dp_cession from dp
	--Calc
		;with
			dc as (
				select parent_id i, cast(calc_date as date) dt
				from i_collect.dbo.debt_calc
				where 
					is_confirmed = 1 and is_cancel = 0
					and id in (select max(id) from i_collect.dbo.debt_calc group by parent_id)
			)
		select * into #dc_cession from dc
-------------------------CTE FINISH-------------------------
	;insert into wh_data.dbo.cession_stream (r, i, n, t, v)
			select
				 row_number() over (order by m.i asc) + 10000 r
				,cast(m.i as varchar) i ,ph.n ,m.tz ,'2' ivr
			from #main_cession m
				 inner join #phone_cession ph on ph.i = m.perid inner join #wt_cession w on w.i = m.i
				 left join #dp_cession dp on dp.i = m.i left join #dc_cession dc on dc.i = m.i
			where
				m.bid in (9, 10, 14, 49, 70, 80)
				and m.i not in (11876, 11877)
				and (m.name like '%SOFT%' or m.name like '%HARD%' or m.name like '%LEGAL%' or m.name like '%EXEC%')
				and ((m.currency = 1 and m.debt_sum > @money)  or (m.currency in (2) and m.debt_sum > (@money/63))
					or (m.currency in (3) and m.debt_sum > (@money/69))
				)
				and (dp.dt is null  or dp.dt !> dateadd(day, -3, @gd)) 
				and (dc.dt is null or dc.dt !> dateadd(month, -2, @gd))
	--count of full stream
		;set @cnt = (select count(*) from wh_data.dbo.cession_stream)
	--modulo
		;if @cnt % 2 != 0
			begin
				set @a = @cnt / 2
				set @b = @a + 1
			end
		else
			begin
				set @a = @cnt / 2
				set @b = @a
			end
	--split stream()
		;insert into wh_data.dbo.cession_stream_2 (r, i, n, t, v)
			select r, i, n, t, v
			from wh_data.dbo.cession_stream
			order by r asc
				offset @a rows
				fetch next @b rows only
		;delete from wh_data.dbo.cession_stream
			where r in (select r from wh_data.dbo.cession_stream_2)

end

