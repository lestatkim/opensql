USE MyDatabase;
GO
;

WITH
    x AS (
		SELECT fk.TABLE_NAME f_table
			, c_fk.COLUMN_NAME f_col
			, '[' + UPPER(pk.TABLE_NAME) + ']' + '.' + LOWER(c_pk.COLUMN_NAME) [link]
		FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS fk
			JOIN INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS AS rc
				ON rc.CONSTRAINT_NAME = fk.CONSTRAINT_NAME
			JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS pk
				ON pk.CONSTRAINT_NAME = rc.UNIQUE_CONSTRAINT_NAME
			JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE AS c_fk
				ON c_fk.CONSTRAINT_NAME = fk.CONSTRAINT_NAME
			JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE AS c_pk
				ON c_pk.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
					AND c_pk.ORDINAL_POSITION = c_fk.ORDINAL_POSITION
		WHERE fk.CONSTRAINT_TYPE = 'FOREIGN KEY'
	),
    main AS (
		SELECT LOWER(_t.name) [Table]
			, LOWER(_c.name) [Column]
			, сс.ORDINAL_POSITION [Column_pos]
			, t.name [Type]
			, _c.max_length [Max_length]
			, _c.is_nullable [Nullable]
			, (
				  /*	:return: int
 						is Field == Primary_key
 					*/
				  SELECT COUNT(COLUMN_NAME)
				  FROM INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE
				  WHERE TABLE_NAME = _t.name
					  AND CONSTRAINT_NAME = (
						  SELECT CONSTRAINT_NAME
						  FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
						  WHERE TABLE_NAME = _t.name
							  AND CONSTRAINT_TYPE = N'primary key'
							  AND COLUMN_NAME = _c.name
					  )
			  ) AS [is_primary_key]
		FROM sys.columns _c
			, sys.types t
			, sys.tables _t
			, INFORMATION_SCHEMA.COLUMNS сс
			, x
		WHERE _t.object_id = _c.object_id
			AND t.system_type_id = _c.system_type_id
			AND t.user_type_id = _c.user_type_id
			AND сс.COLUMN_NAME = _c.name
			AND сс.TABLE_NAME = _t.name
	)
SELECT DISTINCT
    m.[Table]
    , m.[Column]
    , m.[Column_pos]
    , m.[Type]
    , m.[Max_length]
    , m.[Nullable]
    , COALESCE(x.link, '') [Link to]
FROM main m
    LEFT JOIN x
        ON x.f_table = m.[Table]
            AND x.f_col = m.[Column]
ORDER BY m.[Table], m.[Column_pos];

