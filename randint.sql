

/*	Function that returns a random number in the range
*/
use msdb
go

if object_id('__randint_view', 'V') is not null
	drop view __randint_view;
go

create view __randint_view as 
	select rand() i
go

if object_id('__randint') is not null
	drop function __randint
go

create function __randint(@from int, @to int)
	returns int
	as
	begin
		declare @return int;	
		set @return = @from + round(
			(select top 1 i from __randint_view) * (@to - @from), 0
		);
		return @return
	end;
go

/*	Examples random number between 2 and 8:
		1.	declare @i int = msdb.dbo.__randint(2, 8)
			print @i
		2.	select msdb.dbo.__randint(2, 8)
*/