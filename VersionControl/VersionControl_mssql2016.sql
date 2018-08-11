/*	Version Control
	Author: Lestat Kim ( lestvt@gmail.com )
		sqlcom.ru | vk.com/sqlcom | @sqlcom
*/

USE master
GO


-- Сначала создаем историческую таблицу
IF NOT EXISTS (
	SELECT 1 
	FROM sys.objects
	WHERE name = 'VersionControlHistory'
		AND type = 'U'
)
	CREATE TABLE dbo.VersionControlHistory(
		Id INT NOT NULL,
		Event sysname NOT NULL,
		Db sysname NOT NULL,
		Sch sysname NOT NULL,
		Object sysname NOT NULL,
		Sql XML NOT NULL,
		Login sysname NOT NULL,
		StartDate DATETIME2(0) NOT NULL,
		EndDate DATETIME2(0) NOT NULL
	)  ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


-- А затем таблицу журнала изменений
IF NOT EXISTS (
	SELECT 1 
	FROM sys.objects
	WHERE name = 'VersionControl'
		AND type = 'U'
)
	CREATE TABLE dbo.VersionControl(
		Id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_VersionControl 
			PRIMARY KEY NONCLUSTERED,
		Event sysname NOT NULL,
		Db sysname NOT NULL,
		Sch sysname NOT NULL,
		Object sysname NOT NULL,
		Sql XML NOT NULL,
		Login sysname NOT NULL,
		StartDate DATETIME2(0) GENERATED ALWAYS AS ROW START NOT NULL,
		EndDate DATETIME2(0) GENERATED ALWAYS AS ROW END NOT NULL,
		PERIOD FOR SYSTEM_TIME (StartDate, EndDate)
	) WITH ( 
		SYSTEM_VERSIONING = ON (
			HISTORY_TABLE = dbo.VersionControlHistory
		)
	);
GO

-- Создадим полезный индекс для обновления таблицы
IF NOT EXISTS (
	SELECT 1
	FROM sys.indexes
	WHERE name = 'IX_VersionControl_upd_key'
)
	CREATE UNIQUE NONCLUSTERED INDEX IX_VersionControl_upd_key 
		ON MASTER.dbo.VersionControl (Db, Sch, Object)
		INCLUDE (Sql, Event, Login);
GO

	
/*

Важно помнить об ограничениях для Temporal Table
1. После создания temporal table вы не можете применять DDL команды ни к основной, ни 
	к исторической таблицам. И нельзя удалять Temporal table.
2. Нельзя изменять данные в исторической таблице

Второе ограничение - логично. Первое решается инструкцией:

ALTER TABLE dbo.VersionControl SET ( SYSTEM_VERSIONING = OFF )

И снова включаем поддержку изменений:

ALTER TABLE dbo.Products SET ( 
	SYSTEM_VERSIONING = ON ( 
		HISTORY_TABLE = dbo.ProductsHistory, 
		DATA_CONSISTENCY_CHECK = OFF
	) 
) 
*/


-- Проинициалирируем существующие объекты
DECLARE @query NVARCHAR(MAX),
	@template NVARCHAR(MAX) = N'
		USE [db]

		INSERT INTO MASTER.dbo.VersionControl WITH (TABLOCKX) (
			Event, Db, Sch, Object, Sql, Login
		) 
			SELECT ''INIT'' AS Event,
				DB_NAME(),
				ss.name AS Sch,
				so.name AS Object,
				CONCAT(''<query><![CDATA['', sasm.definition, '']]></query>'' ),
				SUSER_SNAME() AS Login
			FROM sys.objects AS so
				JOIN sys.schemas AS ss ON ss.schema_id = so.schema_id
				JOIN sys.all_sql_modules AS sasm ON sasm.object_id = so.object_id
			WHERE so.is_ms_shipped = 0
				AND NOT EXISTS (
					SELECT 1
					FROM MASTER.dbo.VersionControl AS vc
					WHERE vc.Db = ''[db]''
						AND vc.Sch = ss.name
						AND vc.Object = so.name
					);
	';
DECLARE @databases TABLE (rn INT, Name sysname);
	INSERT @databases (rn, Name)
		SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) rn, name
		FROM sys.databases
		WHERE owner_sid != 0x01;

DECLARE @i INT = 1, 
	@max INT = (SELECT MAX(rn) FROM @databases),
	@error NVARCHAR(128),
	@db sysname;

WHILE @i < @max BEGIN

	SELECT @query = REPLACE(@template, '[db]', Name),
		@db = Name
	FROM @databases
	WHERE rn = @i;

	BEGIN TRY
		EXECUTE sp_executesql @query;
		SET @i += 1;
		CONTINUE;
	END TRY
	BEGIN CATCH
		SET @error = CONCAT(
			'XML Parsing error. In this case that''s mean one of [', 
			@db, '] object is invalid for convert to XML'
		);
		PRINT @error;
		SET @i += 1;
		CONTINUE;
	END CATCH

END;
GO


-- Создаем DDL Trigger
IF EXISTS (
	SELECT 1
	FROM sys.server_triggers
	WHERE name = 'tr_VersionControl'
)
	DROP TRIGGER tr_VersionControl ON ALL SERVER
GO
CREATE TRIGGER tr_VersionControl ON ALL SERVER
--WITH ENCRYPTION -- по желанию
/*	Указываем отлавливаемые события
	полный список событий: 
		https://docs.microsoft.com/ru-ru/sql/relational-databases/triggers/ddl-events?view=sql-server-2017
*/
FOR
	CREATE_TABLE, ALTER_TABLE, DROP_TABLE,
	CREATE_VIEW, ALTER_VIEW, DROP_VIEW,
	CREATE_FUNCTION, ALTER_FUNCTION, DROP_FUNCTION,
	CREATE_PROCEDURE, ALTER_PROCEDURE, DROP_PROCEDURE,
	CREATE_ASSEMBLY, ALTER_ASSEMBLY, DROP_ASSEMBLY,
	CREATE_INDEX, ALTER_INDEX, DROP_INDEX,
	CREATE_TRIGGER, ALTER_TRIGGER, DROP_TRIGGER,
	RENAME
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE vs
		SET vs.Event =  ev.EventType,
			vs.Sql = CONCAT('<query><!CDATA', ev.Sql, '></query>' ),
			vs.Login = ev.Login
		FROM MASTER.dbo.VersionControl AS vs
			JOIN (
				SELECT * 
				FROM ( VALUES (
						EVENTDATA().value('(/EVENT_INSTANCE/EventType)[1]', 'NVARCHAR(128)'),
						EVENTDATA().value('(/EVENT_INSTANCE/SchemaName)[1]', 'NVARCHAR(128)'),
						EVENTDATA().value('(/EVENT_INSTANCE/ObjectName)[1]', 'NVARCHAR(128)'),
						EVENTDATA().value('(/EVENT_INSTANCE/TSQLCommand/CommandText)[1]', 'NVARCHAR(MAX)'),
						EVENTDATA().value('(/EVENT_INSTANCE/LoginName)[1]', 'NVARCHAR(128)')
				)) AS Event (EventType, Sch, Object, Sql, Login ) 
			) ev ON vs.Db = DB_NAME()
				AND vs.Sch = ev.Sch
				AND vs.Object = ev.Object
	;

END
GO


-- Включаем триггер
ENABLE TRIGGER tr_VersionControl ON ALL SERVER
GO


-- Для удобного просмотра таблицы с версиями создадим процедуру
CREATE PROC dbo.sp_Vc 
	@db sysname = '%', 
	@sch sysname = '%',
	@obj sysname = '%',
	@from DATETIME2(0) = NULL,
	@to DATETIME2(0) = NULL

AS
BEGIN
	SET NOCOUNT ON;
	
	IF @from IS NULL AND @to IS NULL BEGIN
		SELECT *
		FROM master.dbo.VersionControl
		WHERE Db LIKE @db
			AND Sch LIKE @sch
			AND Object LIKE @obj
		ORDER BY StartDate DESC
	END
	ELSE BEGIN	
		SELECT *
		FROM master.dbo.VersionControl FOR SYSTEM_TIME BETWEEN @from AND @to
		WHERE Db LIKE @db
			AND Sch LIKE @sch
			AND Object LIKE @obj
		ORDER BY StartDate DESC
	END

END
GO

