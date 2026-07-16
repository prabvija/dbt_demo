# practice_dbt — dbt + Snowflake Workshop

A hands-on dbt project for a **2-hour live class**. It has two parts:

| Folder | Purpose |
|---|---|
| [`models/examples/`](docs/EXAMPLES.md) | Tiny standalone models — one per concept (jinja, ref, source, macro, materialization) |
| [`models/project/`](docs/PROJECT.md)   | A mini end-to-end pipeline (customers, orders, products → dim + fct marts) |

---

## 1. Prerequisites

- **Python 3.9+**
- **Snowflake account** with a role that can create schemas/tables in a database
- **Git**

You need these Snowflake values before you start:

| Field | Example |
|---|---|
| Account | `ab12345.us-east-1` |
| User | `you@company.com` |
| Role | `TRANSFORMER` |
| Warehouse | `COMPUTE_WH` |
| Database | `ANALYTICS` |
| Schema | `DBT_<YOUR_NAME>` (personal dev schema) |

---

## 2. One-time setup

```bash
# Clone
git clone <repo-url> practice_dbt
cd practice_dbt

# Virtual env + install
python -m venv .venv
source .venv/bin/activate                # Windows: .venv\Scripts\activate
pip install dbt-snowflake

# Install dbt packages
dbt deps
```

---

## 3. Configure your Snowflake connection

Copy the sample profile to your dbt home:

```bash
mkdir -p ~/.dbt
cp profiles.yml ~/.dbt/profiles.yml
```

Edit `~/.dbt/profiles.yml` and replace the placeholders with your Snowflake values. This project uses **external browser (SSO) auth** by default — a browser tab opens on first connect.

Verify:

```bash
dbt debug
```

You should see **All checks passed!**

---

## 4. Run everything

```bash
dbt seed         # loads all CSVs → *_raw and *_examples schemas
dbt run          # builds every model (examples + project)
dbt test         # runs schema + custom tests
dbt docs generate && dbt docs serve   # opens lineage graph
```

Where the objects land in Snowflake:

| Schema | Contents |
|---|---|
| `DBT_<YOU>_raw`      | Project seed tables (raw_customers, raw_orders, raw_products) |
| `DBT_<YOU>_examples` | Example models + example seed |
| `DBT_<YOU>`          | Project models (staging views, marts) |

---

## 5. Common commands

```bash
dbt run --select examples             # only teaching examples
dbt run --select project              # only the mini project
dbt run --select stg_customers        # one model
dbt run --select +fct_daily_sales     # a model + all its upstreams
dbt build --select project            # seed + run + test the project
dbt compile --select 03_jinja_loop    # see rendered SQL in target/compiled/
```

---

## 6. Where to go next

- **Teaching examples** → [`docs/EXAMPLES.md`](docs/EXAMPLES.md)
- **Mini live project** → [`docs/PROJECT.md`](docs/PROJECT.md)
- **Slides** → [`docs/week1-slides.md`](docs/week1-slides.md)
