SELECT
	count("ID")
	,date_part('month', "TimeStart"::date)

	
FROM	
	"S_Seances"
where
	"SeanceType" = 2
	and 
group by
	date_part('month', "TimeStart"::date)