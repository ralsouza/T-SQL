WITH CPU_Per_Db
AS
(SELECT 
 dmpa.DatabaseID
 , DB_Name(dmpa.DatabaseID) AS [Database]
 , SUM(dmqs.total_worker_time) AS CPUTimeAsMS
 FROM sys.dm_exec_query_stats dmqs 
 CROSS APPLY 
 (SELECT 
 CONVERT(INT, value) AS [DatabaseID] 
 FROM sys.dm_exec_plan_attributes(dmqs.plan_handle)
 WHERE attribute = N'dbid') dmpa
 GROUP BY dmpa.DatabaseID)
 
 SELECT 
 [Database] 
 ,[CPUTimeAsMS] 
 ,CAST([CPUTimeAsMS] * 1.0 / SUM([CPUTimeAsMS]) OVER() * 100.0 AS DECIMAL(5, 2)) AS [CPUTimeAs%]
 FROM CPU_Per_Db
 ORDER BY [CPUTimeAsMS] DESC;
