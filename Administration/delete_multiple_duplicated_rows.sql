WITH CTE AS(
   SELECT column,
       RN = ROW_NUMBER()OVER(PARTITION BY column ORDER BY column)
   FROM [dbo].[table]
   where column is not null and column != 1
)
DELETE FROM CTE WHERE RN > 1
