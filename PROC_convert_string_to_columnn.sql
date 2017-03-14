--
<<<<<<< HEAD
-- Convert string to column
-- arguments : (string, delimeter)
-- example : select * from (N'one/two/three/four/five', '/')


CREATE FUNCTION string_to_column(
	 @str nvarchar(max)
	,@delimeter nchar(1)
)
returns @t table (
	name nvarchar(max)
)
=======
/*	Parse string to table
	arguments : (string, delimeter)
	example : select * from (N'one/two/three/four/five', '/')
*/

CREATE FUNCTION string_to_table(
	 @str nvarchar(max)
	,@delimeter nchar(1)
)
returns @t table ( name nvarchar(max) )
>>>>>>> a90bc14a79430bb5d3904bc26306c0579432910b
as BEGIN
		
	declare @i int

	set @i = CHARINDEX(@delimeter, @str)

	while 1 = 1 begin
		if @i != 0 begin
			insert @t values (left(@str, @i - 1))
				set @str = right(@str, len(@str) - @i)
				set @i = CHARINDEX(@delimeter, @str)
				continue;
		end
		else
			insert @t values(@str)
			set @str = null
			break;
	end;

return
END
<<<<<<< HEAD
=======



>>>>>>> a90bc14a79430bb5d3904bc26306c0579432910b
