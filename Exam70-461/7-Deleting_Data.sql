USE TSQL2012;
GO

--Sample Data
IF OBJECT_ID('Sales.MyOrderDetails', 'U') IS NOT NULL
	DROP TABLE Sales.MyOrderDetails;

IF OBJECT_ID('Sales.MyOrders', 'U') IS NOT NULL
	DROP TABLE Sales.MyOrders;

IF OBJECT_ID('Sales.MyCustomers', 'U') IS NOT NULL
	DROP TABLE Sales.MyCustomers;

SELECT * INTO Sales.MyCustomers FROM Sales.Customers;

ALTER TABLE Sales.MyCustomers
	ADD CONSTRAINT PK_MyCustomers PRIMARY KEY(custid);

SELECT * INTO Sales.MyOrders FROM Sales.Orders;

ALTER TABLE Sales.MyOrders
	ADD CONSTRAINT PK_MyOrders PRIMARY KEY(orderid);

SELECT * INTO Sales.MyOrderDetails FROM Sales.OrderDetails;

ALTER TABLE Sales.MyOrderDetails
	ADD CONSTRAINT PK_MyOrderDetails PRIMARY KEY(orderid, productid);

--DELETE Statement
DELETE FROM Sales.MyOrderDetails
WHERE productid = 11;

--Split large delete into smaller chunks
WHILE 1 = 1
BEGIN
	DELETE TOP (1000) FROM Sales.MyOrderDetails
	WHERE productid = 12;
	IF @@rowcount < 1000 BREAK;
END

--DELETE Based on a Join
/*
As an example, suppose that you want to delete all orders placed by customers from the United States. 
The country is a property of the customer—not the order. So even though the target for the DELETE statement is the Sales.MyOrders table, 
you need to examine the country column in the related customer row in the Sales.MyCustomers table.
You can achieve this by using a DELETE statement based on a join, as follows.
*/
DELETE FROM O
FROM Sales.MyOrders AS O
	INNER JOIN Sales.MyCustomers AS C
		ON O.custid = C.custid
WHERE C.country = N'USA';

--Same task by using a subquery instead of a join
DELETE FROM Sales.MyOrders
WHERE EXISTS
	(SELECT *
	 FROM Sales.MyCustomers
	 WHERE MyCustomers.custid = MyOrders.custid
		AND MyCustomers.country = N'Finland');

--DELETE Using Table Expressions
/*
Suppose that you want to delete the 100 oldest orders (based on orderdate, orderid ordering). 
The DELETE statement supports using the TOP option directly, but it doesn’t support an ORDER BY clause. 
So you don’t have any control over which rows the TOP flter will pick. As a workaround, you can defne a table expression based on a SELECT query
with the TOP option and an ORDER BY clause controlling which rows get fltered. 
Then you can issue a DELETE against the table expression. Here’s how the complete code looks.
*/
WITH OldestOrders AS
(
	SELECT TOP (100) *
	FROM Sales.MyOrders
	ORDER BY orderdate, orderid
)
DELETE FROM OldestOrders;

--Cleanup
IF OBJECT_ID('Sales.MyOrderDetails', 'U') IS NOT NULL
DROP TABLE Sales.MyOrderDetails;
IF OBJECT_ID('Sales.MyOrders', 'U') IS NOT NULL
DROP TABLE Sales.MyOrders;
IF OBJECT_ID('Sales.MyCustomers', 'U') IS NOT NULL
DROP TABLE Sales.MyCustomers;

--PRATICE 1 - Deleting and truncating Data
--1.Sample Data
IF OBJECT_ID('Sales.MyOrders', 'U') IS NOT NULL
	DROP TABLE Sales.MyOrders;

IF OBJECT_ID('Sales.MyCustomers', 'U') IS NOT NULL
	DROP TABLE Sales.MyCustomers;

SELECT * INTO Sales.MyCustomers FROM Sales.Customers;

ALTER TABLE Sales.MyCustomers
	ADD CONSTRAINT PK_MyCustomers PRIMARY KEY(custid);

SELECT * INTO Sales.MyOrders FROM Sales.Orders;

ALTER TABLE Sales.MyOrders
	ADD CONSTRAINT PK_MyOrders PRIMARY KEY(orderid);

ALTER TABLE Sales.MyOrders
	ADD CONSTRAINT FK_MyOrders_MyCustomers
		FOREIGN KEY(custid) REFERENCES Sales.MyCustomers(custid);

--2.Delete base a join
DELETE FROM TGT
FROM Sales.MyCustomers AS TGT
	LEFT OUTER JOIN Sales.Orders AS SRC
		ON TGT.custid = SRC.custid
WHERE SRC.orderid IS NULL;

--3.Use the following query to count the number of customers remaining in the table
SELECT COUNT(*) AS cnt FROM Sales.MyCustomers;

--PRATICE 2 - Truncate Data
--1. Use TRUNCATE statements to clear frst the Sales.MyOrders table and then the Sales.
TRUNCATE TABLE Sales.MyOrders;
TRUNCATE TABLE Sales.MyCustomers;

/*
The second statement fails with the following error.

Msg 4712, Level 16, State 1, Line 1
Cannot truncate table 'Sales.MyCustomers' because it is being referenced by a FOREIGN KEY constraint.

The error happened because a TRUNCATE statement is disallowed when the target
table is referenced by a foreign key constraint, even if there are no related rows in the
referencing table. The solution is to drop the foreign key, truncate the target table, and
then create the foreign key again.
*/

ALTER TABLE Sales.MyOrders
	DROP CONSTRAINT FK_MyOrders_MyCustomers;

TRUNCATE TABLE Sales.MyCustomers;

ALTER TABLE Sales.MyOrders
	ADD CONSTRAINT FK_MyOrders_MyCustomers
		FOREIGN KEY(custid) REFERENCES Sales.MyCustomers(custid);

--Cleanup
IF OBJECT_ID('Sales.MyOrders', 'U') IS NOT NULL
DROP TABLE Sales.MyOrders;
IF OBJECT_ID('Sales.MyCustomers', 'U') IS NOT NULL
DROP TABLE Sales.MyCustomers;
