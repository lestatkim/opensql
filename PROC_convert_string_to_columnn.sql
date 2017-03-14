--Convert string to column
use tempdb
go

/*  @example :
    use tempdb
    go

    select * from ( N'one/two/three/four/five', '/' ) 
*/

create function String_to_column(  @str nvarchar(max), @delimeter nchar(1) )
    
    /*  don't forget to click on Star ;) if u like it
    */
    returns @t table ( name nvarchar(max) )
    as BEGIN
	
	    declare @i int
    	set @i = CHARINDEX(@delimeter, @str)

	    while 1 = 1 begin
    		if @i != 0 begin
    			insert @t values (left(@str, @i - 1))
	    		set @str = right(@str, len(@str) - @i)
		    	set @i = CHARINDEX(@delimeter, @str)
			   	continue;
    		end;

	    	else
		    	insert @t values(@str)
			    set @str = null
    			break;
    	end;

    return
    END

--https://github.com/lestatkim/opensql

