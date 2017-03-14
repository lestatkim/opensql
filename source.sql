


if (select object_id('source')) is not null 
    drop procedure source
go

create procedure source ( @param varchar(max) )
as
  print OBJECT_DEFINITION(OBJECT_ID(@param))
go
