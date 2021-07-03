-- A. Pizza Metrics

-- 1. How many pizzas were ordered?

SELECT
	COUNT(*) AS pizzas_count
FROM customer_orders;

-- 2. How many unique customer orders were made?

SELECT 
	COUNT(DISTINCT order_id) AS orders_count
FROM customer_orders;

-- 3. How many successful orders were delivered by each runner?

SELECT
	runner_id,
    COUNT(order_id) AS successful_orders_count
FROM runner_orders
WHERE cancallation IS NOT IN ('Restaurant Cancellation', 'Customer Cancellation')
GROUP BY runner_id
ORDER BY 2;

-- 4. How many of each type of pizza was delivered?

SELECT
	c.pizza_id,
    COUNT(c.pizza_id) AS pizzas_delivered
FROM customer_orders c
JOIN runner_orders r
	ON c.order_id = r.order_id
WHERE r.cancallation IS NOT IN ('Restaurant Cancellation', 'Customer Cancellation')
GROUP BY c.pizza_id
ORDER BY 2;

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?

SELECT
	c.customer_id,
    SUM(CASE WHEN p.pizza_name = 'Vegetarian' THEN 1 ELSE 0 END) AS Vegetarian,
    SUM(CASE WHEN p.pizza_name = 'Meatlover' THEN 1 ELSE 0 END) AS Meatlover
FROM customer_orders c
JOIN pizza_names p
	ON c.pizza_id = p.pizza_id
GROUP BY c.customer_id;

-- 6. What was the maximum number of pizzas delivered in a single order?

WITH maximum AS (
  SELECT
  	  c.order_id,
  	  COUNT(c.pizza_id) AS orders_amount
  FROM customer_orders c
  JOIN runner_orders r
  	ON c.order_id = r.order_id
  WHERE r.cancallation IS NOT IN ('Restaurant Cancellation', 'Customer Cancellation')
  GROUP BY c.order_id)
  
  SELECT 
  	MAX(orders_amount)
  FROM maximum;

-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

WITH customer_orders_cleaned AS(
  SELECT
  	 order_id,
  	 customer_id,
  	 pizza_id,
  	 CASE WHEN exclusions IN ('null', '') THEN NULL ELSE exclusions END AS exclusions,
     CASE WHEN extras IN ('Nan', 'null', '') THEN NULL ELSE extras END AS extras
  FROM customer_orders)
  
  SELECT
  	c.customer_id,
    SUM(CASE WHEN c.exclusions IS NOT NULL OR c.extras IS NOT NULL THEN 1 ELSE 0 END) AS at_leat_1_change,
    SUM(CASE WHEN c.exclusions IS NULL AND c.extras IS NULL THEN 1 ELSE 0 END) AS no_changes
   FROM customer_orders_cleaned c
   JOIN runner_orders r
		ON c.order_id = r.order_id
   WHERE r.cancallation IS NOT IN ('Restaurant Cancellation', 'Customer Cancellation')
   GROUP BY c.customer_id;

-- 8. How many pizzas were delivered that had both exclusions and extras?

WITH customer_orders_cleaned AS(
  SELECT
  	 order_id,
  	 customer_id,
  	 pizza_id,
  	 CASE WHEN exclusions IN ('null', '') THEN NULL ELSE exclusions END AS exclusions,
     CASE WHEN extras IN ('Nan', 'null', '') THEN NULL ELSE extras END AS extras
  FROM customer_orders),

exclusions_and_extras AS(
  SELECT
  	 order_id,
     pizza_id,
  	 CASE WHEN exclusions IS NOT NULL AND extras IS NOT NULL THEN 1 ELSE 0 END AS excl_and_extr
  FROM customer_orders_cleaned)
  
  SELECT
  	  COUNT(ee.pizza_id) AS pizzas_delivered
  FROM exclusions_and_extras ee
  JOIN runner_orders r
		ON ee.order_id = r.order_id
   WHERE r.cancallation IS NOT IN ('Restaurant Cancellation', 'Customer Cancellation')
   		AND ee.excl_and_extr = 1;

-- 9. What was the total volume of pizzas ordered for each hour of the day?

SELECT
  DATE_PART('hour', r.pickup_time) AS hour_of_day,
  COUNT(c.pizza_id) AS pizza_count
FROM runner_orders r
JOIN customer_orders c
	ON r.order_id = c.order_id
WHERE r.pickup_time != NULL
GROUP BY r.hour_of_day
ORDER BY r.hour_of_day;