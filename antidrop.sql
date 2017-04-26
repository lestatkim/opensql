
IF OBJECT_ID('dbo.antidrop','P') IS NOT NULL
    DROP PROC dbo.antidrop;
GO
CREATE PROC dbo.antidrop @name SYSNAME, @type SYSNAME
AS
BEGIN
    -- /p
    DECLARE @if_tf NVARCHAR(512) = '
        IF OBJECT_ID(' + @name + ', ' + @type + ') IS NULL
            EXEC(''CREATE FUNCTION ' + @name + '() RETURNS @t TABLE(i INT) BEGIN RETURN END'');
        GO
    ';
    DECLARE @fn NVARCHAR(512) = '
        IF OBJECT_ID(' + @name + ', ' + @type + ') IS NULL
            EXEC(''CREATE FUNCTION ' + @name + '(@i INT) RETURNS INT AS BEGIN RETURN @i + 1 END'');
        GO
    ';
    DECLARE @p NVARCHAR(512) = '
        IF OBJECT_ID(' + @name + ', ' + @type + ') IS NULL
            EXEC(''CREATE PROC ' + @name + 'AS BEGIN SELECT 1 END'');
        GO
    ';
    DECLARE @v NVARCHAR(512) = '
        IF OBJECT_ID(' + @name + ', ' + @type + ') IS NULL
            EXEC(''CREATE VIEW ' + @name + ' AS SELECT 1 AS i'');
        GO
    '

    -- /l
    IF @type in ('IF', 'TF')
    BEGIN
        EXEC(@if_tf);
    END

    ELSE IF @type = 'FN'
    BEGIN
        EXEC(@fn);
    END
    
    ELSE IF @type = 'P'
    BEGIN
        EXEC(@p);
    END

    ELSE IF @type = 'V'
    BEGIN
        EXEC(@v);
    END

END
GO
