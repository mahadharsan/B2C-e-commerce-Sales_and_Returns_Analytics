### ANALYTICS ASSIGNMENT
## MAHADHARSAN RAVICHANDRAN - mahadharsanusa@gmail.com
##CONTENTS
-- Questions and Answers Queries
-- Appendix
	   -- Assumptions
       -- Data Exploration 
	   -- Duplicate values Tracked

use acadia;

## QUESTIONS AND ANSWERS
# Q1. Percentage of returns from sales
-- For data where OrderID match the % of returns is 4.63% 
SELECT 
(SELECT COUNT(r.OrderID) FROM returns r INNER JOIN sales s ON s.OrderID = r.OrderID) *100 / 
(SELECT COUNT(DISTINCT s.OrderID) FROM sales s) AS PercentageOfReturnedOrders;


# Q2. What percent of returns are full returns
-- 18.01 Percentage of returns orders from the sales are returned fully.
SELECT ( SELECT COUNT(DISTINCT r.OrderID) FROM returns r 
INNER JOIN sales s ON s.OrderID = r.OrderID
where r.ReturnSales = s.Sales) * 100 / 
(SELECT COUNT(r.OrderID) FROM returns r 
INNER JOIN sales s ON s.OrderID = r.OrderID) as PercentofFullReturns;
	
 
# Q3. Average return % of sales amount
-- 57.87 is the average of % salesamount being returned. 
WITH ReturnTotals AS (
  SELECT OrderID, SUM(ReturnSales) AS TotalReturnSales
  FROM returns
  GROUP BY OrderID
)
SELECT ROUND(AVG((rt.TotalReturnSales / s.Sales) * 100),2) AS AverageReturnPercentage FROM sales s
JOIN ReturnTotals rt ON s.OrderID = rt.OrderID;


# Q4. What percentage of returns occcur within 7 days of the sale
-- 40.225 % of returns are returned within 7 days of sales date
SELECT (SELECT count(r.orderID) FROM returns r 
INNER JOIN sales s ON s.OrderID = r.OrderID
where DATEDIFF(r.ReturnDate,s.TransactionDate) <=7)/ 
(SELECT COUNT(r.OrderID) FROM returns r 
INNER JOIN sales s ON s.OrderID = r.OrderID) * 100 as PercentReturnWindow7;
 
 
# Q5. Average no of days for a return to occur
-- 78 Days
SELECT ROUND(AVG(DATEDIFF(r.ReturnDate, s.TransactionDate))) as AverageReturnWindow FROM returns r 
INNER JOIN sales s on s.OrderID = r.OrderID;


# Q6. Valuable customer
-- The loyal customer : RIVES87271	86441.72 with no returns and highest Net Sales
# First Approach : Highest Net sales 
SELECT s.CustomerID, SUM(s.Sales) - IFNULL(SUM(r.ReturnSales), 0) AS NetSales FROM sales s
LEFT JOIN returns r ON s.OrderID = r.OrderID
GROUP BY s.CustomerID
ORDER BY NetSales DESC
LIMIT 1;

# Second approach : High Sales with no returns
SELECT s.CustomerID, SUM(s.Sales) AS TotalSales
FROM sales s
LEFT JOIN returns r ON s.CustomerID = r.CustomerID
WHERE r.CustomerID IS NULL
GROUP BY s.CustomerID
ORDER BY TotalSales DESC
LIMIT 1;




-------------- APPENDIX ------------------------------------------------

## ASSUMPTIONS 
-- Assumption 1 : OrderID can be repeated in returns because multiple items can be returned using same OrderID.
-- Assumption 2 : Only returns related to Sales table are to be analysed.

## DATA EXPLORATION
/* 
-- I noticed that there are some returns with customerID that is absent in sales tables
-- select max(sales.TransactionDate), min(sales.TransactionDate) from sales;
-- (20150115	20150101)
-- select max(returns.ReturnDate), min(returns.ReturnDate) from returns;
-- (20160923	20141230)

-- select DISTINCT returns.CustomerID from returns 
-- where returns.CustomerID NOT IN (select sales.CustomerID from sales);

SELECT r.CustomerID FROM returns r
LEFT JOIN sales s ON r.CustomerID = s.CustomerID
WHERE s.CustomerID IS NULL;

SELECT r.OrderID FROM returns r
LEFT JOIN sales s ON r.OrderID = s.OrderID
WHERE s.OrderID IS NULL;

-- About 13k data in returns does not have customerID that is there in Sales.CustomerID 
select count(OrderID) as No_of_unique_customers from sales;
-- 33751 (This value should remain same even if DISTINCT orderID is considered and it is passed)

select count(OrderID) as No_of_customers_returned_products from returns;
-- 15808

SELECT COUNT(r.OrderID) AS ReturnedSales
FROM returns r
INNER JOIN sales s ON r.OrderID = s.OrderID;

-- 1565 Returns can be fetched that matches with the orderID in sales
*/

# DUPLICATE VALUES
/* 
SELECT COUNT(DISTINCT r.OrderID) FROM returns r 
INNER JOIN sales s ON s.OrderID = r.OrderID
where r.ReturnSales = s.Sales;

-- 282 Returns are full returns

SELECT COUNT(r.OrderID) FROM returns r 
INNER JOIN sales s ON s.OrderID = r.OrderID
where r.ReturnSales = s.Sales;

-- 284 Returns are full returns. The difference, 2 Returns are duplicated values and is not possible in reality

-- Those two values are duplicated so I decided to find the details
with RepeatedReturnsErrors as (SELECT r.OrderID
FROM returns r
INNER JOIN sales s ON s.OrderID = r.OrderID
WHERE r.ReturnSales = s.Sales
GROUP BY r.OrderID
HAVING COUNT(r.OrderID) > 1)

SELECT s.OrderID, s.Sales AS Sales, r.ReturnSales as ReturnSales, s.CustomerID AS SalesCustomerID, r.CustomerID AS ReturnCustomerID, s.TransactionDate, r.ReturnDate
FROM returns r
INNER JOIN sales s ON s.OrderID = r.OrderID
WHERE r.OrderID IN (SELECT OrderID FROM RepeatedReturnsErrors)
ORDER BY r.OrderID, r.ReturnDate;

01035I2JDDQ 	429.45	429.45	HOWAL72396	HOWAL72396	20150109	20150208
01035I2JDDQ 	429.45	429.45	HOWAL72396	HOWAL72396	20150109	20150311
01105E4KYWH 	381.48	381.48	FISHJ30557	FISHJ30557	20150113	20150117
01105E4KYWH 	381.48	381.48	FISHJ30557	FISHJ30557	20150113	20150117
*/

