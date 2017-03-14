use wh_data
go
set ansi_nulls on
go
set quoted_identifier on
go

create function dbo.__lestvt_percent_rate (
	@id int
)
returns float 
as	/*	dbo.__lestvt_percent_rate
		percent rate for debt's from bank dpd
		:return: float
	*/

begin

	;declare @pr float
	;with
		p as (
			select parent_id b
				  ,id i
				  ,cast(sign_date as date) dt
			from i_collect.dbo.portfolio
		)
		,d as (
			select id i
				  ,r_portfolio_id pid
				  ,[status] s
				  ,cast([start_date] as date) dt
			from i_collect.dbo.debt
			where [status] not in (6,7,8,10)
		)
		,x as (
			select d.i, p.b, datediff(day, d.dt, p.dt) p
			from p inner join d on d.pid = p.i
		)
	
	select 
		@pr = (
			case
				--ATB
				when b = 9 and p between 0 and 60 then 0.11
				when b = 9 and p between 61 and 90 then 0.12
				when b = 9 and p between 91 and 180 then 0.14
				when b = 9 and p between 181 and 270 then 0.175
				when b = 9 and p between 271 and 360 then 0.195
				when b = 9 and p between 361 and 720 then 0.23
				when b = 9 and p !< 721 then 0.25

				--BB_Agent
				when b = 63 and p between 0 and 180 then 0.14
				when b = 63 and p between 181 and 360 then 0.16
				when b = 63 and p between 361 and 720 then 0.19
				when b = 63 and p between 721 and 1000 then 0.22
				when b = 63 and p !< 1000 then 0.26

				--BMW
				when b = 73 and p between 0 and 30 then 0.07
				when b = 73 and p between 31 and 60 then 0.11
				when b = 73 and p between 61 and 90 then 0.14
				when b = 73 and p between 91 and 180 then 0.2
				when b = 73 and p between 181 and 360 then 0.225
				when b = 73 and p !< 361 then 0.3

				--Vivus
				when b = 51 and p between 0 and 180 then 0.2
				when b = 51 and p between 181 and 360 then 0.22
				when b = 51 and p !< 361 then 0.24
				
				--Jet_Money 
				when b = 30 and p between 0 and 60 then 0.15
				when b = 30 and p between 61 and 120 then 0.2
				when b = 30 and p between 121 and 210 then 0.26
				when b = 30 and p between 211 and 300 then 0.29
				when b = 30 and p !< 301 then 0.35
				
				--E_zaem
				when b = 57 and p between 0 and 150 then 0.21
				when b = 57 and p between 151 and 180 then 0.24
				when b = 57 and p between 181 and 360 then 0.25
				when b = 57 and p !< 361 then 0.28
				
				--Credit_Europe_Bank
				when b = 67 and p between 0 and 30 then 0.07
				when b = 67 and p between 31 and 90 then 0.1
				when b = 67 and p between 91 and 120 then 0.15
				when b = 67 and p between 121 and 180 then 0.2
				when b = 67 and p between 181 and 360 then 0.24
				when b = 67 and p between 361 and 540 then 0.27
				when b = 67 and p between 541 and 720 then 0.3
				when b = 67 and p !< 721 then 0.35

				--MTS
				when b = 75 and p between 0 and 90 then 0.07
				when b = 75 and p between 91 and 210 then 0.2
				when b = 75 and p !< 211 then 0.29

				--SKM
				when b = 25 and p between 0 and 90 then 0.14
				when b = 25 and p between 91 and 180 then 0.16
				when b = 25 and p between 181 and 360 then 0.18
				when b = 25 and p between 361 and 720 then 0.2
				when b = 25 and p !< 721 then 0.22

				--SMS_Finans
				when b = 50 and p between 0 and 180 then 0.2
				when b = 50 and p between 181 and 360 then 0.22
				when b = 50 and p !< 361 then 0.24
				
				--Phoenix
				when b = 71 then 0.18
				
				--Credit_Incassa
				when b = 78 then 0.4
				
				--Raiffaizen
				when b = 77 then 0.2 
			end
		)
	from x
	where i = @id
		
	;if (@pr is null)
		set @pr = 1
	;return @pr

end;
go

