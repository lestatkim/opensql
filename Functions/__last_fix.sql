use wh_data
go
set ansi_nulls on
go
set quoted_identifier on
go

create function __last_fix (
	@i int
	,@dt date
)

returns varchar(128)
as
begin

	declare @u varchar(128)
	;with
		__w as (
			select max(id) i
			from i_collect.dbo.work_task_log
			where fd !> @dt
			group by r_debt_id
		)
		,u as (
			select id i, f + ' ' + i + ' ' + o u
			from i_collect.dbo.users 
		)
		,fix as (
			select w.r_debt_id i, u.u
			from i_collect.dbo.work_task_log w
				 inner join __w on __w.i = w.id
				 left join u on u.i = w.r_user_id
		)
	select @u = u from fix where i = @i
	;if (@u is null)
		set @u = ''
	;return @u

end;
go
