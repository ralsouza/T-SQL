--***** Inserting Data *****

--Lesson 1: inserting Data
--***** SAMPLE DATA *****
USE TSQL2012;
IF OBJECT_ID('Sales.MyOrders') IS NOT NULL DROP TABLE Sales.MyOrders;
GO
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

--***** INSERT VALUES *****
--Specifying the target column names after the table name is optional but considered a best practice
INSERT INTO Sales.MyOrders(custid, empid, orderdate, shipcountry, freight)
	VALUES(3, 17, DEFAULT, N'USA', 30.00);
--If you don’t specify a value for a column, SQL Server will first check whether the column gets its value automatically
--If that’s not the case, SQL Server will generate an error
--If you do want to provide your own value instead of letting the IDENTITY property do it for you, you need to first turn on a session option called IDENTITY_INSERT, as follows:
---SET IDENTITY_INSERT <table> ON;
--When you’re done, you need to remember to turn it off

--***** INSERT SELECT *****
--The INSERT SELECT statement inserts the result set returned by a query into the specifed target table

--As an example, the following code inserts into the Sales.MyOrders table the result of a query against Sales.Orders returning orders shipped to customers in Norway
SET IDENTITY_INSERT Sales.MyOrders ON;

INSERT INTO Sales.MyOrders(orderid, custid, empid, orderdate, shipcountry, freight)
	SELECT orderid, custid, empid, orderdate, shipcountry, freight
	FROM Sales.Orders
	WHERE shipcountry = N'Norway';

SET IDENTITY_INSERT Sales.MyOrders OFF;
--The code turns on the IDENTITY_INSERT option against Sales.MyOrders in order to use the original order IDs and not let the IDENTITY property generate those
--In certain conditions, the INSERT SELECT statement can beneft from minimal logging, which could result in improved performance compared to a fully logged operation
--For details, see “The Data Loading Performance Guide”: https://technet.microsoft.com/en-us/library/dd425070(v=sql.100).aspx

--***** INSERT EXEC *****
--With the INSERT EXEC statement, you can insert the result set (or sets) returned by a dynamic batch or a stored procedure into the specifed target table
--To demonstrate the INSERT EXEC statement, the following example uses a procedure called Sales.OrdersForCountry, which accepts a ship country as input and returns orders shipped to the input country.
IF OBJECT_ID('Sales.OrdersForCountry', 'P') IS NOT NULL
DROP PROC Sales.OrdersForCountry;
GO
CREATE PROC Sales.OrdersForCountry
@country AS NVARCHAR(15)
AS
SELECT orderid, custid, empid, orderdate, shipcountry, freight
FROM Sales.Orders
WHERE shipcountry = @country;
GO

--Run the following code to invoke the stored procedure with Portugal as the input country
SET IDENTITY_INSERT Sales.MyOrders ON;
INSERT INTO Sales.MyOrders(orderid, custid, empid, orderdate, shipcountry, freight)
	EXEC Sales.OrdersForCountry	@country = N'Portugal';
SET IDENTITY_INSERT Sales.MyOrders OFF;

SELECT *
FROM Sales.MyOrders;

--***** SELECT INTO *****
--The SELECT INTO statement involves a query (the SELECT part) and a target table (the INTO part)
--The statement creates the target table based on the defInition of the source and inserts the result rows from the query into that table

--The following code shows an example for a SELECT INTO statement that queries the Sales
--Orders table returning orders shipped to Norway, creates a target table called Sales.MyOrders, and stores the query’s result in the target table
IF OBJECT_ID('Sales.MyOrders', 'U') IS NOT NULL DROP TABLE Sales.MyOrders;

SELECT orderid, custid, orderdate, shipcountry, freight
INTO Sales.MyOrders
FROM Sales.Orders
WHERE shipcountry = N'Norway';

