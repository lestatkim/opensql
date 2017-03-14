USE [i_collect]
GO
/*Функция возвращает информацию по входящему/исходящему звонку и выезду */
/*Автор Лестат*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FILBERT_zvonok_i_viezd]

(
	@id int,
	@d1 datetime,
	@d2 datetime
)

RETURNS varchar (7777)

AS

BEGIN

declare @typ varchar(256), @date datetime, @res varchar(256), @info varchar(256)
declare @empty varchar(8000)

declare my_cursor CURSOR FOR

/*zvonok*/
	select
		'Звонок: ' typ,
		dt dt,
		contact_result_set.text text,
		phone.number info

	from

		contact_log
		left join contact_result_set on contact_log.result = contact_result_set.code
		left join phone on phone.id = contact_log.r_phone_id

	where
		r_debt_id = @id
		and dt between @d1 and @d2
		and contact_log.typ in (1,3)
/*zvonok*/

UNION

/*viezd*/
	select
	'Выезд: ' typ,
	dt dt,
	contact_result_set.text text,
	address.full_adr info

from

	contact_log
	left join contact_result_set on contact_log.result = contact_result_set.code
	left join address on contact_log.r_adres_id = address.id

where
	r_debt_id = @id
	and dt between @d1 and @d2
	and contact_log.typ = 2
/*viezd*/


OPEN my_cursor;
	
	fetch next from my_cursor into @typ, @date, @res, @info;
	set @empty = '';

	while (@@FETCH_STATUS = 0)
		BEGIN

			set @empty = @empty+@typ+'дата:'+ convert(varchar, @date,104)+' '+@info+'-'+ @res+';' + CHAR(13) + CHAR(10);

			fetch next from	my_cursor into @typ, @date, @res, @info;
		END

	close my_cursor;
	DEALLOCATE my_cursor


RETURN @empty;

END