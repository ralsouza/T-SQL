-- Exibe os Indices que precisam ser recontruidos
SELECT  OBJECT_SCHEMA_NAME(ind.object_id) AS schema_name,
OBJECT_NAME(ind.OBJECT_ID) AS TableName, 
ind.name AS IndexName, indexstats.index_type_desc AS IndexType, 
indexstats.avg_fragmentation_in_percent 
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, NULL) indexstats 
INNER JOIN sys.indexes ind  
ON ind.object_id = indexstats.object_id 
AND ind.index_id = indexstats.index_id 
WHERE indexstats.avg_fragmentation_in_percent > 30 
ORDER BY indexstats.avg_fragmentation_in_percent DESC

-- Criacao do script para recontriuir os indices com mais de 30% de fragmentacao
select 'ALTER INDEX [' + ind.name + '] ON ['+ OBJECT_SCHEMA_NAME(ind.object_id) +'].[' + OBJECT_NAME(ind.OBJECT_ID)+ '] REBUILD PARTITION = ALL WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)'
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, NULL) indexstats 
INNER JOIN sys.indexes ind  
ON ind.object_id = indexstats.object_id 
AND ind.index_id = indexstats.index_id 
WHERE indexstats.avg_fragmentation_in_percent > 30 
ORDER BY indexstats.avg_fragmentation_in_percent DESC

-- Criacao do script que reorganiza os indices com menos de 30% de fragmentacao
select 'ALTER INDEX [' + ind.name + '] ON ['+ OBJECT_SCHEMA_NAME(ind.object_id) +'].[' + OBJECT_NAME(ind.OBJECT_ID)+ '] REORGANIZE  WITH ( LOB_COMPACTION = ON )'
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, NULL) indexstats 
INNER JOIN sys.indexes ind  
ON ind.object_id = indexstats.object_id 
AND ind.index_id = indexstats.index_id 
WHERE indexstats.avg_fragmentation_in_percent < 30 
ORDER BY indexstats.avg_fragmentation_in_percent DESC


