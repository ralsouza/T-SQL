--Creating a Synonym
USE TSQL2012;
GO
CREATE SYNONYM dbo.Categories FOR Production.Categories;
GO

--Then the end user can select from Categories without needing to specify a schema
SELECT categoryid, categoryname, description
FROM Categories

--You can drop a synonym by using the DROP SYNONYM statement
DROP SYNONYM dbo.Categories