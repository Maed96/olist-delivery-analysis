-- File: 05_avg_days_late_by_seller_state.sql
-- Question: When orders are delivered late, how many days late are they on average, by seller state?
--
-- Method:
--   - Delivered orders only (order_status = 'delivered', delivery date not null)
--   - Late = delivered after the estimated delivery DATE (time of day ignored;
--     delivery on the estimated day counts as on time)
--   - Order Items has one row per item, so orders are deduplicated to
--     one row per order per seller state before averaging
--   - Average is over LATE orders only, not all orders
--   - States with fewer than 30 late orders are excluded
--
-- Note: an order with items from sellers in more than one state
--       is counted once in each of those states.
--
-- Output: seller_state, n_late_orders, avg_days_late

WITH delivered_orders AS (
  SELECT order_id,
CASE
WHEN DATE(order_delivered_customer_date) > DATE(order_estimated_delivery_date)
THEN "late" ELSE "on time"
END AS delivery_status,

DATE_DIFF(DATE(order_delivered_customer_date), DATE(order_estimated_delivery_date), DAY) AS delay

FROM `portfolio-513612.olist.Orders`
WHERE  order_status = "delivered" AND order_delivered_customer_date IS NOT NULL AND order_estimated_delivery_date IS NOT NULL
),

orders_sellers AS (
  SELECT DISTINCT i.order_id, s.seller_state
  FROM `portfolio-513612.olist.Order Items` i
  JOIN `portfolio-513612.olist.Sellers` s ON i.seller_id = s.seller_id
)


SELECT
-- late_orders.order_id,
-- delivery_status,
  seller_state,
  COUNT(*) AS n_late_orders,
  ROUND(AVG(d.delay), 2) AS avg_days_late
FROM delivered_orders d
JOIN orders_sellers os ON os.order_id = d.order_id
WHERE d.delivery_status = 'late'
GROUP BY os.seller_state
-- HAVING n_late_orders >= 10
ORDER BY avg_days_late DESC;

