# Order Reporting and KPI Quality Checks

An operations team wants one order report for online and store sales. This SQLite project combines the two feeds, joins a product catalog, and investigates why a regional chart shows the same return rate for every region.

**Independent portfolio project by Zixuan (Terry) Xiao.** All records are fictional. The project uses no Accenture data, code, or internal screenshots.

## Run the project

Install the SQLite command-line shell (`sqlite3`). From the repository root, run:

```sh
sqlite3 :memory: < run.sql
```

The script loads the [fictional data](data/seed.sql), builds the [reporting views](sql/report.sql), prints the [broken and corrected regional results](sql/debug.sql), and runs the [quality checks](sql/checks.sql). A failed assertion stops the run with a nonzero exit status. Each run starts with an empty in-memory database.

## Reporting logic

The fixture contains 16 single-product orders dated March 1–13, 2026. Each row is one completed or returned order. The two order systems can reuse the same numeric ID, so `(channel, source_order_id)` identifies a row. Normalize the fields and return statuses, combine feeds with `UNION ALL`, and left join the product catalog on `product_id`. Checks catch missing product matches and changes in order counts after the join.

- **Order volume** is the count of order rows, including returns.
- **Return rate** is returned orders divided by all orders in the same group, expressed as a percentage and rounded to two decimal places. The portfolio rate is calculated from the underlying counts.
- **Region** is the shipping region for online orders and the store location for in-store purchases.

| Scope | Orders | Returned orders | Return rate |
| --- | ---: | ---: | ---: |
| All orders | 16 | 5 | 31.25% |
| Online | 9 | 3 | 33.33% |
| Store | 7 | 2 | 28.57% |
| North | 7 | 2 | 28.57% |
| South | 5 | 2 | 40.00% |
| West | 4 | 1 | 25.00% |

## Debug the repeated chart values

The broken query generates three region labels, then attaches the whole-portfolio result to each label. North, South, and West each show **16 orders and 31.25% returned**. The visual can look plausible because every bar has a distinct label, even though all three share the same calculation.

The corrected query groups the underlying orders by `region` and divides within each group. Apply a channel filter to the source rows before grouping when the chart is scoped to one channel. For example, Online-only South has two returned orders out of three (**66.67%**).

Compare the corrected outputs with hand-counted fixture expectations. Regional counts sum to 16 orders and five returns. North, South, and West must match **28.57%, 40.00%, and 25.00%** respectively. Two regions could legitimately have the same rate on a different dataset, so the check compares each expected group and count.

Run the script to see the broken and corrected regional results, followed by four passing quality checks.
