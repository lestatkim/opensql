
DECLARE @s NVARCHAR(max) = OBJECT_DEFINITION(OBJECT_ID('schema.TableName'));
SELECT CAST('<root><![CDATA[' + @s + ']]></root>' AS XML);

