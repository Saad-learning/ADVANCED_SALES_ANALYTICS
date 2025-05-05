--Explore all Objects in the Database

	SELECT
		*
	FROM 
		INFORMATION_SCHEMA.TABLES;

--Explore all Culomns in the Database

	SELECT
		*
	FROM
		INFORMATION_SCHEMA.COLUMNS
	WHERE
		table_name = 'dim_customers';

--Explore all Countries our customer come from
	
	SELECT
		DISTINCT 
		country
	FROM 
		gold.dim_customers;
	
--Explore all Categories 'The major Divisions'
	
	SELECT  
		DISTINCT
		category, subcategory, product_name 
	FROM 
		gold.dim_products
	ORDER BY 
		1, 2, 3;

--Find the date of the first and last order & Find how many years of sales are availabe
	SELECT 
		Min(order_date) AS first_order_date,
		MAX(order_date) AS last_order_date,
		EXTRACT(YEAR FROM MAX(order_date)) - EXTRACT(YEAR FROM MIN(order_date)) AS order_range_years
	FROM 
		gold.fact_sales;

--Find the youngset and the oldest customer
	SELECT 
	 MIN(birthdate) AS oldest_customer,
	 	EXTRACT (YEAR FROM now())-EXTRACT(YEAR FROM MIN(birthdate)) AS oldest_age,
	 MAX(birthdate) AS youngest_customer,
	 	EXTRACT (YEAR FROM now())-EXTRACT(YEAR FROM MAX(birthdate)) AS youngest_age
	FROM gold.dim_customers ;

--Find the total Sales
	
	SELECT
		SUM(sales_amount) AS total_sales
	FROM
		gold.fact_sales;

--Find gow many items are sold
	
	SELECT
		SUM(quantity)  AS totla_quantity
	FROM 
		gold.fact_sales ;

--Find the average selling price
	
	SELECT 
		AVG(price) AS average_price
	FROM 
		gold.fact_sales;
		
--Find the total number of orders
	
	SELECT
		COUNT(DISTINCT order_number) AS total_orders
	FROM 
		gold.fact_sales;

--Find the total number of products
	
	SELECT
		count(product_key) AS total_products
	FROM 
		gold.fact_sales;

--Find the total number of customers 

	SELECT 
		COUNT(customer_key) AS total_cuntomers
	FROM
		gold.dim_customers;

--Find the total number of customers that has placed an order

	SELECT 
		COUNT(DISTINCT customer_key) AS total_cuntomers
	FROM
		gold.fact_sales;

--Generating a Report that shows all key metrics of the buisness

	SELECT 
		'Total Sales' AS measure_name,
		 SUM(sales_amount) AS measure_value 
	FROM gold.fact_sales
	
	UNION ALL 
	
	SELECT
		'Total Quantity' ,
		 SUM(quantity)
	FROM gold.fact_sales 
	
	UNION ALL
	
	SELECT
		'Average Price',
		 AVG(price)
	FROM gold.fact_sales 
	
	UNION ALL
	
	SELECT
		'Total Nr. Orders',
		 COUNT(DISTINCT order_number)
	FROM gold.fact_sales 
	
	UNION ALL
	
	SELECT 
		'Total Nr. Products',
		COUNT(product_name) FROM gold.dim_products
	 
	UNION ALL
	
	SELECT 
		'Total Nr. Customers', COUNT(customer_key) FROM gold.dim_customers;





















































