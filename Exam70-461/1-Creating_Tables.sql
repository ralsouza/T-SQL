USE TSQL2012;
GO
--Use ALTER TABLE to Add And Modify Columns
--Exemplo 1
CREATE TABLE Production.Categories
(
	categoryid	 INT			NOT NULL IDENTITY,
	categoryname NVARCHAR(15)	NOT NULL,
	description	 NVARCHAR(200)	NOT NULL,
	CONSTRAINT PK_categories PRIMARY KEY(categoryid)
);

--Exemplo 2
	CREATE TABLE Sales.MyOrders
	(
		orderid INT NOT NULL IDENTITY(1,1)
			CONSTRAINT PK_MyOrders_orderid PRIMARY KEY,
		custid INT NOT NULL,
		empid INT NOT NULL,
		orderdate DATE NOT NULL
			CONSTRAINT DFT_MyOrders_orderdate DEFAULT (CAST(SYSDATETIME() AS DATE)),
		shipcountry NVARCHAR(15) NOT NULL,
		freight MONEY NOT NULL
	);

CREATE TABLE Production.CategoriesTest
(
	categoryid	INT	NOT NULL IDENTITY
);
GO

--Add categoryname and description columns
ALTER TABLE Production.CategoriesTest
	ADD categoryname NVARCHAR(15)	NOT NULL;
GO
ALTER TABLE Production.CategoriesTest
	ADD description NVARCHAR(200) NOT NULL;
GO

--Insert into the copy table from the original table, but the insert will fail
INSERT Production.CategoriesTest (categoryid, categoryname, description)
SELECT categoryid, categoryname, description
FROM Production.Categories;
GO

--Again with IDENTITY_INSERT ON, which allows a row to be inserted with an explicit identity value
SET IDENTITY_INSERT Production.CategoriesTest ON;
INSERT Production.CategoriesTest (categoryid, categoryname, description)
SELECT categoryid, categoryname, description
FROM Production.Categories;
GO
SET IDENTITY_INSERT Production.CategoriesTest OFF;
GO

--To clean up
IF OBJECT_ID('Production.CategoriesTest','U') IS NOT NULL
DROP TABLE Production.CategoriesTest;
GO

--In this exercise, you use the table from the previous exercise,
--and explore the consequences of adding a column that does not and then does allow NULL
-- Create table Production.CategoriesTest
CREATE TABLE Production.CategoriesTest
(
categoryid INT NOT NULL IDENTITY,
categoryname NVARCHAR(15) NOT NULL,
description NVARCHAR(200) NOT NULL,
CONSTRAINT PK_Categories2 PRIMARY KEY(categoryid)
);
-- Populate the table Production.CategoriesTest
SET IDENTITY_INSERT Production.CategoriesTest ON;
INSERT Production.CategoriesTest (categoryid, categoryname, description)
SELECT categoryid, categoryname, description
FROM Production.Categories;
GO
SET IDENTITY_INSERT Production.CategoriesTest OFF;
GO
--Make the description column larger
ALTER TABLE Production.CategoriesTest
ALTER COLUMN description NVARCHAR(500);
GO
--Test for the existence of any NULLs in the description column. Note there are none:
SELECT description
FROM Production.CategoriesTest
WHERE categoryid = 8; -- Seaweed and fish
--Try to change a value in the description column to NULL. This fails.
UPDATE Production.CategoriesTest
SET description = NULL
WHERE categoryid = 8;
GO
--Alter the table and make the description column allow NULL
ALTER TABLE Production.CategoriesTest
ALTER COLUMN description NVARCHAR(500) NULL ;
GO
--Now retry the update. This works
UPDATE Production.CategoriesTest
SET description = NULL
WHERE categoryid = 8;
GO
--Attempt to change the column back to NOT NULL. This fails
ALTER TABLE Production.CategoriesTest
ALTER COLUMN description NVARCHAR(500) NOT NULL ;
GO
--Retry the update, but give the description back its original value
UPDATE Production.CategoriesTest
SET description = 'Seaweed and fish'
WHERE categoryid = 8;
GO
--Change the description column back to NOT NULL. This succeeds
ALTER TABLE Production.CategoriesTest
ALTER COLUMN description NVARCHAR(500) NOT NULL ;
GO
--To clean
IF OBJECT_ID('Production.CategoriesTest','U') IS NOT NULL
DROP TABLE Production.CategoriesTest;
GO
