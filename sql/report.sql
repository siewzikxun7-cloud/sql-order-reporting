-- Normalize field names and return status before combining the two feeds.
CREATE TEMP VIEW unified_orders AS
SELECT 'Online' AS channel, order_id AS source_order_id,
       order_date, ship_region AS region, product_id,
       CASE order_status WHEN 'returned' THEN 1 ELSE 0 END AS is_returned
FROM online_orders
UNION ALL
SELECT 'Store', receipt_id, sale_date, store_region, sku,
       CASE receipt_status WHEN 'refunded' THEN 1 ELSE 0 END
FROM store_orders;

-- Keep every order in the report and make unmatched product metadata visible.
CREATE TEMP VIEW order_detail AS
SELECT o.*, p.product_name, p.category
FROM unified_orders AS o
LEFT JOIN products AS p USING (product_id);

CREATE TEMP VIEW channel_kpis AS
SELECT channel, COUNT(*) AS orders, SUM(is_returned) AS returns,
       ROUND(100.0 * SUM(is_returned) / COUNT(*), 2) AS return_rate_pct
FROM order_detail
GROUP BY channel;

CREATE TEMP VIEW region_kpis AS
SELECT region, COUNT(*) AS orders, SUM(is_returned) AS returns,
       ROUND(100.0 * SUM(is_returned) / COUNT(*), 2) AS return_rate_pct
FROM order_detail
GROUP BY region;

CREATE TEMP VIEW portfolio_kpis AS
SELECT COUNT(*) AS orders, COALESCE(SUM(is_returned), 0) AS returns,
       ROUND(100.0 * SUM(is_returned) / NULLIF(COUNT(*), 0), 2) AS return_rate_pct
FROM order_detail;
