SELECT
     COUNT(1) AS NumberOfSplits
     ,AllocUnitName
     ,Context
FROM
     fn_dblog(NULL,NULL)
WHERE
     Operation = 'LOP_DELETE_SPLIT'
GROUP BY
     AllocUnitName, Context
ORDER BY
     NumberOfSplits DESC