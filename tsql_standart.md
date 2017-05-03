# Стандарт оформления T-SQL
###### версия 1.0.3.1

____________________________________________________________

## Имена объектов

|Объект|Длина|Префикс|Допустимые символы|Пример|
|------|-----|-------|------------------|------|
|Database|30| |[A-z]|MYDATABASE|
|Database Trigger|50|DTR_|[A-z]|DTR_CheckLogin|
|Schema|30| |[A-z][0-9]|myschema|
|File Table|128|FT_|[A-z][0-9]|FT_MyTable|
|Global Temporary Table|128| |##[A-z][0-9]|##MyTable|
|Local Temporary Table|128| |#[A-z][0-9]|#MyTable|
|Table|30| |[A-z][0-9]|MyTable|
|Table Column|30| |[A-z][0-9]|MyColumn|
|Table Default Values|128|DF_|[A-z][0-9]|DF_MyTable_MyColumn|
|Table Check Column Constraint|128|CK_|[A-z][0-9]|CK_MyTable_MyColumne|


## Завершайте каждый оператор в задании точкой с запятой

Хорошо:
```sql
CREATE TABLE dbo.UserInformation (ID INT);
SET @i += 1;
```
Не хорошо:
```sql
CREATE TABLE dbo.UserInformation (ID INT)
SET @i = @i + 1
```


## Комментарии
> Создавайте комментарии в хранимых процедурах, 
> триггерах и скриптах, когда что-либо не является очевидным.
> В первую очередь пишите зачем нужен этот код, а не что он делает


## Используйте шапку для процедур / триггеров / функций

Пример:
```sql
/*	Author: Name Surname
	Create date: 01.01.2017
	Description: Процедура собирает статистику 
        по всем грузоотправлениям за указанный период
	Example: EXEC dbo.Procedure @from_date, @to_date
*/
```


## Не используйте * в запросах. Указывайте названия столбцов явно

Хорошо:
```sql
SELECT CustomerID, Street, City
FROM dbo.Address
WHERE City = N‘Санкт-Петербург’;
```
Не хорошо:
```sql
SELECT * 
FROM dbo.Address 
WHERE City = N‘Санкт-Петербург’;
```


## Используйте нативные названия переменных. Избегайте аббревиатур и односимвольных имен
Хорошо:
```sql
DECLARE
    @item_weight INT,
    @company_name NVARCHAR(64);
```

Не хорошо:
```sql
DECLARE 
    @IOW INT,
    @c NVARCHAR(64);
```
 

## Соблюдайте DRY (не повторяйтесь)
Хорошо:
```sql
DECLARE
    @item_weight INT,
    @company_name NVARCHAR(16);

SELECT
    @item_weight = 10,
    @company_name = N‘Microsoft’;
```

Избегайте:
```sql
DECLARE @i INT
DECLARE @j INT
DECLARE @s NVARCHAR(25)

SET @i = 5
SET @j = 0
SET @s = ‘Apple’
```


## Используйте нижнее_подчеркивание для именования составных пользовательских объектов или CamelStyle
Хорошо:
```sql
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
```sql
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
```sql
CREATE TABLE dbo.Address;
```   
 
Избегайте:
```sql
CREATE TABLE dbo.Addresses;
```

## Наименование foreing key - используйте сначала имя родительской таблицы

Хорошо:
```sql
fk_ParentTableName_ChildTableName
```
 
Не хорошо:
```sql
fk_ChildTableName_ParentTableName
```



## Используйте схему
>Всегда используйте схему при создании и использовании 
>пользовательских объектов

Хорошо:
```sql
CREATE PROC dbo.NEW_ITEM_INSERT;
```
 
Не хорошо:
```sql
CREATE PROC LAST_ITEM_DELETE
```


## Много / одно - строчные операторы
>Правильно организуйте операторы

Хорошо, однострочный оператор:
```sql
SELECT UserName, Address 
FROM dbo.my_table;
```
Хорошо, многострочный оператор:
```sql
SELECT ROW_NUMBER() OVER (ORDER BY user_name) row_num,
    user_name, address
FROM dbo.Table_1 AS t1
    JOIN dbo.Table_2 AS t2 ON t2.id = t1.id
        AND t2.Value > 100
WHERE t1.String = N'ABC'
    AND t1.user_id IN (
        SELECT user_id
        FROM dbo.Table_3
    );
```
Не хорошо (лишний перевод строки):
```sql
SELECT 
    UserName 
FROM 
    my_table_1
WHERE 
    MyField > 1; 
```
 
Не хорошо (условие and должно стоять в начале условия):
```sql
SELECT user_name, address
FROM my_table_1
WHERE id > 1 AND
    value < 3;
```
 
Избегайте смешивания подходов (отсутствует перевод строки перед FROM):
```sql
SELECT user_name, address FROM my_table 
WHERE value > 1;
```


## Сложные условия
>При определении сложных условий, описывайте каждое условие на новой строке. При этом каждая строка должна начинаться с оператора AND | OR. >Исключением может быть случай, когда два или более условия накладываются на один и тот же столбец - в этом случае их можно разместить на >одной строке.Делайте отступы, соответствующие уровню вложенности условий. Обозначайте скобками группы условий только там, где это необходимо - объединяя группы из условий ИЛИ условием И.

Хорошо:
```sql
SELECT user_name, last_order_date
FROM dbo.Table
WHERE first_order_date > '20170101’ 
    AND last_order_date < ‘20170414’
    AND deleted = 0;
```
Не хорошо:
```sql
SELECT 
    U.Name, U.LastOrderDate
FROM dbo.[User] AS U
WHERE U.LastOrderDate > '2001-01-01' AND
    U.LastOrderDate < '2001-01-31' AND U.deleted = 0;
```
 
Не хорошо:
```sql
SELECT 
    U.Name, U.LastOrderDate
FROM dbo.[User] AS U
WHERE (U.LastOrderDate > '2001-01-01') AND (U.LastOrderDate < '2001-01-31'); -- лишние скобки
```


## Отступы, область видимости
>При создании области видимости всегда делайте отступ. 
>(Рекомендация от себя: при сложных конструкциях, оставляйте комментарии в конце каждой конструкции)
Хорошо:
```sql
WHILE 1 = 1 BEGIN
    (...);
END; -- WHILE 1 = 1
```

Хорошо:
```sql
WHILE 1 = 1 
BEGIN
    (...);
END;
```

Не хорошо:
```sql
WHILE 1 = 1 
    BEGIN (...) END
```

Не хорошо:
```sql
WHILE 1 = 1 BEGIN (...) END
```


## Отступы внутри многострочных запросов
>Перечесление полей в секции SELECT должно быть оформлено единичным оступом по отношению к оператору SELECT. Слова FROM, WHERE, HAVING, GROUP >BY, ORDER BY должны находиться на одном уровне с SELECT. При переносе оператора  JOIN, каждый такой оператор должен иметь единичный >дополнительный отступ по отношению к FROM. При соединении таблиц по нескольким полям, оператор 
>AND должен иметь единичный дополнительный отступ по отношению к 
>LEFT JOIN / JOIN / CROSS APPLY и так далее.

Хорошо:
```sql
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
```sql
RETURN
(
    (...)
);
```

Хорошо (личная рекомендация. Избавляет от лишнего перевода строки):
```sql
RETURN (
    (...)
);
```
 
Не хорошо:
```sql
RETURN (
(...) )
```


## Область видимости и условные операторы
>При использовании оператора IF всегда определяйте область видимости 
>(Рекомендация оставляйте комментарии в конце конструкции)
Хорошо:
```sql
IF 1 > 2
BEGIN
    (...);
END

ELSE BEGIN
    (...);
END; -- IF 1 > 2
```

Хорошо:
```sql
IF 1 > 2 BEGIN
    (...);
END

ELSE BEGIN
    (...);
END; --правильно 
```

 
Не хорошо:
```sql
IF 1 > 2
    (...)
ELSE
    (...)
```

## Область видимости внутри процедур
>Всегда определяйте область видимости при создании процедур и функций содержащих более одного оператора

Хорошо:
```sql
CREATE PROC dbo.MY_PROCEDURE @param INT
AS
BEGIN
    (...);
END;
```
Не хорошо:
```sql
CREATE PROCEDURE dbo.uspMyProcedure @param INT
AS
    (...)
```


## Пробелы вокруг операторов
>Всегда окружайте пробелами операторы в выражениях (равно, не равно, плюс, минус, меньше, больше, умножение, деление и др)

Хорошо:
```sql
SET @i += 1;
```

Хорошо:
```sql
SELECT @start_date = min(start_date) 
FROM dbo.Table
WHERE deleted = 0;
```

Не хорошо:
```sql
SET  @i=1;	
```

Не хорошо:
```sql
SELECT @start_date=min(start_date) 
FROM dbo.Table 
WHERE deleted=0 AND StartDate>'2010-01-01';
```


## Алиасы и джойны
>При выполнении джойнов всегда идентифицируйте все столбцы при помощи алиасов. Ключевое слово AS можно опустить.
Хорошо:
```sql
SELECT u.surname, a.street
FROM dbo.Customer AS u
    JOIN address AS a ON u.address_id = a.address_id;
```
 
Не хорошо:
```sql
SELECT U.Surname, Street
FROM dbo.Users U
JOIN dbo.Address ON U.AddressID = dbo.Address.AddressID
```


## Для джойнов используйте стиль ANSI
>Избегайте джойнов, используя секцию WHERE. Вместо этого используйте стиль ANSI. Ключ, на который ссылается JOIN должен стоять в конце.

Хорошо:
```sql
SELECT u.surname, a.street
FROM dbo.Customer AS u
    JOIN address AS a ON a.address_id = u.address_id
        AND a.field_1 = u.field_1;
```
 
Не хорошо:
```sql
SELECT u.surname, a.street
FROM Customer AS u, address AS a
WHERE U.AddressID = A.AddressID
```



## Хинты
>Используя хинты, разделяйте их запятыми.


## Не используйте скалярные функции в запросах
>Использование скалярных функций в запросах считается дурным тоном и этого стоит избегать по возможности 
>(исключение – генерация композитного идентификатора функцией dbo.fn_getIdEx)

Хорошо:
```sql
SELECT name,
    cast(id / 281474976710656 AS smallint) AS node_id
FROM dbo.Table;
```
 
Не хорошо:
```sql
SELECT name,
    dbo.fn_GetNodeIdFROMCompositeId(id) AS node_id	 
FROM Table;
```


## Проверка на наличие объекта
>Дело в том что если каждый раз делать DROP и CREATE, то удаляются права на объект, а еще объект может быть в репликации и при пересоздании, из неё он удалится тоже. 

Хорошо:
```sql
IF OBJECT_ID('dbo.Function', 'IF') IS NULL
    EXEC('CREATE FUNCTION dbo.Function() RETURNS @t TABLE(i INT) BEGIN RETURN END');
GO
ALTER FUNCTION() ..
```

Хорошо:
```sql
IF OBJECT_ID('dbo.Procedure', 'P') IS NULL
    EXEC('CREATE PROC dbo.Procedure AS');
GO
ALTER PROC dbo.Procedure ..
```

Не хорошо:
```sql
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.MY_PROCEDURE')
    AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.MY_PROCEDURE
GO
```

[Статья на хабре по теме](https://habrahabr.ru/post/327566/)


## Включайте в свои процедуры строку SET NOCOUNT ON;
Хорошо:
```sql
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
```sql
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