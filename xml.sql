declare @xml xml
select @xml = 
'<?xml version="1.0" standalone="yes"?>
    <DocumentElement>
      <bssXmlReader>
       <col_1>text_of_column_1</col_1>
        <col_2>1001001</col_2>
        <col_3>some_text_col_3</col_3>
      </bssXmlReader>
    </DocumentElement>
'
select 
  x.value('./col_1[1]', 'nvarchar(64)') as col_1,
  x.value('./col_2[1]', 'int') as col_2,
  x.value('./col_3[1]', 'nvarchar(64)') as col_3
into #lstt_test 
from @xml.nodes('DocumentElement/bssXmlReader') x (x)

select * from #lstt_test
drop table #lstt_test

------------------------------------------------------------

declare @xml xml
select @xml = 
N'<Adjustment
  ActivityCode="Adjustment" 
  ActivityType="Adjustment" 
  AdjustmentType="+ Корректировка" 
  TimeStamp="2017-04-11T15:13:17" 
  MsgId="2138" 
  TransType="40" 
  UserId="FRomanov" 
  Version="2.2" 
  Warehouse="389" 
  UniqueId="69">
<AdjustmentDtl 
  AdjustmentDtlID="2138" 
/>
</Adjustment>
'
select 
  x.value('./@ActivityCode', 'nvarchar(64)') as ActivityCode,
  x.value('./@ActivityType', 'nvarchar(64)') as ActivityType,
  x.value('./@AdjustmentType', 'nvarchar(64)') as AdjustmentType,
  x.value('./@MsgId', 'int') as MsgId,
  x.value('./@UserId', 'nvarchar(32)') as UserId,
  x.value('./@Version', 'float') as Version,
  x.value('./@Warehouse', 'int') as Warehouse,
  x.value('./@UniqueId', 'int') as UniqueId,
  x.value('./AdjustmentDtl[1]/@AdjustmentDtlID', 'nvarchar(max)') as AdjustmentDtl

from @xml.nodes('/Adjustment') x(x)
