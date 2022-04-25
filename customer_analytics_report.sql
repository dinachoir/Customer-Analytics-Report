-- Project: Customer Analytics Report on Q1 and Q2 Period

-- Dataset:
---Table orders_1 contains data related to sales transactions for the quarter 1 period
---Table orders_2 contains data related to sales transactions for the quarter 2 period
---Table customer contains customer profile data who register to become company customers

-- Project Task:
--- 1. Analyze the current sales growth and customer growth.
--- 2. Analyze the number of transactions and most-purchased product category.
--- 3. Analyze customer retention.

--------------------------------------------------------------------------------------------------

-- 1. Calculate total sales percentage

SELECT
	quarter,
	sum(quantity) as total_penjualan,
	sum(quantity*priceeach) as revenue
FROM
	(SELECT
		orderNumber,
		status,
		quantity,
		priceeach,
		'1' as quarter
	FROM
		orders_1 
	WHERE 
		 status = 'Shipped'
	UNION
	SELECT
		orderNumber,
		status,
		quantity,
		priceeach,
		'2' as quarter
	FROM
		orders_2 
	WHERE 
	 	status = 'Shipped'
	) as tabel_a
GROUP BY quarter

---Insight: There was a decrease in Q1-Q2, -22% in sales and -24% in revenue

-- 2. Calculate number of new customers in Q1 and Q2

SELECT
	quarter,
	count(distinct customerid) as total_customers
FROM
	(SELECT
		customerID,
		createDate,
		quarter(createDate) as quarter	
FROM
		customer 
	WHERE 
		 createdate between '2004-01-01' and '2004-06-30'
	) as tabel_b
GROUP BY quarter

---Insight: The number of new customers in Q2 is 8 less than in Q1

-- 3. Calculate number of new customer who made transaction in Q1 and Q2

SELECT
	quarter, 
	count(distinct customerid) as total_customers
FROM
	(SELECT
		customerid, 
	 	createdate, 
	 	quarter(createdate) as quarter
	FROM
		customer
	WHERE createdate between '2004-01-01' and '2004-06-30'
	) as tabel_b

WHERE customerid IN(SELECT distinct customerid
					FROM orders_1
					UNION
					SELECT distinct customerid
					FROM orders_2)
GROUP BY quarter

---Insight: The number of new customer who made transaction in Q2 is less than in Q1

-- 4. Inspect the most-frequent product category ordered by customers in Q2

SELECT * 
FROM (SELECT 
	  		categoryID, 
	  		COUNT(DISTINCT orderNumber) AS total_order, 
	  		SUM(quantity) AS total_penjualan 
      FROM (SELECT 
       			productCode, 
       			orderNumber, 
       			quantity,
       			status, 
       			LEFT(productCode,3) AS categoryID
			FROM orders_2
			WHERE status = "Shipped"
		   ) tabel_c
GROUP BY categoryID ) a 
ORDER BY total_order DESC

---Insight: Top 3 product categories with the most total orders are S18, S24 and S32 
---- with total sales > 600 while other product categories received total sales of < 600

-- 5. Calculate percentage of Q1 customer who made repeat order in Q2

SELECT
	COUNT(DISTINCT customerid) as total_customers 
FROM orders_1 ; -- total customer = 25

SELECT
	'1' as quarter,
	(COUNT(DISTINCT customerid)/25)*100 as Q2
FROM
	orders_1
WHERE customerid IN(SELECT distinct customerid
  					FROM orders_2)

---Insight: 76% of customers from Q1 did not repeat orders, 
----resulting a decrease in sales in Q2

-------------------------------------------------------------------------------------------------------

-- Conclusion:
---1. Company's performance decreased significantly in Q2, as seen from the value of sales and revenue which dropped by 22% and 24%.
---2. The acquisition of new customers is also not very good, and slightly decreased compared to the previous quarter.
---3. The interest of new customers to purchase is still lacking, only about 56% have made transactions. 
------It is recommended that the Product team need to study customer behavior and make product improvements, 
------so that the conversion rate (register to transaction) can increase.
---4. Product categories S18 and S24 contribute about 50% of total orders and 60% of total sales, 
------so company should focus on developing S18 and S24 product category.
---5. Company's customer retention rate is also very low, only 24%, it means that many customers who have transacted in Q1 do not return to order in Q2 (no repeat orders).
---6. The company experienced negative growth in Q2 and needs to make a lot of improvements both in terms of products and marketing business, 
------so hopefully can achieve the target and have positive growth in the Q3. 
------The low retention rate and conversion rate can be an early diagnosis that customers are not interested/unsatisfied/disappointed in shopping at the company.


