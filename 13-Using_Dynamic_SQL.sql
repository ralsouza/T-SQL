--PRATICE Writing and Testing Dynamic SQL
--In this exercise, you use QUOTENAME to simplify the process of generating T-SQL strings. A quick way to see the benefit of QUOTENAME is when using a variable.

--1. In this step, you use a variable to generate T-SQL strings. Open SSMS and open an empty query window. Execute the following batch of T-SQL code. 
--   Note that the resulting string that is printed does not have the correct delimiters.
USE TSQL2012;
GO
DECLARE @address AS NVARCHAR(60) = '5678 rue de l''Abbaye';
PRINT N'SELECT *
FROM [Sales].[Customers]
WHERE address = ' + @address;
GO

--2. Now embed the variable with QUOTENAME before concatenating it to the PRINT statement. Note that the resulting string is now successful.
USE TSQL2012;
GO
DECLARE @address AS NVARCHAR(60) = '5678 rue de l''Abbaye';
PRINT N'SELECT *
FROM [Sales].[Customers]
WHERE address = '+ QUOTENAME(@address, '''') + ';';
GO

--EXERCISE 2 Prevent SQL Injection
--In this exercise, you simulate SQL injection by using T-SQL, and practice how to prevent it by
--using the sp_executesql stored procedure. You pass a parameter to a stored procedure to
--simulate how a hacker would send in input from a screen.

--1. Open SSMS and load the following stored procedure script into a query window. The
--   procedure uses dynamic SQL to return a list of customers based on address. The exercise uses an address because it is a longer character string that could permit additional
--   SQL commands to be appended to it.
USE TSQL2012;
GO
IF OBJECT_ID('Sales.ListCustomersByAddress') IS NOT NULL
	DROP PROCEDURE Sales.ListCustomersByAddress;
GO
CREATE PROCEDURE Sales.ListCustomersByAddress
	@address NVARCHAR(60)
AS
	DECLARE @sqlstring AS NVARCHAR(4000);
SET @sqlstring = '
SELECT companyname, contactname
FROM Sales.Customers WHERE address = ''' + @address + '''';
	--PRINT @sqlstring;
EXEC(@sqlstring);
RETURN;
GO

--2. The stored procedure works as expected when the input parameter @address is normal. In a separate query window, execute the following.
USE TSQL2012;
GO
EXEC Sales.ListCustomersByAddress @address  = '8901 Tsawassen Blvd.';

--3. To simulate the hacker passing in a single quotation mark, call the stored procedure with two single quotation marks as a delimited string.
--   Note the error message from SQL Server.
USE TSQL2012;
GO
EXEC Sales.ListCustomersByAddress @address  = '''';

--4. Now insert a comment marker after the single quotation mark so that the final string delimiter is ignored.
USE TSQL2012;
GO
EXEC Sales.ListCustomersByAddress @address = '''--';

--5. All that remains is to inject the malicious code. The user actually types seLect 1 -- ',
--   which you can simulate as follows. The SELECT 1 command actually gets executed by
--   SQL Server after execution of the frst SELECT command. The hacker can now insert
--   any command, provided it is within the length of the accepted string.
USE TSQL2012;
GO
EXEC Sales.ListCustomersByAddress @address = ''' SELECT 2 --';

--6. Now revise the stored procedure to use sp_executesql and bring in the address as a parameter to the stored procedure, as follows.
USE TSQL2012;
GO
IF OBJECT_ID('Sales.ListCustomersByAddress') IS NOT NULL
	DROP PROCEDURE Sales.ListCustomersByAddress;
GO
CREATE PROCEDURE Sales.ListCustomersByAddress
	@address NVARCHAR(60)
AS
	DECLARE @sqlstring AS NVARCHAR(4000);
SET @sqlstring = '
SELECT companyname, contactname
FROM Sales.Customers WHERE address = @address';
EXEC sp_executesql
	 @statement = @sqlstring,
				  @params = N'@address NVARCHAR(60)',
				  @address = @address;

RETURN;
GO

--7. Now enter a valid address by using the revised stored procedure. Note that there is
--   no message indicating that there is an unclosed quotation mark. The single quotation
--   mark as a parameter to the stored procedure and to sp_executesql guarantees it will
--   only be treated as a single string.
USE TSQL2012;
GO
EXEC Sales.ListCustomersByAddress @address = '8901 Tsawassen Blvd.';

--8. Execute again the remaining steps to ensure that no unexpected data is returned.
USE TSQL2012;
GO
EXEC Sales.ListCustomersByAddress @address = '''';
EXEC Sales.ListCustomersByAddress @address = ''' -- ';
EXEC Sales.ListCustomersByAddress @address = ''' SELECT 1 -- ';

--EXERCISE 3 Use Output parameters with sp_executesql
--In this exercise, you use sp_executesql to return a value by using an output parameter. 
--Sometimes it is convenient to bring back results in a variable from dynamic SQL. 
--That is not possible with the EXEC statement, but sp_executesql can do that through output parameters

--1. Open SSMS and enter the following script into a query window. The script uses the
--   EXEC command to count the number of rows. Note that it is not possible to return that
--   count value back directly. Apart from storing it in a temporary table or some other
--   persistent mechanism, EXEC simply cannot communicate back to the caller. You can
--   see the count value in the output of SSMS, but cannot capture it in a variable.
USE TSQL2012;
GO
DECLARE @sqlstring AS NVARCHAR(4000);
SET @sqlstring = 'SELECT COUNT(*) FROM Production.Products';
EXEC(@sqlstring);

--2. You can use sp_executesql to capture and return values back to the caller by using
--   output parameters. In the following code, you specify the keyword OUTPUT both in
--   the parameter declaration and in the parameter assignment.
USE TSQL2012;
GO
DECLARE @sqlstring AS NVARCHAR(4000)
	   ,@outercount AS INT;
SET @sqlstring = N'SET @innercount = (SELECT COUNT(*) FROM Production.Products)';
EXEC sp_executesql 
	 @statement = @sqlstring,
	 @params = N'@innercount AS INT OUTPUT',
	 @innercount = @outercount OUTPUT;
SELECT @outercount AS 'RowCount';



/*
Usando o parâmetro OUTPUT - https://msdn.microsoft.com/pt-br/library/ms188001(v=sql.120).aspx
O exemplo a seguir usa um parâmetro OUTPUT para armazenar o conjunto de resultados gerado pela instrução SELECT no parâmetro @SQLString.Duas instruções SELECT que usam o valor do parâmetro OUTPUT são então executadas. 
*/
USE AdventureWorks2012;
GO
DECLARE @SQLString nvarchar(500);
DECLARE @ParmDefinition nvarchar(500);
DECLARE @SalesOrderNumber nvarchar(25);
DECLARE @IntVariable int;

SET @SQLString = N'SELECT @SalesOrderOUT = MAX(SalesOrderNumber)
                   FROM Sales.SalesOrderHeader
                   WHERE CustomerID = @CustomerID';
SET @ParmDefinition = N'@CustomerID int,@SalesOrderOUT nvarchar(25) OUTPUT';
SET @IntVariable = 22276;

EXECUTE sp_executesql
     @SQLString
    ,@ParmDefinition
    ,@CustomerID = @IntVariable
    ,@SalesOrderOUT = @SalesOrderNumber OUTPUT;

-- This SELECT statement returns the value of the OUTPUT parameter.
SELECT @SalesOrderNumber;

-- This SELECT statement uses the value of the OUTPUT parameter in
-- the WHERE clause.
SELECT OrderDate, TotalDue
FROM Sales.SalesOrderHeader
WHERE SalesOrderNumber = @SalesOrderNumber;