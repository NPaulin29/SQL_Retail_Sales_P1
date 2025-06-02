# Retail Sales Analysis SQL Project

## Project Overview

**Project Title**: Retail Sales Analysis  
**Level**: Beginner  
**Database**: `p1_retail_db`

This project is designed to demonstrate SQL skills and techniques typically used by data analysts to explore, clean, and analyze retail sales data. The project involves setting up a retail sales database, performing exploratory data analysis (EDA), and answering specific business questions through SQL queries. This project is ideal for those who are starting their journey in data analysis and want to build a solid foundation in SQL.

## Objectives

1. **Set up a retail sales database**: Create and populate a retail sales database with the provided sales data.
2. **Data Cleaning**: Identify and remove any records with missing or null values.
3. **Exploratory Data Analysis (EDA)**: Perform basic exploratory data analysis to understand the dataset.
4. **Business Analysis**: Use SQL to answer specific business questions and derive insights from the sales data.

## Project Structure

### 1. Database Setup

- **Database Creation**: The project starts by creating a database named `p1_retail_db`.
- **Table Creation**: A table named `retail_sales` is created to store the sales data. The table structure includes columns for transaction ID, sale date, sale time, customer ID, gender, age, product category, quantity sold, price per unit, cost of goods sold (COGS), and total sale amount.

```sql
CREATE DATABASE p1_retail_db;

CREATE TABLE retail_sales
(
    transactions_id INT PRIMARY KEY,
    sale_date DATE,	
    sale_time TIME,
    customer_id INT,	
    gender VARCHAR(10),
    age INT,
    category VARCHAR(35),
    quantity INT,
    price_per_unit FLOAT,	
    cogs FLOAT,
    total_sale FLOAT
);
```

### 2. Data Exploration & Cleaning

- **Record Count**: Determine the total number of records in the dataset.
- **Customer Count**: Find out how many unique customers are in the dataset.
- **Category Count**: Identify all unique product categories in the dataset.
- **Null Value Check**: Check for any null values in the dataset and delete records with missing data.

```sql
SELECT COUNT(*) FROM retail_sales;
SELECT COUNT(DISTINCT customer_id) FROM retail_sales;
SELECT DISTINCT category FROM retail_sales;

SELECT * FROM retail_sales
WHERE 
    sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL OR 
    gender IS NULL OR age IS NULL OR category IS NULL OR 
    quantity IS NULL OR price_per_unit IS NULL OR cogs IS NULL;

DELETE FROM retail_sales
WHERE 
    sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL OR 
    gender IS NULL OR age IS NULL OR category IS NULL OR 
    quantity IS NULL OR price_per_unit IS NULL OR cogs IS NULL;
```

### 3. Data Analysis & Findings

The following SQL queries were developed to answer specific business questions:

1. **Write a SQL query to retrieve all columns for sales made on '2022-11-05**:
```sql
SELECT *
FROM retail_sales
WHERE sale_date = '2022-11-05';
```

2. **Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022**:
```sql
SELECT 
  *
FROM retail_sales
WHERE 
    category = 'Clothing'
    AND 
    TO_CHAR(sale_date, 'YYYY-MM') = '2022-11'
    AND
    quantity >= 4
```

3. **Write a SQL query to calculate the total sales (total_sale) for each category.**:
```sql
SELECT 
    category,
    SUM(total_sale) as net_sale,
    COUNT(*) as total_orders
FROM retail_sales
GROUP BY 1
```

4. **Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.**:
```sql
SELECT
    ROUND(AVG(age), 2) as avg_age
FROM retail_sales
WHERE category = 'Beauty'
```

5. **Write a SQL query to find all transactions where the total_sale is greater than 1000.**:
```sql
SELECT * FROM retail_sales
WHERE total_sale > 1000
```

6. **Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.**:
```sql
SELECT 
    category,
    gender,
    COUNT(*) as total_trans
FROM retail_sales
GROUP 
    BY 
    category,
    gender
ORDER BY 1
```

7. **Write a SQL query to calculate the average sale for each month. Find out best selling month in each year**:
```sql
SELECT 
       year,
       month,
    avg_sale
FROM 
(    
SELECT 
    EXTRACT(YEAR FROM sale_date) as year,
    EXTRACT(MONTH FROM sale_date) as month,
    AVG(total_sale) as avg_sale,
    RANK() OVER(PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY AVG(total_sale) DESC) as rank
FROM retail_sales
GROUP BY 1, 2
) as t1
WHERE rank = 1
```

8. **Write a SQL query to find the top 5 customers based on the highest total sales **:
```sql
SELECT 
    customer_id,
    SUM(total_sale) as total_sales
FROM retail_sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5
```

9. **Write a SQL query to find the number of unique customers who purchased items from each category.**:
```sql
SELECT 
    category,    
    COUNT(DISTINCT customer_id) as cnt_unique_cs
FROM retail_sales
GROUP BY category
```

10. **Write a SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17)**:
```sql
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
```

11. **Which customer segment (age groups) generates the highest average total sales?**
```sql 
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
```

12.What is the profit margin for each category and which category is the most profitable overall?
```sql
SELECT
    category,
    ROUND(SUM(total_sale - cogs)::numeric,2) AS total_profit,
    ROUND(AVG(total_sale - cogs)::numeric, 2) AS avg_profit_per_transaction
FROM retail_sales
GROUP BY category
ORDER BY total_profit DESC;
```

13. What is the return rate (low quantity but high frequency) by customer ID?
```sql
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
```

14. Which hour of the day sees the highest total sales?
 ```sql
SELECT 
	EXTRACT(HOUR FROM sale_time) AS sale_hour,
	SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY sale_hour
ORDER BY total_sales DESC
LIMIT 1;
```

15. Which hour of the day sees the lowest total sales?
```sql
SELECT 
	EXTRACT(HOUR FROM sale_time) AS sale_hour,
	SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY sale_hour
ORDER BY total_sales ASC
LIMIT 1;
```

16. What is the monthly growth rate in total sales, and are there months with negative growth?
```sql
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
```



## Findings

- **Customer Demographics**: The dataset includes customers from various age groups, with sales distributed across different categories such as Clothing and Beauty.
- **High-Value Transactions**: Several transactions had a total sale amount greater than 1000, indicating premium purchases.
- **Sales Trends**: Monthly analysis shows variations in sales, helping identify peak seasons.
- **Customer Insights**: The analysis identifies the top-spending customers and the most popular product categories.

## Reports

- **Sales Summary**: A detailed report summarizing total sales, customer demographics, and category performance.
- **Trend Analysis**: Insights into sales trends across different months and shifts.
- **Customer Insights**: Reports on top customers and unique customer counts per category.

## Conclusion
This retail sales analysis project provided a comprehensive look into customer behavior, sales performance, and category-level profitability across a full calendar year. Using PostgreSQL and pgAdmin 4, we explored key business intelligence questions that revealed patterns in transaction volume, purchasing habits, and revenue-driving segments.

Through structured SQL queries, we uncovered high-performing age demographics (with Prime Earners and Established Adults driving the highest average sales), identified the most profitable product categories, and measured month-over-month sales growth, flagging periods of decline for strategic review. Additionally, time-based insights highlighted the most active sales hours, and customer segmentation revealed potential return behavior or sampling trends among low-quantity, high-frequency shoppers.

These findings enable more informed decision-making around targeted marketing, inventory planning, staffing, and customer retention strategies. Future recommendations include visualizing this data in dashboards using Power BI and integrating predictive analytics to forecast seasonal performance and optimize category offerings.

This project demonstrates how data-driven storytelling can transform raw transactional data into actionable business insights, setting the foundation for scalable analytics solutions in retail environments


