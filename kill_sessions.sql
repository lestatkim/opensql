/*  Kill session's
    Autor: Igor Opium
*/
DECLARE @TABLE TABLE
(
    id INT
    , spid INT
);

DECLARE
    @id INT
    , @count INT
    , @sql NVARCHAR(MAX)
;

INSERT INTO @table
    SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL))
        , spid
    FROM sys.sysprocesses
    WHERE spid > 50 
        AND [status] = N'sleeping'
        AND open_tran = 0 
        AND spid != @@spid
        AND DATEDIFF( mi, last_batch, GETDATE() ) !< 180
;

SELECT @count = count(spid)
FROM @table
;

SET @id = 1
;

WHILE @id !> @count
BEGIN
    SET @sql = 'kill ' 
        + (
            SELECT CAST( spid AS NVARCHAR(20) )
            FROM @table 
            WHERE id = @id
        )
    ;
    EXEC (@sql)
    ;
    SET @id += 1
    ;
END
;