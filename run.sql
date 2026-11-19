.bail on
.headers on
.mode column

.read data/seed.sql
.read sql/report.sql

.print '01  Portfolio KPIs'
SELECT * FROM portfolio_kpis;
.print ''
.print '02  KPIs by channel'
SELECT * FROM channel_kpis ORDER BY channel;
.print ''
.print '03  Repeated region values (bug), then grouped values (fix)'
.read sql/debug.sql
.print ''
.print '04  Corrected region KPIs filtered to Online'
SELECT * FROM online_region_kpis ORDER BY region;
.print ''
.print '05  Quality checks'
.read sql/checks.sql
