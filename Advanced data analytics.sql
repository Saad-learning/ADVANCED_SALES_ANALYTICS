                -- Change-Over-Time analysis (Trends) --
	SELECT 
		EXTRACT(month FROM order_date) AS order_month,
		EXTRACT(year FROM order_date) AS order_year,
		SUM(sales_amount) AS total_sales,
		COUNT(DISTINCT customer_key) AS total_customers,
		SUM(quantity) AS total_quantity
	FROM 
		gold.fact_sales
	WHERE 
		order_date 
			IS NOT NULL
	GROUP BY 
		EXTRACT(month FROM order_date),
		EXTRACT(year FROM order_date)
	ORDER BY 
		EXTRACT(MONTH FROM order_date),
		EXTRACT(year FROM order_date);

				-- 		Cumulative Analysis		 --
	/*Calculate the total sales per month and the running total of the sales over time*/ 
	SELECT 
		order_date,
		total_sales,
		SUM(total_sales) OVER (
		ORDER BY order_date) AS running_total,
		SUM(total_sales) OVER (
		ORDER BY order_date) AS Running_total_sales
	FROM
		(
				SELECT 
					date_trunc('MONTH', order_date) AS order_date,
					SUM(sales_amount) AS total_sales
				FROM
					gold.fact_sales
				WHERE
					order_date IS NOT NULL
				GROUP BY
					date_trunc('MONTH', order_date)
				ORDER BY
					date_trunc('MONTH', order_date)
				)t
	;

				--		Performance Analysis	 --
	/*Analyze the yearly performance of priducts by comparing their salaes to bothe the average sales performance of the product and the precious year's sales*/
WITH yearly_product_sales AS (
	SELECT
		EXTRACT(YEAR FROM f.order_date) AS order_year,
		p.product_name,
		SUM(f.sales_amount) AS current_sales
	FROM
		gold.fact_sales f
	LEFT JOIN gold.dim_products p 
	ON
		f.customer_key = p.product_key
	WHERE 
		f.order_date IS NOT NULL 
	GROUP BY
		EXTRACT(YEAR FROM f.order_date),
		p.product_name
)
 SELECT
	order_year,
	product_name,
	current_sales,
	AVG(current_sales) OVER(PARTITION BY product_name) avg_sales,
	current_sales - AVG(current_sales) OVER(PARTITION BY product_name) AS diff_avg,
	CASE 
		WHEN 
			current_sales - AVG(current_sales) OVER(PARTITION BY product_name) > 0 
				THEN 'Above AVG'
		WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) = 0
				THEN 'AVG'
		ELSE 'Below AVG'
	END,
	LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) AS py_sales,
	current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) AS diff_py,
	CASE 
		WHEN 
			current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year)>0 
				THEN 'Increse'
		WHEN 
			current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year)<0
				THEN 'Decrease'
		ELSE 'No Change'
	END
FROM
	yearly_product_sales
ORDER BY 
	product_name,order_year;

				--		Part To Whole Analysis	 --
	--Which categories contribute the most overall sales?
WITH category_sales AS (
	SELECT 
		category,
		SUM(sales_amount) total_sales
	FROM 
		gold.fact_sales f
	LEFT JOIN 
		gold.dim_products p	
	ON 
		p.product_key = f.product_key
	GROUP BY 
		category
)
SELECT 
	category,
	total_sales,
	sum(total_sales) OVER () overall_sales,
	CONCAT(ROUND((total_sales / sum(total_sales) OVER ())*100,2),'%') AS persentage_of_total
FROM 
	category_sales
ORDER BY
	total_sales DESC ;

				-- 		Data Segmentation		 ---
			
	/*Segment products into cost range and count how many products fall into each segment*/
WITH product_segments AS(
SELECT 
	product_key,
	product_name,
	COST,
	CASE WHEN COST < 100 THEN 'below 100'
		 WHEN COST BETWEEN 100 AND 500 THEN '100-500'
		 WHEN COST BETWEEN 500 AND 100 THEN '500-1000'
		 ELSE 'Above 1000'
	END cost_range	
FROM 
	gold.dim_products
)
SELECT
	cost_range,
	COUNT(product_key) AS total_products
FROM
	product_segments
GROUP BY
	cost_range
ORDER BY
	total_products DESC;
	/* Group customers into three segments based on their spending behavior:
	 	- VIP: Customers with at least 12 months of history and spending more than $5,000.
	 	- Regular: Cutomers with at least 12 month of history by spending $5,000 or less .
	 	- New: Customers with lifespan less than 12 months.
	 and find the total number of customers by each group 
	*/
WITH customer_spending AS(
SELECT
	c.customer_key,
	Sum(f.sales_amount) AS total_spending,
	MIN(order_date) AS first_spending,
	MAX(order_date) AS last_order,
    DATE_PART('year', AGE(MAX(order_date), MIN(order_date))) * 12 +
    DATE_PART('month', AGE(MAX(order_date), MIN(order_date))) AS lifespan
FROM 
	gold.fact_sales f 
LEFT JOIN 
	gold.dim_customers c
ON 
	f.customer_key = f.customer_key
GROUP BY
 	 c.customer_key
) 
SELECT 
customer_segment,
COUNT(customer_key) total_customers 
FROM (
	SELECT 
		customer_key,
		total_spending,
		lifespan,
		CASE
			WHEN lifespan >= 12 AND total_spending > 5000 
				THEN 'VIP'
			WHEN lifespan >= 12 AND total_spending <= 5000 
				THEN 'Regular'
			ELSE 'New'
		END customer_segment 
	FROM customer_spending ) t 
GROUP BY customer_segment 
ORDER BY total_customers DESC 

	

	
	
	

	

	
	
	

	
				
				

	
	
	
	
	
	
	
	