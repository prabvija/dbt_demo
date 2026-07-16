# Mini Live Project — Retail Sales Pipeline

A small end-to-end pipeline the class runs themselves. It uses everything from the examples applied together.

Location: `models/project/` · Seeds: `seeds/project/`

---

## What we're building

```
raw_customers ─┐
raw_orders    ─┤─► staging ─► intermediate ─► marts
raw_products  ─┘
```

**Marts produced:**
- `dim_customers` — one row per customer, lifetime value + order counts
- `fct_orders` — one row per order (incremental)
- `fct_daily_sales` — daily revenue per product category

---

## Model list

| Layer | Model | Materialization | Purpose |
|---|---|---|---|
| staging | `stg_customers`  | view | Clean + rename customer fields |
| staging | `stg_orders`     | view | Clean + rename order fields |
| staging | `stg_products`   | view | Clean + rename product fields |
| intermediate | `int_orders_enriched` | view | Join orders + customers + products |
| marts | `dim_customers`   | table | Customer LTV table |
| marts | `fct_orders`      | incremental | Orders fact (append-only) |
| marts | `fct_daily_sales` | table | Daily category revenue |

---

## Run the project (live-class steps)

**Assumes `dbt debug` already works.** See main [README](../README.md) for setup.

```bash
# 1. Load raw seeds into Snowflake
dbt seed --select project

# 2. Build the pipeline (staging → intermediate → marts)
dbt run --select project

# 3. Run tests
dbt test --select project

# 4. See the lineage
dbt docs generate
dbt docs serve
```

Or in a single command:

```bash
dbt build --select project
```

---

## Verify in Snowflake

```sql
-- Customer lifetime value
select * from dbt_<you>.dim_customers order by lifetime_value_usd desc;

-- Daily category sales
select * from dbt_<you>.fct_daily_sales order by order_date, category;

-- All completed orders enriched
select * from dbt_<you>.fct_orders where status = 'completed';
```

---

## Try the incremental model

```bash
# First run — builds the full table
dbt run --select fct_orders

# Add a new row to seeds/project/raw_orders.csv, then:
dbt seed --select raw_orders
dbt run  --select fct_orders     # only the new row is inserted

# Force a full rebuild
dbt run  --select fct_orders --full-refresh
```

---

## Selectors cheat sheet

```bash
dbt run --select stg_orders              # one model
dbt run --select project.staging         # a subfolder
dbt run --select +fct_daily_sales        # model + all upstreams
dbt run --select fct_daily_sales+        # model + all downstreams
dbt run --select tag:daily               # by tag (if configured)
```

---

## Homework ideas

1. Add a `dim_products` mart (products + their total revenue).
2. Add a test: `fct_daily_sales.revenue_usd >= 0`.
3. Write a macro `clean_email(col)` that lowercases + trims, use it in `stg_customers`.
4. Add a `_docs.md` file with a description block, reference it in `_schema.yml`.
