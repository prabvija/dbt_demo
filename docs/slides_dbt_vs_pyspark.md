# Slide 1: What Are They, Really?

---

## dbt (data build tool)

> **"Write SQL. dbt does the rest."**

- dbt is a **transformation** tool — it only does the **T** in ELT
- You write `.sql` files; dbt compiles and runs them **inside your data warehouse**
- No servers, no clusters, no infrastructure — your warehouse is the engine
- Outputs are tables/views sitting right in your warehouse schema

```
Your SQL file  →  dbt compiles it  →  Warehouse runs it  →  Table/View created
```

```sql
-- models/marts/fct_orders.sql
select
    order_id,
    customer_id,
    amount,
    order_date
from {{ ref('int_orders_enriched') }}
where status = 'completed'
```

dbt figures out the order to run everything. You just write SQL.

---

## PySpark

> **"Process data at scale, anywhere."**

- PySpark is a **distributed compute framework** — it does E, T, and sometimes L
- You write Python (or Scala); code runs on a **Spark cluster** (separate from your warehouse)
- You manage compute, memory, partitioning, and cluster config
- Outputs can go anywhere: S3, HDFS, a database, Kafka, etc.

```
Your Python file  →  Spark cluster executes  →  Output written to storage/DB
```

```python
# PySpark equivalent of the same logic
from pyspark.sql import functions as F

df = spark.table("raw.orders")

result = (
    df.filter(F.col("status") == "completed")
      .select("order_id", "customer_id", "amount", "order_date")
)

result.write.mode("overwrite").saveAsTable("marts.fct_orders")
```

You control every step: cluster, memory, write mode, partitioning.

---
---

# Slide 2: Side-by-Side — Pick the Right Tool

---

| Dimension               | dbt                                      | PySpark                                      |
|-------------------------|------------------------------------------|----------------------------------------------|
| **Language**            | SQL (+ Jinja templating)                 | Python / Scala / Java / R                    |
| **Where it runs**       | Inside your data warehouse               | On a Spark cluster (EMR, Databricks, etc.)   |
| **Infrastructure**      | None — warehouse is the engine           | Cluster required; you size & manage it       |
| **Primary use case**    | Transform structured data in a warehouse | Process any data at any scale, anywhere      |
| **Data it handles**     | Structured (tables, views)               | Structured, semi-structured, unstructured    |
| **Streaming support**   | No                                       | Yes (Spark Structured Streaming)             |
| **ML / advanced logic** | No                                       | Yes (MLlib, arbitrary Python logic)          |
| **Lineage / DAG**       | Built-in, auto-generated                 | Manual (or via Airflow/orchestrator)         |
| **Testing**             | Built-in schema + data tests             | Custom — you write your own assertions       |
| **Learning curve**      | Low — if you know SQL, you know dbt      | Medium-High — distributed systems concepts   |
| **Best for**            | Analytics engineers, BI, reporting       | Data engineers, large-scale ETL, ML pipelines|

---

## The Mental Model

```
Raw Data  ──►  Ingest / Heavy ETL  ──►  Warehouse  ──►  Transform / Model  ──►  BI / Reports
                     ▲                                          ▲
               [ PySpark ]                                  [ dbt ]
          (move, clean, scale,                       (structure, document,
           handle any format)                         test, serve to analysts)
```

**They are complementary, not competing.**

A common modern stack:
- **PySpark** (or Fivetran/Airbyte) ingests and lands raw data into the warehouse
- **dbt** takes over from there — models, tests, documents, and serves it to the business

---

## One-line summary

| | |
|---|---|
| **dbt** | *"I transform clean, structured data that's already in my warehouse — using SQL."* |
| **PySpark** | *"I process anything, at any scale, anywhere — using code."* |
