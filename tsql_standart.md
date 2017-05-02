# Стандарт оформления T-SQL

____________________________________________________________



## Завершайте каждый оператор в задании точкой с запятой

Хорошо:
```
    CREATE TABLE dbo.UserInformation (ID INT);
    SET @i += 1;
```
Не хорошо:
```
    CREATE TABLE dbo.UserInformation  (ID INT)
    SET @i = @i + 1
```


## Комментарии
> Создавайте комментарии в хранимых процедурах, триггерах и скриптах когда что-либо не является очевидным.
> В первую очередь пишите зачем нужен этот код, а не что он делает


## Используйте шапку для процедур / триггеров / функций

Пример:
```
/*	Author: Name Surname
	Create date: 01.01.2017
	Description: Процедура собирает статистику по всем грузоотправлениям
		За указанный период
	Example: EXEC dbo.Procedure @from_date, @to_date
*/
```


## Не используйте * в запросах. Указывайте названия столбцов явно

Хорошо:
```
SELECT CustomerID, Street, City
FROM dbo.Address
WHERE City = N‘Санкт-Петербург’;
```
Не хорошо:
```
SELECT * 
FROM dbo.Address 
WHERE City = N‘Санкт-Петербург’;
```


## Используйте нативные названия переменных. Избегайте аббревиатур и односимвольных имен
Хорошо:
```
DECLARE 
    @item_weight INT,
    @company_name NVARCHAR(64);
```

Не хорошо:
```
DECLARE 
    @IOW INT,
    @c NVARCHAR(64);
```
 

## Соблюдайте DRY (не повторяйтесь)
Хорошо:
```
DECLARE
    @item_weight INT,
    @company_name NVARCHAR(16);

SELECT
    @item_weight = 10,
    @company_name = N‘Microsoft’;
```

Избегайте:
```
DECLARE @i INT
DECLARE @j INT
DECLARE @s NVARCHAR(25)

SET @i = 5
SET @j = 0
SET @s = ‘Apple’
```


## Используйте нижнее_подчеркивание для именования составных пользовательских объектов или CamelStyle
Хорошо:
```
CREATE TABLE dbo.MyTable (
    MyField INT
);

CREATE TABLE dbo.my_table
(
    my_field INT
);

CREATE PROC dbo.KC_MY_PROC 
    @date_FROM DATE,
    @date_to DATE
...
```

Не хорошо:
```
CREATE TABLE [User Information];

DECLARE strangevariableforsomething INT;
```

## Используйте префиксы для именования объектов
-	P   - User Stored Procedures
-	V   – Views
-	FN  - Scalar Valued Functions
-	TF  - Table Valued Functions
-	FK  - Foreign keys
-	DF  - Default constraints
-	IX  - Indexes
-   TR  - Trigger


## (Рекомендуется) Используйте имена таблиц - в единственном числе

Хорошо:
```
CREATE TABLE dbo.Address;
```   
 
Избегайте:
```
CREATE TABLE dbo.Addresses;
```

## Наименование foreing key - используйте сначала имя родительской таблицы

Хорошо:
```
fk_ParentTableName_ChildTableName
```
 
Не хорошо:
```
fk_ChildTableName_ParentTableName
```



## Используйте схему
>Всегда используйте схему при создании и использовании 
>пользовательских объектов

Хорошо:
```
CREATE PROC dbo.NEW_ITEM_INSERT;
```
 
Не хорошо:
```
CREATE PROC LAST_ITEM_DELETE
```


## Много / одно - строчные операторы
>Правильно организуйте операторы
Хорошо, однострочный оператор:
```
SELECT UserName, Address 
FROM dbo.my_table;
```
Хорошо, многострочный оператор:
```
SELECT row_number() over (ORDER BY user_name) row_num,
    user_name, address
FROM my_table_1 as t1
    JOIN my_table_2 AS t2 ON t2.id = t1.id
WHERE my_column > 1
    AND user_id IN (
        SELECT user_id
        FROM my_table_2
    );
```
Не хорошо (лишний перевод строки):
```
SELECT 
    UserName 
FROM 
    my_table_1
WHERE 
    MyField > 1; 
```
 
Не хорошо (условие and должно стоять в начале условия):
```
SELECT user_name, address
FROM my_table_1
WHERE id > 1 AND
    value < 3;
```
 
Избегайте смешивания подходов (отсутствует перевод строки перед FROM):
```
SELECT user_name, address FROM my_table 
WHERE value > 1;
```


## Сложные условия
>При определении сложных условий, описывайте каждое условие на новой строке. При этом каждая строка должна начинаться с оператора AND | OR. >Исключением может быть случай, когда два или более условия накладываются на один и тот же столбец - в этом случае их можно разместить на >одной строке. 
>Делайте отступы, соответствующие уровню вложенности условий. Обозначайте скобками группы условий только там, где это необходимо - объединяя группы из условий ИЛИ условием И.

Хорошо:
```
SELECT user_name, last_order_date
FROM dbo.Table
WHERE first_order_date > '20170101’ 
    AND last_order_date < ‘20170414’
    AND deleted = 0;
```
Не хорошо:
```
SELECT 
    U.Name, U.LastOrderDate
FROM dbo.[User] AS U
WHERE U.LastOrderDate > '2001-01-01' AND
    U.LastOrderDate < '2001-01-31' AND U.deleted = 0;
```
 
Не хорошо:
```
SELECT 
    U.Name, U.LastOrderDate
FROM dbo.[User] AS U
WHERE (U.LastOrderDate > '2001-01-01') AND (U.LastOrderDate < '2001-01-31'); -- лишние скобки
```


## Отступы, область видимости
>При создании области видимости всегда делайте отступ. 
>(Рекомендация от себя: при сложных конструкциях, оставляйте комментарии в конце каждой конструкции)
Хорошо:
```
WHILE 1 = 1 BEGIN
    (...);
END; -- WHILE 1 = 1
```

Хорошо:
```
WHILE 1 = 1 
BEGIN
    (...);
END;
```

Не хорошо:
```
WHILE 1 = 1 
    BEGIN (...) END
```

Не хорошо:
```
WHILE 1 = 1 BEGIN (...) END
```


## Отступы внутри многострочных запросов
>Перечесление полей в секции SELECT должно быть оформлено единичным оступом по отношению к оператору SELECT. Слова FROM, WHERE, HAVING, GROUP >BY, ORDER BY должны находиться на одном уровне с SELECT. При переносе оператора  JOIN, каждый такой оператор должен иметь единичный >дополнительный отступ по отношению к FROM. При соединении таблиц по нескольким полям, оператор 
>AND должен иметь единичный дополнительный отступ по отношению к 
>LEFT JOIN / JOIN / CROSS APPLY и так далее.

Хорошо:
```
SELECT ROW_NUMBER() OBER (ORDER BY c.id) row_num,
    c.Name, SUM(o.Amount) AS Amount
FROM dbo.Customers AS c
    JOIN dbo.Orders AS o ON c.id = o.id 
        AND o.date = c.date
WHERE c.Region = 'USA'
    AND c.Gender = 'Female' 
GROUP BY c.Name
HAVING SUM(o.Amount) > 100
ORDER BY o.Amount DESC,
    c.Name ASC
```

## Скобки
>В случае, когда вы используете скобки вокруг многострочных выражений, пользуйтесь одним из ниже приведенных способов

Хорошо (подобная конструкция так же используется в с#):
```
RETURN
(
    (...)
);
```

Хорошо (личная рекомендация. Избавляет от лишнего перевода строки):
```
RETURN (
    (...)
);
```
 
Не хорошо:
```
RETURN (
(...) )
```


## Область видимости и условные операторы
>При использовании оператора IF всегда определяйте область видимости 
>(Рекомендация оставляйте комментарии в конце конструкции)
Хорошо:
```
IF 1 > 2
BEGIN
    (...);
END

ELSE BEGIN
    (...);
END; -- IF 1 > 2
```

Хорошо:
```
IF 1 > 2 BEGIN
    (...);
END

ELSE BEGIN
    (...);
END; --правильно 
```

 
Не хорошо:
```
IF 1 > 2
    (...)
ELSE
    (...)
```

## Область видимости внутри процедур
>Всегда определяйте область видимости при создании процедур и функций содержащих более одного оператора

Хорошо:
```
CREATE PROC dbo.MY_PROCEDURE @param INT
AS
BEGIN
    (...);
END;
```
Не хорошо:
```
CREATE PROCEDURE dbo.uspMyProcedure @param INT
AS
    (...)
```


## Пробелы вокруг операторов
>Всегда окружайте пробелами операторы в выражениях (равно, не равно, плюс, минус, меньше, больше, умножение, деление и др)

Хорошо:
```
SET @i += 1;
```

Хорошо:
```
SELECT @start_date = min(start_date) 
FROM dbo.Table
WHERE deleted = 0;
```

Не хорошо:
```
SET  @i=1;	
```

Не хорошо:
```
SELECT @start_date=min(start_date) 
FROM dbo.Table 
WHERE deleted=0 AND StartDate>'2010-01-01';
```


## Алиасы и джойны
>При выполнении джойнов всегда идентифицируйте все столбцы при помощи алиасов. Ключевое слово AS можно опустить.
Хорошо:
```
SELECT u.surname, a.street
FROM dbo.Customer AS u
    JOIN address AS a ON u.address_id = a.address_id;
```
 
Не хорошо:
```
SELECT U.Surname, Street
FROM dbo.Users U
JOIN dbo.Address ON U.AddressID = dbo.Address.AddressID
```


## Для джойнов используйте стиль ANSI
>Избегайте джойнов, используя секцию WHERE. Вместо этого используйте стиль ANSI. Ключ, на который ссылается JOIN должен стоять в конце.

Хорошо:
```
SELECT u.surname, a.street
FROM dbo.Customer AS u
    JOIN address AS a ON a.address_id = u.address_id
        AND a.field_1 = u.field_1;
```
 
Не хорошо:
```
SELECT u.surname, a.street
FROM Customer AS u, address AS a
WHERE U.AddressID = A.AddressID
```


## Используйте LEFT JOIN
>Избегайте использования RIGHT JOIN - перепишите запрос 
>на использование LEFT JOIN.


## Хинты
>Используя хинты, разделяйте их запятыми.


## Не используйте скалярные функции в запросах
>Использование скалярных функций в запросах считается дурным тоном и этого стоит избегать по возможности 
>(исключение – генерация композитного идентификатора функцией dbo.fn_getIdEx)

Хорошо:
```
SELECT name,
    cast(id / 281474976710656 AS smallint) AS node_id
FROM dbo.Table;
```
 
Не хорошо:
```
SELECT name,
    dbo.fn_GetNodeIdFROMCompositeId(id) AS node_id	 
FROM Table;
```


## Проверка на наличие объекта
>Дело в том что если каждый раз делать DROP и CREATE, то удаляются права на объект, а еще объект может быть в репликации и при пересоздании, из неё он удалится тоже. 

Хорошо:
```
IF OBJECT_ID('dbo.Function, 'IF') IS NULL
    EXEC('CREATE FUNCTION dbo.Function() RETURNS @t TABLE(i INT) BEGIN RETURN END');
GO
ALTER FUNCTION() ..
```

Хорошо:
```
IF OBJECT_ID('dbo.Procedure') IS NULL
    EXEC('CREATE PROC dbo.Procedure AS');
GO
ALTER PROC dbo.Procedure ..
```

Не хорошо:
```
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = 	OBJECT_ID(N'dbo.’MY_PROCEDURE’)
    AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.MY_PROCEDURE
GO
```

[Статья на хабре по теме](https://habrahabr.ru/post/327566/)


## Включайте в свои процедуры строку SET NOCOUNT ON;
Хорошо:
```
CREATE PROC dbo.Procedure @i INT
AS 
BEGIN
SET NOCOUNT ON;
    
    SELECT Field
    FROM dbo.Table
    WHERE id = @i;

SET NOCOUNT OFF;
END
GO
```

## Используйте TRY – CATCH для отлова ошибок
Хорошо:
```
BEGIN TRY
    --код
END TRY

BEGIN CATCH
    --код отлова ошибок
END CATCH;
```

__________________________________________________________________
 *_Спасибо за внимание_*

[sqlcom](http://sqlcom.ru)

[VK](http://vk.com/sqlcom)

[GitHub](https://github.com/lestatkim/opensql)