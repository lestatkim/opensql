USE [i_collect]
GO
/*тестовая функция*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER FUNCTION [dbo].[FILBERT_ivr+sms]

(
	@id int,
	@d1 datetime,
	@d2 datetime
)

RETURNS varchar (7777)

AS

BEGIN

declare @typ varchar(256), @date datetime, @res varchar(256), @phone varchar(256)
declare @empty varchar(8000)

declare my_cursor CURSOR FOR

--ivr

	select
		'Автоинф-р' typ,
		dt dt,
		contact_result_set.text text,
		phone.number phone

	from

		contact_log
		left join contact_result_set on contact_log.result = contact_result_set.code
		left join phone on phone.id = contact_log.r_phone_id

	where
		r_debt_id = @id
		and dt between @d1 and @d2
		and contact_log.typ = 19

--/ivr	

UNION

--sms

	select

		'Смс' typ,
		dt dt,
		di.name text,
		phone.number phone

	from
		debt_sms
		left join phone on phone.id = debt_sms.r_phone_id
		left join
				(
					select
						code,
						name
					from
						dict
					where
						parent_id = 50

				)di 	on debt_sms.status = di.code

	where
		debt_sms.parent_id = @id
		and dt between @d1 and @d2

	order by
		dt

--/sms


OPEN my_cursor;
	
	fetch next from my_cursor into @typ, @date, @res, @phone;
	set @empty = '';

	while (@@FETCH_STATUS = 0)
		BEGIN

			set @empty = @empty+@typ+' '+ convert(varchar, @date,104)+' '+@phone+'-'+ @res + CHAR(13) + CHAR(10);

			fetch next from	my_cursor into @typ, @date, @res, @phone;
		END

	close my_cursor;
	DEALLOCATE my_cursor


RETURN REPLACE(@empty, '(Импортировано из Infinity)', '');

END