--***** UPDATING DATA *****
-- Use the UPDATE statement to modify rows.
-- Update data by using joins.
-- Describe the circumstances in which you get nondeterministic updates.
-- Update data through table expressions.
-- Update data by using variables.
-- Describe the implications of the all-at-once property of SQL on updates.

--***** SAMPLE DATA *****
--Use the following code to create and populate the sample tables
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

--The following code demonstrates an UPDATE statement that adds a 5 percent discount to these order lines
UPDATE Sales.MyOrderDetails
SET discount += 0.05
WHERE orderid = 10251;
/*
Notice the use of the compound assignment operator discount += 0.05. This assignment
is equivalent to discount = discount + 0.05. T-SQL supports such enhanced operators for all
binary assignment operators: += (add), -= (subtract), *= (multiply), /= (divide), %= (modulo),
&= (bitwise and), |= (bitwise or), ^= (bitwise xor), += (concatenate). */

--Query again the order lines associated with order 10251 to see their state after the update
SELECT *
FROM Sales.MyOrderDetails
WHERE orderid = 10251;

--Use the following code to reduce the discount in the aforementioned order lines by 5 percent
UPDATE Sales.MyOrderDetails
SET discount -= 0.05
WHERE orderid = 10251;

--***** UPDATE BASED ON JOIN *****
-- idea is that you might want to update rows in a table, and refer to related rows in other tables for filtering and assignment purposes
SELECT OD.*
FROM Sales.MyCustomers AS C
INNER JOIN Sales.MyOrders AS O
ON C.custid = O.custid
INNER JOIN Sales.MyOrderDetails AS OD
ON O.orderid = OD.orderid
WHERE C.country = N'Norway';
--In order to perform the desired update, simply replace the SELECT clause from the last query with an UPDATE clause
UPDATE OD
SET OD.discount += 0.05
FROM Sales.MyCustomers AS C
	INNER JOIN Sales.MyOrders AS O
		ON C.custid = O.custid
	INNER JOIN Sales.MyOrderDetails AS OD
		ON O.orderid = OD.orderid
WHERE C.country = N'Norway';
--To get the previous order lines back to their original state, run an UPDATE statement that reduces the discount by 5 percent
UPDATE OD
SET OD.discount -= 0.05
FROM Sales.MyCustomers AS C
	INNER JOIN Sales.MyOrders AS O
		ON C.custid = O.custid
	INNER JOIN Sales.MyOrderDetails AS OD
		ON O.orderid = OD.orderid
WHERE C.country = N'Norway';

--***** NONDETERMINISTIC UPDATE *****
--The statement is nondeterministic when multiple source rows match one target row
--Unfortunately, in such a case, SQL Server doesn’t generate an error or even a warning
--Instead of using the nonstandard UPDATE statement based on joins, you can use the standard MERGE statement

--***** UPDATE AND TABLE EXPRESSIONS
--With T-SQL, you can modify data through table expressions like CTEs and derived tables
--This capability can be useful, for example, when you want to be able to see which rows are going
--to be modifed and with what data before you actually apply the update

--Suppose that you need to modify the country and postalcode columns of the Sales.MyCustomers table with the data from the respective rows from the Sales.Customers table
--But you want to be able to run the code as a SELECT statement first in order to see the data that you’re about to update
--You could first write a SELECT query, as follows:
SELECT TGT.custid,
	TGT.country AS tgt_country, SRC.country AS src_country,
	TGT.postalcode AS tgt_postalcode, SRC.postalcode AS src_postalcode
FROM Sales.MyCustomers AS TGT
	INNER JOIN Sales.Customers AS SRC
		ON TGT.custid = SRC.custid;

--But to actually perform the update, you now need to replace the SELECT clause with an  UPDATE clause, as follows:
UPDATE  TGT
	SET TGT.country = SRC.country,
		TGT.postalcode = SRC.postalcode
FROM Sales.MyCustomers AS TGT
	INNER JOIN Sales.Customers AS SRC
		ON TGT.custid = SRC.custid;
--As an alternative, you will probably fnd it easier to defne a table expression based on the last query, and issue the modifcation through the table expression
WITH C AS
(
	SELECT TGT.custid,
		   TGT.country    AS tgt_country,
		   TGT.postalcode AS tgt_postalcode,
		   SRC.country    AS src_country,
		   SRC.postalcode AS src_postalcode
	FROM Sales.MyCustomers AS TGT
		INNER JOIN Sales.Customers AS SRC
			ON TGT.custid = SRC.custid
)
UPDATE C
	SET tgt_country = src_country,
		tgt_postalcode = src_postalcode;
--But with this solution, you can always highlight just the inner SELECT query and run it independently just to see the data
--involved in the update without actually applying it.

--You can achieve the same thing using a derived table, as follows:
UPDATE D
SET tgt_country = src_country,
tgt_postalcode = src_postalcode
FROM (
SELECT TGT.custid,
TGT.country AS tgt_country, SRC.country AS src_country,
TGT.postalcode AS tgt_postalcode, SRC.postalcode AS src_postalcode
FROM Sales.MyCustomers AS TGT
INNER JOIN Sales.Customers AS SRC
ON TGT.custid = SRC.custid
) AS D;


--***** UPDATE BASED ON A VARIABLE *****
--Sometimes you need to modify a row and also collect the result of the modifed columns into variables

SELECT *
FROM Sales.MyOrderDetails
WHERE orderid = 10250
AND productid = 51;

--Suppose that you need to modify the row, increasing the discount by 5 percent, and collect the new discount into a variable called @newdiscount.
DECLARE @newdiscount AS NUMERIC(4, 3) = NULL;

UPDATE Sales.MyOrderDetails
SET @newdiscount = discount += 0.05
WHERE orderid = 10250
AND productid = 51;

SELECT @newdiscount;

--Issue the following code to undo the last change
UPDATE Sales.MyOrderDetails
SET discount -= 0.05
WHERE orderid = 10250
AND productid = 51;

--Exercise 1 - Update Data by Using Joins

--1. Use the following code to create the table Sales.MyCustomers and populate it with a couple of rows representing customers with IDs 22 and 57
IF OBJECT_ID('Sales.MyCustomers') IS NOT NULL DROP TABLE Sales.MyCustomers;

CREATE TABLE Sales.MyCustomers
(
	custid INT NOT NULL
	CONSTRAINT PK_MyCustomers PRIMARY KEY,
	companyname NVARCHAR(40) NOT NULL,
	contactname NVARCHAR(30) NOT NULL,
	contacttitle NVARCHAR(30) NOT NULL,
	address NVARCHAR(60) NOT NULL,
	city NVARCHAR(15) NOT NULL,
	region NVARCHAR(15) NULL,
	postalcode NVARCHAR(10) NULL,
	country NVARCHAR(15) NOT NULL,
	phone NVARCHAR(24) NOT NULL,
	fax NVARCHAR(24) NULL
);

INSERT INTO Sales.MyCustomers (custid, companyname, contactname, contacttitle, address,
							   city, region, postalcode, country, phone, fax)
VALUES(22, N'', N'', N'', N'', N'', N'', N'', N'', N'', N''),
	  (57, N'', N'', N'', N'', N'', N'', N'', N'', N'', N'');

--2. Write an UPDATE statement that overwrites the values of all nonkey columns in the Sales.MyCustomers table with those from the respective 
--   rows in the Sales.Customers table. Your solution should look like the following:
UPDATE TGT
	SET TGT.custid = SRC.custid ,
		TGT.companyname = SRC.companyname ,
		TGT.contactname = SRC.contactname ,
		TGT.contacttitle = SRC.contacttitle,
		TGT.address = SRC.address ,
		TGT.city = SRC.city ,
		TGT.region = SRC.region ,
		TGT.postalcode = SRC.postalcode ,
		TGT.country = SRC.country ,
		TGT.phone = SRC.phone ,
		TGT.fax = SRC.fax
FROM Sales.MyCustomers AS TGT
	INNER JOIN Sales.Customers AS SRC
		ON TGT.custid = SRC.custid;

--Exercise 2 - Update Data by Using a CTE

--1. You are given the same task as in Exercise 1, step 3; namely, update the values of all nonkey columns in the Sales.MyCustomers table with those 
--   from the respective rows in the Sales.Customers table. But this time you want to be able to examine the data that needs to be modifed before 
--   actually applying the update. Implement the task by using a CTE. Your solution should look like the following

WITH C AS
(
	SELECT
		TGT.custid			AS tgt_custid			, SRC.custid		AS src_custid ,
		TGT.companyname		AS tgt_companyname		, SRC.companyname	AS src_companyname ,
		TGT.contactname		AS tgt_contactname		, SRC.contactname	AS src_contactname ,
		TGT.contacttitle	AS tgt_contacttitle		, SRC.contacttitle	AS src_contacttitle,
		TGT.address			AS tgt_address			, SRC.address		AS src_address ,
		TGT.city			AS tgt_city				, SRC.city			AS src_city ,
		TGT.region			AS tgt_region			, SRC.region		AS src_region ,
		TGT.postalcode		AS tgt_postalcode		, SRC.postalcode	AS src_postalcode ,
		TGT.country			AS tgt_country			, SRC.country		AS src_country ,
		TGT.phone			AS tgt_phone			, SRC.phone			AS src_phone ,
		TGT.fax				AS tgt_fax				, SRC.fax			AS src_fax
	FROM Sales.MyCustomers AS TGT
		INNER JOIN Sales.Customers AS SRC
			ON TGT.custid = SRC.custid
)
UPDATE C
	SET tgt_custid = src_custid ,
		tgt_companyname = src_companyname ,
		tgt_contactname = src_contactname ,
		tgt_contacttitle = src_contacttitle,
		tgt_address = src_address ,
		tgt_city = src_city ,
		tgt_region = src_region ,
		tgt_postalcode = src_postalcode ,
		tgt_country = src_country ,
		tgt_phone = src_phone ,
		tgt_fax = src_fax;
--You can use the inner SELECT query with the join both before and after issuing the actual update to ensure that you achieved the desired result

--***** DELETING DATA *****
Página 356
