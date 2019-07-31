
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF EXISTS(
    SELECT 1 
    FROM sys.triggers st 
    WHERE st.name = 'tr_DataBaseChangeTrigger' 
      AND st.parent_class = 0
    )
BEGIN
	EXEC ('DROP TRIGGER [tr_DataBaseChangeTrigger] ON DATABASE');
END
GO

CREATE TRIGGER [tr_DataBaseChangeTrigger] ON DATABASE
WITH ENCRYPTION
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
	
	SELECT * INTO #__DataBaseChange
	FROM (
		VALUES (
			EVENTDATA().value('(/EVENT_INSTANCE/EventType)[1]', 'nvarchar(128)'),
			EVENTDATA().value('(/EVENT_INSTANCE/DatabaseName)[1]', 'nvarchar(128)'),
			EVENTDATA().value('(/EVENT_INSTANCE/SchemaName)[1]', 'nvarchar(128)'),
			EVENTDATA().value('(/EVENT_INSTANCE/ObjectName)[1]', 'nvarchar(128)'),
			EVENTDATA().value('(/EVENT_INSTANCE/TSQLCommand/CommandText)[1]', 'NVARCHAR(MAX)'),
			EVENTDATA().value('(/EVENT_INSTANCE/LoginName)[1]', 'nvarchar(128)'),
			GETDATE()
			) 
		) AS Events (event, db, sch, object, sql, login, date)
	;

	INSERT INTO MASTER.[dbo].[DataBaseChange] (event, db, sch, object, sql, login, date) 
		SELECT EVENT, db, sch, object,
			CONCAT('<query><![CDATA[', sql, ']]></query>' ),
			login, date
		FROM #__DataBaseChange
	;

END
GO

ENABLE TRIGGER [tr_DataBaseChangeTrigger] ON DATABASE
GO


