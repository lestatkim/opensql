# -*- coding: utf-8 -*-

sqlcom = '#sqlcom'
insert = """
Инструкция INSERT добавляет одну
или несколько строк в таблицу
или представление SQL Server

--пример с values
declare @i int = 5;
declare @t table (
     field_1 tinyint identity(1, 1)
    ,field_2 tinyint
);

while @i != 0 begin
    insert into @t (field_2) values (@i);
    set @i -= 1
end;

select * from @t

--пример с селект
declare @t table (
    var system
);

insert @t
    select top 5 name
    from sys.table

select * from @t;

"""
delete = """
Инструкция DELETE удаляет одну
или несколько строк из таблицы
или представления в SQL Server

--пример
declare @t table (
   id smallint identity(1, 1)
  ,name varchar(16)
);
insert into @t (name) values ('one');
insert into @t (name) values ('two');
insert into @t (name) values ('three');

delete from @t
where id = 3;

select * from @t;

"""
update = """
Инструкция UPDATE изменяет
существующие данные в таблице
или представлении в SQL Server

--пример
declare @t table (
  name varchar(16)
);
insert into @t (name) values ('one');
insert into @t (name) values ('2');

update @t
set name = 'two'
where name = '2';

select * from @t;

"""