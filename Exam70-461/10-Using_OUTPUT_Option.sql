USE TSQL2012;
GO

--EXERCISE 1 Use OUTPUT in an UPDATE Statement
--In this exercise, you use the OUTPUT clause in an UPDATE statement and compare columns before and after the change

--1. You need to apply an update to products in category 1 that are supplied by supplier 16
--   You first issue the following query against the Production.Products table to examine the products that you’re about to update
SELECT productid, productname, unitprice
FROM Production.Products
WHERE categoryid = 1
	AND supplierid = 16;

/*2. Write an UPDATE statement that modifes the products in category 1 that are supplied by supplier 16, increasing their unit prices by 2.5.
     Include an OUTPUT clause that returns the product ID, product name, old price, new price, and percent difference between the new and old prices. 
     Your UPDATE statement should look like the following */
UPDATE Production.Products
	SET unitprice += 2.5
	OUTPUT
		inserted.productid,
		inserted.productname,
		deleted.unitprice AS old_price,
		inserted.unitprice AS new_price,
		CAST(100.0 * (inserted.unitprice - deleted.unitprice)
					  / deleted.unitprice AS NUMERIC(5,2)) AS pct_increase
WHERE categoryid = 1
	AND supplierid = 16;

/* 3.To get back to the original values, write an inverse UPDATE statement, reducing the unit prices by 2.5
     Include the same output information as in the previous statement
     Your code should look like the following */
UPDATE Production.Products
	SET unitprice -= 2.5
	OUTPUT
		inserted.productid,
		inserted.productname,
		deleted.unitprice AS old_price,
		inserted.unitprice AS new_price,
		CAST(100.0 * (inserted.unitprice - deleted.unitprice)
					  / deleted.unitprice AS NUMERIC(5,2)) AS pct_increase
WHERE categoryid = 1
	AND supplierid = 16;

--EXERCISE 2 Use Composable DML
--In this exercise, you use composable DML. You delete rows from a table and archive in another table a subset of the deleted rows

--1. Create the tables and sample for this exercise by running the following code
IF OBJECT_ID('Sales.MyOrdersArchive') IS NOT NULL
DROP TABLE Sales.MyOrdersArchive;

IF OBJECT_ID('Sales.MyOrders') IS NOT NULL
DROP TABLE Sales.MyOrders;

CREATE TABLE Sales.MyOrders
(
	orderid INT NOT NULL
	CONSTRAINT PK_MyOrders PRIMARY KEY,
	custid INT NOT NULL,
	empid INT NOT NULL,
	orderdate DATE NOT NULL
);

INSERT INTO Sales.MyOrders(orderid, custid, empid, orderdate)
SELECT orderid, custid, empid, orderdate
FROM Sales.Orders;

CREATE TABLE Sales.MyOrdersArchive
(
orderid INT NOT NULL
	CONSTRAINT PK_MyOrdersArchive PRIMARY KEY,
	custid INT NOT NULL,
	empid INT NOT NULL,
	orderdate DATE NOT NULL
);

/*2. Write a statement against the Sales.MyOrders table that deletes orders placed before the year 2007
     Use composable DML to archive deleted orders that were placed by the customers that have IDs of 17 and 19
	 Implement and execute the following statement */
INSERT INTO Sales.MyOrdersArchive(orderid,custid,empid,orderdate)
	SELECT orderid,custid,empid,orderdate
	FROM(DELETE FROM Sales.MyOrders
			OUTPUT deleted.*
		 WHERE orderdate < '20070101') AS D 
	WHERE custid IN (17,19);

--3. Query the Sales.MyOrdersArchive table to see which rows got archived
SELECT *
FROM Sales.MyOrdersArchive;

--4. When you’re done, run the following code for cleanup
IF OBJECT_ID('Sales.MyOrdersArchive') IS NOT NULL
	DROP TABLE Sales. MyOrdersArchive;
IF OBJECT_ID('Sales.MyOrders') IS NOT NULL
	DROP TABLE Sales.MyOrders;
