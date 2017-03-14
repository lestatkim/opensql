
/*	Name 				:	Database Structure
	Created / modify 	:	2017-03-10 / 2017-03-14
	Author 				:	Lestat Kim
*/

-- (!) choose your Database
use ILS_LK
go

;with
	x as (
		/*	Get primary, foreign tables and columns 
			For the final connection and getting the link
		*/
		select fk.table_name f_table ,c_fk.column_name f_col
			,'[' + upper(pk.table_name) + ']' + '.' + lower(c_pk.column_name) [link]
		from information_schema.table_constraints as fk
			 join information_schema.referential_constraints as rc on rc.constraint_name = fk.constraint_name
			 join information_schema.table_constraints as pk on pk.constraint_name = rc.unique_constraint_name
			 join information_schema.key_column_usage as c_fk on c_fk.constraint_name = fk.constraint_name
			 join information_schema.key_column_usage as c_pk on c_pk.constraint_name = pk.constraint_name
					and	c_pk.ordinal_position = c_fk.ordinal_position
		where fk.constraint_type = 'FOREIGN KEY'
	)
	,main as (
		/*	get basic information about
			tables and columns
		*/
		select
			 lower(_t.name) [Table] ,lower(_c.name) [Column]
			,сс.ordinal_position [Column_pos] ,t.name [Type]
			,_c.max_length [Max_length] ,_c.is_nullable [Nullable]			
			,(
				/*	:return: int
					is Field == Primary_key
				*/
				select count(column_name)
				from information_schema.constraint_column_usage 
				where
					table_name = _t.name and
					constraint_name = (
						select constraint_name
						from information_schema.table_constraints
						where
							table_name = _t.name
							and constraint_type = 'primary key'
							and column_name = _c.name
					)
			) [is_primary_key]
	
		from sys.columns _c, sys.types t, sys.tables _t
			 ,information_schema.columns сс, x
		where
			_t.object_id = _c.object_id
			and t.system_type_id = _c.system_type_id and t.user_type_id = _c.user_type_id
			and сс.column_name = _c.name and сс.table_name = _t.name
	)

-- if __name__ == '__main__':
	select distinct
		 m.[Table], m.[Column], m.[Column_pos], m.[Type], m.[Max_length]
		,m.[Nullable], coalesce(x.link, '') [Link to]
	from main m left join x on x.f_table = m.[Table] and x.f_col = m.[Column]
	order by m.[Table], m.[Column_pos]

