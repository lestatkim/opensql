
use wh_data
go

alter function dbo.dailer_monitor()

returns @t table (
	 [name] varchar(16)
	,[all] int
	,[unempty] int
	,[empty] int
	,[penetr] float --empty / all * 100
	,[proc] int --obrabotan State = 7
	,[proc_%] float 
	,[lost] int --poteryan State = 12
	,[lost_%] float --poteryan State = 12
)
as 

begin 
--1
	declare @1_f int = (select count(*) from [INFINITY2].[Cx_Work].[public].[Table_5000081023])
	declare @1_ne int = (select count(*) from [INFINITY2].[Cx_Work].[public].[Table_5000081023] where [State] is not null)
	declare @1_e int = (select count(*) from [INFINITY2].[Cx_Work].[public].[Table_5000081023] where [State] is null)
	declare @1_pen float = round((cast(@1_ne as float) / cast(@1_f as float)) * 100.00, 2)
	declare @1_proc int = (select count(*) from [INFINITY2].[Cx_Work].[public].[Table_5000081023] where [State] = 7)
	declare @1_lost int = (select count(*) from [INFINITY2].[Cx_Work].[public].[Table_5000081023] where [State] = 12)

---2
	declare @2_f int = (select count(*) from [INFINITY2].[Cx_Work].[public].[Table_5000081044])
	declare @2_ne int = (select count(*) from [INFINITY2].[Cx_Work].[public].[Table_5000081044] where [State] is not null)
	declare @2_e int = (select count(*) from [INFINITY2].[Cx_Work].[public].[Table_5000081044] where [State] is null)
	declare @2_pen float = round((cast(@2_ne as float) / cast(@2_f as float)) * 100.00, 2)
	declare @2_proc int = (select count(*) from [INFINITY2].[Cx_Work].[public].[Table_5000081044] where [State] = 7)
	declare @2_lost int = (select count(*) from [INFINITY2].[Cx_Work].[public].[Table_5000081044] where [State] = 12)

---3
	declare @3_f int = (select count(*) from [INFINITY2].[Cx_Work].[public].[Table_5015640658])
	declare @3_ne int = (select count(*) from [INFINITY2].[Cx_Work].[public].[Table_5015640658] where [State] is not null)
	declare @3_e int = (select count(*) from [INFINITY2].[Cx_Work].[public].[Table_5015640658] where [State] is null)
	declare @3_pen float = round((cast(@3_ne as float) / cast(@3_f as float)) * 100.00, 2)
	declare @3_proc int = (select count(*) from [INFINITY2].[Cx_Work].[public].[Table_5015640658] where [State] = 7)
	declare @3_lost int = (select count(*) from [INFINITY2].[Cx_Work].[public].[Table_5015640658] where [State] = 12)

---4
	declare @4_f int = (select count(*) from [INFINITY2].[Cx_Work].[public].[Table_5042218921])
	declare @4_ne int = (select count(*) from [INFINITY2].[Cx_Work].[public].[Table_5042218921] where [State] is not null)
	declare @4_e int = (select count(*) from [INFINITY2].[Cx_Work].[public].[Table_5042218921] where [State] is null)
	declare @4_pen float = round((cast(@4_ne as float) / cast(@4_f as float)) * 100.00, 2)
	declare @4_proc int = (select count(*) from [INFINITY2].[Cx_Work].[public].[Table_5042218921] where [State] = 7)
	declare @4_lost int = (select count(*) from [INFINITY2].[Cx_Work].[public].[Table_5042218921] where [State] = 12)

--5
	declare @5_f int = (select count(*) from [INFINITY2].[Cx_Work].[public].[Table_5052709673])
	declare @5_ne int = (select count(*) from [INFINITY2].[Cx_Work].[public].[Table_5052709673] where [State] is not null)
	declare @5_e int = (select count(*) from [INFINITY2].[Cx_Work].[public].[Table_5052709673] where [State] is null)
	declare @5_pen float = round((cast(@5_ne as float) / cast(@5_f as float)) * 100.00, 2)
	declare @5_proc int = (select count(*) from [INFINITY2].[Cx_Work].[public].[Table_5052709673] where [State] = 7)
	declare @5_lost int = (select count(*) from [INFINITY2].[Cx_Work].[public].[Table_5052709673] where [State] = 12)

--6
	declare @6_f int = (select count(*) from [INFINITY2].[Cx_Work].[public].[Table_5602983666])
	declare @6_ne int = (select count(*) from [INFINITY2].[Cx_Work].[public].[Table_5602983666] where [State] is not null)
	declare @6_e int = (select count(*) from [INFINITY2].[Cx_Work].[public].[Table_5602983666] where [State] is null)
	declare @6_pen float = round((cast(@6_ne as float) / cast(@6_f as float)) * 100.00, 2)
	declare @6_proc int = (select count(*) from [INFINITY2].[Cx_Work].[public].[Table_5602983666] where [State] = 7)
	declare @6_lost int = (select count(*) from [INFINITY2].[Cx_Work].[public].[Table_5602983666] where [State] = 12)

--7
	declare @7_f int = (select count(*) from [INFINITY2].[Cx_Work].[public].[Table_5068758013])
	declare @7_ne int = (select count(*) from [INFINITY2].[Cx_Work].[public].[Table_5068758013] where [State] is not null)
	declare @7_e int = (select count(*) from [INFINITY2].[Cx_Work].[public].[Table_5068758013] where [State] is null)
	declare @7_pen float = round((cast(@7_ne as float) / cast(@7_f as float)) * 100.00, 2)
	declare @7_proc int = (select count(*) from [INFINITY2].[Cx_Work].[public].[Table_5068758013] where [State] = 7)
	declare @7_lost int = (select count(*) from [INFINITY2].[Cx_Work].[public].[Table_5068758013] where [State] = 12)


--8
	declare @8_f int = (select count(*) from [INFINITY2].[Cx_Work].[public].[Table_5336960870])
	declare @8_ne int = (select count(*) from [INFINITY2].[Cx_Work].[public].[Table_5336960870] where [State] is not null)
	declare @8_e int = (select count(*) from [INFINITY2].[Cx_Work].[public].[Table_5336960870] where [State] is null)
	declare @8_pen float = round((cast(@8_ne as float) / cast(@8_f as float)) * 100.00, 2)
	declare @8_proc int = (select count(*) from [INFINITY2].[Cx_Work].[public].[Table_5336960870] where [State] = 7)
	declare @8_lost int = (select count(*) from [INFINITY2].[Cx_Work].[public].[Table_5336960870] where [State] = 12)

--vip
	declare @v_f int = (select count(*) from [INFINITY2].[Cx_Work].[public].[Table_5601960904])
	declare @v_ne int = (select count(*) from [INFINITY2].[Cx_Work].[public].[Table_5601960904] where [State] is not null)
	declare @v_e int = (select count(*) from [INFINITY2].[Cx_Work].[public].[Table_5601960904] where [State] is null)
	declare @v_pen float = round((cast(@v_ne as float) / cast(@v_f as float)) * 100.00, 2)
	declare @v_proc int = (select count(*) from [INFINITY2].[Cx_Work].[public].[Table_5601960904] where [State] = 7)
	declare @v_lost int = (select count(*) from [INFINITY2].[Cx_Work].[public].[Table_5601960904] where [State] = 12)

	;insert into @t (
		 [name] --название кампании
		,[all] --все долги
		,[unempty] --долги без пустых статусов
		,[empty] --долги с пустым статусом
		,[penetr] --кол-во долгов без пустых статусов / на все долги
		,[proc] --долги со статусом Обработан
		,[proc_%] --кол-во долгов со статусом Обработан / на все долги * 100
		,[lost] --долги со статусом Потерян
		,[lost_%] --кол-во долгов со статусом потерян / на все долги * 100
	)

		select
			 '1'
			,@1_f
			,@1_ne
			,@1_e
			,@1_pen
			,@1_proc
			,round((cast(@1_proc as float) / cast(@1_f as float)) * 100.00	, 2)
			,@1_lost
			,round((cast(@1_lost as float) / cast(@1_f as float)) * 100.00, 2)

	union

		select
			 '2'
			,@2_f
			,@2_ne
			,@2_e
			,@2_pen
			,@2_proc
			,round((cast(@2_proc as float) / cast(@2_f as float)) * 100.00, 2)
			,@2_lost
			,round((cast(@2_lost as float) / cast(@2_f as float)) * 100.00, 2)

	union

		select
			 '3'
			,@3_f
			,@3_ne
			,@3_e
			,@3_pen
			,@3_proc
			,round((cast(@3_proc as float) / cast(@3_f as float)) * 100.00, 2)
			,@3_lost
			,round((cast(@3_lost as float) / cast(@3_f as float)) * 100.00, 2)

	union

		select
			 '4'
			,@4_f
			,@4_ne
			,@4_e
			,@4_pen
			,@4_proc
			,round((cast(@4_proc as float) / cast(@4_f as float)) * 100.00, 2)
			,@4_lost
			,round((cast(@4_lost as float) / cast(@4_f as float)) * 100.00, 2)

	union

		select
			 '5'
			,@5_f
			,@5_ne
			,@5_e
			,@5_pen
			,@5_proc
			,round((cast(@5_proc as float) / cast(@5_f as float)) * 100.00, 2)
			,@5_lost
			,round((cast(@5_lost as float) / cast(@5_f as float)) * 100.00, 2)

	union

		select
			 '6'
			,@6_f
			,@6_ne
			,@6_e
			,@6_pen
			,@6_proc
			,round((cast(@6_proc as float) / cast(@6_f as float)) * 100.00, 2)
			,@6_lost
			,round((cast(@6_lost as float) / cast(@6_f as float)) * 100.00, 2)

	union

		select
			 '7'
			,@7_f
			,@7_ne
			,@7_e
			,@7_pen
			,@7_proc
			,round((cast(@7_proc as float) / cast(@7_f as float)) * 100.00, 2)
			,@7_lost
			,round((cast(@7_lost as float) / cast(@7_f as float)) * 100.00, 2)

	union

		select
			 '8'
			,@8_f
			,@8_ne
			,@8_e
			,@8_pen
			,@8_proc
			,round((cast(@8_proc as float) / cast(@8_f as float)) * 100.00, 2)
			,@8_lost
			,round((cast(@8_lost as float) / cast(@8_f as float)) * 100.00, 2)

	union

		select
			 'v'
			,@v_f
			,@v_ne
			,@v_e
			,@v_pen
			,@v_proc
			,round((cast(@v_proc as float) / cast(@v_f as float)) * 100.00, 2)
			,@v_lost
			,round((cast(@v_lost as float) / cast(@v_f as float)) * 100.00, 2)

return
end



