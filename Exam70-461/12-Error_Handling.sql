USE TSQL2012;
GO

--Exercise 1 Work with Unstructured Error handling
--In this exercise, you work with unstructured error handling, using the @@ERROR function
/* 1- This step uses @@ERROR. In the following code, you test the value of the @@ERROR
      statement immediately after a data modifcation statement takes place. Open SSMS
      error message that SQL Server sends back to the client application, SQL Server Management Studio. */
DECLARE @errnum AS int;

BEGIN TRAN;
SET IDENTITY_INSERT production.Products ON;
INSERT INTO Production.Products(productid,productname,supplierid,categoryid,unitprice,discontinued)
	VALUES (1,N'Teste1: Ok categoryid',1,1,18.00,0);
SET @errnum = @@ERROR;
IF @errnum <> 0 --Handle the error
	BEGIN
		PRINT 'Insert into Prodiction.Products failed with error ' + CAST(@errnum as VARCHAR);
	END;
GO

/* 2- In this step, you work with unstructured error handling in a transaction. In the following code, 
      you have two INSERT statements in a batch and wrap them in a transaction in order to roll back the transaction if either statement fails. 
	  The frst INSERT fails, but the second succeeds because SQL Server, by default, will not roll back a transaction
	  with a duplicate primary key error. When the code runs, note that the frst INSERT fails, due to a primary key violation, 
	  and the transaction is rolled back. However, the second
	  INSERT succeeds because the unstructured error handling does not transfer control of
	  the program in a way that would avoid the second INSERT. To achieve better control,
	  you must add signifcant coding to get around this problem. Open SSMS and open an
	  empty query window. Execute the entire batch of T-SQL code. */
USE TSQL2012;
GO

DECLARE @errnum AS INT;

BEGIN TRAN;
	SET IDENTITY_INSERT Production.Products ON;
	--Insert #1 will fail because of duplicate primary key
	INSERT INTO Production.Products(productid,productname,supplierid,categoryid,unitprice,discontinued)
		VALUES(1,N'Teste1: Ok caategoryid',1,1,18.00,0);
	SET @errnum = @@ERROR;
	IF @errnum <> 0
		BEGIN
			IF @@TRANCOUNT > 0 ROLLBACK TRAN;
			PRINT 'Insert #1 into Production.Products failed with error ' + CAST(@errnum AS VARCHAR);
		END;
	--Insert #2 will succeed
	INSERT INTO Production.Products(productid,productname,supplierid,categoryid,unitprice,discontinued)
		VALUES(101,N'Teste2: Bad categoryid',1,1,18.00,0);
	SET @errnum = @@ERROR;
	IF @errnum <> 0 
		BEGIN
			IF @@TRANCOUNT > 0 ROLLBACK TRAN;
			PRINT 'Insert #2 into Production.Products failed with error ' + CAST(@errnum AS VARCHAR);
		END;
	SET IDENTITY_INSERT Production.Products OFF;
	IF @@TRANCOUNT > 0 COMMIT TRAN;
--Remove the inserted row
DELETE FROM Production.Products WHERE productid = 101;
PRINT 'Deleted ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';

--Exercise 2 Use XACT_ABORT to handle Errors
/* 1- In this step, you use XACT_ABORT and encounter an error. 
      In the following code, you verify that XACT_ABORT will abort a batch if SQL Server encounters an error in a data modifcation statement. 
	  Open SSMS and open an empty query window. Execute both batches of T-SQL code.
	  Note the error message that SQL Server sends back to the client application, SQL Server Management Studio. */
USE TSQL2012;
GO

SET XACT_ABORT ON;
PRINT 'Before Error';
SET IDENTITY_INSERT Production.Products ON;
INSERT INTO Production.Products(productid,productname,supplierid,categoryid,unitprice,discontinued)
	VALUES(1,N'Teste1: Ok categoryid',1,1,18.00,0);
SET IDENTITY_INSERT Production.Products OFF;
PRINT 'After Error';
GO

PRINT 'New batch';
SET XACT_ABORT OFF;

/*2- This step uses THROW with XACT_ABORT. In the following code, you verify that XACT_ABORT will abort a batch if you throw an error. 
     Open SSMS and open an empty query window. Note that executing THROW with XACT_ABORT ON causes the batch to be terminated. 
	 Execute both batches of T-SQL code.*/
USE TSQL2012;
GO

SET XACT_ABORT ON;
PRINT 'Before Error';
THROW 50000,'Error in usp_InsertCategories stored procedure',0;
PRINT 'After Error';
GO

PRINT 'New batch';
SET XACT_ABORT OFF;

--Exercise 3 Work with Structured Error handling by Using TRY/CATCH
/*1 - In this step, you start out with TRY/CATCH.
      The following code has two INSERT statements in a single batch, wrapped in a transaction. 
      The first INSERT fails, but the second will succeed because SQL Server by default will not roll back a transaction with a duplicate primary key error. 
	  When the code runs, note that the first INSERT fails, due to a duplicate key violation, and the transaction is rolled back.
	  However, no error is sent to the client, and execution transfers to the CATCH block. 
	  The error is handled and the transaction is rolled back. 
	  Open SSMS and open an empty query window. Execute the entire batch of T-SQL code. */
USE TSQL2012;
GO

BEGIN TRY
BEGIN TRAN;
	SET IDENTITY_INSERT Production.Products ON;
	INSERT INTO Production.Products(productid,productname,supplierid,categoryid,unitprice,discontinued) VALUES(1  ,N'Test1: Ok categoryid', 1,1 ,18.00,0);
	INSERT INTO Production.Products(productid,productname,supplierid,categoryid,unitprice,discontinued) VALUES(101,N'Test2: Bad categoryid',1,10,18.00,0);
	SET IDENTITY_INSERT Production.Products OFF;
COMMIT TRAN;
END TRY
BEGIN CATCH
	IF ERROR_NUMBER() = 2627 --Duplicate key violation
		BEGIN
			PRINT 'Primary Key violation';
		END
	ELSE IF ERROR_NUMBER() = 547 --Constraint violations
		BEGIN
			PRINT 'Constraint violation';
		END
	ELSE 
		BEGIN
			PRINT 'Unhandled error';
		END;
	IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
END CATCH;

--2. Revise the CATCH block by using variables to capture error information and re-raise the error using RAISERROR
USE TSQL2012;
GO

SET NOCOUNT ON;

DECLARE	@error_num AS INT,
	    @error_message AS NVARCHAR(1000),
		@error_severity AS INT;

BEGIN TRY
BEGIN TRAN;
	SET IDENTITY_INSERT Production.Products ON;
	INSERT INTO Production.Products(productid,productname,supplierid,categoryid,unitprice,discontinued) VALUES(1  ,N'Test1: Ok categoryid' ,1,1 ,18.00,0);
	INSERT INTO Production.Products(productid,productname,supplierid,categoryid,unitprice,discontinued) VALUES(101,N'Test2: Bad categoryid',1,10,18.00,0);
	SET IDENTITY_INSERT Production.Products OFF;
COMMIT TRAN;
END TRY
BEGIN CATCH
	SELECT XACT_STATE() AS 'XACT_STATE', @@TRANCOUNT AS 'TRANCOUNT';
	SELECT @error_num = ERROR_NUMBER(), @error_message = ERROR_MESSAGE(),@error_severity = ERROR_SEVERITY();
	RAISERROR(@error_message, @error_severity, 1);
	IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
END CATCH;

--3. Next, use a THROW statement without parameters to re-raise (re-throw) the original error message and send it back to the client
--   This is by far the best method for reporting the error back to the caller
USE TSQL2012;
GO

BEGIN TRY
BEGIN TRAN;
	SET IDENTITY_INSERT Production.Products ON;
	INSERT INTO Production.Products(productid,productname,supplierid,categoryid,unitprice,discontinued) VALUES(1  ,N'Test1: Ok categoryid' ,1,1,18.00,0);
	INSERT INTO Production.Products(productid,productname,supplierid,categoryid,unitprice,discontinued) VALUES(101,N'Test2: Bad categoryid',1,10,18.00,0);
	SET IDENTITY_INSERT Production.Products OFF;
COMMIT TRAN;
END TRY
BEGIN CATCH
	SELECT XACT_STATE() AS 'XACT_STATE',@@TRANCOUNT AS 'TRANCOUNT';
	IF @@TRANCOUNT > 0 ROLLBACK TRAN;
	THROW;
END CATCH;
GO
SELECT XACT_STATE() AS 'XACT_STATE',@@TRANCOUNT AS 'TRANCOUNT';


/*O exemplo a seguir usa XACT_STATE no bloco CATCH de uma construção TRY…CATCH para determinar se uma transação será confirmada ou revertida. 
  Como SET XACT_ABORT é ON, o erro de violação de restrição faz a transação entrar em um estado não confirmável.
  URL: https://docs.microsoft.com/pt-br/sql/t-sql/functions/xact-state-transact-sql
  */

USE AdventureWorks2012;  
GO  

-- SET XACT_ABORT ON will render the transaction uncommittable  
-- when the constraint violation occurs.  
SET XACT_ABORT ON;  

BEGIN TRY  
    BEGIN TRANSACTION;  
        -- A FOREIGN KEY constraint exists on this table. This   
        -- statement will generate a constraint violation error.  
        DELETE FROM Production.Product  
            WHERE ProductID = 980;  

    -- If the delete operation succeeds, commit the transaction. The CATCH  
    -- block will not execute.  
    COMMIT TRANSACTION;  
END TRY  
BEGIN CATCH  
    -- Test XACT_STATE for 0, 1, or -1.  
    -- If  1, the transaction is committable.  
    -- If -1, the transaction is uncommittable and should   
    --     be rolled back.  
    -- XACT_STATE = 0 means there is no transaction and  
    --     a commit or rollback operation would generate an error.  

    -- Test whether the transaction is uncommittable.  
    IF (XACT_STATE()) = -1  
    BEGIN  
        PRINT 'The transaction is in an uncommittable state.' +  
              ' Rolling back transaction.'  
        ROLLBACK TRANSACTION;  
    END;  

    -- Test whether the transaction is active and valid.  
    IF (XACT_STATE()) = 1  
    BEGIN  
        PRINT 'The transaction is committable.' +   
              ' Committing transaction.'  
        COMMIT TRANSACTION;     
    END;  
END CATCH;  
GO  
