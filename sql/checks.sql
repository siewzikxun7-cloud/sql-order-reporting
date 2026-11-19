-- A failed assertion aborts the run. Expected rows were hand-counted from seed.sql.
CREATE TEMP TABLE checks (
    test TEXT PRIMARY KEY,
    mismatches INTEGER NOT NULL CHECK (mismatches = 0)
);

INSERT INTO checks
SELECT 'Source row counts reconcile', ABS(
    (SELECT COUNT(*) FROM unified_orders)
    - (SELECT COUNT(*) FROM online_orders)
    - (SELECT COUNT(*) FROM store_orders)
);

INSERT INTO checks
SELECT 'No duplicate channel + order ID', COUNT(*)
FROM (
    SELECT channel, source_order_id
    FROM unified_orders
    GROUP BY channel, source_order_id
    HAVING COUNT(*) <> 1
);

INSERT INTO checks
SELECT 'Product join preserves grain and matches every order',
       ABS((SELECT COUNT(*) FROM order_detail) - (SELECT COUNT(*) FROM unified_orders))
       + (SELECT COUNT(*) FROM order_detail WHERE product_name IS NULL);

INSERT INTO checks
WITH expected(dimension, label, orders, returns, rate) AS (
    VALUES ('Total', 'All', 16, 5, 31.25),
           ('Channel', 'Online', 9, 3, 33.33),
           ('Channel', 'Store', 7, 2, 28.57),
           ('Region', 'North', 7, 2, 28.57),
           ('Region', 'South', 5, 2, 40.00),
           ('Region', 'West', 4, 1, 25.00),
           ('Online region', 'North', 4, 1, 25.00),
           ('Online region', 'South', 3, 2, 66.67),
           ('Online region', 'West', 2, 0, 0.00)
), actual AS (
    SELECT 'Total', 'All', orders, returns, return_rate_pct FROM portfolio_kpis
    UNION ALL
    SELECT 'Channel', channel, orders, returns, return_rate_pct FROM channel_kpis
    UNION ALL
    SELECT 'Region', region, orders, returns, return_rate_pct FROM region_kpis
    UNION ALL
    SELECT 'Online region', region, orders, returns, return_rate_pct FROM online_region_kpis
), missing AS (
    SELECT * FROM expected EXCEPT SELECT * FROM actual
), unexpected AS (
    SELECT * FROM actual EXCEPT SELECT * FROM expected
)
SELECT 'All reported KPIs match the expected results',
       (SELECT COUNT(*) FROM missing) + (SELECT COUNT(*) FROM unexpected);

SELECT test, 'PASS' AS result FROM checks ORDER BY rowid;
