--Designing Inline Functions
USE TSQL2012;
GO

DECLARE @orderyear int = 2007;

CREATE FUNCTION Sales.fn_OrderTotalsByYear (@orderyear int)
RETURNS TABLE
AS
RETURN
(
	SELECT orderyear, qty FROM Sales.OrderTotalsByYear
	WHERE orderyear = @orderyear
);
GO

--You can query the function but pass the year you want to see, as follows
SELECT orderyear, qty FROM Sales.fn_OrderTotalsByYear(2007);

--Exercise 1 - Build a View for a Report
SELECT
	C.companyname AS customercompany,
	S.companyname AS shippercompany,
	YEAR(O.orderdate) AS orderyear,
	SUM(OD.qty) AS qty,
	CAST(SUM(OD.qty * OD.unitprice * (1 - OD.discount))	AS NUMERIC(12, 2)) AS val
FROM Sales.Orders AS O
	JOIN Sales.OrderDetails AS OD
		ON OD.orderid = O.orderid
	JOIN Sales.Customers AS C
		ON O.custid = C.custid
	JOIN Sales.Shippers AS S
		ON O.shipperid = S.shipperid
GROUP BY YEAR(O.orderdate), C.companyname, S.companyname;

--Turn this into a view called sales.Ordertotalsbyyearcustship
IF OBJECT_ID (N'Sales.OrderTotalsByYearCustShip', N'V') IS NOT NULL
	DROP VIEW Sales.OrderTotalsByYearCustShip;
GO

CREATE VIEW Sales.OrderTotalsByYearCustShip
WITH SCHEMABINDING
AS
SELECT
	C.companyname AS customercompany,
	S.companyname AS shippercompany,
	YEAR(O.orderdate) AS orderyear,
	SUM(OD.qty) AS qty,
	CAST(SUM(OD.qty * OD.unitprice * (1 - OD.discount)) AS NUMERIC(12, 2)) AS val
FROM Sales.Orders AS O
	JOIN Sales.OrderDetails AS OD
		ON OD.orderid = O.orderid
	JOIN Sales.Customers AS C
		ON O.custid = C.custid
	JOIN Sales.Shippers AS S
		ON O.shipperid = S.shipperid
GROUP BY YEAR(O.orderdate), C.companyname, S.companyname;
GO

--Test the view by selecting from it
SELECT customercompany, shippercompany, orderyear, qty, val
FROM Sales.OrderTotalsByYearCustShip
ORDER BY customercompany, shippercompany, orderyear;

--Clean up
IF OBJECT_ID(' Sales.OrderTotalsByYearCustShip', N'V') IS NOT NULL
	DROP VIEW Sales.OrderTotalsByYearCustShip

--Exercise 2 - Convert a View into an Inline Function
IF OBJECT_ID (N'Sales.fn_OrderTotalsByYearCustShip', N'IF') IS NOT NULL
DROP FUNCTION Sales.fn_OrderTotalsByYearCustShip;
GO

CREATE FUNCTION Sales.fn_OrderTotalsByYearCustShip (@lowqty int, @highqty int)
RETURNS TABLE
AS
RETURN
(
SELECT
	C.companyname AS customercompany,
	S.companyname AS shippercompany,
	YEAR(O.orderdate) AS orderyear,
	SUM(OD.qty) AS qty,
	CAST(SUM(OD.qty * OD.unitprice * (1 - OD.discount)) AS NUMERIC(12, 2)) AS val
FROM Sales.Orders AS O
	JOIN Sales.OrderDetails AS OD
		ON OD.orderid = O.orderid
	JOIN Sales.Customers AS C
		ON O.custid = C.custid
	JOIN Sales.Shippers AS S
		ON O.shipperid = S.shipperid
GROUP BY YEAR(O.orderdate), C.companyname, S.companyname
HAVING SUM(OD.qty) >= @lowqty AND SUM(OD.qty) <= @highqty
);
GO

--Test the function
SELECT customercompany, shippercompany, orderyear, qty, val
FROM Sales.fn_OrderTotalsByYearCustShip (100, 200)
ORDER BY customercompany, shippercompany, orderyear;

--Clean up
IF OBJECT_ID (N'Sales.OrderTotalsByYearCustShip', N'V') IS NOT NULL
DROP VIEW Sales.OrderTotalsByYearCustShip;
GO
IF OBJECT_ID (N'Sales.fn_OrderTotalsByYearCustShip', N'IF') IS NOT NULL
DROP FUNCTION Sales.fn_OrderTotalsByYearCustShip;
GO