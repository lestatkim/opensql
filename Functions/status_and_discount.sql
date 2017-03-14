USE [i_collect]
GO
/*Функция возвращает статус долга + акцию*/
/*Автор Лестат*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER FUNCTION [dbo].[FILBERT_work_result_with_debtor]

(
	@id int
)

RETURNS varchar (777)

AS

BEGIN

declare @status varchar(256), @discount varchar(256)
declare @empty varchar(777)

declare my_cursor CURSOR FOR


	select
		status.name status,
		(case when dis.name like '%минимальная%' then 'Цессия' else replace(dis.name, '(КЕБ) ', '') end) info
	

	from
		debt as d
		inner join
				(
					select
						dd.r_debt_id,
						dis.name
					from
						debt_discount as dd
						inner join
								(
									select
										id,
										name
									from
										discount

								)dis 	on dd.r_discount_id = dis.id
										
				)dis 	on d.id = dis.r_debt_id

		left join
				(
					select 
						code,
						name
					from
						dict
					where
						parent_id = 6
				)status		on d.status = status.code

	where
		d.id = @id


OPEN my_cursor;
	
	fetch next from my_cursor into @status, @discount;
	set @empty = '';

	while (@@FETCH_STATUS = 0)
		BEGIN

			set @empty = 'Статус:'+@status+' '+'Акция:'+@discount;

			fetch next from	my_cursor into @status,@discount;
		END

	close my_cursor;
	DEALLOCATE my_cursor

RETURN @empty;

END