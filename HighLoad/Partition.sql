-- Удаляем по классике таблицы перед созданием
IF EXISTS (SELECT * FROM sys.tables WHERE name = N'SalesSource')
    DROP TABLE SalesSource;
IF EXISTS (SELECT * FROM sys.tables WHERE name = N'SalesTarget')
    DROP TABLE SalesTarget;
IF EXISTS (SELECT * FROM sys.partition_schemes WHERE name = N'psSales')
    DROP PARTITION SCHEME psSales;
IF EXISTS (SELECT * FROM sys.partition_functions WHERE name = N'pfSales')
    DROP PARTITION FUNCTION pfSales;
 

-- Создаём функцию секционирования
CREATE PARTITION FUNCTION pfSales (DATE)
AS RANGE RIGHT FOR VALUES 
('2018-11-07', '2018-11-08', '2018-11-09');
 
-- Создаем схему секционирования
CREATE PARTITION SCHEME psSales
AS PARTITION pfSales 
ALL TO ([Primary]);
 

-- Создаем секционированную таблицу источник (кучу)
CREATE TABLE SalesSource (
    SalesDate DATE,
    Quantity INT
) ON psSales(SalesDate);


-- Вставляем тестовые данные
INSERT INTO SalesSource(SalesDate, Quantity)
SELECT DATEADD(DAY,dates.n-1,'2012-01-01') AS SalesDate, qty.n AS Quantity
FROM GetNums(1, DATEDIFF(DD,'2012-01-01','2013-01-01')) dates
CROSS JOIN GetNums(1, 1000) AS qty;


-- Создаем секционированную таблицу назначения (кучу)
CREATE TABLE SalesTarget (
    SalesDate DATE,
    Quantity INT
) ON psSales(SalesDate);
 

-- Проверяем кол-во строк перед переключением
SELECT 
	pstats.partition_number AS PartitionNumber
	,pstats.row_count AS PartitionRowCount
FROM sys.dm_db_partition_stats AS pstats
WHERE pstats.object_id = OBJECT_ID('SalesSource')
ORDER BY PartitionNumber;
SELECT 
	pstats.partition_number AS PartitionNumber
	,pstats.row_count AS PartitionRowCount
FROM sys.dm_db_partition_stats AS pstats
WHERE pstats.object_id = OBJECT_ID('SalesTarget')
ORDER BY PartitionNumber; 


-- Включаем стат
SET STATISTICS TIME ON;

-- Снова проверяем на сколько это быстро
ALTER TABLE SalesSource SWITCH PARTITION 1 TO SalesTarget PARTITION 1;

-- Выключаем статистику
SET STATISTICS TIME OFF;

-- Проверям кол-во строк после переключения
SELECT 
	pstats.partition_number AS PartitionNumber
	,pstats.row_count AS PartitionRowCount
FROM sys.dm_db_partition_stats AS pstats
WHERE pstats.object_id = OBJECT_ID('SalesSource')
ORDER BY PartitionNumber; 
SELECT 
	pstats.partition_number AS PartitionNumber
	,pstats.row_count AS PartitionRowCount
FROM sys.dm_db_partition_stats AS pstats
WHERE pstats.object_id = OBJECT_ID('SalesTarget')
ORDER BY PartitionNumber; 


-- Смотрим ошибки
SELECT message_id, text 
FROM sys.messages 
WHERE language_id = 1033
AND text LIKE '%ALTER TABLE SWITCH%';