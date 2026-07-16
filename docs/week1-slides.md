---
marp: true
paginate: true
size: 16:9
header: 'dbt Tech Talk · Week 1'
footer: 'Foundations · Models · Sources · Macros'
style: |
  section {
    background: #ffffff;
    color: #2a2352;
    font-family: -apple-system, "Segoe UI", sans-serif;
    font-size: 28px;
    padding: 60px 80px;
    border-top: 8px solid #b8a9dc;
  }
  section.lead {
    background: linear-gradient(135deg, #ede8f7 0%, #ffffff 100%);
    text-align: center;
    justify-content: center;
  }
  h1 { color: #4b3f8f; border-bottom: 3px solid #b8a9dc; padding-bottom: 10px; font-size: 44px; }
  h2 { color: #4b3f8f; font-size: 36px; }
  h3 { color: #6a5cae; }
  strong { color: #4b3f8f; }
  code { background: #f1edf9; color: #2a2352; padding: 2px 6px; border-radius: 4px; }
  pre { background: #faf8fd; border-left: 4px solid #b8a9dc; padding: 16px; border-radius: 4px; }
  pre code { background: transparent; font-size: 22px; }
  table { font-size: 24px; border-collapse: collapse; }
  th { background: #ede8f7; color: #2a2352; padding: 10px 14px; }
  td { padding: 10px 14px; border-bottom: 1px solid #dcd2ee; }
  blockquote { border-left: 4px solid #8a76c4; background: #faf8fd; padding: 12px 18px; color: #2a2352; }
  section::after { color: #8a76c4; }
  ul, ol { line-height: 1.7; }
---

<!-- _class: lead -->

# Building Pipelines with **dbt**
### Week 1 — Foundations

Running on **Snowflake**

---

## Agenda

- Why dbt?
- dbt vs PySpark
- Project structure
- Config files
- Jinja & Macros
- Models & Sources

---

## 1. Why dbt?

- Write plain **SELECTs**
- dbt handles **build order**
- Built-in **tests, docs, lineage**
- **Git-based** workflow

> SQL, done like software.

---

## 2. dbt vs PySpark on Snowflake

| | **PySpark** | **dbt** |
|---|---|---|
| Language | Python | SQL + Jinja |
| Compute | Spark cluster | Snowflake |
| Best for | ETL, ML | ELT / analytics |
| Lineage & tests | DIY | Built-in |

**Rule:** PySpark for Python/ML · dbt for SQL inside Snowflake.

---

## 3. How teams adopt dbt

- ELT — land raw, transform in-warehouse
- Layered mono-repo, PR-reviewed
- CI runs `dbt build` on changed models
- `dbt docs` replaces stale wikis

---

## 4. Project structure

```
practice_dbt/
├── dbt_project.yml     # project config
├── packages.yml        # 3rd-party packages
├── profiles.yml        # DB connection
├── seeds/              # CSV → table
├── models/             # your SELECTs
├── macros/             # reusable snippets
├── tests/              # custom tests
└── snapshots/          # SCD tracking
```

---

## 5. `profiles.yml`

Lives in `~/.dbt/profiles.yml` · **never commit**.

```yaml
practice_dbt:
  target: dev
  outputs:
    dev:
      type: snowflake
      account:       "YOUR_ACCOUNT"
      user:          "you@company.com"
      authenticator: externalbrowser   # SSO login
      role:          "TRANSFORMER"
      warehouse:     "COMPUTE_WH"
      database:      "ANALYTICS"
      schema:        "DBT_DEV"
```

`externalbrowser` → SSO popup, no password stored.

---

## 6. `packages.yml`

Reuse community-built packages.

```yaml
packages:
  - package: dbt-labs/dbt_utils
    version: 1.3.0

  - package: calogica/dbt_expectations
    version: 0.10.4
```

Install:

```bash
dbt deps
```

---

## 6b. Using a package

```sql
select
    {{ dbt_utils.generate_surrogate_key(
        ['customer_id', 'order_id']
    ) }} as pk
from {{ ref('stg_orders') }}
```

Skip re-writing utilities — use battle-tested ones.

---

## 7. `dbt_project.yml`

```yaml
name: 'practice_dbt'
profile: 'practice_dbt'      # links to profiles.yml

models:
  practice_dbt:
    staging:      { +materialized: view }
    intermediate: { +materialized: view }
    marts:        { +materialized: table }
```

Set materialization **per folder**, override per model.

---

## 8. Jinja — what is it?

```
.sql file  ──►  Jinja renders  ──►  pure SQL  ──►  Snowflake
```

- Runs **before** SQL hits the warehouse
- Anything in `{{ ... }}` or `{% ... %}` is Jinja

> Debug tip: `dbt compile` → open `target/compiled/`

---

## 8b. Jinja — sample

```sql
{% set statuses = ['completed', 'returned'] %}

select
    customer_id,
    {% for s in statuses %}
    sum(case when status = '{{ s }}'
             then 1 else 0 end) as {{ s }}_count
    {%- if not loop.last %},{% endif %}
    {% endfor %}
from {{ ref('stg_orders') }}
group by customer_id
```

One loop → many columns.

---

## 9. Models — basic structure

One `.sql` file · one `SELECT`. dbt wraps it in `CREATE TABLE / VIEW`.

```sql
-- models/staging/stg_customers.sql
with source as (
    select * from {{ source('raw', 'raw_customers') }}
)
select
    customer_id,
    lower(email)              as email,
    cast(signup_date as date) as signup_date,
    country
from source
```

Filename = model name. No `CREATE`, no `INSERT`.

---

## 10. Types of models

| Type | dbt runs | Use for |
|---|---|---|
| **view** | `CREATE VIEW` | Staging · always fresh |
| **table** | `CREATE TABLE AS` | Marts · fast reads |
| **incremental** | Insert new rows | Big append-only |
| **ephemeral** | Inlined as CTE | Helper models |

---

## 10b. Incremental — example

```sql
{{ config(
    materialized = 'incremental',
    unique_key   = 'order_id'
) }}

select * from {{ ref('int_orders_enriched') }}

{% if is_incremental() %}
    where order_date > (
        select max(order_date) from {{ this }}
    )
{% endif %}
```

First run: full build · after: only new rows.

---

## 11. Referring models — `ref()`

```sql
select
    c.customer_id,
    count(o.order_id) as total_orders
from {{ ref('stg_customers') }} c
left join {{ ref('stg_orders') }} o
    using (customer_id)
group by c.customer_id
```

- Never hard-code table names
- `ref()` builds the **DAG** for you
- Enables lineage · parallelism · selectors

---

## 12. Sources — what & why

A **source** = a raw table dbt did **not** build.

Declaring sources gives you:

- Named handle `source('raw', 'orders')`
- **Lineage** from raw layer
- **Freshness** checks
- Docs for upstream data

> Not built by dbt? → `source()`
> Built by dbt? → `ref()`

---

## 13. Sources — declare

```yaml
# models/staging/_sources.yml
version: 2
sources:
  - name: raw
    database: ANALYTICS
    schema:   RAW
    tables:
      - name: raw_customers
      - name: raw_orders
        loaded_at_field: _loaded_at
        freshness:
          warn_after:  { count: 12, period: hour }
          error_after: { count: 24, period: hour }
```

---

## 13b. Sources — use

```sql
-- models/staging/stg_orders.sql
select *
from {{ source('raw', 'raw_orders') }}
```

Check freshness:

```bash
dbt source freshness
```

---

## 14. Macros — what & why

A **macro** = a Jinja function you write once, reuse everywhere.

- DRY for SQL
- Consistent logic across models
- One place to change

---

## 14b. Macros — code

```sql
-- macros/cents_to_dollars.sql
{% macro cents_to_dollars(column_name, precision=2) %}
    ({{ column_name }} / 100.0)::numeric(16, {{ precision }})
{% endmacro %}
```

Use it:

```sql
select
    order_id,
    {{ cents_to_dollars('amount_cents') }} as amount_usd
from {{ ref('stg_orders') }}
```

---

## Demo cheat sheet

```bash
pip install dbt-snowflake
dbt deps          # install packages
dbt debug         # verify connection
dbt seed          # load CSVs
dbt run           # build models
dbt test          # run tests
dbt docs serve    # lineage graph
```

---

<!-- _class: lead -->

# Recap

**Config** — profiles · project · packages
**Models** — SELECTs · view/table/incremental
**Linking** — `source()` · `ref()` → DAG
**Reuse** — Jinja · macros

---

<!-- _class: lead -->

# Questions?

Repo · README on GitHub
