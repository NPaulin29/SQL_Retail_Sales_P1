-- SQL Retail Sales Analysis - P1
CREATE DATABASE sql_project_p2;

--Create TABLE
DROP TABLE IF EXISTS retail_sales;
CREATE TABLE retail_sales
			(
								  transactions_id INT PRIMARY KEY,
								  sale_date	DATE,
								  sale_time	TIME,
								  customer_id INT,	
								  gender VARCHAR(15),	
								  age INT,	
								  category VARCHAR(15),	
								  quantity INT,
								  price_per_unit FLOAT,
								  cogs FLOAT,
								  total_sale FLOAT
			);	
--Reviewing the data
SELECT *
FROM retail_sales
LIMIT 10;
-----------------------------
--Validating data from the excel sheet
SELECT COUNT(*)
FROM retail_sales;
-----------------------------
--Missing values for Transaction ID--
SELECT *
FROM retail_sales
WHERE transactions_id IS NULL;
-----------------------------
---Missing Values for Sale_date
SELECT *
FROM retail_sales
WHERE sale_date IS NULL;
-------------------------------
--Missing values for sale_time
SELECT *
FROM retail_sales
WHERE sale_time IS NULL;
-------------------------------
--Missing values for customer_id
SELECT *
FROM retail_sales
WHERE customer_id IS NULL;
--------------------------------
--Missing values for gender
SELECT *
FROM retail_sales
WHERE gender IS NULL;
--------------------------------
--Missing values for age (10 missing)
SELECT *
FROM retail_sales
WHERE age IS NULL;
----------------------------------
--Missing values for category--simplier way to check others
SELECT *
FROM retail_sales
WHERE category IS NULL
	OR
	quantity IS NULL
	OR
	price_per_unit IS NULL
	OR
	cogs IS NULL
	OR
	total_sale IS NULL;
-----------------------------------
--Data Cleanup
--3 values located for transactions_id 679,746,and 1225 missing quantity, price_per_unit, cogs, total_sale will delete for demo
DELETE FROM retail_sales
WHERE category IS NULL
	OR
	age IS NULL
	OR
	quantity IS NULL
	OR
	price_per_unit IS NULL
	OR
	cogs IS NULL
	OR
	total_sale IS NULL;
---------------------------------------
--Data Exploration
--How many sales do we have?
SELECT COUNT (*) as total_sale
FROM retail_sales;

--How many unique customers do we have?
SELECT COUNT (DISTINCT customer_id) as total_customerids
FROM retail_sales;

--How many categories do we have?
SELECT COUNT (DISTINCT category) as total_categories
FROM retail_sales;

--view results
SELECT DISTINCT category 
FROM retail_sales;

--Data Analysis & Business Key Problems & Answers

--Q1. What were the sales made on 2022-11-05?
SELECT *
FROM retail_sales
WHERE sale_date = '2022-11-05';

--Q2. What were the all the 'clothing' category transactions and quantity sold over 4 in the month of Nov-22?
SELECT *
FROM retail_sales
WHERE category = 'Clothing'
	AND
	TO_CHAR(sale_date, 'YYYY-MM') = '2022-11'
	AND
	quantity >= 4;
	
--Q3. What is the total sales (total_sale) for each category?
SELECT 
	category,
	SUM(total_sale) as net_sale,
	COUNT(*) as total_orders
FROM retail_sales
GROUP BY 1;

--Q4. What is the average age of customers who purchased items from the 'Beauty' category
SELECT 
	ROUND(AVG(age),2) as avg_age
FROM retail_sales
WHERE category = 'Beauty';

--Q5. Show all transactions where the total_sale is greater than 1000.
SELECT *
FROM retail_sales
WHERE total_sale > 1000

--Q6. Find the total number of transactions (transactions_id) made by each gender in each category.
SELECT
	category, 
	gender, 
	COUNT(*) as total_trans
FROM retail_sales
GROUP BY category, 
gender
ORDER BY 1;

--Q7. Calculate the average sale for each month, which month is the best selling month each year?
SELECT
	year, 
	month, 
	avg_sales
FROM
(
SELECT
	EXTRACT (YEAR FROM sale_date) as year, 
	EXTRACT (MONTH FROM sale_date) as month, 
	AVG(total_sale) as avg_sales,
	RANK()OVER(PARTITION BY EXTRACT(YEAR FROM sale_date)ORDER BY AVG(total_sale)DESC ) as rank
FROM retail_sales
GROUP BY 1,2
) as T1
WHERE rank = 1

--Q8. What are the top 5 customers based on the highest total sales?
SELECT 
	customer_id, 
	SUM(total_sale) as total_sales
FROM retail_sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

--Q9. What is the number of unique customers who purchased items from each category?
SELECT 
	category, 
	COUNT (DISTINCT customer_id) as unique_customers
FROM retail_sales
GROUP BY 1

--Q10. What is the number of orders processed during each shift? (Example Morning <12, Afternoon Beween 12 & 17, Evening > 17)
WITH hourly_sale
AS
(
SELECT *,
	CASE 
		WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
		WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
		ELSE 'Evening'
	END as shift
FROM retail_sales
)
SELECT 
	shift,
	COUNT(*) as total_orders
FROM hourly_sale
GROUP BY shift

--Q11. Which customer segment (age groups) generates the highest average total sale?
WITH age_segments
AS
(
SELECT *, 
CASE
	WHEN age < 25 THEN 'Gen Z Shopper'
	WHEN age BETWEEN 25 AND 34 THEN 'Young Adult'
	WHEN age BETWEEN 35 AND 44 THEN 'Established Adult'
	WHEN age BETWEEN 45 AND 54 THEN 'Prime Earner'
	ELSE 'Senior Shopper'
	END AS age_segments
FROM retail_sales
)
SELECT
	age_segments,
	ROUND(AVG(total_sale)::numeric,2) AS avg_sales_demo
FROM age_segments
GROUP BY age_segments
ORDER BY avg_sales_demo DESC

--Q12. What is the profit margin for each category and which category is the most profitable overall?
SELECT
    category,
    ROUND(SUM(total_sale - cogs)::numeric,2) AS total_profit,
    ROUND(AVG(total_sale - cogs)::numeric, 2) AS avg_profit_per_transaction
FROM retail_sales
GROUP BY category
ORDER BY total_profit DESC;

--Q13. What is the return rate (low quantity but high frequency) by customer ID?
SELECT
    customer_id,
    COUNT(*) AS low_quantity_orders,
    ROUND(AVG(quantity)::numeric, 2) AS avg_quantity,
    SUM(total_sale) AS total_spent
FROM retail_sales
WHERE quantity <= 2
GROUP BY customer_id
HAVING COUNT(*) > 1
ORDER BY low_quantity_orders DESC;

--Q14.Which hour of the day sees the highest total sales?
SELECT 
	EXTRACT(HOUR FROM sale_time) AS sale_hour,
	SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY sale_hour
ORDER BY total_sales DESC
LIMIT 1;

--Q15. Which hour of the day sees the lowest total sales?
SELECT 
	EXTRACT(HOUR FROM sale_time) AS sale_hour,
	SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY sale_hour
ORDER BY total_sales ASC
LIMIT 1;

-- Q16. What is the monthly growth rate in total sales, and are there months with negative growth?
WITH monthly_sales AS (
    SELECT
        DATE_TRUNC('month', sale_date) AS month,
        SUM(total_sale) AS total_sales
    FROM retail_sales
    GROUP BY DATE_TRUNC('month', sale_date)
),
growth_calc AS (
    SELECT
        month,
        total_sales,
        LAG(total_sales) OVER (ORDER BY month) AS previous_month_sales,
        ROUND(
            (100.0 * (total_sales - LAG(total_sales) OVER (ORDER BY month)) 
             / NULLIF(LAG(total_sales) OVER (ORDER BY month), 0))::numeric,
            2
        ) AS growth_rate_percent
    FROM monthly_sales
)
SELECT *
FROM growth_calc
ORDER BY month;

--END PROJECT