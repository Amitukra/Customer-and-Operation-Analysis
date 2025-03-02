

------------------------------------------------------------------------------------------------------
--------------------------------------    SQL ASSIGMNET      -----------------------------------------
------------------------------------------------------------------------------------------------------

------  Question : Consider you are working with an online grocery delivery business   ---------------
------             and you want to know the average time from 1st order placed to next ---------------
------             order placed until 10th order placed.                               ---------------


CREATE DATABASE Buncha;
 
use Buncha;

CREATE TABLE user_table (
    Id INT PRIMARY KEY,
    UserName VARCHAR(255) NOT NULL,
    CreatedAt DATETIME NOT NULL
);

INSERT INTO user_table (Id, UserName, CreatedAt) VALUES
(24280, 'Kayla Evans', '2023-03-06 23:42:00'),
(24603, 'Nichole Robinson', '2023-06-21 11:04:00'),
(24812, 'Amanda Luedtke', '2024-03-07 14:01:00'),
(25039, 'Cassandra Nelson', '2023-03-17 20:41:00'),
(25040, 'Deena Hougard', '2023-03-17 20:45:00'),
(25851, 'John Horihan', '2023-04-02 17:49:00'),
(25953, 'Katie Cvelbar', '2023-04-03 07:04:00');

select * from user_table;

CREATE TABLE orders_table (
    Id INT PRIMARY KEY,
    BuyerId INT NOT NULL,
    CreatedAt DATETIME NOT NULL,
    Cancelled BIT NOT NULL,  -- Using BIT for boolean values in MS SQL Server
    FOREIGN KEY (BuyerId) REFERENCES user_table(Id)
);

INSERT INTO orders_table (Id, BuyerId, CreatedAt, Cancelled) VALUES
(67507, 24280, '2023-03-08 23:42:00', 0),
(67618, 25039, '2023-03-29 13:08:00', 0),
(68660, 24603, '2023-07-05 09:09:00', 1),
(68750, 24280, '2023-04-02 17:55:00', 0),
(69645, 25851, '2023-04-07 16:01:00', 1),
(70264, 24603, '2023-07-08 12:45:00', 0),
(70390, 25953, '2023-04-10 10:28:00', 0);

select * from orders_table;

WITH RankedOrders AS (
    SELECT 
        BuyerId, 
        Id AS OrderId,
        CreatedAt,
        RANK() OVER (PARTITION BY BuyerId ORDER BY CreatedAt) AS OrderRank
    FROM orders_table
),
TimeDiffs AS (
    SELECT 
        o1.BuyerId,
        o1.CreatedAt AS FirstOrderTime,
        o2.CreatedAt AS NextOrderTime,
        DATEDIFF(HOUR, o1.CreatedAt, o2.CreatedAt) AS TimeDiff
    FROM RankedOrders o1
    JOIN RankedOrders o2 
        ON o1.BuyerId = o2.BuyerId 
        AND o1.OrderRank + 1 = o2.OrderRank
    WHERE o1.OrderRank BETWEEN 1 AND 9
)
SELECT 
    BuyerId,
    AVG(CAST(TimeDiff AS FLOAT)) AS AvgTimeBetweenOrders_Hours
FROM TimeDiffs
GROUP BY BuyerId;



------------------------------------------------------------------------------------------------------
--------------------------------------    SQL ASSIGMNET      -----------------------------------------
--------------------        Customer Purchase & Delivery Analysis      -------------------------------
------------------------------------------------------------------------------------------------------

SELECT * FROM orders;
select * from delivery_performance;

---   Tasks 
----  1. Identify customers who haven't placed an order in the last 60 days but had at least 2 orders before.

	SELECT distinct(customer_id)
	FROM Orders
	WHERE order_date < DATEADD(DAY, -60, GETDATE())
	GROUP BY customer_id
	HAVING COUNT(order_id) >= 2;


---   Tasks 
----  2. Calculate the average time between consecutive orders for repeat customers.

	WITH Order_Differences AS (
	SELECT 
		customer_id,
		order_id,
		order_date,
		LEAD(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS next_order_date
	FROM Orders
	)
	SELECT  
		customer_id,
		AVG(DATEDIFF(DAY, order_date, next_order_date)) AS avg_days_between_orders
	FROM Order_Differences
	WHERE next_order_date IS NOT NULL
	GROUP BY customer_id;


---   Tasks 
----  3. Determine the top 10% of customers by total spend and their average order value.

	WITH Customer_Spend AS (
		SELECT 
			customer_id,
			SUM(total_amount) AS total_spend,
			COUNT(order_id) AS total_orders
		FROM Orders
		GROUP BY customer_id
	),
	Top_10_Percent_Customers AS (
		SELECT 
			customer_id,
			total_spend,
			total_orders,
			PERCENT_RANK() OVER (ORDER BY total_spend DESC) AS spend_percentile
		FROM Customer_Spend
	)
	SELECT 
		customer_id,
		total_spend,
		total_orders,
		total_spend / total_orders AS avg_order_value
	FROM Top_10_Percent_Customers
	WHERE spend_percentile <= 0.1
	ORDER BY total_spend DESC;


---   Tasks 
----  4. Analyze delivery time efficiency by calculating the percentage of on-time deliveries per region.

	WITH Delivery_Stats AS (
		SELECT 
			o.city,
			COUNT(*) AS total_deliveries,
			SUM(CASE WHEN dp.delivery_status = 'On Time' THEN 1 ELSE 0 END) AS on_time_deliveries
		FROM delivery_performance dp
		JOIN Orders o ON dp.customer_id = o.customer_id  
		GROUP BY o.city
	)
	SELECT  
		city,
		total_deliveries,
		on_time_deliveries,
		(on_time_deliveries * 100.0 / total_deliveries) AS on_time_percentage
	FROM Delivery_Stats;

