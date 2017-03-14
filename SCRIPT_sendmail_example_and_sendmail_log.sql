
§
EXEC msdb.dbo.sp_send_dbmail
     @profile_name = 'test1'
    ,@recipients = 'o.salnikova@filbert.pro'
	,@subject = 'отправляем письма кодом'
    ,@body = 'sql почта'
    


select sent_status, * 
from msdb.dbo.sysmail_allitems 
order by mailitem_id desc -- mail log

select * 
from msdb..sysmail_event_log 
order by log_id desc -- error mail log

select * 
from msdb.dbo.sysmail_profile



EXEC sp_configure 'show advanced option', '1' -- turn on advanced options
GO 
RECONFIGURE;
GO   

exec sp_configure 'Database Mail XPs', 1; -- set access to mail send == 1
GO
RECONFIGURE;
GO
