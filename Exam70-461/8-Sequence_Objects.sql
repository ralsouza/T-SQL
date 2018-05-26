USE TSQL2012;
GO
--Test Github
--Here’s an example you can use to defne a sequence that will help generate order IDs
CREATE SEQUENCE Sales.SeqOrderIDs AS INT
	MINVALUE 1
	CYCLE; -- Note that in real-life cases, normally you would not allow a sequence generating order IDs to cycle

--To request a new value from the sequence, use the NEXT VALUE FOR <sequence name> function
--For example, run the following code three times.
SELECT NEXT VALUE FOR Sales.SeqOrderIDs;

--You cannot change the data type of an existing sequence, but you can change all of its properties by using the ALTER SEQUENCE command
--For example, if you want to change the current value, you can do so with the following code
ALTER SEQUENCE Sales.SeqOrderIDs
	RESTART WITH 1;

--To see for yourself how to use sequence values when inserting rows into a table, recreate the Sales.MyOrders table by running the following code
IF OBJECT_ID('Sales.MyOrders') IS NOT NULL 
	DROP TABLE Sales.MyOrders;
GO

CREATE TABLE Sales.MyOrders
(
	orderid INT NOT NULL
		CONSTRAINT PK_MyOrders_orderid PRIMARY KEY,
	custid INT NOT NULL
		CONSTRAINT CHK_MyOrders_custid CHECK(custid > 0),
	empid INT NOT NULL
		CONSTRAINT CHK_MyOrders_empid CHECK(empid > 0),
	orderdate DATE NOT NULL
);

--Observe that this time the orderid column doesn’t have an IDENTITY property
--Here’s an example of using the NEXT VALUE FOR function in an INSERT VALUES statement that inserts three rows into the table
INSERT INTO Sales.MyOrders(orderid, custid, empid, orderdate) VALUES
	(NEXT VALUE FOR Sales.SeqOrderIDs, 1, 2, '20120620'),
	(NEXT VALUE FOR Sales.SeqOrderIDs, 1, 3, '20120620'),
	(NEXT VALUE FOR Sales.SeqOrderIDs, 2, 2, '20120620');

SELECT * FROM Sales.MyOrders;

--As mentioned, you can also use the function in INSERT SELECT statements
--In such a case, you can optionally add an OVER clause with an ORDER BY list to control the order in which the sequence values are assigned to the result rows
INSERT INTO Sales.MyOrders(orderid, custid, empid, orderdate)
	SELECT
		NEXT VALUE FOR Sales.SeqOrderIDs OVER(ORDER BY orderid),custid,empid,orderdate
	FROM Sales.Orders
	WHERE custid = 1;

SELECT * FROM Sales.MyOrders;

--You can also use the NEXT VALUE FOR function in a DEFAULT constraint, and this way let the constraint generate the values automatically when you insert rows
--Use the following code to defne such a DEFAULT constraint for the orderid column
ALTER TABLE Sales.MyOrders
	ADD CONSTRAINT DFT_MyOrders_orderid
		DEFAULT(NEXT VALUE FOR Sales.SeqOrderIDs) FOR orderid;

--Next, run the following INSERT statement, omitting the orderid column
INSERT INTO Sales.MyOrders(custid, empid, orderdate)
	SELECT
		custid, empid, orderdate
	FROM Sales.Orders
	WHERE custid = 2;

--An example of changing the cache value to 100
ALTER SEQUENCE Sales.SeqOrderIDs
	CACHE 100;

--T-SQL also supports a stored procedure called sp_sequence_get_range that you can use to allocate an entire range of sequence values of a requested size
--SQL Server provides a view called sys.sequences that you can use to query the properties of sequences defned in the current database

select * from sys.sequences

--Exercise 1 - Create a Sequence with Default Options
--1. Run the following code to create a sequence called dbo.Seq1
--You specify only the schema and object names and rely on defaults for all of the sequence properties
CREATE SEQUENCE dbo.Seq1;

--2. Issue the following code against the sys.sequences view to query the sequence properties
SELECT
	TYPE_NAME(system_type_id) AS type,
	start_value, minimum_value, current_value, increment, is_cycling
FROM sys.sequences
WHERE object_id = OBJECT_ID('dbo.Seq1');
/*
Observe that SQL Server used the BIGINT data type by default, the lowest value supported by the type (-9223372036854775808) as both the minimum and current values,
the highest value supported by the type as the maximum value, 1 as the increment, and no cycling
*/

--Exercise 2 - Create a Sequence with Nondefault Options
--1. Start with the sequence named dbo.Seq1 that you created in Exercise 1. In this exercise
--   you will alter the data type of the sequence from the default BIGINT to INT, in addition
--   to making it start with 1 and supporting cycling. However, unlike all other properties, the data type of an existing sequence cannot be altered. 
--   You have to recreate the sequence. Run the following code to drop and recreate the sequence.
IF OBJECT_ID('dbo.Seq1') IS NOT NULL 
	DROP SEQUENCE dbo.Seq1;

CREATE SEQUENCE dbo.Seq1 AS INT
START WITH 1 CYCLE;

--This code creates a sequence with an INT data type, indicating 1 as the start value, and creates support for cycling. Query the properties of the sequence
SELECT
	TYPE_NAME(system_type_id) AS type,
	start_value, minimum_value, current_value, increment, is_cycling
FROM sys.sequences
WHERE object_id = OBJECT_ID('dbo.Seq1');

/*
Observe that although the sequence was defned with a start value of 1, the minimum
value was still set to the lowest value in the type (-2147483648 in the case of INT) by default.
*/

--2.To see what happens after you get to the maximum value, frst alter the current sequence value to the maximum supported by the type by using the following code
ALTER SEQUENCE dbo.Seq1 RESTART WITH 2147483647;
--Then run the following code twice
SELECT NEXT VALUE FOR dbo.Seq1;
--You frst get 2147483647, and then get -2147483648—not 1—because the minimum sequence is defned as -2147483648

--3. If you want to create a sequence that cycles and supports only positive values, you need to set the MINVALUE property to 1. Run the following code to achieve this
IF OBJECT_ID('dbo.Seq1') IS NOT NULL 
	DROP SEQUENCE dbo.Seq1;

CREATE SEQUENCE dbo.Seq1 AS INT
	MINVALUE 1 CYCLE;

--4. Query the sequence properties by running the following code
SELECT
	TYPE_NAME(system_type_id) AS type,
	start_value, minimum_value, current_value, increment, is_cycling
FROM sys.sequences
WHERE object_id = OBJECT_ID('dbo.Seq1');
--Notice that both the minimum value and the start value were set to 1

--5. To see what happens when you reach the maximum value, frst run the following code
ALTER SEQUENCE dbo.Seq1 RESTART WITH 2147483647;
--Then run the following code twice to request two new sequence values.
SELECT NEXT VALUE FOR dbo.Seq1;
--You frst get 2147483647, and then you get 1.
