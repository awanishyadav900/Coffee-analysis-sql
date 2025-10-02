Drop table if exists city;
Drop table if exists customers;
Drop table if exists products ;
Drop table if exists sales;
-- creating city table
create table city(
        city_id int primary key,
		city_name varchar (50),
		population bigint,
		estimated_rent float,
		city_rank int 

);

--impoting city data 
--creating customer table
  create table customers(
    customer_id int primary key ,
	customer_name varchar(20) ,
	city_id int ,
	CONSTRAINT fk_city FOREIGN KEY (city_id) REFERENCES city(city_id)

  );
--importing data 

-- creating table products
 create table products(
   product_id int primary key,
   product_name	varchar(150),
   price float

 )
 --imporing data

--creating table sales
 
 CREATE TABLE sales
(
	sale_id	INT PRIMARY KEY,
	sale_date	date,
	product_id	INT,
	customer_id	INT,
	total FLOAT,
	rating INT,
	CONSTRAINT fk_products FOREIGN KEY (product_id) REFERENCES products(product_id),
	CONSTRAINT fk_customers FOREIGN KEY (customer_id) REFERENCES customers(customer_id) 
);

-- to see the data
 select * from city;
 select * from customers;
 select * from products;
 select * from sales;


------------------>
---QUESTION------->
--1. Coffee Consumers Count
--Q1How many people in each city are estimated to consume coffee, given that 25% of the population does?

--2.Total Revenue from Coffee Sales
--Q2.What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?

--3.Sales Count for Each Product
--Q3.How many units of each coffee product have been sold?

--4.Average Sales Amount per City
--Q4.What is the average sales amount per customer in each city?

--5.City Population and Coffee Consumers
--Q5.Provide a list of cities along with their populations and estimated coffee consumers.

--6.Top Selling Products by City
--Q6.What are the top 3 selling products in each city based on sales volume?

--7.Customer Segmentation by City
--Q7.How many unique customers are there in each city who have purchased coffee products?

--8.Average Sale vs Rent
--Q8.Find each city and their average sale per customer and avg rent per customer

--9.Monthly Sales Growth
--Q9.Sales growth rate: Calculate the percentage growth (or decline) in sales over different time periods (monthly).

--10.Market Potential Analysis
--Q10.Identify top 3 city based on highest sales, return city name, total sale, total rent, total customers, estimated coffee consumer.

----------->
-- ANSWER-->
----------->

  --Q1How many people in each city are estimated to consume coffee, given that 25% of the population does?
     
	 SELECT 
	city_name,
	ROUND(
	(population * 0.25)/1000000, 
	2) as coffee_consumers_in_millions,
	city_rank
FROM city
ORDER BY coffee_consumers_in_millions DESC ;

--Q2.What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?

	select 
	   sum(total) as total_revenue 
	    from sales
		where
	extract (year FROM sale_date) = 2023
	and 
	extract (quarter from sale_date) = 4;
----total revenue by each city:
	SELECT 
	ci.city_name,
	SUM(s.total) as total_revenue
FROM sales as s
JOIN customers as c
ON s.customer_id = c.customer_id
JOIN city as ci
ON ci.city_id = c.city_id
WHERE 
	EXTRACT(YEAR FROM s.sale_date)  = 2023
	AND
	EXTRACT(quarter FROM s.sale_date) = 4
GROUP BY 1
ORDER BY 2 DESC


--Q3.How many units of each coffee product have been sold?

    select p.product_name,
	    count(s.sale_id) as unit_sold
		 from products as p
		 join sales as s
		 on s.product_id=p.product_id
		 group by product_name
		 order by unit_sold desc;

--4.Average Sales Amount per City
--Q4.What is the average sales amount per customer in each city?

    SELECT 
	ci.city_name,
	SUM(s.total) as total_revenue,
	COUNT(DISTINCT s.customer_id) as total_cx,
	ROUND(
			SUM(s.total)::numeric/
				COUNT(DISTINCT s.customer_id)::numeric
			,2) as avg_sale_pr_cx
	
FROM sales as s
JOIN customers as c
ON s.customer_id = c.customer_id
JOIN city as ci
ON ci.city_id = c.city_id
GROUP BY city_name
ORDER BY total_revenue DESC;

--5.City Population and Coffee Consumers
--Q5.Provide a list of cities along with their populations and estimated coffee consumers.?
    WITH city_table as 
(
	SELECT 
		city_name,
		ROUND((population * 0.25)/1000000, 2) as coffee_consumers
	FROM city
),
customers_table
AS
(
	SELECT 
		ci.city_name,
		COUNT(DISTINCT c.customer_id) as unique_cx
	FROM sales as s
	JOIN customers as c
	ON c.customer_id = s.customer_id
	JOIN city as ci
	ON ci.city_id = c.city_id
	GROUP BY 1
)
SELECT 
	customers_table.city_name,
	city_table.coffee_consumers as coffee_consumer_in_millions,
	customers_table.unique_cx
FROM city_table
JOIN 
customers_table
ON city_table.city_name = customers_table.city_name;



-- -- Q6
-- Top Selling Products by City
-- What are the top 3 selling products in each city based on sales volume?

SELECT * 
FROM -- table
(
	SELECT 
		ci.city_name,
		p.product_name,
		COUNT(s.sale_id) as total_orders,
		DENSE_RANK() OVER(PARTITION BY ci.city_name ORDER BY COUNT(s.sale_id) DESC) as rank
	FROM sales as s
	JOIN products as p
	ON s.product_id = p.product_id
	JOIN customers as c
	ON c.customer_id = s.customer_id
	JOIN city as ci
	ON ci.city_id = c.city_id
	GROUP BY 1, 2
	-- ORDER BY 1, 3 DESC
) as t1
WHERE rank <= 3


-- Q.7
-- Customer Segmentation by City
-- How many unique customers are there in each city who have purchased coffee products?

SELECT * FROM products;



SELECT 
	ci.city_name,
	COUNT(DISTINCT c.customer_id) as unique_cx
FROM city as ci
LEFT JOIN
customers as c
ON c.city_id = ci.city_id
JOIN sales as s
ON s.customer_id = c.customer_id
WHERE 
	s.product_id IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14)
GROUP BY 1


-- -- Q.8
-- Average Sale vs Rent
-- Find each city and their average sale per customer and avg rent per customer

-- Conclusions

WITH city_table
AS
(
	SELECT 
		ci.city_name,
		SUM(s.total) as total_revenue,
		COUNT(DISTINCT s.customer_id) as total_cx,
		ROUND(
				SUM(s.total)::numeric/
					COUNT(DISTINCT s.customer_id)::numeric
				,2) as avg_sale_pr_cx
		
	FROM sales as s
	JOIN customers as c
	ON s.customer_id = c.customer_id
	JOIN city as ci
	ON ci.city_id = c.city_id
	GROUP BY 1
	ORDER BY 2 DESC
),
city_rent
AS
(SELECT 
	city_name, 
	estimated_rent
FROM city
)
SELECT 
	cr.city_name,
	cr.estimated_rent,
	ct.total_cx,
	ct.avg_sale_pr_cx,
	ROUND(
		cr.estimated_rent::numeric/
									ct.total_cx::numeric
		, 2) as avg_rent_per_cx
FROM city_rent as cr
JOIN city_table as ct
ON cr.city_name = ct.city_name
ORDER BY 4 DESC



		  