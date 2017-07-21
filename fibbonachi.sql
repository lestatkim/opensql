/*  Return: string
    Description: show fibbonachi numbers -le @param
    Example: EXEC dbo.fib 1000
*/
IF OBJECT_ID('dbo.fib', 'P') IS NULL
    EXEC('CREATE PROC dbo.fib AS')
;
GO
ALTER PROC dbo.fib @i NUMERIC(38, 4)
AS
BEGIN
SET NOCOUNT ON
;
    WITH
        t (i, val) AS
        (
            SELECT 1, 1
            
            UNION ALL
            
            SELECT val, i + val
            FROM t
            WHERE val !> @i
        )
    SELECT CAST(val AS NVARCHAR) + ',' AS [text()]
    FROM t
    FOR XML PATH('')
    ;


SET NOCOUNT OFF
;
END
GO
