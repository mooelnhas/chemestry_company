USE master;
GO

/*=================================================
                CREATE DATABASE
=================================================*/

CREATE DATABASE chemestry_company
ON
(
    NAME = chemestry_company_data,

    FILENAME =
'C:\Program Files\Microsoft SQL Server\MSSQL17.MSSQLSERVER\MSSQL\DATA\chemestry_company_data.mdf',

    SIZE = 10MB,
    MAXSIZE = 50MB,
    FILEGROWTH = 5MB
)

LOG ON
(
    NAME = chemestry_company_log,

    FILENAME =
'C:\Program Files\Microsoft SQL Server\MSSQL17.MSSQLSERVER\MSSQL\DATA\chemestry_company_log.ldf',

    SIZE = 5MB,
    MAXSIZE = 25MB,
    FILEGROWTH = 5MB
);
---------------------------------------------
-- Relations --------------------------------
---------------------------------------------
use chemestry_company ;
---------------------------------------------
alter table product
add constraint fk_product_countries  foreign key (ManufacturingCountryID)
references countries (CountryID);
-----------------------------------------------------------------------
alter table orders 
add constraint fk_orders_product 
foreign key (ProductID)
references product(ProductID);
-----------------------------------------------------------------------
alter table orders 
add constraint fk_orders_employee 
foreign key (EmployeeID)
references employee (EmployeeID);
-----------------------------------------------------------------------
----------------------------------------------------------------------
alter table orders 
add constraint fk_orders_customer
foreign key (CustomerID)
references customer (CustomerID);
----------------------------------------------------------------------
----------------------------------------------------------------------

----------------------------------------------------------------------
----- analysis
----------------------------------------------------------------------
select sum(o.Quantity *p.Unit_Cost)as total_cost,sum(o.Quantity *p.Unit_Price) as total_price ,sum(o.Quantity *p.Unit_Price)- sum(o.Quantity *p.Unit_Cost) as profit
from orders o join product p
on o.ProductID = p.ProductID;

-- create view 
create view All_Requirements
as
select p.DrugName ,e.EmployeeName ,r.CountryName,c.CustomerName , sum(o.Quantity *p.Unit_Cost)as total_cost,sum(o.Quantity *p.Unit_Price) as total_price ,sum(o.Quantity *p.Unit_Price)- sum(o.Quantity *p.Unit_Cost) as profit
from orders o join product p
on o.ProductID = p.ProductID join employee e 
on e.EmployeeID=o.EmployeeID join customer c
on c.CustomerID=o.CustomerID join countries r
on r.CountryName =c.Country 
group by  p.DrugName
,e.EmployeeName
,r.CountryName
,c.CustomerName;

/*=================================================
                PRODUCT ANALYSIS
=================================================*/

---------------------------------------------------
-- Display all product records
-- Show complete product information
---------------------------------------------------
SELECT *
FROM product;



---------------------------------------------------
-- Count total number of products
-- Calculate how many products exist
---------------------------------------------------
SELECT 
    COUNT(p.ProductID) AS num_product
FROM product p;



---------------------------------------------------
-- Calculate average selling price
-- Return the average unit price of products
---------------------------------------------------
SELECT 
    AVG(Unit_Price) AS average_price
FROM product;



---------------------------------------------------
-- Top 5 products by total revenue
-- Revenue = Quantity × Unit Price
---------------------------------------------------
SELECT TOP 5
    p.DrugName,
    SUM(o.Quantity * p.Unit_Price) AS total_revenue
FROM product p
JOIN orders o
    ON o.ProductID = p.ProductID
GROUP BY p.DrugName
ORDER BY total_revenue DESC;



---------------------------------------------------
-- Calculate total sales for each product
-- Sales = Quantity × Unit Price
---------------------------------------------------
SELECT
    p.DrugName,
    SUM(o.Quantity * p.Unit_Price) AS total_sales
FROM orders o
JOIN product p
    ON o.ProductID = p.ProductID
GROUP BY p.DrugName
ORDER BY total_sales DESC;



---------------------------------------------------
-- Calculate total cost for each product
-- Cost = Quantity × Unit Cost
---------------------------------------------------
SELECT
    p.DrugName,
    SUM(o.Quantity * p.Unit_Cost) AS total_cost
FROM orders o
JOIN product p
    ON o.ProductID = p.ProductID
GROUP BY p.DrugName
ORDER BY total_cost DESC;



---------------------------------------------------
-- Calculate total profit for each product
-- Profit = Sales − Cost
---------------------------------------------------
SELECT
    p.DrugName,
    SUM(o.Quantity * p.Unit_Price)
    -
    SUM(o.Quantity * p.Unit_Cost) AS profit
FROM orders o
JOIN product p
    ON o.ProductID = p.ProductID
GROUP BY p.DrugName
ORDER BY profit DESC;



---------------------------------------------------
-- Calculate total quantity sold per product
-- Measure product demand
---------------------------------------------------
SELECT
    p.DrugName,
    SUM(o.Quantity) AS total_quantity
FROM orders o
JOIN product p
    ON o.ProductID = p.ProductID
GROUP BY p.DrugName
ORDER BY total_quantity DESC;



---------------------------------------------------
-- Identify the lowest selling products
-- Display bottom 10 products by quantity sold
-- Useful for slow-moving product analysis
---------------------------------------------------
SELECT TOP 10
    p.DrugName,
    SUM(o.Quantity) AS total_qty
FROM orders o
JOIN product p
    ON p.ProductID = o.ProductID
GROUP BY p.DrugName
ORDER BY total_qty ASC;


/*=================================================
               EMPLOYEE ANALYSIS
=================================================*/

---------------------------------------------------
-- Display employee performance summary
-- Show total cost, total revenue, and profit
-- using the analysis view
---------------------------------------------------
SELECT
    a.EmployeeName,
    a.total_cost,
    a.total_price,
    a.profit
FROM All_Requirements a;



---------------------------------------------------
-- Calculate total sales generated by each employee
-- Sales = Quantity × Unit Price
---------------------------------------------------
SELECT
    e.EmployeeName,
    SUM(o.Quantity * p.Unit_Price) AS total_sales
FROM orders o
JOIN employee e
    ON o.EmployeeID = e.EmployeeID
JOIN product p
    ON o.ProductID = p.ProductID
GROUP BY e.EmployeeName;



---------------------------------------------------
-- Count total number of orders handled
-- by each employee
---------------------------------------------------
SELECT
    e.EmployeeName,
    COUNT(*) AS total_orders
FROM orders o
JOIN employee e
    ON o.EmployeeID = e.EmployeeID
GROUP BY e.EmployeeName;



---------------------------------------------------
-- Display top 5 employees by total revenue
-- Revenue = Quantity × Unit Price
---------------------------------------------------
SELECT TOP 5
    e.EmployeeName,
    SUM(o.Quantity * p.Unit_Price) AS total_revenue
FROM orders o
JOIN employee e
    ON o.EmployeeID = e.EmployeeID
JOIN product p
    ON p.ProductID = o.ProductID
GROUP BY e.EmployeeName
ORDER BY total_revenue DESC;
/*=================================================
               CUSTOMER ANALYSIS
=================================================*/

---------------------------------------------------
-- Display top 10 customers by total revenue
-- Revenue = Quantity × Unit Price
---------------------------------------------------
SELECT TOP 10
    c.CustomerName,
    SUM(o.Quantity * p.Unit_Price) AS total_revenue
FROM customer c
JOIN orders o
    ON o.CustomerID = c.CustomerID
JOIN product p
    ON p.ProductID = o.ProductID
GROUP BY c.CustomerName
ORDER BY total_revenue DESC;



---------------------------------------------------
-- Display top 10 customers by generated profit
-- Profit = Revenue − Cost
---------------------------------------------------
SELECT TOP 10
    c.CustomerName,
    SUM(o.Quantity * (p.Unit_Price - p.Unit_Cost)) AS profit
FROM orders o
JOIN customer c
    ON c.CustomerID = o.CustomerID
JOIN product p
    ON p.ProductID = o.ProductID
GROUP BY c.CustomerName
ORDER BY profit DESC;




/*=================================================
                 DATE ANALYSIS
=================================================*/

---------------------------------------------------
-- Calculate total monthly sales
-- Group sales by Year and Month
---------------------------------------------------
SELECT
    FORMAT(o.OrderDate, 'yyyy-MM') AS month,
    SUM(o.Quantity * p.Unit_Price) AS total_sales
FROM orders o
JOIN product p
    ON p.ProductID = o.ProductID
GROUP BY FORMAT(o.OrderDate, 'yyyy-MM')
ORDER BY total_sales DESC;



---------------------------------------------------
-- Display top 5 most profitable months
-- WITH TIES returns all months with equal profit
---------------------------------------------------
SELECT TOP 5 WITH TIES
    FORMAT(o.OrderDate, 'yyyy-MM') AS month,
    SUM(o.Quantity * p.Unit_Price)
    -
    SUM(o.Quantity * p.Unit_Cost) AS profit
FROM orders o
JOIN product p
    ON p.ProductID = o.ProductID
GROUP BY FORMAT(o.OrderDate, 'yyyy-MM')
ORDER BY profit DESC;



---------------------------------------------------
-- Count total number of orders per month
---------------------------------------------------
SELECT
    FORMAT(o.OrderDate, 'yyyy-MM') AS month,
    COUNT(*) AS total_orders
FROM orders o
GROUP BY FORMAT(o.OrderDate, 'yyyy-MM')
ORDER BY month;



---------------------------------------------------
-- Display top 10 products by sold quantity
-- Measure product demand over time
---------------------------------------------------
SELECT TOP 10
    p.DrugName,
    SUM(o.Quantity) AS total_quantity
FROM orders o
JOIN product p
    ON o.ProductID = p.ProductID
GROUP BY p.DrugName
ORDER BY total_quantity DESC;



---------------------------------------------------
-- Display top 5 sales days
-- Aggregate sales by day
---------------------------------------------------
SELECT TOP 5
    CAST(OrderDate AS DATE) AS day,
    SUM(Quantity * Unit_Price) AS sales
FROM orders o
JOIN product p
    ON o.ProductID = p.ProductID
GROUP BY CAST(OrderDate AS DATE)
ORDER BY sales DESC;




/*=================================================
               COUNTRY ANALYSIS
=================================================*/

---------------------------------------------------
-- Calculate total revenue by country
-- Revenue grouped by customer country
---------------------------------------------------
SELECT
    r.CountryName,
    SUM(o.Quantity * p.Unit_Price) AS revenue
FROM orders o
JOIN customer c
    ON c.CustomerID = o.CustomerID
JOIN countries r
    ON r.CountryName = c.Country
JOIN product p
    ON p.ProductID = o.ProductID
GROUP BY r.CountryName
ORDER BY revenue DESC;