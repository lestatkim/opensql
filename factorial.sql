
if object_id('dbo.factorial', 'FN') is not null
	drop function dbo.factorial;
go
create function dbo.factorial(@n int)
	
/*	Описание: Функция вычисляет факториал
	от заданного числа. 
	Справка: факториал числа 5 это 1 * 2 * 3 * 4 * 5
	Пример: select dbo.factorial(7)
*/
returns int
as begin
	declare 
		@result int, 
		@i int;

	select 
		@i = 1,
		@result = 1;
	
	while @i !> @n begin
		select
			@result *= @i,
			@i += 1;
	end;

	return @result
end;
go
