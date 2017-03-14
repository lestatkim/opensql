CREATE TRIGGER [dbo].[Filbert_ivrCession] ON [dbo].[Filbert_ivrCessionPostgreSQL]
WITH EXECUTE AS CALLER
FOR INSERT
AS
BEGIN

 if 
	
	@@ROWCOUNT = 1
	

	begin  
		insert openrowset 
		(
		N'MSDASQL', 'Driver=PostgreSQL Unicode(x64);uid=KimLA;Server=192.168.11.13;port=10000;database=Cx_Work;pwd=78787878',
    
 
		'
		 select 
		  "ID", 
		  "ID_долга", 
		  "Телефон1", 
		  "Часовой_пояс", 
		  "Дата_перезвона"  
		 from 
		  "Table_5000081060"
    
		'
		)

		select top 7
			abs(checksum(newid())),
			cast(debt.id as varchar),
			cast(phone.number as varchar),
			cast(gmt.code-4 as varchar),
			getdate()
		from
			debt
			join person on debt.parent_id=person.id
			join (select * from dict where parent_id=51) gmt on gmt.code=debt.gmt
			join portfolio on portfolio.id=debt.r_portfolio_id
			join phone on phone.parent_id=person.id
		where
			debt.status in (1,2,3,4,11,13,15) and
			portfolio.status = 2 and
			debt.debt_sum > 100 and
			portfolio.parent_id in (9,10,11,14,49,70) and
			phone.typ in (1,2,3,4) and
			phone.block_flag = 0
			and (debt.mark1 in (1,2,4) or debt.mark1 is null)
			and portfolio.parent_id not in (73, 68, 56)
			and debt.id not in
				(
				select 
				r_debt_id 
				from 
				work_task 
				where 
				r_user_id in 
					(
					select 
						id 
					from 
						users
					)
				);



		exec xp_cmdshell 'start http://192.168.11.13:10080/campaign/startcampaign/?IDCampaign=5045656235';
  
		waitfor delay '00:00:02.000';

		exec xp_cmdshell 'tskill iexplore';

		waitfor delay '00:00:01.000';

		exec xp_cmdshell 'tskill cmd';


	end;
END;

