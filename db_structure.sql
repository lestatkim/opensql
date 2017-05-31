USE MyDatabase
GO

WITH
 	x AS 
    (
 		/*	Get primary, foreign tables AND columns 
 			For the final connection AND getting the link
 		*/
 		SELECT fk.table_name f_table ,c_fk.column_name f_col
 			,'[' + upper(pk.table_name) + ']' + '.' + lower(c_pk.column_name) [link]
 		FROM information_schema.table_constraints AS fk
 			 JOIN information_schema.referential_constraints AS rc ON rc.constraint_name = fk.constraint_name
 			 JOIN information_schema.table_constraints AS pk ON pk.constraint_name = rc.unique_constraint_name
 			 JOIN information_schema.key_column_usage AS c_fk ON c_fk.constraint_name = fk.constraint_name
 			 JOIN information_schema.key_column_usage AS c_pk ON c_pk.constraint_name = pk.constraint_name
 					AND	c_pk.ordinal_position = c_fk.ordinal_position
 		WHERE fk.constraint_type = 'FOREIGN KEY'
 	),

 	main AS
    (
 		/*	get basic information about
 			tables AND columns
 		*/
 		SELECT
 			 lower(_t.name) [Table] ,lower(_c.name) [Column]
 			,сс.ordinal_position [Column_pos] ,t.name [Type]
 			,_c.max_length [Max_length] ,_c.is_nullable [Nullable]			
 			,(
 				/*	:return: int
 					is Field == Primary_key
 				*/
 				SELECT count(column_name)
 				FROM information_schema.constraint_column_usage 
 				WHERE table_name = _t.name 
                    AND constraint_name = 
                    (
 						SELECT constraint_name
 						FROM information_schema.table_constraints
 						WHERE table_name = _t.name
 							AND constraint_type = N'primary key'
 							AND column_name = _c.name
 					)
 			) AS [is_primary_key]
 	
 		FROM sys.columns _c, sys.types t, sys.tables _t
 			 ,information_schema.columns сс, x
 		WHERE _t.object_id = _c.object_id
 			AND t.system_type_id = _c.system_type_id
            AND t.user_type_id = _c.user_type_id
 			AND сс.column_name = _c.name
            AND сс.table_name = _t.name
 	)

SELECT DISTINCT
    m.[Table], m.[Column], m.[Column_pos], m.[Type], m.[Max_length],
 	m.[Nullable], coalesce(x.link, '') [Link to]
FROM main m 
    LEFT JOIN x ON x.f_table = m.[Table]
        AND x.f_col = m.[Column]
ORDER BY m.[Table], m.[Column_pos]
