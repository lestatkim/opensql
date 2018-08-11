
CREATE TABLE DataBaseChange (
	id int NOT NULL IDENTITY(1,1)
	, event sysname NOT NULL
	, db sysname NOT NULL
	, sch sysname NOT NULL
	, object sysname NOT NULL
	, sql XML NOT NULL
	, login sysname NOT NULL
	, date datetime2(0) NOT NULL
	, [commit] NVARCHAR(256) NULL
	, CONSTRAINT [PK_dbo_DataBaseChange_ID]
		PRIMARY KEY CLUSTERED (id ASC)
	)
;
	
IF NOT EXISTS(
	SELECT 1
	FROM sys.indexes si
	WHERE si.object_id = OBJECT_ID(N'dbo.DataBaseChange', N'U')
		AND si.name = 'IX_dbo_DataBaseChange_ObjectName_ChangeDate'
    )
BEGIN
	CREATE NONCLUSTERED INDEX IX_dbo_DataBaseChange_ObjectName_ChangeDate
		ON DataBaseChange (
			object,
			date
			)
END
;

IF NOT EXISTS(
    SELECT 1
    FROM sys.indexes si
    WHERE si.object_id = OBJECT_ID(N'dbo.DataBaseChange', N'U')
      AND si.name = 'IX_dbo_DataBaseChange_ChangeDate'
    )
BEGIN
	CREATE NONCLUSTERED INDEX IX_dbo_DataBaseChange_ChangeDate
		ON DataBaseChange(date)
END
;

INSERT INTO master.dbo.[DataBaseChange] (
	event,
	db,
	sch,
	object,
	sql,
	login,
	date
	)
    SELECT 'INIT' as EventType
		, DB_NAME()
        , ss.name as SchemaName
        , so.name as ObjectName
		, CONCAT('<query><![CDATA[', sasm.[definition], ']]></query>' ) AS ObjectDefinition
        , SUSER_SNAME() AS LoginName
        , GETDATE() AS ChangeDate
    FROM sys.objects so
        JOIN sys.schemas ss ON ss.schema_id = so.schema_id
        JOIN sys.all_sql_modules sasm ON sasm.object_id = so.object_id
    WHERE so.is_ms_shipped = 0
		AND NOT EXISTS (
			SELECT 1
			FROM master.dbo.DataBaseChange dboc 
			WHERE dboc.object = so.name 
				AND dboc.sch = ss.name
			)
;

