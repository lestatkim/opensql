use [i_collect]
GO
/****Добавленная информация (телефоны, адреса)****/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER FUNCTION [dbo].[Filbert_dobavlenie_tel_i_adresa]

	(
		@id int,
		@d1 datetime,
		@d2 datetime
	)

RETURNS varchar (7777)

as 

begin

	declare @typ varchar(256), @info varchar(4000)
	declare @empty varchar(7777)

	declare my_cursor CURSOR FOR

/*adresa*/
	select
		'Адрес:' typ,
		a.full_adr info

	from	
		portfolio as p
		inner join debt as d on p.id = d.r_portfolio_id
		inner join person as per on d.parent_id = per.id
		left join address a on a.parent_id = per.id

	where
		d.id = @id
		and a.load_dt between @d1 and @d2
		and a.load_dt > dateadd(day, 3, p.sign_date)
		and a.dsc != 'Импортировано при загрузке данных.'
/*adresa*/

UNION

/*phones*/

	select
		'Телефон:' typ,
		ph.number info

	from
		portfolio as p
		inner join debt as d on p.id = d.r_portfolio_id
		inner join person as per on d.parent_id = per.id
		left join phone ph on ph.parent_id = per.id

	where
		d.id = @id
		and ph.load_dt between @d1 and @d2
		and ph.load_dt > p.sign_date
		and ph.dsc != 'Импортировано при загрузке данных.'
/*phones*/


open my_cursor;
	
	fetch next from my_cursor into @typ, @info;
	set @empty = '';

	while (@@FETCH_STATUS = 0)
		begin
			
			set @empty = @typ+@info+char(13)+char(10)

			fetch next from my_cursor into @typ, @info;

		end

	close my_cursor;
	DEALLOCATE my_cursor

RETURN @empty

END