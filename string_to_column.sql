--Convert string to column
use tempdb
go

/*  @example :
        use tempdb
        go
        select * from ( N'one/two/three/four/five', '/' ) 
*/
if object_id('STRING_TO_COLUMN') is not null
    drop function STRING_TO_COLUMN;

create function STRING_TO_COLUMN(  @str varchar(max), @delimeter char(1) )

    returns @t table ( name nvarchar(max) )
    as 
    BEGIN
	
        declare @i int
        set @i = CHARINDEX(@delimeter, @str)

	    while 1 = 1 
            begin
    		    if @i != 0
                    begin
    			        insert @t values ( left(@str, @i - 1) );

	    		        set @str = right( @str, len(@str) - @i )
		    	        set @i = charindex( @delimeter, @str )
			   	        continue;
    		        end;

	    	    else
		    	    insert @t values(@str)
			        set @str = null
    			    break;
    	    end;

    return
    END
GO


--xml

DECLARE @xml as xml,@str as varchar(100),@delimiter as varchar(10)
SET @str='A,B,C,D,E'
SET @delimiter =','
SET @xml = cast(('<X>'+replace(@str,@delimiter ,'</X><X>')+'</X>') as xml)
SELECT N.value('.', 'varchar(10)') as value 
FROM @xml.nodes('X') as T(N)
;

