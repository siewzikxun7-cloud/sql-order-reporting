-- Bug: generate region labels, then attach the same unfiltered portfolio total.
CREATE TEMP VIEW repeated_chart_values AS
SELECT labels.region, totals.orders, totals.returns, totals.return_rate_pct
FROM (SELECT DISTINCT region FROM order_detail) AS labels
CROSS JOIN portfolio_kpis AS totals;

-- Fix: aggregate order rows by the category used on the chart's axis.
-- For a channel-filtered chart, apply WHERE channel = ... to order_detail
-- before GROUP BY region. Filtering only the labels leaves totals untouched.
CREATE TEMP VIEW online_region_kpis AS
SELECT region, COUNT(*) AS orders, SUM(is_returned) AS returns,
       ROUND(100.0 * SUM(is_returned) / COUNT(*), 2) AS return_rate_pct
FROM order_detail
WHERE channel = 'Online'
GROUP BY region;

SELECT * FROM repeated_chart_values ORDER BY region;
SELECT * FROM region_kpis ORDER BY region;
