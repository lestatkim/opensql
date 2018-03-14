/*Создаем гипотетический индекс*/
CREATE NONCLUSTERED INDEX [IXO_Test]
ON [dbo].[Booking_tbl] ([Booked])
INCLUDE ([BookingId],[BookingRef],[BookingTypeId],[Title],[SiteId],[BalanceDue],[BalanceDueDate],[BalanceDueDays],[BookedDate])
WITH STATISTICS_ONLY = -1

/* Убедимся что наш гипотетический индекс существует */
SELECT ss.name,
       id,
       indid,
       dpages,
       rowcnt
FROM sysindexes ss
JOIN sys.indexes i ON i.name = ss.name
WHERE i.object_id = 1927013946 
ORDER BY indid 


/* Указываем какие из индексов будут участвовать в поиске */
/*
К вопросу о TypeID, это наверное поле type из sys.sysindexes
0 = Heap (Собственно данные таблицы)
1 = Clustered
2 = Nonclustered
3 = XML
4 = Spatial
5 = Clustered xVelocity memory optimized columnstore index (Reserved for future use.)
6 = Nonclustered columnstore index
*/

/*
DBCC AUTOPILOT (typeid [, dbid [, {maxQueryCost | tabid [, indid [, pages [, flag [, rowcounts]]]]} ]])
*/
DBCC AUTOPILOT (1, 8, 1927013946, 1, 0, 0, 0)
DBCC AUTOPILOT (2, 8, 1927013946, 10, 0, 0, 0)
DBCC AUTOPILOT (2, 8, 1927013946, 24, 0, 0, 0)
DBCC AUTOPILOT (2, 8, 1927013946, 55, 0, 0, 0)
DBCC AUTOPILOT (2, 8, 1927013946, 74, 0, 0, 0)
DBCC AUTOPILOT (2, 8, 1927013946, 80, 0, 0, 0)
DBCC AUTOPILOT (2, 8, 1927013946, 84, 0, 0, 0)
DBCC AUTOPILOT (2, 8, 1927013946, 86, 0, 0, 0)
DBCC AUTOPILOT (2, 8, 1927013946, 90, 0, 0, 0)
DBCC AUTOPILOT (2, 8, 1927013946, 91, 0, 0, 0)
DBCC AUTOPILOT (2, 8, 1927013946, 108, 0, 0, 0)
DBCC AUTOPILOT (2, 8, 1927013946, 110, 0, 0, 0)
DBCC AUTOPILOT (2, 8, 1927013946, 112, 0, 0, 0)
DBCC AUTOPILOT (2, 8, 1927013946, 125, 0, 0, 0)
DBCC AUTOPILOT (2, 8, 1927013946, 126, 0, 0, 0)
DBCC AUTOPILOT (2, 8, 1927013946, 127, 0, 0, 0)
DBCC AUTOPILOT (2, 8, 1927013946, 131, 0, 0, 0)
DBCC AUTOPILOT (2, 8, 1927013946, 144, 0, 0, 0)
DBCC AUTOPILOT (2, 8, 1927013946, 148, 0, 0, 0)
DBCC AUTOPILOT (2, 8, 1927013946, 151, 0, 0, 0)
DBCC AUTOPILOT (2, 8, 1927013946, 154, 0, 0, 0)
DBCC AUTOPILOT (2, 8, 1927013946, 155, 0, 0, 0)
DBCC AUTOPILOT (2, 8, 1927013946, 156, 0, 0, 0)
DBCC AUTOPILOT (2, 8, 1927013946, 157, 0, 0, 0)
DBCC AUTOPILOT (2, 8, 1927013946, 158, 0, 0, 0)
DBCC AUTOPILOT (0, 8, 1927013946, 159, 0, 0, 0)


/* Проверяем работу гипотетического индекса */
GO 
SET SHOWPLAN_ALL ON 
GO 
SET NOEXEC ON 
GO 
SET AUTOPILOT ON
GO
SELECT TOP 100 BookingId,
               BookingRef,
               BookingTypeId,
               Title,
               SiteId,
               BalanceDue,
               BalanceDueDate,
               BalanceDueDays,
               Booked,
               BookedDate    
     FROM dbo.Booking_tbl (NOLOCK) WHERE Booked = 1 
OPTION (RECOMPILE)
GO
SET SHOWPLAN_ALL OFF 
GO
SET NOEXEC OFF 
GO 
SET AUTOPILOT OFF
GO


