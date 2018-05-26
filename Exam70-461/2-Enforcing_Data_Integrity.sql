--After this lesson, you will be able to:
-- Implement declarative data integrity on your tables.
-- Defne and use primary key constraints.
-- Defne and use unique constraints.
-- Defne and use foreign key constraints.
-- Defne and use check constraints.
-- Defne default constraints.

--Script with constraint primary key
CREATE TABLE Production.Categories
(
categoryid INT NOT NULL IDENTITY,
categoryname NVARCHAR(15) NOT NULL,
description NVARCHAR(200) NOT NULL,
CONSTRAINT PK_Categories PRIMARY KEY(categoryid)
);

--Another way of declaring a column as a primary key is to use the ALTER TABLE statement
ALTER TABLE Production.Categories
ADD CONSTRAINT PK_Categories PRIMARY KEY(categoryid);
GO

--To list the primary key constraints in a database, you can query the sys.key_constraints table fltering on a type of PK
SELECT *
FROM sys.key_constraints
WHERE type = 'PK';

--Also you can find the unique index that SQL Server uses to enforce a primary key constraint by querying sys.indexes
SELECT *
FROM sys.indexes
WHERE object_id = OBJECT_ID('Production.Categories') AND name = 'PK_Categories';

--You might also want to enforce that all category names be unique, so you could declare a unique constraint on the categoryname column, with the following
ALTER TABLE Production.Categories
ADD CONSTRAINT UC_Categories UNIQUE (categoryname);
GO

--you can list unique constraints in a database by querying the sys.key_constraints table fltering on a type of UQ
SELECT *
FROM sys.key_constraints
WHERE type = 'UQ';

--Here's the code to create the foreign key
--Creating a constraint WITH CHECK implies that if there is any data in the table already, and if there would be violations of the constraint, then the ALTER TABLE will fail
--You can also create foreign key constraints on computed columns
ALTER TABLE Production.Products WITH CHECK
ADD CONSTRAINT FK_Products_Categories FOREIGN KEY(categoryid)
REFERENCES Production.Categories (categoryid)
GO

--To find a database’s foreign keys, you can query the sys.foreign_keys table
SELECT *
FROM sys.foreign_keys
WHERE name = 'FK_Products_Categories';

--Criar índices não clusterizados em colunas com chaves estrangeiras, pode melhorar as consultas com Join.
--Isto pode ajudar o SQL Server a resolver o join mais rapidamente se houver um índice em uma grande tabela.

--Com uma restrição de verificação, você declara que os valores de uma coluna são restritos de alguma forma
ALTER TABLE Production.Products WITH CHECK
ADD CONSTRAINT CHK_Products_unitprice
CHECK (unitprice>=0);
GO

--You can list the check constraints for a table by querying sys.check_constraints, as in the following
SELECT *
FROM sys.check_constraints
WHERE parent_object_id = OBJECT_ID('Production.Products');

--The following query fnds all the default constraints for the Production.Products table
SELECT *
FROM sys.default_constraints
WHERE parent_object_id = OBJECT_ID('Production.Products');

-- The following is the CREATE TABLE statement for Production.Products, taken from TSQL2012.sql
CREATE TABLE Production.Products
(
	productid INT NOT NULL IDENTITY,
	productname NVARCHAR(40) NOT NULL,
	supplierid INT NOT NULL,
	categoryid INT NOT NULL,
	unitprice MONEY NOT NULL
		CONSTRAINT DFT_Products_unitprice DEFAULT(0),
	discontinued BIT NOT NULL
		CONSTRAINT DFT_Products_discontinued DEFAULT(0),
		CONSTRAINT PK_Products PRIMARY KEY(productid),
		CONSTRAINT FK_Products_Categories FOREIGN KEY(categoryid)
	REFERENCES Production.Categories(categoryid),
		CONSTRAINT FK_Products_Suppliers FOREIGN KEY(supplierid)
	REFERENCES Production.Suppliers(supplierid),
		CONSTRAINT CHK_Products_unitprice CHECK(unitprice >= 0)
);

--In this exercise, you test the primary key and foreign key constraints of the table
--You use ALTER TABLE to drop, test, and add a foreign key constraint back into the table

--1. Test the primary key using the following
SELECT productname FROM Production.Products
WHERE productid = 1;
SET IDENTITY_INSERT Production.Products ON;
GO
INSERT INTO Production.Products (productid, productname, supplierid, categoryid,
unitprice, discontinued)
VALUES (1, N'Product TEST', 1, 1, 18, 0);
GO
SET IDENTITY_INSERT Production.Products OFF;
