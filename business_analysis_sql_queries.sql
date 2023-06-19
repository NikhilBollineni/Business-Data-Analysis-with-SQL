USE gdb023;

SELECT *FROM dim_customer;
SELECT *FROM dim_product;

SELECT *FROM fact_gross_price;
SELECT *FROM fact_manufacturing_cost;

SELECT *FROM fact_pre_invoice_deductions;
SELECT *FROM fact_sales_monthly


-- 1  Provide the list of markets in which customer "Atliq Exclusive" operates its business in the APAC region.

SELECT DISTINCT(market) FROM dim_customer
WHERE region = 'APAC'

-- 2 What is the percentage of unique product increase in 2021 vs. 2020?

WITH cte_1 AS (
				SELECT COUNT(product_code) AS unique_products, SUM(manufacturing_cost) AS total_cost FROM fact_manufacturing_cost
                WHERE cost_year = 2020
			   ),
cte_2 AS (
				SELECT COUNT(product_code) AS unique_products, SUM(manufacturing_cost) AS total_cost FROM fact_manufacturing_cost
                WHERE cost_year = 2021
                ),
cte_3 AS (
	SELECT unique_products AS unique_products_2020, 
	(SELECT unique_products FROM cte_2) unique_products_2021, 
    (SELECT total_cost FROM cte_1) AS total_cost_2020, 
    (SELECT total_cost FROM cte_2) AS total_cost_2021
FROM cte_1
		)
SELECT unique_products_2020, unique_products_2021, ((total_cost_2021-total_cost_2020)/total_cost_2020*100) AS percentage_chg FROM cte_3



-- 3 Provide a report with all the unique product counts for each segment and sort them in descending order of product counts.

SELECT segment, COUNT(segment) AS product_count FROM dim_product
GROUP BY segment
ORDER BY product_count DESC

-- 4 Follow-up: Which segment had the most increase in unique products in 2021 vs 2020?
WITH cte_1 AS (
			SELECT segment, COUNT(segment) AS  product_count_2020 FROM fact_gross_price FG
			JOIN dim_product DM 
			ON FG.product_code = DM.product_code
			WHERE fiscal_year = 2020
			GROUP BY segment
			ORDER BY product_count_2020 DESC
			),
cte_2 AS (
			SELECT segment, COUNT(segment) AS  product_count_2021 FROM fact_gross_price FG
			JOIN dim_product DM 
			ON FG.product_code = DM.product_code
			WHERE fiscal_year = 2021
			GROUP BY segment
			ORDER BY product_count_2021 DESC
		)
SELECT cte_1.segment, cte_1.product_count_2020, cte_2.product_count_2021, (cte_2.product_count_2021 - cte_1.product_count_2020) AS difference FROM cte_1
JOIN cte_2
ON cte_1. segment = cte_2. segment


-- 5 Get the products that have the highest and lowest manufacturing costs.

SELECT FMC.product_code, DP.product, FMC.manufacturing_cost FROM fact_manufacturing_cost  FMC
JOIN dim_product  DP
ON FMC.product_code = DP.product_code
WHERE manufacturing_cost = (SELECT MAX(manufacturing_cost) FROM fact_manufacturing_cost FMC)

UNION

SELECT FMC.product_code,  DP.product, FMC.manufacturing_cost FROM fact_manufacturing_cost  FMC
JOIN dim_product  DP
ON FMC.product_code = DP.product_code
WHERE manufacturing_cost = (SELECT MIN(manufacturing_cost) FROM fact_manufacturing_cost FMC)


-- 6 Generate a report which contains the top 5 customers who received an average high pre_invoice_discount_pct for the fiscal year 2021 and in the Indian market

SELECT  I.customer_code, DM.customer,  ROUND(I.pre_invoice_discount_pct  *100,2) AS avg_discount_percentage  FROM fact_pre_invoice_deductions I
JOIN dim_customer DM 
ON I.customer_code = DM.customer_code
WHERE fiscal_year = 2021 AND market = 'India'
ORDER BY avg_discount_percentage DESC
LIMIT 5

 





