USE TSQL2012;
GO

--Merging Data
--With the MERGE statement, you can MERGE data from a source table or table expression intoa target table. 
--The general form of the MERGE statement is as follows.
	MERGE INTO <target table> AS TGT
	USING <SOURCE TABLE> AS SRC
	ON <merge predicate>
	WHEN MATCHED [AND <predicate>] -- two clauses allowed:
		THEN <action> -- one with UPDATE one with DELETE
	WHEN NOT MATCHED [BY TARGET] [AND <predicate>] -- one clause allowed:
		THEN INSERT... -- if indicated, action must be INSERT
	WHEN NOT MATCHED BY SOURCE [AND <predicate>] -- two clauses allowed:
		THEN <action>; -- one with UPDATE one with DELETE

--To demonstrate examples of the MERGE statement, this lesson uses the Sales.MyOrders table and the Sales.SeqOrderIDs sequence from the previous lesson
--If you still have them in the database, use the following code to clear the table and reset the sequence
TRUNCATE TABLE Sales.MyOrders;
ALTER SEQUENCE Sales.SeqOrderIDs RESTART WITH 1;

--If the table and sequence don’t exist in the database, use the following code to create them
IF OBJECT_ID('Sales.MyOrders') IS NOT NULL 
	DROP TABLE Sales.MyOrders;

IF OBJECT_ID('Sales.SeqOrderIDs') IS NOT NULL 
	DROP SEQUENCE Sales.SeqOrderIDs;

CREATE SEQUENCE Sales.SeqOrderIDs AS INT
	MINVALUE 1
	CYCLE;

CREATE TABLE Sales.MyOrders
(
	orderid INT NOT NULL
		CONSTRAINT PK_MyOrders_orderid PRIMARY KEY
		CONSTRAINT DFT_MyOrders_orderid
		DEFAULT(NEXT VALUE FOR Sales.SeqOrderIDs),
	custid INT NOT NULL
		CONSTRAINT CHK_MyOrders_custid CHECK(custid > 0),
	empid INT NOT NULL
		CONSTRAINT CHK_MyOrders_empid CHECK(empid > 0),
	orderdate DATE NOT NULL
);

--Suppose that you need to define a stored procedure that accepts as input parameters attributes of an order
--If an order with the input order ID already exists in the Sales.MyOrders table, you need to update the row, setting the values of the nonkey columns to the new ones
--If the order ID doesn’t exist in the target table, you need to insert a new row
--The first things to identify in a MERGE statement are the target and the source tables
--The target is easy it’s the Sales.MyOrders
--The source is supposed to be a table or table expression, but in this case, it’s just a set of input parameters making an order
--To turn the inputs into a table expression, you can use one of two options: a SELECT without a FROM clause or the VALUES table value constructor

--Here’s an example for a query against a table expression defined from input variables based on a SELECT statement without a FROM clause
DECLARE
	@orderid   AS INT  = 1,
	@custid    AS INT  = 1,
	@empid     AS INT  = 2,
	@orderdate AS DATE = '20120620';

SELECT *
FROM (SELECT @orderid, @custid, @empid, @orderdate )
	  AS SRC( orderid, custid, empid, orderdate );

--Here’s an example of doing the same thing with the VALUES table value constructor
DECLARE
	@orderid AS INT = 1,
	@custid  AS INT = 1,
	@empid   AS INT = 2,
	@orderdate AS DATE = '20120620';

SELECT *
FROM (VALUES(@orderid, @custid, @empid, @orderdate))
	  AS SRC( orderid, custid, empid, orderdate);

--The following code implements what some people refer to as upsert logic (update where exists, insert where not exists)
--The code uses the Sales.MyOrders table as the target table and the table value constructor from the previous example as the source table
DECLARE
	@orderid AS INT = 1,
	@custid AS INT  = 1,
	@empid AS INT   = 2,
	@orderdate AS DATE = '20120620';

MERGE INTO Sales.MyOrders WITH (HOLDLOCK) AS TGT
USING (VALUES(@orderid, @custid, @empid, @orderdate))
	   AS SRC( orderid, custid, empid, orderdate)
	ON SRC.orderid = TGT.orderid
WHEN MATCHED THEN UPDATE
	SET TGT.custid    = SRC.custid,
		TGT.empid     = SRC.empid,
		TGT.orderdate = SRC.orderdate
WHEN NOT MATCHED THEN INSERT
	VALUES(SRC.orderid, SRC.custid, SRC.empid, SRC.orderdate);

SELECT * FROM Sales.MyOrders

/*
Observe that the MERGE predicate compares the source order ID with the target order
ID. When a match is found (the source order ID is matched by a target order ID), the MERGE
statement performs an UPDATE action that updates the values of the nonkey columns in the
target to those from the respective source row.

When a match isn’t found (the source order ID is not matched by a target order ID), the
MERGE statement inserts a new row with the source order information into the target.
*/

/*
IMPORTANT Avoiding MERGE Conflicts
Suppose that a certain key K doesn’t yet exist in the target table. Two processes, P1 and P2,
run a MERGE statement such as the previous one at the same time with the same source
key K. It is normally possible for the MERGE statement issued by P1 to insert a new row
with the key K between the points in time when the MERGE statement issued by P2 checks
whether the target already has that key and inserts rows. In such a case, the MERGE statement issued by P2 will fail due to a primary key violation. 
To prevent such a failure, use the hint SERIALIZABLE or HOLDLOCK (both have equivalent meanings) against the target as
shown in the previous statement.
*/

/*
TIP - MERGE Requires Only One Clause at Minimum
The MERGE statement doesn’t require you to always specify the WHEN MATCHED and WHEN NOT MATCHED clauses;
at a minimum, you are required to specify only one clause, and it could be any of the three WHEN clauses. 
For example, a MERGE statement that specifes only the WHEN MATCHED clause is a standard alternative to an UPDATE statement based on a join, 
which isn’t standard.

USING clause where you define the source for the MERGE operation is that it’s designed like the FROM clause in a SELECT statement
This means that you can define table operators like JOIN, APPLY, PIVOT, and UNPIVOT; and use table expressions like
derived tables, CTEs, views, inline table functions, and even table functions like OPENROWSET and OPENXML.
the USING clause returns a table result, and that table result is used as the source for the MERGE statement.
*/

--Regarding the second run of the code, notice that it’s a waste to issue an UPDATE action when the source and target rows are completely identical
--You can add a predicate that says that at least one of the nonkey column values in the source and the target must be different in order to apply the UPDATE action
DECLARE @orderid	AS INT	= 1,
		@custid		AS INT	= 1,
		@empid		AS INT  = 2,
		@orderdate	AS DATE	= '20120620';

MERGE INTO Sales.MyOrders WITH (HOLDLOCK) AS TGT
USING (VALUES(@orderid,@custid,@empid,@orderdate))
	   AS SRC( orderid ,custid ,empid ,orderdate)
	ON SRC.orderid = TGT.orderid
WHEN MATCHED AND (	   TGT.custid    <> SRC.custid
					OR TGT.empid     <> SRC.empid
					OR TGT.orderdate <> SRC.orderdate) THEN UPDATE
		SET TGT.custid    = SRC.custid,
			TGT.empid	  = SRC.empid,
			TGT.orderdate = SRC.orderdate
WHEN NOT MATCHED THEN INSERT
	VALUES(SRC.orderid,SRC.custid,SRC.empid,SRC.orderdate);

--Now the code updates the target row only when the source order ID is equal to the target order ID,
--and at least one of the other columns have different values in the source and the target
--If the source order ID is not found in the target, the statement will insert a new row like before

/*
IMPORTANT MERGE Predicate and NULLs
When checking whether the target column value is different than the source column value,
the preceding MERGE statement uses a simple inequality operator (<>). In this example,
neither the target nor the source columns can be NULL. But if NULLs are possible in the
data, you need to add logic to deal with those, and consider a case when one side is NULL
and the other isn’t as true. For example, say the custid column allowed NULLs. You would
use the following predicate.
*/

TGT.custid = SRC.custid OR (TGT.custid IS NULL AND SRC.custid IS NOT
NULL) OR (TGT.custid IS NOT NULL AND SRC.custid IS NULL)

/*
T-SQL extends standard SQL by supporting a third clause called WHEN NOT MATCHED
BY SOURCE. With this clause, you can define an action to take against the target row when
the target row exists but is not matched by a source row. The allowed actions are UPDATE
and DELETE.

For example, suppose that you want to add such a clause to the last example to
indicate that if a target row exists and it is not matched by a source row, you want to delete
the target row. Here’s how your MERGE statement would look (this time using a table variable
with multiple orders as the source).
*/
select * from sales.MyOrders;

DECLARE @Orders AS TABLE
(
	orderid INT NOT NULL PRIMARY KEY,
	custid INT NOT NULL,
	empid INT NOT NULL,
	orderdate DATE NOT NULL
);

INSERT INTO @Orders(orderid, custid, empid, orderdate) VALUES
	(2, 1, 3, '20120612'),
	(3, 2, 2, '20120612'),
	(4, 3, 5, '20120612');

MERGE INTO Sales.MyOrders AS TGT
USING @Orders AS SRC
	ON SRC.orderid = TGT.orderid
WHEN MATCHED AND (   TGT.custid    <> SRC.custid
				  OR TGT.empid     <> SRC.empid
				  OR TGT.orderdate <> SRC.orderdate) THEN UPDATE
	SET TGT.custid    = SRC.custid,
		TGT.empid     = SRC.empid,
		TGT.orderdate = SRC.orderdate
WHEN NOT MATCHED THEN INSERT
	VALUES(SRC.orderid, SRC.custid, SRC.empid, SRC.orderdate)
WHEN NOT MATCHED BY SOURCE THEN DELETE;

select * from sales.MyOrders;

--Before you ran this statement, only one row in the table had order ID 1
--So the statement inserted the three rows with order IDs 2, 3, and 4, and deleted the row that had order ID 1 Query the current state of the table

--What are the possible actions in the WHEN MATCHED clause? UPDATE and DELETE.
--How many WHEN MATCHED clauses can a single MERGE statement have? Two—one with an UPDATE action and one with a DELETE action.
--389 (421 / 738)