USE [wh_data]
go
/****** Object:  StoredProcedure [dbo].[Filbert_HOROVOD]    Script Date: 25.11.2016 19:44:58 ******/
SET ANSI_NULLS ON
go
SET QUOTED_IDENTIFIER ON
go
set nocount on
go

ALTER procedure [dbo].[Filbert_HOROVOD] (@n int)
AS
BEGIN
	 if object_id('tempdb..#___closed') is not null
		drop table #___closed
	;if object_id('tempdb..#___prom') is not null
		drop table #___prom
	;if object_id('tempdb..#___fixed') is not null
		drop table #___fixed
	;if object_id('tempdb..#__phone_fail') is not null
		drop table #__phone_fail
	;if object_id('tempdb..#___open_d') is not null
		drop table #___open_d
	;if object_id('tempdb..#__phone_all') is not null
	    drop table #__phone_all


	;declare @gd datetime = getdate()
	;declare @gdd date = getdate()

		
	;with
		__open_d as (
			select id i, parent_id pid, gmt
			from i_collect.dbo.debt 
			where status not in (6,7,8,10)
		)
		select * into #___open_d from __open_d
			

	;with
		_______closed_mx as (
			select max(id) id
			from profisql.i_collect.dbo.debt_status_log
			where
				cast(dt as date) !< dateadd(week, -2, cast(getdate() as date))
				and status in (6,7,8,10)
			group by parent_id
		)
		,__closed as (
			select dbl.parent_id id
			from profisql.i_collect.dbo.debt_status_log dbl
				 inner join _______closed_mx mx on mx.id = dbl.id
		)
		select * into #___closed from __closed
		
		
	;with
		__prom as (
			select dp.parent_id id
			from profisql.i_collect.dbo.debt_promise dp
			where 
				cast(dp.prom_date as date) >= @gdd
			or	cast (dp.dt as date) >= @gdd
		)
		select * into #___prom from __prom


	;with
		__fixed as (
			select distinct r_debt_id id
			from profisql.i_collect.dbo.work_task 
			where r_user_id is not null and r_user_id != -1
		)
		select * into #___fixed from __fixed


	;with
		__phone_fail as (
			select substring(number, 2, 11) n	
			from profisql.i_collect.dbo.phone ph
			where ph.status = 3
		)
		select n into #__phone_fail from __phone_fail

	;with
		__phone_all as (
			select substring(number, 2, 11) n	
			from i_collect.dbo.phone ph
			where ph.typ = 3
		)
		select n into #__phone_all from __phone_all



----------------------------------------------------------------------
--<district_1>
	if @n = 1 --конъюнктура
		begin
			 declare @del_1_full tinyint = 0
			;while @del_1_full < 7
				begin
					begin try
						delete from [INFINITY2].[Cx_Work].[public].[Table_5000081023]
							where [ID] in (
									select id from #___closed
								union
									select id from #___fixed
								union
									select id from #___prom
							)
						;break
					end try

					begin catch
						 set @del_1_full += 1
						;waitfor delay '00:00:05:000'
					end catch
				end
			
		
			;declare @i_1 tinyint = 1
			;declare @t_orig_1 varchar(16) = 'Телефон'
			;declare @t_1 varchar(16) = 'Телефон'
			;while @i_1 < 16
				begin
					set @t_1 += cast(@i_1 as varchar(4))
					declare @sql_1 varchar(512) = '
						UPDATE [INFINITY2].[Cx_Work].[public].[Table_5000081023]
						set '+@t_1+' = null
						where substring('+@t_1+', 2, 11) in (
								select n from #__phone_fail
							union
								select n from #__phone_all
							)
					'

					;declare @ie_1 tinyint = 0
					;while @ie_1 < 7
						begin
							begin try
								 exec(@sql_1)
								;break
							end try

							begin catch
								 set @ie_1 += 1
								;waitfor delay '00:00:05:000'
							end catch
						end

					set @i_1 += 1
					set @t_1 = @t_orig_1
				end

			
			;declare @del_1 tinyint = 0
			;while @del_1 < 7
				begin
					begin try
						delete from [INFINITY2].[Cx_Work].[public].Table_5000081023
						where 
								[Телефон1]	 is null
							and [Телефон2]	 is null
							and [Телефон3]	 is null
							and [Телефон4]	 is null
							and [Телефон5]	 is null
							and [Телефон6]	 is null
							and [Телефон7]	 is null
							and [Телефон8]	 is null
							and [Телефон9]	 is null
							and [Телефон10]	 is null
							and [Телефон11]	 is null
							and [Телефон12]	 is null
							and [Телефон13]	 is null
							and [Телефон14]	 is null
							and [Телефон15]	 is null
						;break
					end try

					begin catch
						 set @del_1 += 1
						;waitfor delay '00:00:05:000'
					end catch
				end
	end
			
--------------------------------
	else if @n = 11 --сортировка
		begin
			if object_id('tempdb..#tmp_campaign_11') is not null
				drop table #tmp_campaign_11
			if object_id('tempdb..#___sort1') is not null
				drop table #___sort1

			;with
				_____sort as (
					select max(c.id) id
					from i_collect.dbo.contact_log c
					where c.typ = 1
					group by c.r_debt_id
				)
				,__sort as (
					select cl.r_debt_id id ,cl.dt dt
					from i_collect.dbo.contact_log cl
						 inner join _____sort s on cl.id = s.id	
				)	
				select * into #___sort1 from __sort

			;select * into #tmp_campaign_11 from [INFINITY2].[Cx_Work].[public].[Table_5000081023]
			;delete from [INFINITY2].[Cx_Work].[public].[Table_5000081023]
			;insert into [INFINITY2].[Cx_Work].[public].[Table_5000081023] (
				 [ID]
				,[State]
				,[ID_долга]
				,[Банк]
				,[Фамилия]
				,[Имя]
				,[Отчество]
				,[Телефон1]
				,[Телефон2]
				,[Телефон3]
				,[Телефон4]
				,[Телефон5]
				,[Остаток_долга]
				,[Дата_перезвона]
				,[Часовой_пояс]
				,[Телефон_для_перезвона]
				,[Телефон6]
				,[Телефон7]
				,[Телефон8]
				,[Телефон9]
				,[Телефон10]
				,[Телефон11]
				,[Телефон12]
				,[Телефон13]
				,[Телефон14]
				,[Телефон15]
			)	
			select
				 [ID]
				,[State]
				,[ID_долга]
				,[Банк]
				,[Фамилия]
				,[Имя]
				,[Отчество]
				,[Телефон1]
				,[Телефон2]
				,[Телефон3]
				,[Телефон4]
				,[Телефон5]
				,[Остаток_долга]
				,[Дата_перезвона]
				,[Часовой_пояс]
				,[Телефон_для_перезвона]
				,[Телефон6]
				,[Телефон7]
				,[Телефон8]
				,[Телефон9]
				,[Телефон10]
				,[Телефон11]
				,[Телефон12]
				,[Телефон13]
				,[Телефон14]
				,[Телефон15]
		from #tmp_campaign_11
			 left join (select id i, dt from #___sort1)cl on #tmp_campaign_11.[ID] = cl.i
		order by cl.dt asc
		

		;update [INFINITY2].[Cx_Work].[public].Table_5000081023
			set [State] = null
			where [State] is not null		

		end


	else if @n = 12 --удаляем закрытые дела
		begin
			 declare @del_12 tinyint = 0
			;while @del_12 < 7
				begin
					begin try
						 delete from [INFINITY2].[Cx_Work].[public].[Table_5000081023]
						 where [ID] in (select id from #___closed)
						;break
					end try

					begin catch
						 set @del_12 += 1
						;waitfor delay '00:00:05:000'
					end catch
				end
		end


	else if @n = 13 --удаляем закрепленные
		begin
			 declare @del_13 tinyint = 0
			;while @del_13 < 7
				begin
					begin try
						 delete from [INFINITY2].[Cx_Work].[public].[Table_5000081023]
						 where [ID] in (select id from #___fixed)
						;break
					end try

					begin catch
						 set @del_13 += 1
						;waitfor delay '00:00:05:000'
					end catch
				end
		end


	else if @n = 14 --удаляем рабочие телефоны с учетом часового пояса !> 17
		begin
			;if object_id('tempdb..#__phone1') is not null
				drop table #__phone1
			;with
				__phone as (
					select substring(ph.number, 2, 11) num
					from i_collect.dbo.phone as ph
						 inner join #___open_d d on d.pid = ph.parent_id
					where 
						ph.typ = 3
						and (isnull(d.gmt-4, 0) + datepart(hour, @gdd)) !< 17
				)
				select * into #__phone1 from __phone

			declare @i_14 tinyint = 1
			declare @t_orig_14 varchar(16) = 'Телефон'
			declare @t_14 varchar(16) = 'Телефон'
			while @i_14 < 16
				begin
					set @t_14 += cast(@i_14 as varchar(4))
					declare @sql_14 varchar(512) = '
						UPDATE [INFINITY2].[Cx_Work].[public].[Table_5000081023]
						set '+@t_14+' = null
						where substring('+@t_14+', 2, 11) in (select n from #__phone1)
					'

					;declare @ie_14 tinyint = 0
					;while @ie_14 < 7
						begin
							begin try
								 exec (@sql_14)
								;break
							end try

							begin catch
								 set @ie_14 += 1
								;waitfor delay '00:00:05:000'
							end catch
						end

					set @i_14 += 1
					set @t_14 = @t_orig_14
				end


		;declare @del_14 tinyint = 0
		;while @del_14 < 7
			begin 
				begin try
					delete from [INFINITY2].[Cx_Work].[public].[Table_5000081023]
						where 
								[Телефон1]	 is null
							and [Телефон2]	 is null
							and [Телефон3]	 is null
							and [Телефон4]	 is null
							and [Телефон5]	 is null
							and [Телефон6]	 is null
							and [Телефон7]	 is null
							and [Телефон8]	 is null
							and [Телефон9]	 is null
							and [Телефон10]	 is null
							and [Телефон11]	 is null
							and [Телефон12]	 is null
							and [Телефон13]	 is null
							and [Телефон14]	 is null
							and [Телефон15]	 is null
						;break
					end try

					begin catch
						 set @del_14 += 1
						;waitfor delay '00:00:05:000'
					end catch
				end
		end

	else if @n = 15 --удаляем долги с обещаниями
		begin
			 declare @del_15 tinyint = 0
			;while @del_15 < 7
				begin
					begin try
						 delete from [INFINITY2].[Cx_Work].[public].Table_5000081023
						 where [ID] in (select id from #___prom)
						;break
					end try

					begin catch
						 set @del_15 += 1 
						;waitfor delay '00:00:05:000'
					end catch
				end
		end


	else if @n = 16 -- удаляем вообще все рабочие
		begin
			
			declare @i_16 tinyint = 1
			declare @t_orig_16 varchar(16) = 'Телефон'
			declare @t_16 varchar(16) = 'Телефон'
			while @i_16 < 16
			begin
				set @t_16 += cast(@i_16 as varchar(4))
				declare @sql_16 varchar(512) = '
					UPDATE [INFINITY2].[Cx_Work].[public].[Table_5000081023]
					set '+@t_16+' = null
					where substring('+@t_16+', 2, 11) in (select n from #__phone_all)
				'

				;declare @ie_16 tinyint = 0
				;while @ie_16 < 7
					begin
						begin try
							 exec (@sql_16)
							;break
						end try

						begin catch
							 set @ie_16 += 1
							;waitfor delay '00:00:05:000'
						end catch
					end

				set @i_16 += 1
				set @t_16 = @t_orig_16
			end


			;declare @del_16 tinyint = 0
			;while @del_16 < 7
				begin
					begin try
						delete from [INFINITY2].[Cx_Work].[public].[Table_5000081023]
						where 
								[Телефон1]	 is null
							and [Телефон2]	 is null
							and [Телефон3]	 is null
							and [Телефон4]	 is null
							and [Телефон5]	 is null
							and [Телефон6]	 is null
							and [Телефон7]	 is null
							and [Телефон8]	 is null
							and [Телефон9]	 is null
							and [Телефон10]	 is null
							and [Телефон11]	 is null
							and [Телефон12]	 is null
							and [Телефон13]	 is null
							and [Телефон14]	 is null
							and [Телефон15]	 is null
						;break
					end try

					begin catch
						 set @del_16 += 1
						;waitfor delay '00:00:05:000'
					end catch
				end
		end
		
	else if @n = 17 --удаляем все телефоны со статусом неверный номер
		begin
			declare @i_17 tinyint = 1
			declare @t_orig_17 varchar(16) = 'Телефон'
			declare @t_17 varchar(16) = 'Телефон'
			--declare @i varchar(4) = '3'
			while @i_17 < 16
			begin
				set @t_17 += cast(@i_17 as varchar(4))
				declare @sql_17 varchar(512) = '
					UPDATE [INFINITY2].[Cx_Work].[public].[Table_5000081023]
					set '+@t_17+' = null
					where substring('+@t_17+', 2, 11) in (select n from #__phone_fail)
				'

				;declare @ie_17 tinyint = 0
				;while @ie_17 < 7
					begin
						begin try
							 exec (@sql_17)
							;break
						end try

						begin catch
							 set @ie_17 += 1
							;waitfor delay '00:00:05:000'
						end catch
					end

				set @i_17 += 1
				set @t_17 = @t_orig_17
			end

			
			;declare @del_17 tinyint = 0
			;while @del_17 < 17
				begin
					begin try
						delete from [INFINITY2].[Cx_Work].[public].[Table_5000081023]
						where 
								[Телефон1]	is null
							and [Телефон2]	is null
							and [Телефон3]	is null
							and [Телефон4]	is null
							and [Телефон5]	is null
							and [Телефон6]	is null
							and [Телефон7]	is null
							and [Телефон8]	is null
							and [Телефон9]	is null
							and [Телефон10]	is null
							and [Телефон11]	is null
							and [Телефон12]	is null
							and [Телефон13]	is null
							and [Телефон14]	is null
							and [Телефон15]	is null
						;break
					end try

					begin catch
						 set @del_17 += 1
						;waitfor delay '00:00:05:000'
					end catch
				end
		end



	else if @n = 18
		begin
			update [INFINITY2].[Cx_Work].[public].[Table_5000081023]
				set [State] = null
				where [State] is not null
		end
	
--</district_1>
----------------------------------------------------------------------

--<district_2>
	else if @n = 2 --конъюнктура
		begin
		
		;declare @del_2_full tinyint = 0
		;while @del_2_full < 7
			begin
				begin try
					delete from [INFINITY2].[Cx_Work].[public].[Table_5000081044]
							where [ID] in (
									select id from #___closed
								union
									select id from #___fixed
								union
									select id from #___prom
							)
					;break
				end try

				begin catch
					 set @del_2_full += 1
					;waitfor delay '00:00:05:000'
				end catch
			end
			
		
		;declare @i_2 tinyint = 1
		;declare @t_orig_2 varchar(16) = 'Телефон'
		;declare @t_2 varchar(16) = 'Телефон'
		;while @i_2 < 16
			begin
				set @t_2 += cast(@i_2 as varchar(4))
				declare @sql_2 varchar(512) = '
					UPDATE [INFINITY2].[Cx_Work].[public].[Table_5000081044]
					set '+@t_2+' = null
					where substring('+@t_2+', 2, 11) in (
							select n from #__phone_fail
							union
							select n from #__phone_all
						)
				'

				;declare @ie_2 tinyint = 0
				;while @ie_2 < 7
					begin
						begin try
							 exec (@sql_2)
							;break
						end try

						begin catch
							 set @ie_2 += 1
							;waitfor delay '00:00:05:000'
						end catch
					end

				set @i_2 += 1
				set @t_2 = @t_orig_2
			end

		
		;declare @del_2 tinyint = 0
		;while @del_2 < 7
			begin
				begin try
					delete from [INFINITY2].[Cx_Work].[public].Table_5000081044
					where 
							[Телефон1]	is null
						and [Телефон2]	is null
						and [Телефон3]	is null
						and [Телефон4]	is null
						and [Телефон5]	is null
						and [Телефон6]	is null
						and [Телефон7]	is null
						and [Телефон8]	is null
						and [Телефон9]	is null
						and [Телефон10]	is null
						and [Телефон11]	is null
						and [Телефон12]	is null
						and [Телефон13]	is null
						and [Телефон14]	is null
						and [Телефон15]	is null
					;break
				end try

				begin catch
					 set @del_2 += 1
					;waitfor delay '00:00:05:000'
				end catch
			end
	end

	else if @n = 21 --сортировка
		begin
		if object_id('tempdb..#tmp_campaign_21') is not null
			drop table #tmp_campaign_21
		;if object_id('tempdb..#___sort2') is not null
				drop table #___sort2
		;with
			_____sort as (
				select max(c.id) id
				from i_collect.dbo.contact_log c
				where c.typ = 1
				group by c.r_debt_id
			)
			,__sort as (
				select cl.r_debt_id id ,cl.dt dt
				from i_collect.dbo.contact_log cl
					 inner join _____sort s on cl.id = s.id	
			)	
			select * into #___sort2 from __sort

				;select * into #tmp_campaign_21 from [INFINITY2].[Cx_Work].[public].[Table_5000081044]
				;delete from [INFINITY2].[Cx_Work].[public].[Table_5000081044]
				;insert into [INFINITY2].[Cx_Work].[public].[Table_5000081044] (
					 [ID]
					,[State]
					,[ID_долга]
					,[Банк]
					,[Фамилия]
					,[Имя]
					,[Отчество]
					,[Телефон1]
					,[Телефон2]
					,[Телефон3]
					,[Телефон4]
					,[Телефон5]
					,[Остаток_долга]
					,[Дата_перезвона]
					,[Часовой_пояс]
					,[Телефон_для_перезвона]
					,[Телефон6]
					,[Телефон7]
					,[Телефон8]
					,[Телефон9]
					,[Телефон10]
					,[Телефон11]
					,[Телефон12]
					,[Телефон13]
					,[Телефон14]
					,[Телефон15]
					,[КолПопыток]
					,[ПерсональныйОпер]
				)
				select
					 [ID]
					,[State]
					,[ID_долга]
					,[Банк]
					,[Фамилия]
					,[Имя]
					,[Отчество]
					,[Телефон1]
					,[Телефон2]
					,[Телефон3]
					,[Телефон4]
					,[Телефон5]
					,[Остаток_долга]
					,[Дата_перезвона]
					,[Часовой_пояс]
					,[Телефон_для_перезвона]
					,[Телефон6]
					,[Телефон7]
					,[Телефон8]
					,[Телефон9]
					,[Телефон10]
					,[Телефон11]
					,[Телефон12]
					,[Телефон13]
					,[Телефон14]
					,[Телефон15]
					,[КолПопыток]
					,[ПерсональныйОпер]
				from
					#tmp_campaign_21
					left join (select id i, dt from #___sort2)cl on #tmp_campaign_21.[ID] = cl.i
				order by
					cl.dt asc


				;UPDATE [INFINITY2].[Cx_Work].[public].[Table_5000081044]
					set [State] = null
					where [State] is not null
		end

	else if @n = 22 --удаляем закрытые дела
		begin
			declare @del_22 tinyint = 0
			;while @del_22 < 7
				begin
					begin try
						 delete from [INFINITY2].[Cx_Work].[public].[Table_5000081044]
						 where [ID] in (select id from #___closed)
						;break
					end try

					begin catch
						 set @del_22 += 1
						;waitfor delay '00:00:05:000'
					end catch
				end
		end


	else if @n = 23 --удаляем закрепленные
		begin
			 declare @del_23 tinyint = 0
			;while @del_23 < 7
				begin 
					begin try
						 delete from [INFINITY2].[Cx_Work].[public].[Table_5000081044]
						 where [ID] in (select id from #___fixed)
						;break
					end try

					begin catch
						 set @del_23 += 1
						;waitfor delay '00:00:05:000'
					end catch
				end
		end


	else if @n = 24 --удаляем рабочие телефоны с учетом часового пояса !> 17
		begin
			;if object_id('tempdb..#__phone2') is not null
				drop table #__phone2
			;with
				__phone as (
					select substring(ph.number, 2, 11) num
					from i_collect.dbo.phone as ph
						 inner join #___open_d d on d.pid = ph.parent_id
					where 
						ph.typ = 3
						and (isnull(d.gmt-4, 0) + datepart(hour, @gdd)) !< 17
				)
				select * into #__phone2 from __phone

			declare @i_24 tinyint = 1
			declare @t_orig_24 varchar(16) = 'Телефон'
			declare @t_24 varchar(16) = 'Телефон'
			while @i_24 < 16
				begin
					set @t_24 += cast(@i_24 as varchar(4))
					declare @sql_24 varchar(512) = '
						UPDATE [INFINITY2].[Cx_Work].[public].[Table_5000081044]
						set '+@t_24+' = null
						where substring('+@t_24+', 2, 11) in (select n from #__phone2)
					'

					;declare @ie_24 tinyint = 0
					;while @ie_24 < 7
						begin
							begin try
								 exec (@sql_24)
								;break
							end try

							begin catch
								 set @ie_24 += 1
								;waitfor delay '00:00:05:000'
							end catch
						end

					set @i_24 += 1
					set @t_24 = @t_orig_24
				end


		;declare @del_24 tinyint = 0
		;while @del_24 < 7
			begin
				begin try
					delete from [INFINITY2].[Cx_Work].[public].[Table_5000081044]
						where 
								[Телефон1]	is null
							and [Телефон2]	is null
							and [Телефон3]	is null
							and [Телефон4]	is null
							and [Телефон5]	is null
							and [Телефон6]	is null
							and [Телефон7]	is null
							and [Телефон8]	is null
							and [Телефон9]	is null
							and [Телефон10]	is null
							and [Телефон11]	is null
							and [Телефон12]	is null
							and [Телефон13]	is null
							and [Телефон14]	is null
							and [Телефон15]	is null
					;break
				end try

				begin catch
					 set @del_24 += 1
					;waitfor delay '00:00:05:000'
				end catch
			end
		end

	else if @n = 25 --удаляем долги с обещаниями
		begin
			 declare @del_25 tinyint = 0
			;while @del_25 < 7
				begin
					begin try
						 delete from [INFINITY2].[Cx_Work].[public].[Table_5000081044]
						 where [ID] in (select id from #___prom)
						;break
					end try

					begin catch
						 set @del_25 += 1
						;waitfor delay '00:00:05:000'
					end catch
				end
		end

	else if @n = 26
		begin

			declare @i_26 tinyint = 1
			declare @t_orig_26 varchar(16) = 'Телефон'
			declare @t_26 varchar(16) = 'Телефон'
			while @i_26 < 16
			begin
				set @t_26 += cast(@i_26 as varchar(4))
				declare @sql_26 varchar(512) = '
					UPDATE [INFINITY2].[Cx_Work].[public].[Table_5000081044]
					set '+@t_26+' = null
					where substring('+@t_26+', 2, 11) in (select n from #__phone_all)
				'

				;declare @ie_26 tinyint = 0
				;while @ie_26 < 7
					begin
						begin try
							 exec (@sql_26)
							;break
						end try

						begin catch
							 set @ie_26 += 1
							;waitfor delay '00:00:05:000'
						end catch
					end

				set @i_26 += 1
				set @t_26 = @t_orig_26
			end		

			
			;declare @del_26 tinyint = 0
			;while @del_26 < 7
				begin
					begin try
						delete from [INFINITY2].[Cx_Work].[public].[Table_5000081044]
						where 
								[Телефон1]	is null
							and [Телефон2]	is null
							and [Телефон3]	is null
							and [Телефон4]	is null
							and [Телефон5]	is null
							and [Телефон6]	is null
							and [Телефон7]	is null
							and [Телефон8]	is null
							and [Телефон9]	is null
							and [Телефон10]	is null
							and [Телефон11]	is null
							and [Телефон12]	is null
							and [Телефон13]	is null
							and [Телефон14]	is null
							and [Телефон15]	is null
						;break
					end try

					begin catch
						 set @del_26 += 1
						;waitfor delay '00:00:05:000'
					end catch
				end
		end
	
	else if @n = 27
		begin
			declare @i_27 tinyint = 1
			declare @t_orig_27 varchar(16) = 'Телефон'
			declare @t_27 varchar(16) = 'Телефон'
			while @i_27 < 16
				begin
					set @t_27 += cast(@i_27 as varchar(4))
					declare @sql_27 varchar(512) = '
						UPDATE [INFINITY2].[Cx_Work].[public].[Table_5000081044]
						set '+@t_27+' = null
						where substring('+@t_27+', 2, 11) in (select n from #__phone_fail)
					'

					;declare @ie_27 tinyint = 0
					;while @ie_27 < 7
						begin
							begin try
								 exec (@sql_27)
								;break
							end try

							begin catch
								 set @ie_27 += 1
								;waitfor delay '00:00:05:000'
							end catch
						end

					set @i_27 += 1
					set @t_27 = @t_orig_27
				end

			;declare @del_27 tinyint = 0
			;while @del_27 < 7
				begin
					begin try
						delete from [INFINITY2].[Cx_Work].[public].[Table_5000081044]
						where 
								[Телефон1]	is null
							and [Телефон2]	is null
							and [Телефон3]	is null
							and [Телефон4]	is null
							and [Телефон5]	is null
							and [Телефон6]	is null
							and [Телефон7]	is null
							and [Телефон8]	is null
							and [Телефон9]	is null
							and [Телефон10]	is null
							and [Телефон11]	is null
							and [Телефон12]	is null
							and [Телефон13]	is null
							and [Телефон14]	is null
							and [Телефон15]	is null
						;break
					end try

					begin catch
						 set @del_27 += 1
						;waitfor delay '00:00:05:000'
					end catch
				end
		end



	else if @n = 28
		begin
			update [INFINITY2].[Cx_Work].[public].[Table_5000081044]
				set [State] = null
				where [State] is not null
		end
--</district_2>
----------------------------------------------------------------------
--<district_3>
	else if @n = 3 --конъюнктура
		begin
			;declare @del_3_full tinyint = 0
			;while @del_3_full < 7
				begin
					begin try
						delete from [INFINITY2].[Cx_Work].[public].Table_5015640658
							where [ID] in (
									select id from #___closed
								union
									select id from #___fixed
								union
									select id from #___prom
							)
						;break
					end try

					begin catch
						 set @del_3_full += 1
						;waitfor delay '00:00:05:000'
					end catch
				end
			
		
			;declare @i_3 tinyint = 1
			;declare @t_orig_3 varchar(16) = 'Телефон'
			;declare @t_3 varchar(16) = 'Телефон'
			;while @i_3 < 16
				begin
					set @t_3 += cast(@i_3 as varchar(4))
					declare @sql_3 varchar(512) = '
						UPDATE [INFINITY2].[Cx_Work].[public].[Table_5015640658]
						set '+@t_3+' = null
						where substring('+@t_3+', 2, 11) in (
								select n from #__phone_fail
								union
								select n from #__phone_all
							)
					'

					;declare @ie_3 tinyint = 0
					;while @ie_3 < 7
						begin
							begin try
								 exec (@sql_3)
								;break
							end try

							begin catch
								 set @ie_3 += 1
								;waitfor delay '00:00:05:000'
							end catch
						end

					set @i_3 += 1
					set @t_3 = @t_orig_3
				end

			
			;declare @del_3 tinyint = 0
			;while @del_3 < 7
				begin
					begin try			
						delete from [INFINITY2].[Cx_Work].[public].Table_5015640658
						where 
								[Телефон1]	is null
							and [Телефон2]	is null
							and [Телефон3]	is null
							and [Телефон4]	is null
							and [Телефон5]	is null
							and [Телефон6]	is null
							and [Телефон7]	is null
							and [Телефон8]	is null
							and [Телефон9]	is null
							and [Телефон10]	is null
							and [Телефон11]	is null
							and [Телефон12]	is null
							and [Телефон13]	is null
							and [Телефон14]	is null
							and [Телефон15]	is null
						;break
					end try

					begin catch
						 set @del_3 += 1
						;waitfor delay '00:00:05:000'
					end catch
				end
		end

	else if @n = 31 --сортировка
		begin
			if object_id('tempdb..#tmp_campaign_31') is not null
				drop table #tmp_campaign_31
			;if object_id('tempdb..#___sort3') is not null
				drop table #___sort3

			;with
				_____sort as (
					select max(c.id) id
					from i_collect.dbo.contact_log c
					where c.typ = 1
					group by c.r_debt_id
				)
				,__sort as (
					select cl.r_debt_id id ,cl.dt dt
					from i_collect.dbo.contact_log cl
						 inner join _____sort s on cl.id = s.id	
				)	
				select * into #___sort3 from __sort

			;select * into #tmp_campaign_31 from [INFINITY2].[Cx_Work].[public].[Table_5015640658]
			;delete from [INFINITY2].[Cx_Work].[public].[Table_5015640658]
			;insert into [INFINITY2].[Cx_Work].[public].[Table_5015640658] (
				 [ID]
				,[State]
				,[ID_долга]
				,[Банк]
				,[Фамилия]
				,[Имя]
				,[Отчество] 
				,[Телефон1] 
				,[Телефон2] 
				,[Телефон3] 
				,[Телефон4] 
				,[Телефон5] 
				,[Телефон6] 
				,[Телефон7] 
				,[Телефон8] 
				,[Телефон9] 
				,[Телефон10]
				,[Телефон11]
				,[Телефон12]
				,[Телефон13]
				,[Телефон14]
				,[Телефон15]
				,[Остаток_долга]
				,[Дата_перезвона]
				,[Часовой_пояс]
				,[Телефон_для_перезвона]
				,[ПерсональныйОпер]				
			)
			select
				 [ID]
				,[State]
				,[ID_долга]
				,[Банк]
				,[Фамилия]
				,[Имя]
				,[Отчество] 
				,[Телефон1] 
				,[Телефон2] 
				,[Телефон3] 
				,[Телефон4] 
				,[Телефон5] 
				,[Телефон6] 
				,[Телефон7] 
				,[Телефон8] 
				,[Телефон9] 
				,[Телефон10]
				,[Телефон11]
				,[Телефон12]
				,[Телефон13]
				,[Телефон14]
				,[Телефон15]
				,[Остаток_долга]
				,[Дата_перезвона]
				,[Часовой_пояс]
				,[Телефон_для_перезвона]
				,[ПерсональныйОпер]	
			from
				#tmp_campaign_31
				left join (select id i, dt from #___sort3)cl on #tmp_campaign_31.[ID] = cl.i
			order by
				cl.dt asc


			;update [INFINITY2].[Cx_Work].[public].Table_5015640658
				set [State] = null
				where [State] is not null
		end

	else if @n = 32 --удаляем закрытые дела
		begin
			declare @del_32 tinyint = 0
			;while @del_32 < 7
				begin
					begin try
						 delete from [INFINITY2].[Cx_Work].[public].[Table_5015640658]
						 where [ID] in (select id from #___closed)
						;break
					end try

					begin catch
						 set @del_32 += 1
						;waitfor delay '00:00:05:000'
					end catch
				end
		end


	else if @n = 33 --удаляем закрепленные
		begin
			 declare @del_33 tinyint = 0
			;while @del_33 < 7
				begin
					begin try
						 delete from [INFINITY2].[Cx_Work].[public].[Table_5015640658]
						 where [ID] in (select id from #___fixed)
						;break
					end try

					begin catch
						 set @del_33 += 1
						;waitfor delay '00:00:05:000'
					end catch
				end
		end


	else if @n = 34 --удаляем рабочие телефоны с учетом часового пояса !> 17
		begin
			;if object_id('tempdb..#__phone3') is not null
				drop table #__phone3
			;with
				__phone as (
					select substring(ph.number, 2, 11) num
					from i_collect.dbo.phone as ph
						 inner join #___open_d d on d.pid = ph.parent_id
					where 
						ph.typ = 3
						and (isnull(d.gmt-4, 0) + datepart(hour, @gdd)) !< 17
				)
				select * into #__phone3 from __phone

			declare @i_34 tinyint = 1
			declare @t_orig_34 varchar(16) = 'Телефон'
			declare @t_34 varchar(16) = 'Телефон'
			while @i_34 < 16
				begin
					set @t_34 += cast(@i_34 as varchar(4))
					declare @sql_34 varchar(512) = '
						UPDATE [INFINITY2].[Cx_Work].[public].[Table_5015640658]
						set '+@t_34+' = null
						where substring('+@t_34+', 2, 11) in (select n from #__phone3)
					'

					;declare @ie_34 tinyint = 0
					;while @ie_34 < 7
						begin 
							begin try
								 exec (@sql_34)
								;break
							end try

							begin catch
								 set @ie_34 += 1
								;waitfor delay '00:00:05:000'
							end catch
						end

					set @i_34 += 1
					set @t_34 = @t_orig_34
				end	


			;declare @del_34 tinyint = 0
			;while @del_34 < 7
				begin
					begin try
						delete from [INFINITY2].[Cx_Work].[public].[Table_5015640658]
						where 
								[Телефон1]	is null
							and [Телефон2]	is null
							and [Телефон3]	is null
							and [Телефон4]	is null
							and [Телефон5]	is null
							and [Телефон6]	is null
							and [Телефон7]	is null
							and [Телефон8]	is null
							and [Телефон9]	is null
							and [Телефон10]	is null
							and [Телефон11]	is null
							and [Телефон12]	is null
							and [Телефон13]	is null
							and [Телефон14]	is null
							and [Телефон15]	is null
						;break
					end try

					begin catch
						 set @del_34 += 1
						;waitfor delay '00:00:05:000'
					end catch
				end
		end


	else if @n = 35 --удаляем долги с обещаниями
		begin
			 declare @del_35 tinyint = 0
			;while @del_35 < 7
				begin 
					begin try
						 delete from [INFINITY2].[Cx_Work].[public].[Table_5015640658]
						 where [ID] in (select id from #___prom)		
						;break
					end try

					begin catch
						 set @del_35 += 1
						;waitfor delay '00:00:05:000'
					end catch
				end
		end

	else if @n = 36 --#__phone_all
		begin
			declare @i_36 tinyint = 1
			declare @t_orig_36 varchar(16) = 'Телефон'
			declare @t_36 varchar(16) = 'Телефон'
			while @i_36 < 16
				begin
					set @t_36 += cast(@i_36 as varchar(4))
					declare @sql_36 varchar(512) = '
						UPDATE [INFINITY2].[Cx_Work].[public].[Table_5015640658]
						set '+@t_36+' = null
						where substring('+@t_36+', 2, 11) in (select n from #__phone_all)
					'

					;declare @ie_36 tinyint = 0
					;while @ie_36 < 7
						begin
							begin try
								exec (@sql_36)
								;break
							end try

							begin catch
								 set @ie_36 += 1
								;waitfor delay '00:00:05:000'
							end catch
						end

					set @i_36 += 1
					set @t_36 = @t_orig_36
				end

			;declare @del_36 tinyint = 0
			;while @del_36 < 7
				begin
					begin try
						delete from [INFINITY2].[Cx_Work].[public].[Table_5015640658]
						where 
								[Телефон1]	is null
							and [Телефон2]	is null
							and [Телефон3]	is null
							and [Телефон4]	is null
							and [Телефон5]	is null
							and [Телефон6]	is null
							and [Телефон7]	is null
							and [Телефон8]	is null
							and [Телефон9]	is null
							and [Телефон10]	is null
							and [Телефон11]	is null
							and [Телефон12]	is null
							and [Телефон13]	is null
							and [Телефон14]	is null
							and [Телефон15]	is null
						;break
					end try

					begin catch
						 set @del_36 += 1
						;waitfor delay '00:00:05:000'
					end catch
				end
		end

	else if @n = 37
		begin		
			declare @i_37 tinyint = 1
			declare @t_orig_37 varchar(16) = 'Телефон'
			declare @t_37 varchar(16) = 'Телефон'
			while @i_37 < 16
				begin
					set @t_37 += cast(@i_37 as varchar(4))
					declare @sql_37 varchar(512) = '
						UPDATE [INFINITY2].[Cx_Work].[public].[Table_5015640658]
						set '+@t_37+' = null
						where substring('+@t_37+', 2, 11) in (select n from #__phone_fail)
					'

					;declare @ie_37 tinyint = 0
					;while @ie_37 < 7
						begin
							begin try
								 exec (@sql_37)
								;break
							end try

							begin catch
								 set @ie_37 += 1
								;waitfor delay '00:00:05:000'
							end catch
						end

					set @i_37 += 1
					set @t_37 = @t_orig_37
				end


			;declare @del_37 tinyint = 0
			;while @del_37 < 7
				begin
					begin try
						delete from [INFINITY2].[Cx_Work].[public].[Table_5015640658]
						where 
								[Телефон1]	is null
							and [Телефон2]	is null
							and [Телефон3]	is null
							and [Телефон4]	is null
							and [Телефон5]	is null
							and [Телефон6]	is null
							and [Телефон7]	is null
							and [Телефон8]	is null
							and [Телефон9]	is null
							and [Телефон10]	is null
							and [Телефон11]	is null
							and [Телефон12]	is null
							and [Телефон13]	is null
							and [Телефон14]	is null
							and [Телефон15]	is null
						;break
					end try

					begin catch
						 set @del_37 += 1
						;waitfor delay '00:00:05:000'
					end catch
				end
		end



	else if @n = 38
		begin
			update [INFINITY2].[Cx_Work].[public].[Table_5015640658]
				set [State] = null
				where [State] is not null
		end
--</district_3>
----------------------------------------------------------------------
--<district_4>
	else if @n = 4 --конъюнктура
		begin
		
			;declare @del_4_full tinyint = 0
			;while @del_4_full < 7
				begin
					begin try
						delete from [INFINITY2].[Cx_Work].[public].[Table_5042218921]
							where [ID] in (
									select id from #___closed
								union
									select id from #___fixed
								union
									select id from #___prom
							)
						;break
					end try

					begin catch
						 set @del_4_full += 1
						;waitfor delay '00:00:05:000'
					end catch
				end
			
		
			;declare @i_4 tinyint = 1
			;declare @t_orig_4 varchar(16) = 'Телефон'
			;declare @t_4 varchar(16) = 'Телефон'
			;while @i_4 < 16
				begin
					set @t_4 += cast(@i_4 as varchar(4))
					declare @sql_4 varchar(512) = '
						UPDATE [INFINITY2].[Cx_Work].[public].[Table_5042218921]
						set '+@t_4+' = null
						where substring('+@t_4+', 2, 11) in (
								select n from #__phone_fail
								union
								select n from #__phone_all
							)
					'

					;declare @ie_4 tinyint = 0
					;while @ie_4 < 7
						begin
							begin try
								 exec (@sql_4)
								;break
							end try

							begin catch
								 set @ie_4 += 1
								;waitfor delay '00:00:05:000'
							end catch
						end

					set @i_4 += 1
					set @t_4 = @t_orig_4
				end

			;declare @del_4 tinyint = 0
			;while @del_4 < 7
				begin
					begin try			
						delete from [INFINITY2].[Cx_Work].[public].[Table_5042218921]
						where 
								[Телефон1]	is null
							and [Телефон2]	is null
							and [Телефон3]	is null
							and [Телефон4]	is null
							and [Телефон5]	is null
							and [Телефон6]	is null
							and [Телефон7]	is null
							and [Телефон8]	is null
							and [Телефон9]	is null
							and [Телефон10] is null
							and [Телефон11] is null
							and [Телефон12] is null
							and [Телефон13] is null
							and [Телефон14] is null
							and [Телефон15] is null
						;break
					end try

					begin catch
						 set @del_4 += 1
						;waitfor delay '00:00:05:000'
					end catch
				end
		end


	else if @n = 41 --сортировка
		begin
			if object_id('tempdb..#tmp_campaign_41') is not null
				drop table #tmp_campaign_41
			;if object_id('tempdb..#___sort4') is not null
				drop table #___sort4
			;with
				_____sort as (
					select max(c.id) id
					from i_collect.dbo.contact_log c
					where c.typ = 1
					group by c.r_debt_id
				)
				,__sort as (
					select cl.r_debt_id id ,cl.dt dt
					from i_collect.dbo.contact_log cl
						 inner join _____sort s on cl.id = s.id	
				)	
				select * into #___sort4 from __sort

			;select * into #tmp_campaign_41 from [INFINITY2].[Cx_Work].[public].[Table_5042218921]
			;delete from [INFINITY2].[Cx_Work].[public].[Table_5042218921]
			;insert into [INFINITY2].[Cx_Work].[public].[Table_5042218921] (
				 [ID]
				,[State]
				,[ID_долга]
				,[Банк]
				,[Фамилия]
				,[Имя]
				,[Отчество]
				,[Телефон1]
				,[Телефон2]
				,[Телефон3]
				,[Телефон4]
				,[Телефон5]
				,[Телефон6]
				,[Телефон7]
				,[Телефон8]
				,[Телефон9]
				,[Телефон10]
				,[Телефон11]
				,[Телефон12]
				,[Телефон13]
				,[Телефон14]
				,[Телефон15]
				,[Остаток_долга]
				,[Дата_перезвона]
				,[Часовой_пояс]
				,[Телефон_для_перезвона]
				,[ПерсональныйОператор]
			)
			select
				 [ID]
				,[State]
				,[ID_долга]
				,[Банк]
				,[Фамилия]
				,[Имя]
				,[Отчество]
				,[Телефон1]
				,[Телефон2]
				,[Телефон3]
				,[Телефон4]
				,[Телефон5]
				,[Телефон6]
				,[Телефон7]
				,[Телефон8]
				,[Телефон9]
				,[Телефон10]
				,[Телефон11]
				,[Телефон12]
				,[Телефон13]
				,[Телефон14]
				,[Телефон15]
				,[Остаток_долга]
				,[Дата_перезвона]
				,[Часовой_пояс]
				,[Телефон_для_перезвона]
				,[ПерсональныйОператор]
			from
				#tmp_campaign_41
				left join (select id i, dt from #___sort4)cl on #tmp_campaign_41.[ID] = cl.i
			order by
				cl.dt asc

			
			;update [INFINITY2].[Cx_Work].[public].[Table_5042218921]
				set [State] = null
				where [State] is not null
		end


	else if @n = 42 --удаляем закрытые дела
		begin
			 declare @del_42 tinyint = 0
			;while @del_42 < 7
				begin
					begin try
						 delete from [INFINITY2].[Cx_Work].[public].[Table_5042218921]
						 where [ID] in (select id from #___closed)
						;break
					end try

					begin catch
						 set @del_42 += 1
						;waitfor delay '00:00:05:000'
					end catch
				end
		end

	else if @n = 43 --удаляем закрепленные
		begin
			 declare @del_43 tinyint = 0
			;while @del_43 < 7
				begin
					begin try
						 delete from [INFINITY2].[Cx_Work].[public].[Table_5042218921]
						 where [ID] in (select id from #___fixed)
						;break
					end try

					begin catch
						 set @del_43 += 1
						;waitfor delay '00:00:05:000'
					end catch
				end
		end


	else if @n = 44 --удаляем рабочие телефоны с учетом часового пояса !> 17
		begin	
			;if object_id('tempdb..#__phone4') is not null
				drop table #__phone4
			;with
				__phone as (
					select substring(ph.number, 2, 11) num
					from i_collect.dbo.phone as ph
						 inner join #___open_d d on d.pid = ph.parent_id
					where 
						ph.typ = 3
						and (isnull(d.gmt-4, 0) + datepart(hour, @gdd)) !< 17
				)
				select * into #__phone4 from __phone

			declare @i_44 tinyint = 1
			declare @t_orig_44 varchar(16) = 'Телефон'
			declare @t_44 varchar(16) = 'Телефон'
			while @i_44 < 16
				begin
					set @t_44 += cast(@i_44 as varchar(4))
					declare @sql_44 varchar(512) = '
						UPDATE [INFINITY2].[Cx_Work].[public].[Table_5042218921]
						set '+@t_44+' = null
						where substring('+@t_44+', 2, 11) in (select n from #__phone4)
					'

					;declare @ie_44 tinyint = 0
					;while @ie_44 < 7
						begin
							begin try
								 exec (@sql_44)
								;break
							end try

							begin catch
								 set @ie_44 += 1
								;waitfor delay '00:00:05:000'
							end catch
						end

					set @i_44 += 1
					set @t_44 = @t_orig_44
				end


			;declare @del_44 tinyint = 0
			;while @del_44 < 7
				begin
					begin try
						delete from [INFINITY2].[Cx_Work].[public].[Table_5042218921]
						where
								[Телефон1]	is null
							and [Телефон2]	is null
							and [Телефон3]	is null
							and [Телефон4]	is null
							and [Телефон5]	is null
							and [Телефон6]	is null
							and [Телефон7]	is null
							and [Телефон8]	is null
							and [Телефон9]	is null
							and [Телефон10]	is null
							and [Телефон11]	is null
							and [Телефон12]	is null
							and [Телефон13]	is null
							and [Телефон14]	is null
							and [Телефон15]	is null
						;break
					end try

					begin catch
						 set @del_44 += 1
						;waitfor delay '00:00:05:000'
					end catch
				end
		end


	else if @n = 45 --удаляем долги с обещаниями
		begin
			 declare @del_45 tinyint = 0
			;while @del_45 < 7
				begin
					begin try
						 delete from [INFINITY2].[Cx_Work].[public].[Table_5042218921]
						 where [ID] in (select id from #___prom)	
						;break
					end try

					begin catch
						 set @del_45 += 1
						;waitfor delay '00:00:05:000'
					end catch
				end
		end

	else if @n = 46
		begin
			declare @i_46 tinyint = 1
			declare @t_orig_46 varchar(16) = 'Телефон'
			declare @t_46 varchar(16) = 'Телефон'
			while @i_46 < 16
				begin
					set @t_46 += cast(@i_46 as varchar(4))
					declare @sql_46 varchar(512) = '
						UPDATE [INFINITY2].[Cx_Work].[public].[Table_5042218921]
						set '+@t_46+' = null
						where substring('+@t_46+', 2, 11) in (select n from #__phone_all)
					'

					;declare @ie_46 tinyint = 0
					;while @ie_46 < 7
						begin
							begin try
								 exec (@sql_46)
								;break
							end try

							begin catch
								 set @ie_46 += 1
								;waitfor delay '00:00:05:000'
							end catch
						end

					set @i_46 += 1
					set @t_46 = @t_orig_46
				end


			;declare @del_46 tinyint = 0
			;while @del_46 < 7
				begin
					begin try
						delete from [INFINITY2].[Cx_Work].[public].[Table_5042218921]
						where 
								[Телефон1]	is null
							and [Телефон2]	is null
							and [Телефон3]	is null
							and [Телефон4]	is null
							and [Телефон5]	is null
							and [Телефон6]	is null
							and [Телефон7]	is null
							and [Телефон8]	is null
							and [Телефон9]	is null
							and [Телефон10]	is null
							and [Телефон11]	is null
							and [Телефон12]	is null
							and [Телефон13]	is null
							and [Телефон14]	is null
							and [Телефон15]	is null
						;break
					end try

					begin catch
						 set @del_46 += 1
						;waitfor delay '00:00:05:000'
					end catch
				end
		end

	
	else if @n = 47
		begin
		
			declare @i_47 tinyint = 1
			declare @t_orig_47 varchar(16) = 'Телефон'
			declare @t_47 varchar(16) = 'Телефон'
			while @i_47 < 16
				begin
					set @t_47 += cast(@i_47 as varchar(4))
					declare @sql_47 varchar(512) = '
						UPDATE [INFINITY2].[Cx_Work].[public].[Table_5042218921]
						set '+@t_47+' = null
						where substring('+@t_47+', 2, 11) in (select n from #__phone_fail)
					'

					;declare @ie_47 tinyint = 0
					;while @ie_47 < 7
						begin
							begin try
								 exec (@sql_47)
								;break
							end try

							begin catch
								 set @ie_47 += 1
								;waitfor delay '00:00:05:000'
							end catch
						end

					set @i_47 += 1
					set @t_47 = @t_orig_47
				end

			
			;declare @del_47 tinyint = 0
			;while @del_47 < 7
				begin
					begin try
						delete from [INFINITY2].[Cx_Work].[public].[Table_5042218921]
						where 
								[Телефон1]	is null
							and [Телефон2]	is null
							and [Телефон3]	is null
							and [Телефон4]	is null
							and [Телефон5]	is null
							and [Телефон6]	is null
							and [Телефон7]	is null
							and [Телефон8]	is null
							and [Телефон9]	is null
							and [Телефон10]	is null
							and [Телефон11]	is null
							and [Телефон12]	is null
							and [Телефон13]	is null
							and [Телефон14]	is null
							and [Телефон15]	is null
						;break
					end try

					begin catch
						 set @del_47 += 1
						;break
					end catch
				end

		end



	else if @n = 48
		begin
			update [INFINITY2].[Cx_Work].[public].[Table_5042218921]
				set [State] = null
				where [State] is not null
		end
--</district_4>
----------------------------------------------------------------------
--<district_5>
	else if @n = 5 --конъюнктура
		begin
		
			;declare @del_5_full tinyint = 0
			;while @del_5_full < 7
				begin
					begin try
						delete from [INFINITY2].[Cx_Work].[public].[Table_5052709673]
							where [ID] in (
									select id from #___closed
								union
									select id from #___fixed
								union
									select id from #___prom
							)
						;break
					end try

					begin catch
						 set @del_5_full += 1
						;waitfor delay '00:00:05:000'
					end catch
				end

			
			;declare @i_5 tinyint = 1
			;declare @t_orig_5 varchar(16) = 'Телефон'
			;declare @t_5 varchar(16) = 'Телефон'
			;while @i_5 < 16
				begin
					set @t_5 += cast(@i_5 as varchar(4))
					declare @sql_5 varchar(512) = '
						UPDATE [INFINITY2].[Cx_Work].[public].[Table_5052709673]
						set '+@t_5+' = null
						where substring('+@t_5+', 2, 11) in (
								select n from #__phone_fail
							union
								select n from #__phone_all
							)
					'

					;declare @ie_5 tinyint = 0
					;while @ie_5 < 7
						begin
							begin try
								 exec (@sql_5)
								;break
							end try

							begin catch
								 set @ie_5 += 1
								;waitfor delay '00:00:05:000'
							end catch
						end

					set @i_5 += 1
					set @t_5 = @t_orig_5
				end


			;declare @del_5 tinyint = 0
			;while @del_5 < 7
				begin
					begin try
						delete from [INFINITY2].[Cx_Work].[public].Table_5052709673
						where 
								[Телефон1]	is null
							and [Телефон2]	is null
							and [Телефон3]	is null
							and [Телефон4]	is null
							and [Телефон5]	is null
							and [Телефон6]	is null
							and [Телефон7]	is null
							and [Телефон8]	is null
							and [Телефон9]	is null
							and [Телефон10]	is null
							and [Телефон11]	is null
							and [Телефон12]	is null
							and [Телефон13]	is null
							and [Телефон14]	is null
							and [Телефон15]	is null
						;break
					end try

					begin catch
						 set @del_5 += 1
						;waitfor delay '00:00:05:000'
					end catch
				end
		end


	else if @n = 51 --сортировка
		begin
			if object_id('tempdb..#tmp_campaign_51') is not null
				drop table #tmp_campaign_51
			;if object_id('tempdb..#___sort5') is not null
				drop table #___sort5
			;with
				_____sort as (
					select max(c.id) id
					from i_collect.dbo.contact_log c
					where c.typ = 1
					group by c.r_debt_id
				)
				,__sort as (
					select cl.r_debt_id id ,cl.dt dt
					from i_collect.dbo.contact_log cl
						 inner join _____sort s on cl.id = s.id	
				)	
				select * into #___sort5 from __sort

			;select * into #tmp_campaign_51 from [INFINITY2].[Cx_Work].[public].[Table_5052709673]
			;delete from [INFINITY2].[Cx_Work].[public].[Table_5052709673]
			;insert into [INFINITY2].[Cx_Work].[public].[Table_5052709673] (
				 [ID]
				,[State]
				,[ID_долга]
				,[Банк]
				,[Фамилия]
				,[Имя]
				,[Отчество]
				,[Остаток_долга]
				,[Часовой_пояс]
				,[Телефон1]
				,[Телефон2]
				,[Телефон_для_перезвона]
				,[ПерсональныйОператор]
				,[Телефон3]
				,[Телефон4]
				,[Телефон5]
				,[Телефон6]
				,[Телефон7]
				,[Телефон8]
				,[Телефон9]
				,[Телефон10]
				,[Телефон11]
				,[Телефон12]
				,[Телефон13]
				,[Телефон14]
				,[Телефон15]
				,[Дата_перезвона] 
			)
			select
				 [ID]
				,[State]
				,[ID_долга]
				,[Банк]
				,[Фамилия]
				,[Имя]
				,[Отчество]
				,[Остаток_долга]
				,[Часовой_пояс]
				,[Телефон1]
				,[Телефон2]
				,[Телефон_для_перезвона]
				,[ПерсональныйОператор]
				,[Телефон3]
				,[Телефон4]
				,[Телефон5]
				,[Телефон6]
				,[Телефон7]
				,[Телефон8]
				,[Телефон9]
				,[Телефон10]
				,[Телефон11]
				,[Телефон12]
				,[Телефон13]
				,[Телефон14]
				,[Телефон15]
				,[Дата_перезвона]
			from
				#tmp_campaign_51
				left join (select id i, dt from #___sort5)cl on #tmp_campaign_51.[ID] = cl.i
			order by
				cl.dt asc
		end


	else if @n = 52 --удаляем закрытые дела
		begin
			 declare @del_52 tinyint = 0
			;while @del_52 < 7
				begin
					begin try
						 delete from [INFINITY2].[Cx_Work].[public].[Table_5052709673]
						 where [ID] in (select id from #___closed)
						;break
					end try

					begin catch
						 set @del_52 += 1
						;waitfor delay '00:00:05:000'
					end catch
				end
		end


	else if @n = 53 --удаляем закрепленные
		begin
			 declare @del_53 tinyint = 0
			;while @del_53 < 7
				begin
					begin try
						 delete from [INFINITY2].[Cx_Work].[public].[Table_5052709673]
						 where [ID] in (select id from #___fixed)
						;break
					end try

					begin catch
						 set @del_53 += 1
						;waitfor delay '00:00:05:000'
					end catch
				end
		end


	else if @n = 54 --удаляем рабочие телефоны с учетом часового пояса !> 17
		begin		
			;if object_id('tempdb..#__phone5') is not null
				drop table #__phone5
			;with
				__phone as (
					select substring(ph.number, 2, 11) num
					from i_collect.dbo.phone as ph
						 inner join #___open_d d on d.pid = ph.parent_id
					where 
						ph.typ = 3
						and (isnull(d.gmt-4, 0) + datepart(hour, @gdd)) !< 17
				)
				select * into #__phone5 from __phone

			declare @i_54 tinyint = 1
			declare @t_orig_54 varchar(16) = 'Телефон'
			declare @t_54 varchar(16) = 'Телефон'
			while @i_54 < 16
				begin
					set @t_54 += cast(@i_54 as varchar(4))
					declare @sql_54 varchar(512) = '
						UPDATE [INFINITY2].[Cx_Work].[public].[Table_5052709673]
						set '+@t_54+' = null
						where substring('+@t_54+', 2, 11) in (select n from #__phone5)
					'

					;declare @ie_54 tinyint = 0
					;while @ie_54 < 7
						begin
							begin try
								 exec (@sql_54)
								;break
							end try

							begin catch
								 set @ie_54 += 1
								;waitfor delay '00:00:05:000'
							end catch
						end

					set @i_54 += 1
					set @t_54 = @t_orig_54
				end

			;declare @del_54 tinyint = 0
			;while @del_54 < 7
				begin
					begin try
						delete from [INFINITY2].[Cx_Work].[public].[Table_5052709673]
						where 
								[Телефон1]	is null
							and [Телефон2]	is null
							and [Телефон3]	is null
							and [Телефон4]	is null
							and [Телефон5]	is null
							and [Телефон6]	is null
							and [Телефон7]	is null
							and [Телефон8]	is null
							and [Телефон9]	is null
							and [Телефон10]	is null
							and [Телефон11]	is null
							and [Телефон12]	is null
							and [Телефон13]	is null
							and [Телефон14]	is null
							and [Телефон15]	is null
						;break
					end try

					begin catch
						 set @del_54 += 1
						;waitfor delay '00:00:05:000'
					end catch
				end
		end

	else if @n = 55 --удаляем долги с обещаниями
		begin
			 declare @del_55 tinyint = 0
			;while @del_55 < 7
				begin
					begin try
						 delete from [INFINITY2].[Cx_Work].[public].[Table_5052709673]
						 where [ID] in (select id from #___prom)	
						;break
					end try

					begin catch
						 set @del_55 += 1
						;waitfor delay '00:00:05:000'
					end catch
				end
		end


	else if @n = 56
		begin
			declare @i_56 tinyint = 1
			declare @t_orig_56 varchar(16) = 'Телефон'
			declare @t_56 varchar(16) = 'Телефон'
			while @i_56 < 16
				begin
					set @t_56 += cast(@i_56 as varchar(4))
					declare @sql_56 varchar(512) = '
						UPDATE [INFINITY2].[Cx_Work].[public].[Table_5052709673]
						set '+@t_56+' = null
						where substring('+@t_56+', 2, 11) in (select n from #__phone_all)
					'

					;declare @ie_56 tinyint = 0
					;while @ie_56 < 7
						begin
							begin try
								 exec (@sql_56)
								;break
							end try

							begin catch
								 set @ie_56 += 1
								;waitfor delay '00:00:05:000'
							end catch
						end

					set @i_56 += 1
					set @t_56 = @t_orig_56
				end


			;declare @del_56 tinyint = 0
			;while @del_56 < 7
				begin
					begin try
						delete from [INFINITY2].[Cx_Work].[public].[Table_5052709673]
						where 
								[Телефон1]	is null
							and [Телефон2]	is null
							and [Телефон3]	is null
							and [Телефон4]	is null
							and [Телефон5]	is null
							and [Телефон6]	is null
							and [Телефон7]	is null
							and [Телефон8]	is null
							and [Телефон9]	is null
							and [Телефон10]	is null
							and [Телефон11]	is null
							and [Телефон12]	is null
							and [Телефон13]	is null
							and [Телефон14]	is null
							and [Телефон15]	is null
						;break
					end try

					begin catch
						 set @del_56 += 1
						;waitfor delay '00:00:05:000'
					end catch
				end
		end

	else if @n = 57
		begin		
			declare @i_57 tinyint = 1
			declare @t_orig_57 varchar(16) = 'Телефон'
			declare @t_57 varchar(16) = 'Телефон'
			while @i_57 < 16
				begin
					set @t_57 += cast(@i_57 as varchar(4))
					declare @sql_57 varchar(512) = '
						UPDATE [INFINITY2].[Cx_Work].[public].[Table_5052709673]
						set '+@t_57+' = null
						where substring('+@t_57+', 2, 11) in (select n from #__phone_fail)
					'

					;declare @ie_57 tinyint = 0
					;while @ie_57 < 7
						begin
							begin try
								 exec (@sql_57)
								;break
							end try

							begin catch
								 set @ie_57 += 1
								;waitfor delay '00:00:05:000'
							end catch
						end

					set @i_57 += 1
					set @t_57 = @t_orig_57
				end


			;declare @del_57 tinyint = 0
			;while @del_57 < 7
				begin
					begin try
						delete from [INFINITY2].[Cx_Work].[public].[Table_5052709673]
						where 
								[Телефон1]	is null
							and [Телефон2]	is null
							and [Телефон3]	is null
							and [Телефон4]	is null
							and [Телефон5]	is null
							and [Телефон6]	is null
							and [Телефон7]	is null
							and [Телефон8]	is null
							and [Телефон9]	is null
							and [Телефон10]	is null
							and [Телефон11]	is null
							and [Телефон12]	is null
							and [Телефон13]	is null
							and [Телефон14]	is null
							and [Телефон15]	is null
						;break
					end try

					begin catch
						 set @del_57	+= 1
						;waitfor delay '00:00:05:000'
					end catch
				end
		end



	else if @n = 58
		begin
			update [INFINITY2].[Cx_Work].[public].[Table_5052709673]
				set [State] = null
				where [State] is not null
		end

--</district_5>
----------------------------------------------------------------------
--<district_6>
	else if @n = 6 --конъюнктура
		begin		
			;declare @del_6_full tinyint = 0
			;while @del_6_full < 7
				begin
					begin try
						delete from [INFINITY2].[Cx_Work].[public].[Table_5602983666]
							where [ID] in (
									select id from #___closed
								union
									select id from #___fixed
								union
									select id from #___prom
							)
						;break
					end try

					begin catch
						 set @del_6_full += 1
						;waitfor delay '00:00:05:000'
					end catch
				end
			
		
			;declare @i_6 tinyint = 1
			;declare @t_orig_6 varchar(16) = 'Телефон'
			;declare @t_6 varchar(16) = 'Телефон'
			;while @i_6 < 16
				begin
					set @t_6 += cast(@i_6 as varchar(4))
					declare @sql_6 varchar(512) = '
						UPDATE [INFINITY2].[Cx_Work].[public].[Table_5602983666]
						set '+@t_6+' = null
						where substring('+@t_6+', 2, 11) in (
								select n from #__phone_fail
								union
								select n from #__phone_all
							)
					'

					;declare @ie_6 tinyint = 0
					;while @ie_6 < 7
						begin
							begin try
								 exec (@sql_6)
								;break
							end try

							begin catch
								 set @ie_6 += 1
								;waitfor delay '00:00:05:000'
							end catch
						end

					set @i_6 += 1
					set @t_6 = @t_orig_6
				end

			
			;declare @del_6 tinyint = 0
			;while @del_6 < 7
				begin
					begin try
						delete from [INFINITY2].[Cx_Work].[public].[Table_5602983666]
						where
								[Телефон1]	is null
							and [Телефон2]	is null
							and [Телефон3]	is null
							and [Телефон4]	is null
							and [Телефон5]	is null
							and [Телефон6]	is null
							and [Телефон7]	is null
							and [Телефон8]	is null
							and [Телефон9]	is null
							and [Телефон10]	is null
							and [Телефон11]	is null
							and [Телефон12]	is null
							and [Телефон13]	is null
							and [Телефон14]	is null
							and [Телефон15]	is null
						;break
					end try

					begin catch
						 set @del_6 += 1
						;waitfor delay '00:00:05:000'
					end catch
				end
		end		


	else if @n = 61 --сортировка
		begin
			if object_id ('tempdb..tmp_campaign_61') is not null
				drop table #tmp_campaign_61
			;if object_id('tempdb..#___sort6') is not null
				drop table #___sort6
			;with
				_____sort as (
					select max(c.id) id
					from i_collect.dbo.contact_log c
					where c.typ = 1
					group by c.r_debt_id
				)
				,__sort as (
					select cl.r_debt_id id ,cl.dt dt
					from i_collect.dbo.contact_log cl
						 inner join _____sort s on cl.id = s.id	
				)	
				select * into #___sort6 from __sort

			;select * into #tmp_campaign_61 from [INFINITY2].[Cx_Work].[public].[Table_5602983666]
			;delete from [INFINITY2].[Cx_Work].[public].[Table_5602983666]
			;insert into [INFINITY2].[Cx_Work].[public].[Table_5602983666] (
				 [ID]
				,[State]
				,[ID_долга]
				,[Банк]
				,[Фамилия]
				,[Имя]
				,[Отчество]
				,[Телефон1]
				,[Телефон2]
				,[Телефон3]
				,[Телефон4]
				,[Телефон5]
				,[Телефон6]
				,[Телефон7]
				,[Телефон8]
				,[Телефон9]
				,[Телефон10]
				,[Телефон11]
				,[Телефон12]
				,[Телефон13]
				,[Телефон14]
				,[Телефон15]
				,[Остаток_долга]
				,[Дата_презвона]
				,[Телефон_для_перезвона]
				,[Часовой_пояс]
				,[КолПопыток]
				,[ПерсональныйОпер]
			)
			select
				 [ID]
				,[State]
				,[ID_долга]
				,[Банк]
				,[Фамилия]
				,[Имя]
				,[Отчество]
				,[Телефон1]
				,[Телефон2]
				,[Телефон3]
				,[Телефон4]
				,[Телефон5]
				,[Телефон6]
				,[Телефон7]
				,[Телефон8]
				,[Телефон9]
				,[Телефон10]
				,[Телефон11]
				,[Телефон12]
				,[Телефон13]
				,[Телефон14]
				,[Телефон15]
				,[Остаток_долга]
				,[Дата_презвона]
				,[Телефон_для_перезвона]
				,[Часовой_пояс]
				,[КолПопыток]
				,[ПерсональныйОпер]
			from
				#tmp_campaign_61
				left join (select id i, dt from #___sort6)cl on #tmp_campaign_61.[ID] = cl.i
			order by
				cl.dt asc
		end


	else if @n = 62 --удаляем закрытые дела
		begin
			declare @del_62 tinyint = 0
			;while @del_62 < 7
				begin
					begin try
						 delete from [INFINITY2].[Cx_Work].[public].[Table_5602983666]
						 where [ID] in (select id from #___closed)
						;break
					end try

					begin catch
						 set @del_62 += 1
						;waitfor delay '00:00:05:000'
					end catch
				end
		end


	else if @n = 63 --удаляем закрепленные
		begin
			 declare @del_63 tinyint = 0
			;while @del_63 < 7
				begin
					begin try
						 delete from [INFINITY2].[Cx_Work].[public].[Table_5602983666]
						 where [ID] in (select id from #___fixed)
						;break
					end try

					begin catch
						 set @del_63 += 1
						;waitfor delay '00:00:05:000'
					end catch
				end
		end



	else if @n = 64 --удаляем рабочие телефоны с учетом часового пояса !> 17
		begin
			;if object_id('tempdb..#__phone6') is not null
				drop table #__phone6
			;with
				__phone as (
					select substring(ph.number, 2, 11) num
					from i_collect.dbo.phone as ph
						 inner join #___open_d d on d.pid = ph.parent_id
					where 
						ph.typ = 3
						and (isnull(d.gmt-4, 0) + datepart(hour, @gdd)) !< 17
				)
				select * into #__phone6 from __phone

			declare @i_64 tinyint = 1
			declare @t_orig_64 varchar(16) = 'Телефон'
			declare @t_64 varchar(16) = 'Телефон'
			while @i_64 < 16
				begin
					set @t_64 += cast(@i_64 as varchar(4))
					declare @sql_64 varchar(512) = '
						UPDATE [INFINITY2].[Cx_Work].[public].[Table_5602983666]
						set '+@t_64+' = null
						where substring('+@t_64+', 2, 11) in (select n from #__phone6)
					'
					
					;declare @ie_64 tinyint = 0
					;while @ie_64 < 7
						begin
							begin try
								 exec (@sql_64)
								;break
							end try

							begin catch
								 set @ie_64 += 1
								;waitfor delay '00:00:05:000'
							end catch
						end

					set @i_64 += 1
					set @t_64 = @t_orig_64
				end


			;declare @del_64 tinyint = 0
			;while @del_64 < 7
				begin
					begin try		
						delete from [INFINITY2].[Cx_Work].[public].[Table_5602983666]
						where 
								[Телефон1]	is null
							and [Телефон2]	is null
							and [Телефон3]	is null
							and [Телефон4]	is null
							and [Телефон5]	is null
							and [Телефон6]	is null
							and [Телефон7]	is null
							and [Телефон8]	is null
							and [Телефон9]	is null
							and [Телефон10]	is null
							and [Телефон11]	is null
							and [Телефон12]	is null
							and [Телефон13]	is null
							and [Телефон14]	is null
							and [Телефон15]	is null
						;break
					end try

					begin catch
						 set @del_64 += 1
						;waitfor delay '00:00:05:000'
					end catch
				end
		end

	else if @n = 65 -- удаляем долги с обещаниями
		begin
			 declare @del_65 tinyint = 0
			;while @del_65 < 7
				begin
					begin try
						 delete from [INFINITY2].[Cx_Work].[public].[Table_5602983666]
						 where [ID] in (select id from #___prom)
						;break
					end try

					begin catch
						 set @del_65 += 1
						;waitfor delay '00:00:05:000'
					end catch
				end
		end

	else if @n = 66
		begin
			declare @i_66 tinyint = 1
			declare @t_orig_66 varchar(16) = 'Телефон'
			declare @t_66 varchar(16) = 'Телефон'
			while @i_66 < 16
				begin
					set @t_66 += cast(@i_66 as varchar(4))
					declare @sql_66 varchar(512) = '
						UPDATE [INFINITY2].[Cx_Work].[public].[Table_5602983666]
						set '+@t_66+' = null
						where substring('+@t_66+', 2, 11) in (select n from #__phone_all)
					'

					;declare @ie_66 tinyint = 0
					;while @ie_66 < 7
						begin
							begin try
								 exec(@sql_66)
								;break
							end try

							begin catch
								 set @ie_66 += 1
								;waitfor delay '00:00:05:000'
							end catch
						end

					set @i_66 += 1
					set @t_66 = @t_orig_66
				end

			;declare @del_66 tinyint = 0
			;while @del_66 < 7
				begin
					begin try
						delete from [INFINITY2].[Cx_Work].[public].[Table_5602983666]
						where 
								[Телефон1]	is null
							and [Телефон2]	is null
							and [Телефон3]	is null
							and [Телефон4]	is null
							and [Телефон5]	is null
							and [Телефон6]	is null
							and [Телефон7]	is null
							and [Телефон8]	is null
							and [Телефон9]	is null
							and [Телефон10]	is null
							and [Телефон11]	is null
							and [Телефон12]	is null
							and [Телефон13]	is null
							and [Телефон14]	is null
							and [Телефон15]	is null
						;break
					end try

					begin catch
						 set @del_66 += 1
						;waitfor delay '00:00:05:000'
					end catch
				end
		end

	else if @n = 67
		begin		
			declare @i_67 tinyint = 1
			declare @t_orig_67 varchar(16) = 'Телефон'
			declare @t_67 varchar(16) = 'Телефон'
			while @i_67 < 16
				begin
					set @t_67 += cast(@i_67 as varchar(4))
					declare @sql_67 varchar(512) = '
						UPDATE [INFINITY2].[Cx_Work].[public].[Table_5602983666]
						set '+@t_67+' = null
						where substring('+@t_67+', 2, 11) in (select n from #__phone_fail)
					'

					;declare @ie_67 tinyint = 0
					;while @ie_67 < 7
						begin
							begin try
								 exec (@sql_67)
								;break
							end try

							begin catch
								 set @ie_67 += 1
								;waitfor delay '00:00:05:000'
							end catch
						end

					set @i_67 += 1
					set @t_67 = @t_orig_67
				end


			;declare @del_67 tinyint = 0
			;while @del_67 < 7
				begin
					begin try
						;delete from [INFINITY2].[Cx_Work].[public].[Table_5602983666]
						where 
								[Телефон1]	is null
							and [Телефон2]	is null
							and [Телефон3]	is null
							and [Телефон4]	is null
							and [Телефон5]	is null
							and [Телефон6]	is null
							and [Телефон7]	is null
							and [Телефон8]	is null
							and [Телефон9]	is null
							and [Телефон10]	is null
							and [Телефон11]	is null
							and [Телефон12]	is null
							and [Телефон13]	is null
							and [Телефон14]	is null
							and [Телефон15]	is null
						;break
					end try

					begin catch
						 set @del_67 += 1
						;waitfor delay '00:00:05:000'
					end catch
				end
		end



	else if @n = 68
		begin
			update [INFINITY2].[Cx_Work].[public].[Table_5602983666]
				set [State] = null
				where [State] is not null
		end

	
--</district_6>
----------------------------------------------------------------------
--<district_7>
	else if @n = 7 --конъюнктура
		begin
		
			;declare @del_7_full tinyint = 0
			;while @del_7_full < 7
				begin
					begin try
						delete from [INFINITY2].[Cx_Work].[public].[Table_5068758013]
							where [ID] in (
									select id from #___closed
								union
									select id from #___fixed
								union
									select id from #___prom
							)
						;break
					end try

					begin catch
						 set @del_7_full += 1
						;waitfor delay '00:00:05:000'
					end catch
				end
			
		
			;declare @i_7 tinyint = 1
			;declare @t_orig_7 varchar(16) = 'Телефон'
			;declare @t_7 varchar(16) = 'Телефон'
			;while @i_7 < 16
				begin
					set @t_7 += cast(@i_7 as varchar(4))
					declare @sql_7 varchar(512) = '
						UPDATE [INFINITY2].[Cx_Work].[public].[Table_5068758013]
						set '+@t_7+' = null
						where substring('+@t_7+', 2, 11) in (
								select n from #__phone_fail
							union
								select n from #__phone_all
							)
					'
					
					;declare @ie_7 tinyint = 0
					;while @ie_7 < 7
						begin
							begin try
								 exec(@sql_7)
								;break
							end try

							begin catch
								 set @ie_7 += 1
								;waitfor delay '00:00:05:000'
							end catch
						end

					set @i_7 += 1
					set @t_7 = @t_orig_7
				end

			
			;declare @del_7 tinyint = 0
			;while @del_7 < 7
				begin
					begin try
						delete from [INFINITY2].[Cx_Work].[public].[Table_5068758013]
						where 
								[Телефон1]	is null
							and [Телефон2]	is null
							and [Телефон3]	is null
							and [Телефон4]	is null
							and [Телефон5]	is null
							and [Телефон6]	is null
							and [Телефон7]	is null
							and [Телефон8]	is null
							and [Телефон9]	is null
							and [Телефон10]	is null
							and [Телефон11]	is null
							and [Телефон12]	is null
							and [Телефон13]	is null
							and [Телефон14]	is null
							and [Телефон15]	is null
						;break
					end try

					begin catch
						 set @del_7 += 1
						;waitfor delay '00:00:05:000'
					end catch
				end

		end
		
	else if @n = 71 --сортировка
		begin
			;if object_id('tempdb..#___sort7') is not null
				drop table #___sort7
			if object_id('tempdb..#tmp_campaign_71') is not null
				drop table #tmp_campaign_71
			
			;with
				_____sort as (
					select max(c.id) id
					from i_collect.dbo.contact_log c
					where c.typ = 1
					group by c.r_debt_id
				)
				,__sort as (
					select cl.r_debt_id id ,cl.dt dt
					from i_collect.dbo.contact_log cl
						 inner join _____sort s on cl.id = s.id	
				)	
				select * into #___sort7 from __sort

			;select * into #tmp_campaign_71 from [INFINITY2].[Cx_Work].[public].[Table_5068758013]
			;delete from [INFINITY2].[Cx_Work].[public].[Table_5068758013]
			;insert into [INFINITY2].[Cx_Work].[public].[Table_5068758013] (
				 [ID]
				,[State]
				,[ID_долга]
				,[Банк]
				,[Фамилия]
				,[Имя]
				,[Отчество]
				,[Остаток_долга]
				,[Часовой_пояс]
				,[ПерсональныйОператор]
				,[Телефон_для_перезвона]
				,[Дата_перезвона]
				,[Телефон1]
				,[Телефон2]
				,[Телефон3]
				,[Телефон4]
				,[Телефон5]
				,[Телефон6]
				,[Телефон7]
				,[Телефон8]
				,[Телефон9]
				,[Телефон10]
				,[Телефон11]
				,[Телефон12]
				,[Телефон13]
				,[Телефон14]
				,[Телефон15]
			)
			select
				 [ID]
				,[State]
				,[ID_долга]
				,[Банк]
				,[Фамилия]
				,[Имя]
				,[Отчество]
				,[Остаток_долга]
				,[Часовой_пояс]
				,[ПерсональныйОператор]
				,[Телефон_для_перезвона]
				,[Дата_перезвона]
				,[Телефон1]
				,[Телефон2]
				,[Телефон3]
				,[Телефон4]
				,[Телефон5]
				,[Телефон6]
				,[Телефон7]
				,[Телефон8]
				,[Телефон9]
				,[Телефон10]
				,[Телефон11]
				,[Телефон12]
				,[Телефон13]
				,[Телефон14]
				,[Телефон15]
			from
				#tmp_campaign_71
				left join (select id i, dt from #___sort7)cl on #tmp_campaign_71.[ID] = cl.i
			order by
				cl.dt asc
		end



	else if @n = 72
		begin
			 declare @del_72 tinyint = 0
			;while @del_72 < 7
				begin
					begin try
						 delete from [INFINITY2].[Cx_Work].[public].[Table_5068758013]
						 where [ID] in (select id from #___closed)
						;break
					end try

					begin catch
						 set @del_72 += 1 
						;waitfor delay '00:00:05:000'
					end catch
				end
		end



	else if @n = 73
		begin
			 declare @del_73 tinyint = 0
			;while @del_73 < 7
				begin
					begin try
						 delete from [INFINITY2].[Cx_Work].[public].[Table_5068758013]
						 where [ID] in (select id from #___fixed)
						;break
					end try

					begin catch
						 set @del_73 += 1
						;waitfor delay '00:00:05:000'
					end catch
				end
		end



	else if @n = 74 
		begin
			;if object_id('tempdb..#__phone7') is not null
					drop table #__phone7
			;with
				__phone as (
					select substring(ph.number, 2, 11) num
					from i_collect.dbo.phone as ph
						 inner join #___open_d d on d.pid = ph.parent_id
					where 
						ph.typ = 3
						and (isnull(d.gmt-4, 0) + datepart(hour, @gdd)) !< 17
				)
				select * into #__phone7 from __phone

			declare @i_74 tinyint = 1
			declare @t_orig_74 varchar(16) = 'Телефон'
			declare @t_74 varchar(16) = 'Телефон'
			while @i_74 < 16
				begin
					set @t_74 += cast(@i_74 as varchar(4))
					declare @sql_74 varchar(512) = '
						UPDATE [INFINITY2].[Cx_Work].[public].[Table_5068758013]
						set '+@t_74+' = null
						where substring('+@t_74+', 2, 11) in (select n from #__phone7)
					'
					
					;declare @ie_74 tinyint = 0
					;while @ie_74 < 4
						begin
							begin try
								 exec (@sql_74)
								;break
							end try

							begin catch
								 set @ie_74 += 1
								;waitfor delay '00:00:05:000'
							end catch
						end
					set @i_74 += 1
					set @t_74 = @t_orig_74
				end

			;declare @del_74 tinyint = 0
			;while @del_74 < 7
				begin
					begin try
						;delete from [INFINITY2].[Cx_Work].[public].[Table_5068758013]
						where 
								[Телефон1]	is null
							and [Телефон2]	is null
							and [Телефон3]	is null
							and [Телефон4]	is null
							and [Телефон5]	is null
							and [Телефон6]	is null
							and [Телефон7]	is null
							and [Телефон8]	is null
							and [Телефон9]	is null
							and [Телефон10] is null
							and [Телефон11] is null
							and [Телефон12] is null
							and [Телефон13] is null
							and [Телефон14] is null
							and [Телефон15] is null
						;break
					end try

					begin catch
						set @del_74 += 1
						;waitfor delay '00:00:05:000'
					end catch
				end

		end

	else if @n = 75 --удаляем долги с обещаниями
		begin
			;declare @del_75 tinyint = 0
			;while @del_75 < 7
				begin
					begin try
						 delete from [INFINITY2].[Cx_Work].[public].[Table_5068758013]
						 where [ID] in (select id from #___prom)
						;break
					end try

					begin catch
						 set @del_75 += 1
						;waitfor delay '00:00:05:000'
					end catch
				end
		end

	else if @n = 76
		begin	
		 	 declare @i_76 tinyint = 1
			;declare @t_orig_76 varchar(16) = 'Телефон'
			;declare @t_76 varchar(16) = 'Телефон'
			;while @i_76 < 16
				begin
					set @t_76 += cast(@i_76 as varchar(4))
					declare @sql_76 varchar(512) = '
						UPDATE [INFINITY2].[Cx_Work].[public].[Table_5068758013]
						set '+@t_76+' = null
						where substring('+@t_76+', 2, 11) in (select n from #__phone_all)
					'

					;declare @ie_76 tinyint = 0
					;while @ie_76 < 4
						begin
							begin try
								 exec (@sql_76)
								;break
							end try

							begin catch
								 set @ie_76 += 1
								;waitfor delay '00:00:05:000'
							end catch
						end
					;set @i_76 += 1
					;set @t_76 = @t_orig_76
				end

			;declare @del_76 tinyint = 0
			;while @del_76 < 7
				begin
					begin try
						;delete from [INFINITY2].[Cx_Work].[public].[Table_5068758013]
						where 
								[Телефон1]	is null
							and [Телефон2]	is null
							and [Телефон3]	is null
							and [Телефон4]	is null
							and [Телефон5]	is null
							and [Телефон6]	is null
							and [Телефон7]	is null
							and [Телефон8]	is null
							and [Телефон9]	is null
							and [Телефон10] is null
							and [Телефон11] is null
							and [Телефон12] is null
							and [Телефон13] is null
							and [Телефон14] is null
							and [Телефон15] is null
						;break
					end try

					begin catch
						set @del_76 += 1
						;waitfor delay '00:00:05:000'
					end catch
				end

		end

	else if @n = 77
		begin
		
			declare @i_77 tinyint = 1
			declare @t_orig_77 varchar(16) = 'Телефон'
			declare @t_77 varchar(16) = 'Телефон'
			while @i_77 < 16
				begin
					set @t_77 += cast(@i_77 as varchar(4))
					declare @sql_77 varchar(512) = '
						UPDATE [INFINITY2].[Cx_Work].[public].[Table_5068758013]
						set '+@t_77+' = null
						where substring('+@t_77+', 2, 11) in (select n from #__phone_fail)
					'

					;declare @ie_77 tinyint = 0
					;while @ie_77 < 4
						begin
							begin try
								 exec (@sql_77)
								;break
							end try

							begin catch
								 set @ie_77 += 1
								;waitfor delay '00:00:05:000'
							end catch
						end
					set @i_77 += 1
					set @t_77 = @t_orig_77
				end
			

			;declare @del_77 tinyint = 0
			;while @del_77 < 7
				begin
					begin try
						;delete from [INFINITY2].[Cx_Work].[public].[Table_5068758013]
						where 
								[Телефон1]	is null
							and [Телефон2]	is null
							and [Телефон3]	is null
							and [Телефон4]	is null
							and [Телефон5]	is null
							and [Телефон6]	is null
							and [Телефон7]	is null
							and [Телефон8]	is null
							and [Телефон9]	is null
							and [Телефон10] is null
							and [Телефон11] is null
							and [Телефон12] is null
							and [Телефон13] is null
							and [Телефон14] is null
							and [Телефон15] is null
						;break
					end try

					begin catch
						set @del_77 += 1
						;waitfor delay '00:00:05:000'
					end catch
				end

		end


	else if @n = 78
		begin
			update [INFINITY2].[Cx_Work].[public].[Table_5068758013]
				set [State] = null
				where [State] is not null
		end
			
--</district_7>
----------------------------------------------------------------------
--<district_8>
	else if @n = 8 --конъюнктура
		begin		

			;declare @del_8_full tinyint = 0
			;while @del_8_full < 7
				begin
					begin try
						 delete from [INFINITY2].[Cx_Work].[public].[Table_5336960870]
							where [ID] in (
									select id from #___closed
								union
									select id from #___fixed
								union
									select id from #___prom
							)
						;break
					end try

					begin catch
						 set @del_8_full += 1
						;waitfor delay '00:00:05:000'
					end catch
				end
			

			;declare @i_8 tinyint = 1
			;declare @t_orig_8 varchar(16) = 'Телефон'
			;declare @t_8 varchar(16) = 'Телефон'
			;while @i_8 < 16
				begin
					set @t_8 += cast(@i_8 as varchar(4))
					declare @sql_8 varchar(512) = '
						UPDATE [INFINITY2].[Cx_Work].[public].[Table_5336960870]
						set '+@t_8+' = null
						where substring('+@t_8+', 2, 11) in (
								select n from #__phone_fail
							union
								select n from #__phone_all
							)
					'
					
					;declare @ie_8 tinyint = 0
					;while @ie_8 < 7
						begin
							begin try
								 exec (@sql_8)
								;break
							end try

							begin catch
								 set @ie_8 += 1
								;waitfor delay '00:00:05:000'
							end catch
						end
					set @i_8 += 1
					set @t_8 = @t_orig_8
				end

			
			;declare @del_8 tinyint = 0
			;while @del_8 < 7
				begin
					begin try
						;delete from [INFINITY2].[Cx_Work].[public].[Table_5336960870]
						where 
								[Телефон1]	is null
							and [Телефон2]	is null
							and [Телефон3]	is null
							and [Телефон4]	is null
							and [Телефон5]	is null
							and [Телефон6]	is null
							and [Телефон7]	is null
							and [Телефон8]	is null
							and [Телефон9]	is null
							and [Телефон10] is null 
							and [Телефон11] is null
							and [Телефон12] is null
							and [Телефон13] is null
							and [Телефон14] is null
							and [Телефон15] is null
						;break
					end try

					begin catch
						 set @del_8 += 1
						;waitfor delay '00:00:05:000'
					end catch
				end

		end
		

	else if @n = 81 --сортировка
		begin
			if object_id('tempdb..#tmp_campaign_81') is not null
				drop table #tmp_campaign_81
			;if object_id('tempdb..#___sort8') is not null
				drop table #___sort8
			;with
				_____sort as (
					select max(c.id) id
					from i_collect.dbo.contact_log c
					where c.typ = 1
					group by c.r_debt_id
				)
				,__sort as (
					select cl.r_debt_id id ,cl.dt dt
					from i_collect.dbo.contact_log cl
						 inner join _____sort s on cl.id = s.id	
				)	
				select * into #___sort8 from __sort

			;select * into #tmp_campaign_81 from [INFINITY2].[Cx_Work].[public].[Table_5336960870]
			;delete from [INFINITY2].[Cx_Work].[public].[Table_5336960870]
			;insert into [INFINITY2].[Cx_Work].[public].[Table_5336960870] (
				 [ID]
				,[State]
				,[ID_долга]
				,[Банк]
				,[Фамилия]
				,[Имя]
				,[Отчество]
				,[Телефон1]
				,[Телефон2]
				,[Телефон3]
				,[Телефон4]
				,[Телефон5]
				,[Телефон6]
				,[Телефон7]
				,[Телефон8]
				,[Телефон9]
				,[Телефон10]
				,[Телефон11]
				,[Телефон12]
				,[Телефон13]
				,[Телефон14]
				,[Телефон15]
				,[Остаток_долга]
				,[Дата_перезвона]
				,[Часовой_пояс]
				,[Телефон_для_перезвона]
				,[ПерсональныйОператор] 
			)
			select
				 [ID]
				,[State]
				,[ID_долга]
				,[Банк]
				,[Фамилия]
				,[Имя]
				,[Отчество]
				,[Телефон1]
				,[Телефон2]
				,[Телефон3]
				,[Телефон4]
				,[Телефон5]
				,[Телефон6]
				,[Телефон7]
				,[Телефон8]
				,[Телефон9]
				,[Телефон10]
				,[Телефон11]
				,[Телефон12]
				,[Телефон13]
				,[Телефон14]
				,[Телефон15]
				,[Остаток_долга]
				,[Дата_перезвона]
				,[Часовой_пояс]
				,[Телефон_для_перезвона]
				,[ПерсональныйОператор]
			from
				#tmp_campaign_81
				left join (select id i, dt from #___sort8)cl on #tmp_campaign_81.[ID] = cl.i
			order by
				cl.dt asc			
		end



	else if @n = 82 --удаляем закрытые дела
		begin
			 declare @del_82 tinyint = 0
			;while @del_82 < 7
				begin
					begin try
						 delete from [INFINITY2].[Cx_Work].[public].[Table_5336960870]
						 where [ID] in (select id from #___closed)
						;break
					end try

					begin catch
						 set @del_82 += 1
						;waitfor delay '00:00:05:000'
					end catch
				end
		end


	else if @n = 83 --удаляем закрепленные
		begin
			 declare @del_83 tinyint = 0
			;while @del_83 < 7
				begin
					begin try
						 delete from [INFINITY2].[Cx_Work].[public].[Table_5336960870]
						 where [ID] in (select id from #___fixed)
						;break
					end try

					begin catch
						 set @del_83 += 1
						;waitfor delay '00:00:05:000'
					end catch
				end

		end

	else if @n = 84 --удаляем рабочие телефоны с учетом часового пояса !> 17
		begin
			;if object_id('tempdb..#__phone8') is not null
				drop table #__phone8
			;with
				__phone as (
					select substring(ph.number, 2, 11) num
					from i_collect.dbo.phone as ph
						 inner join #___open_d d on d.pid = ph.parent_id
					where 
						ph.typ = 3
						and (isnull(d.gmt-4, 0) + datepart(hour, @gdd)) !< 17
				)
				select * into #__phone8 from __phone
		
			declare @i_84 tinyint = 1
			declare @t_orig_84 varchar(16) = 'Телефон'
			declare @t_84 varchar(16) = 'Телефон'
			while @i_84 < 16
				begin
					set @t_84 += cast(@i_84 as varchar(4))
					declare @sql_84 varchar(512) = '
						UPDATE [INFINITY2].[Cx_Work].[public].[Table_5336960870]
						set '+@t_84+' = null
						where substring('+@t_84+', 2, 11) in (select n from #__phone8)
					'
					
					;declare @ie_84 tinyint = 0
					;while @ie_84 < 7
						begin
							begin try
								 exec (@sql_84)
								;break
							end try

							begin catch
								 set @ie_84 += 1
								;waitfor delay '00:00:05:000'
							end catch
						end
					set @i_84 += 1
					set @t_84 = @t_orig_84
				end
			
			;declare @del_84 tinyint = 0
			;while @del_84 < 7
				begin
					begin try
						;delete from [INFINITY2].[Cx_Work].[public].[Table_5336960870]
						where 
								[Телефон1]	is null
							and [Телефон2]	is null
							and [Телефон3]	is null
							and [Телефон4]	is null
							and [Телефон5]	is null
							and [Телефон6]	is null
							and [Телефон7]	is null
							and [Телефон8]	is null
							and [Телефон9]	is null
							and [Телефон10] is null 
							and [Телефон11] is null
							and [Телефон12] is null
							and [Телефон13] is null
							and [Телефон14] is null
							and [Телефон15] is null
						;break
					end try

					begin catch
						 set @del_84 += 1
						;waitfor delay '00:00:05:000'
					end catch
				end

		end


	else if @n = 85 --удаляем долги с обещаниями

		begin
			 declare @del_85 tinyint = 0
			;while @del_85 < 7
				begin
					begin try
						 delete from [INFINITY2].[Cx_Work].[public].[Table_5336960870]
						 where [ID] in (select id from #___prom)
						;break
					end try

					begin catch
						 set @del_85 += 1
						;waitfor delay '00:00:05:000'
					end catch
				end
		end


	else if @n = 86
		begin
			declare @i_86 tinyint = 1
			;declare @t_orig_86 varchar(16) = 'Телефон'
			;declare @t_86 varchar(16) = 'Телефон'
			;while @i_86 < 16
				begin
					 set @t_86 += cast(@i_86 as varchar(4))
					;declare @sql_86 varchar(512) = '
						UPDATE [INFINITY2].[Cx_Work].[public].[Table_5336960870]
						set '+@t_86+' = null
						where substring('+@t_86+', 2, 11) in (select n from #__phone_all)
					'
					
					;declare @ie_86 tinyint = 0
					;while @ie_86 < 7
						begin
							begin try
								 exec (@sql_86)
								;break
							end try

							begin catch
								 set @ie_86 += 1
								;waitfor delay '00:00:05:000'
							end catch
						end
					set @i_86 += 1
					set @t_86 = @t_orig_86
				end

			
			;declare @del_86 tinyint = 0
			;while @del_86 < 7
				begin
					begin try
						;delete from [INFINITY2].[Cx_Work].[public].[Table_5336960870]
						where 
								[Телефон1]	is null
							and [Телефон2]	is null
							and [Телефон3]	is null
							and [Телефон4]	is null
							and [Телефон5]	is null
							and [Телефон6]	is null
							and [Телефон7]	is null
							and [Телефон8]	is null
							and [Телефон9]	is null
							and [Телефон10] is null
							and [Телефон11] is null
							and [Телефон12] is null
							and [Телефон13] is null
							and [Телефон14] is null
							and [Телефон15] is null
						;break
					end try

					begin catch
						 set @del_86 += 1
						;waitfor delay '00:00:05:000'
					end catch
				end

		end

	else if @n = 87
		begin
		
			declare @i_87 tinyint = 1
			declare @t_orig_87 varchar(16) = 'Телефон'
			declare @t_87 varchar(16) = 'Телефон'
			while @i_87 < 16
				begin
					set @t_87 += cast(@i_87 as varchar(4))
					declare @sql_87 varchar(512) = '
						UPDATE [INFINITY2].[Cx_Work].[public].[Table_5336960870]
						set '+@t_87+' = null
						where substring('+@t_87+', 2, 11) in (select n from #__phone_fail)
					'
					
					;declare @ie_87 tinyint = 0
					;while @ie_87 < 7
						begin
							begin try
								 exec(@sql_87)
								;break
							end try

							begin catch
								 set @ie_87 += 1
								;waitfor delay '00:00:05:000'
							end catch
						end
					exec (@sql_87)
					set @i_87 += 1
					set @t_87 = @t_orig_87
				end
			

			;declare @del_87 tinyint = 0
			;while @del_87 < 7
				begin
					begin try
						delete from [INFINITY2].[Cx_Work].[public].[Table_5336960870]
						where 
								[Телефон1]	is null
							and [Телефон2]	is null
							and [Телефон3]	is null
							and [Телефон4]	is null
							and [Телефон5]  is null
							and [Телефон6]  is null
							and [Телефон7]  is null
							and [Телефон8]  is null
							and [Телефон9]  is null
							and [Телефон10]	is null
							and [Телефон11] is null
							and [Телефон12] is null
							and [Телефон13] is null
							and [Телефон14] is null
							and [Телефон15] is null
						;break
					end try

					begin catch
						 set @del_87 += 1
						;waitfor delay '00:00:05:000'
					end catch
				end

		end


	else if @n = 88
		begin
			update [INFINITY2].[Cx_Work].[public].[Table_5336960870]
				set [State] = null
				where [State] is not null
		end

--set nocount off;

END