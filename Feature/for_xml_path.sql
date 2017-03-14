--вместо курсора

declare @bd date = '01-05-2016'
declare @ed date = getdate()

select

	per.id
	,(
		select 
			number2+' '+ dsc+'||' 
		from 
			phone
		where 
			parent_id  = per.id  
			and block_flag  = 0	
			--and dsc <> 'Импортировано при загрузке данных.' 
			and load_dt  between @bd and @ed
	
		for xml path('') 

	) new_info


from
	person per

where
	per.id = 603669


	