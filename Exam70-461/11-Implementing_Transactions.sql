/*

EXERCISE 1 Work with Transaction Modes

1. Work with an implicit transaction first by opening SSMS and opening an empty query
window. Execute the following code. Execute each command step by step, in sequence.
Note the output of @@TRANCOUNT. */
USE TSQL2012;
SET IMPLICIT_TRANSACTIONS ON;
SELECT @@TRANCOUNT; --0
SET IDENTITY_INSERT Production.Products ON;
--Issue DML or DDL command here
INSERT INTO Production.Products(productid, productname, supplierid, categoryid,unitprice, discontinued) VALUES
(101, N'Test2: Bad categoryid', 1, 1, 18.00, 0);
SELECT @@TRANCOUNT; --1
COMMIT TRAN;
SET IDENTITY_INSERT Production.Products OFF;
SET IMPLICIT_TRANSACTIONS OFF;
--Remove the inserted row
DELETE FROM Production.Products WHERE productid = 101; -- Note the row is deleted

/*
2. Next, you work with an explicit transaction. Execute the following code. Note the value
of @@TRANCOUNT */
USE TSQL2012;
SELECT @@TRANCOUNT; --0
BEGIN TRAN;
	SELECT @@TRANCOUNT;--1
	SET IDENTITY_INSERT Production.Products ON;
	INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued) VALUES
		(101, N'Test2: Bad categoryid', 1, 1, 18.00, 0);
	SELECT @@TRANCOUNT; --1
	SET IDENTITY_INSERT Production.Products OFF;
COMMIT TRAN;
--Remove the inserted row
DELETE FROM Production.Products WHERE productid = 101; -- Note the row is deleted

/*
To work with a nested transaction by using COMMIT TRAN, execute the following
code. Note that the value of @@TRANCOUNT increments to 2. */
USE TSQL2012;
SELECT @@TRANCOUNT; -- = 0
BEGIN TRAN;
	SELECT @@TRANCOUNT; -- = 1
	BEGIN TRAN
		--Issue data modification or DDL commands here
		SELECT @@TRANCOUNT; -- = 2
		SET IDENTITY_INSERT Production.Products ON;
		INSERT INTO Production.Products(productid, productname, supplierid, categoryid, unitprice, discontinued) VALUES
			(101, N'Test2: Bad categoryid', 1, 1, 18.00, 0);
		SELECT @@TRANCOUNT; -- = 2
		SET IDENTITY_INSERT Production.Products OFF;
	COMMIT
	SELECT @@TRANCOUNT;-- = 1
COMMIT TRAN;
SELECT @@TRANCOUNT;-- = 0
DELETE FROM Production.Products WHERE productid = 101; -- Note the row is deleted

/*
4. To work with a nested transaction by using ROLLBACK TRAN, execute the following
code. Note that the value of @@TRANCOUNT increments to 2 but only one ROLLBACK
is required. */
USE TSQL2012;
SELECT @@TRANCOUNT;-- = 0
BEGIN TRAN;
	SELECT @@TRANCOUNT;-- = 1
	BEGIN TRAN;
		SELECT @@TRANCOUNT;-- = 2
		--Issue data modification or DDL command here
	ROLLBACK; -- rolls back the entire transaction at this point
SELECT @@TRANCOUNT; -- = 0

/*
Exercise 2 Work with Blocking and Deadlocking

In this exercise, you work with two common scenarios: blocking and deadlocking.

1. In this step, you work with writers blocking writers. Open SSMS and two empty query
windows. Execute the code side by side as shown in Table 12-4. Execute each step in
sequence. When locks are incompatible, the session requesting the incompatible lock
must wait and is considered to be in a blocked state. Session 1 obtains an exclusive
lock on the row being changed. At nearly the same time or shortly thereafter, Session
2 tries to update the same row. Session 1 has not released its exclusive lock on the
row because in a transaction, all exclusive locks are held until the end of the transaction.
Therefore, Session 2 has to wait until Session 1 either commits or rolls back, and the
lock on the row is released, for its update to finish. 

Note Writers Block Writers: An exclusive lock is incompatible with a similar exclusive lock request.
*/

--Session 1
USE TSQL2012;
BEGIN TRAN;
-----------------
UPDATE HR.Employees
SET postalcode = N'10004'
WHERE empid = 1;
-----------------
--<morework>
-----------------
COMMIT TRAN;
-----------------


-----------------
--Cleanup:
UPDATE HR.Employees
SET postalcode = N'10003'
WHERE empid = 1;

--Session 2
USE TSQL2012;
-----------------
UPDATE HR.Employees
SET phone = N'555-9999'
WHERE empid = 1;
-----------------
--<blocked>
-----------------


-----------------
--<results returned>
-----------------

/*
2. This step works with READ UNCOMMITTED. In the READ COMMITTED isolation level,
even a reader may have to wait for a transaction to fnish, causing blocking and even
deadlocking in busy systems. One way to reduce that blocking is to allow readers to
read uncommitted data by using the READ UNCOMMITTED isolation level. Open SSMS
and two empty query windows. Execute the code side by side as shown in Table 12-7.
Execute each step in sequence. Note that the SELECT statement in Session 2 now reads
uncommitted data. */
