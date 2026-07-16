# Examples — Teaching Guide

These are **tiny, standalone** models. Each demonstrates **one concept**. Walk through them in order during the talk.

Location: `models/examples/` · Seed: `seeds/examples/example_countries.csv`

Run just the examples:

```bash
dbt seed --select examples
dbt run  --select examples
```

---

## 01 — First model

**File:** `01_first_model.sql`

```sql
select 1 as id, 'hello' as message
```

**Teach:**
- A model = one `.sql` file with one `SELECT`
- Filename = model name in the warehouse
- dbt wraps it in `CREATE VIEW / CREATE TABLE`

**Show live:**
```bash
dbt run --select 01_first_model
```
Then query it in Snowflake: `select * from dbt_<you>_examples."01_first_model";`

---

## 02 — Materializations

**Files:** `02_materialization_table.sql`, `02_materialization_ephemeral.sql`

**Teach:**
- Default in this folder = `view` (set in `dbt_project.yml`)
- `{{ config(materialized='table') }}` overrides per model
- `ephemeral` → no DB object, inlined as a CTE

**Show live:**
```bash
dbt run --select 02_materialization_table
```
Check Snowflake — a real **table** exists. Then note that `02_materialization_ephemeral` doesn't create any object.

---

## 03 — Jinja

**Files:** `03_jinja_variables.sql`, `03_jinja_loop.sql`

**Teach:**
- Jinja runs **before** SQL hits Snowflake
- `{% set %}` for variables, `{% for %}` for loops
- Loops let you generate many columns from one template

**Show live — the "aha" moment:**
```bash
dbt compile --select 03_jinja_loop
cat target/compiled/practice_dbt/models/examples/03_jinja_loop.sql
```
You'll see the loop expanded into three `sum(case when ...)` columns.

---

## 04 — `source()` and `ref()`

**Files:** `04_using_source.sql`, `04_using_ref.sql`

**Teach:**
- `source()` → raw table dbt did **not** build (declared in `_sources.yml`)
- `ref()`   → another dbt model
- Both are read by dbt to build the **DAG**

**Show live:**
```bash
dbt run --select 04_using_source 04_using_ref
```
Then open `dbt docs serve` and show the two boxes connected by an arrow.

---

## 05 — Macros

**File:** `05_using_macro.sql` · **Macro:** `macros/cents_to_dollars.sql`

**Teach:**
- A macro = reusable Jinja function
- Write once, call from any model
- Compiles to plain SQL

**Show live:**
```bash
dbt compile --select 05_using_macro
```
Open the compiled SQL — the macro call is replaced with real SQL.

---

## Suggested classroom flow

| Time | Do this |
|---|---|
| 0–5 min  | Explain folder + run `dbt seed --select examples` |
| 5–15 min | Walk `01` and `02_*` — materializations |
| 15–30 min| Walk `03_*` — Jinja + `dbt compile` |
| 30–45 min| Walk `04_*` — `source`/`ref` + open `dbt docs serve` |
| 45–55 min| Walk `05_*` — macros + compiled output |

Then move to the mini project → [`PROJECT.md`](PROJECT.md).
