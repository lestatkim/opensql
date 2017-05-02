# Стандарт оформленя T-SQL


## Завершайте каждый оператор в задании точкой с запятой

> хорошо
	**CREATE TABLE** dbo.UserInformation;
 
> не хорошо
	**CREATE TABLE** dbo.UserInformation


## Комментарии
* Создавайте комментарии в хранимых процедурах, триггерах и скриптах когда что-либо не является очевидным. *
* В первую очередь пишите зачем нужен этот код, а не что он делает *


## Используйте шапку для процедур / триггеров / функций

> пример
	/*	Author: Name Surname
		Create date: 01.01.2017
		Description: Процедура собирает статистику по всем грузоотправлениям
			За указанный период
		Example: exec KC_FORWARD_STATISCTIC @FROM_date, @to_date
	*/


## Не используйте * в запросах. Указывайте названия столбцов явно

> хорошо
	*SELECT* CustomerID, Street, City
	*FROM* dbo.Address
	*WHERE* City = N‘Санкт-Петербург’;
 
> не хорошо	
	*SELECT* * 
    *FROM* dbo.Address 
    *WHERE* City = N‘Санкт-Петербург’;
 








Используйте нативные названия переменных. Избегайте аббревиатур и односимвольных имен
--хорошо
	DECLARE 
		@item_weight int,
		@company_name nvarchar(64);

--не хорошо	
	DECLARE 
		@IOW int,
		@c nvarchar(64);
 

Соблюдайте DRY (не повторяйтесь)
--хорошо
	DECLARE
		@item_weight int,
		@company_name nvarchar(16);

	SELECT
		@item_weight = 10,
		@company_name = ‘Microsoft’;

--избегайте	
	DECLARE @i int
	DECLARE @j int
	DECLARE @s nvarchar(25)

	SET @i = 5
	SET @j = 0
	SET @s = ‘Apple’


Используйте нижнее_подчеркивание для именования составных пользовательских объектов или CamelStyle (от себя рекомендую использовать нижнее подчеркивание)

--хорошо
	CREATE TABLE dbo.MyTable (
   		MyField int
	);

	CREATE TABLE dbo.MyTable 
	(
   		MyField int
	);

	
	CREATE PROC dbo.KC_MY_PROC 
		@date_FROM date,
		@date_to date
	...



--не хорошо
	CREATE TABLE [User Information];

	DECLARE strangevariableforsomething int;


Используйте префиксы для именования объектов
▪	P - User Stored Procedures
▪	V – Views
▪	FN - Scalar Valued Functions
▪	TF - Table Valued Functions
▪	FK - Foreign keys
▪	DF - Default constraints
▪	IX - Indexes


(Рекомендуется) Используйте имена таблиц - в единственном числе

--хорошо
	CREATE TABLE dbo.Address;
 
--не хорошо	
	CREATE TABLE dbo.Addresses;


Наименование foreing key - используйте сначала имя родительской таблицы

--хорошо
	fk_ParentTableName_ChildTableName
 
--не хорошо
	fk_ChildTableName_ParentTableName



Используйте схему
Всегда используйте схему при создании и использовании 
пользовательских объектов
--хорошо
	CREATE PROC dbo.NEW_ITEM_INSERT
 
--не хорошо	
	CREATE PROC LAST_ITEM_DELETE






Много / одно - строчные операторы
Правильно организуйте операторы
--хорошо, однострочный оператор
	SELECT UserName, Address 
	FROM dbo.my_table;
 





--хорошо, многострочный оператор
	SELECT row_number() over (ORDER BY user_name) row_num,
		user_name, address
	FROM my_table_1 as t1
		JOIN my_table_2 AS t2 ON t2.id = t1.id
	WHERE my_column > 1
		AND user_id IN (
			SELECT user_id
	     	FROM my_table_2
		); 
 
--не хорошо (лишний перевод строки)
	SELECT 
	   UserName 
	FROM 
	   my_table_1
	WHERE 
	   MyField > 1; 
 
--не хорошо (условие and должно стоять в начале условия)	
	SELECT user_name, address
	FROM my_table_1
	WHERE id > 1 AND
   		value < 3;
 
--избегайте смешивания подходов (отсутствует перевод строки перед FROM)
	SELECT user_name, address FROM my_table 
	WHERE value > 1;


Сложные условия
При определении сложных условий, описывайте каждое условие на новой строке. При этом каждая строка должна начинаться с оператора and | or. Исключением может быть случай, когда два или более условия накладываются на один и тот же столбец - в этом случае их можно разместить на одной строке. Делайте отступы, соответствующие уровню вложенности условий. Обозначайте скобками группы условий только там, где это необходимо - объединяя группы из условий ИЛИ условием И.

--хорошо
	SELECT user_name, last_order_date
	FROM table_1
	WHERE first_order_date > '20170101’ 
		AND last_order_date < ‘20170414’
		AND deleted = 0;

--не хорошо
	SELECT 
	   U.Name, U.LastOrderDate
	FROM dbo.[User] AS U
	WHERE U.LastOrderDate > '2001-01-01' AND
	   U.LastOrderDate < '2001-01-31' AND U.deleted = 0;
 
--не хорошо
	SELECT 
	   U.Name, U.LastOrderDate
	FROM dbo.[User] AS U
	WHERE (U.LastOrderDate > '2001-01-01') AND (U.LastOrderDate 	< '2001-01-31'); -- лишние скобки


Отступы, область видимости
При создании области видимости всегда делайте отступ. 
(Рекомендация от себя: при сложных конструкциях, оставляйте комментарии в конце каждой конструкции)
-- хорошо
	WHILE 1 = 1 BEGIN
		(...);
	END; -- WHILE 1 = 1

-- хорошо
	WHILE 1 = 1 
	BEGIN
		(...);
	END;

--не хорошо
	WHILE 1 = 1 
		BEGIN (...) END

--не хорошо
	WHILE 1 = 1 BEGIN (...) END


Отступы внутри многострочных запросов
Перечесление полей в секции SELECT должно быть оформлено единичным оступом по отношению к оператору SELECT. Слова FROM, WHERE, HAVING, GROUP BY, ORDER BY должны находиться на одном уровне с SELECT. При переносе оператора  JOIN, каждый такой оператор должен иметь единичный дополнительный отступ по отношению к FROM. При соединении таблиц по нескольким полям, оператор 
AND должен иметь единичный дополнительный отступ по отношению к 
left JOIN / JOIN / cross apply и так далее.

--хорошо
	SELECT row_number() over (ORDER BY c.id) row_num,
	   c.Name, sum(o.Amount) AS Amount
	FROM Customers AS c
		JOIN Orders AS o ON c.id = o.id 
	   		and o.date = c.date
	WHERE c.Region = 'USA'
	   and c.GENDer = 'Female' 
	GROUP BY c.Name
	HAVING sum(o.Amount) > 100
	ORDER BY o.Amount DESC,
	   c.Name ASC

Скобки
В случае, когда вы используете скобки вокруг многострочных выражений, пользуйтесь одним из ниже приведенных способов
--хорошо (подобная конструкция так же используется в с#)
	RETURN
	(
	  (...)
	);

-- хорошо (личная рекомендация. Избавляет от лишнего перевода строки)
	RETURN (
	  (...)
	);
 
--не хорошо	
	RETURN (
	(...) )


Область видимости и условные операторы
При использовании оператора IFвсегда определяйте область видимости (Рекомендация оставляйте комментарии в конце конструкции)
-- хорошо
	IF 1 > 2
	BEGIN
	   (...);
	END
	ELSE
	BEGIN
	   (...);
	END; -- IF 1 > 2

-- хорошо
	IF 1 > 2 BEGIN
	   (...);
	END
	ELSE BEGIN
	   (...);
	END; --правильно 

 
--не хорошо	
	IF 1 > 2
	   (...)
	ELSE
	   (...)


Область видимости внутри процедур
Всегда определяйте область видимости при создании процедур и функций содержащих более одного оператора
--хорошо
	CREATE PROC dbo.MY_PROCEDURE @param type
	AS
	BEGIN
	   (...);
	END;
 
--не хорошо	
	CREATE PROCEDURE dbo.uspMyProcedure @param type
	AS
	   (...)


Пробелы вокруг операторов
Всегда окружайте пробелами операторы в выражениях (равно, не равно, плюс, минус, меньше, больше, умножение, деление и др)

--правильно
	SET  @i += 1;

--правильно
	SELECT @start_date = min(start_date) 
	FROM table
	WHERE deleted = 0;

--не хорошо
	 SET  @i=1;	

--не хорошо	
	SELECT @start_date=min(start_date) 
	FROM table 
	WHERE deleted=0 AND StartDate>'2010-01-01' ;


Алиасы и джойны
При выполнении джойнов всегда идентифицируйте все столбцы при помощи алиасов. Ключевое слово AS можно опустить.
--правильно
	SELECT u.surname, a.street
	FROM customer AS u
		JOIN address AS a ON u.address_id = a.address_id
 
--не хорошо	
	SELECT U.Surname, Street
	FROM Users U
	JOIN dbo.Address ON U.AddressID = dbo.Address.AddressID


Для джойнов используйте стиль ANSI
Избегайте джойнов, используя секцию WHERE. Вместо этого используйте стиль ANSI. Ключ, на который ссылается JOIN должен стоять в конце.

--хорошо
	SELECT u.surname, a.street
	FROM customer AS u
		JOIN address AS a ON a.address_id = u.address_id
			and a.field_1 = u.field_1
 
--не хорошо	
	SELECT u.surname, a.street
	FROM customer AS u, address AS a
	WHERE U.AddressID = A.AddressID


Используйте LEFT JOIN
Избегайте использования right JOIN - перепишите запрос 
на использование left JOIN.


Хинты
Используя хинты, разделяйте их запятыми.


Не используйте скалярные функции в запросах
Использование скалярных функций в запросах считается дурным тоном и этого стоит избегать по возможности (исключение – генерация композитного идентификатора функцией dbo.fn_getIdEx)

--хорошо	
	SELECT name,
		cast(id / 281474976710656 AS smallint) AS node_id
	FROM table;
 
--не хорошо
	SELECT name,
		dbo.fn_GetNodeIdFROMCompositeId(id) AS node_id	 
	FROM table;







Проверка на наличие объекта

--хорошо
	IF object_id('dbo.MY_FUNC, 'IF') is not null 
	    DROP FUNCTION dbo.MY_FUNC;
	go

--хорошо (proc и procedure – это синонимы, при использовании PROC, названия процедуры встают на один ряд)
	IF object_id('dbo.LAST_ITEM_DELETE, 'P') is not null 
	    DROP PROC dbo.LAST_ITEM_DELETE;
	go

FN = скалярная функция
TF = возвращающая табличное значение функция
P = хранимая процедура
TR = триггер
U = таблица

--не хорошо
	IF EXISTS (SELECT * FROM sys.objects WHERE object_id = 	OBJECT_ID(N'dbo.’MY_PROCEDURE’)
	    AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION dbo.MY_PROCEDURE
	GO


Включайте в свои процедуры строку SET NOCOUNT ON;
--хорошо	
	CREATE PROC dbo.MY_PROC
	AS BEGIN
		SET NOCOUNT ON;
		
		SELECT column_1
		FROM table;

		SET NOCOUNT OFF;
	END;

	
Используйте IFexists (SELECT 1) вместо IFexists (SELECT *)
--хорошо
	IF EXISTS (SELECT 1 FROM table)
		...

--не хорошо
	IF EXISTS (SELECT * FROM table)
		...






Используйте TRY – CATCH для отлова ошибок
--хорошо
	BEGIN try
		--код
	END try
	BEGIN catch
		--код отлова ошибок
	END catch;

https://github.com/lestatkim/opensql

