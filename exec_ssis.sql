-- get execution_id
DECLARE @execution_id BIGINT;

-- initialize package
EXEC [SSISDB].[catalog].[create_execution] @package_name = N'LOAD_LOY_ADV_ACTION_IN_PURCHASE.dtsx'
    , @project_name = N'LOYAL'
    , @folder_name = N'DWH 2.0'
    , @use32bitruntime = False
    , @reference_id = NULL
    , @execution_id = @execution_id OUTPUT;


-- set package parameters
EXEC [SSISDB].[catalog].[set_execution_parameter_value] @execution_id
	, @object_type = 50 -- System parameter
	, @parameter_name = N'SYNCHRONIZED'
	, @parameter_value = 1;

-- start ssis package
EXEC [SSISDB].[catalog].[start_execution] @execution_id;

-- 7 - successed execution
IF 7 <> (
    SELECT [status]
    FROM [SSISDB].[catalog].[executions]
    WHERE execution_id = @execution_id
)
    RAISERROR(
        'The package LOAD_LOY_ADV_ACTION_IN_PURCHASE failed. Check the SSIS catalog logs for more information'
        , 16
        , 1
    );
