# dbt_demo — a hands-on dbt + Snowflake starter project

Welcome! This is a practice project for the bootcamp. You don't need to be a
programmer to follow it. Just copy each command exactly, in order, and read the
short note under it that says what it does and what you should see.

**Before you start, you should already have:**
- a **Snowflake account** you can log in to, and
- **Python 3** and **Git** installed on your computer.

## What are these two tools? (plain English)

- **Snowflake** is a database that lives in the cloud. Think of it as a giant,
  super-fast spreadsheet warehouse where your data is stored and organised.
- **dbt** is a tool that takes messy raw data and turns it into clean, useful
  tables — step by step. Think of it like a **kitchen**: you start with raw
  ingredients and end with a finished dish.

### The "kitchen" analogy for how data flows

```
seeds  →  sources  →  staging  →  intermediate  →  marts
```

| Stage          | Kitchen analogy                          | What actually happens                          |
|----------------|------------------------------------------|------------------------------------------------|
| **seeds**      | Raw ingredients delivered to the kitchen | Load the example CSV files into Snowflake       |
| **sources**    | A label saying "these are the raw items" | Just a note telling dbt where the raw data is   |
| **staging**    | Washing & chopping the ingredients       | Tidy up each raw table (rename, fix formats)    |
| **intermediate** | Mixing ingredients together            | Combine tidied tables into useful building blocks |
| **marts**      | The finished dish served to guests       | Final tables that reports & dashboards use      |

Everything in this project is small and safe — you can run it as many times as
you like.

---

## The big picture: what you'll do

There are **two parts**:

1. **One-time setup** (sections 0–3) — check your tools, prepare a small
   workspace in Snowflake, and connect your computer to it. You only do this
   once.
2. **The workflow** (section 4) — the fun part you'll actually practice in the
   bootcamp.

> **A note on the "terminal":** the terminal (also called a command line) is a
> plain text window where you type commands instead of clicking buttons.
> - On **Mac**, open the app called **Terminal**.
> - On **Windows**, open **Git Bash** (it comes with Git — search for it in the
>   Start menu).
> You'll paste commands there and press **Enter** to run each one.

---

## 0. Quick prerequisite check (do this first)

Let's make sure the three things you need are ready **before** we start. Open
your terminal (**Terminal** on Mac, **Git Bash** on Windows) and run each
command below. You're just looking for a version number or a success message —
if you get one, that item is ready. ✅

### Check 1 — Python

**On Mac:**

```bash
python3 --version
```

**On Windows (Git Bash):**

```bash
python --version
```

✅ Expected: something like `Python 3.9.0` or higher.

### Check 2 — Git & Git Bash

Run this on **both** Mac and Windows:

```bash
git --version
```

✅ Expected: something like `git version 2.40.0`.

> On Windows, the very fact that you're typing this inside a **Git Bash** window
> means Git Bash is installed — so this check covers both. If you can't find
> Git Bash in your Start menu, Git isn't installed yet.

> **Both checks passed?** Great — continue to section 1.

---

## 1. Find your Snowflake "account identifier"

The one value you need from Snowflake is your **account identifier**. It's the
part of your Snowflake web address before `.snowflakecomputing.com`.

Example: if your address is
`https://acme_corp-xy12345.snowflakecomputing.com`, then your account
identifier is **`acme_corp-xy12345`**.

Keep this handy — you'll paste it in during setup.

---

## 2. Prepare Snowflake (run this once)

Now you'll set up a small workspace inside Snowflake. Don't worry about
understanding every line — this creates:

- a **warehouse** (the engine that does the work),
- a **database** (where tables live),
- a **role** (a set of permissions), and
- a **user** (the login dbt will use).

**How to run it:** In your Snowflake web page (Snowsight), click **Projects →
Worksheets → + Worksheet**, paste the block below, and click **Run**.

> ✏️ Before running, change `Str0ngPass!` to a password of your own.

```sql
-- Run as an admin (ACCOUNTADMIN)
USE ROLE ACCOUNTADMIN;

-- 1. Warehouse (the engine that runs the work)
CREATE WAREHOUSE IF NOT EXISTS DBT_WH
  WITH WAREHOUSE_SIZE = 'XSMALL'
       AUTO_SUSPEND = 60
       AUTO_RESUME = TRUE
       INITIALLY_SUSPENDED = TRUE;

-- 2. Database (where your tables will live)
CREATE DATABASE IF NOT EXISTS DBT_DEMO;

-- 3. Role (a set of permissions)
CREATE ROLE IF NOT EXISTS DBT_ROLE;

-- 4. User (the login dbt will use — change the password!)
CREATE USER IF NOT EXISTS DBT_USER
  PASSWORD = 'Str0ngPass!'
  DEFAULT_ROLE = DBT_ROLE
  DEFAULT_WAREHOUSE = DBT_WH
  MUST_CHANGE_PASSWORD = FALSE;

-- 5. Give the role the permissions it needs
GRANT ROLE DBT_ROLE TO USER DBT_USER;

GRANT USAGE  ON WAREHOUSE DBT_WH TO ROLE DBT_ROLE;
GRANT OPERATE ON WAREHOUSE DBT_WH TO ROLE DBT_ROLE;

GRANT USAGE            ON DATABASE DBT_DEMO TO ROLE DBT_ROLE;
GRANT CREATE SCHEMA    ON DATABASE DBT_DEMO TO ROLE DBT_ROLE;

GRANT USAGE                     ON FUTURE SCHEMAS IN DATABASE DBT_DEMO TO ROLE DBT_ROLE;
GRANT SELECT                    ON FUTURE TABLES  IN DATABASE DBT_DEMO TO ROLE DBT_ROLE;
GRANT SELECT                    ON FUTURE VIEWS   IN DATABASE DBT_DEMO TO ROLE DBT_ROLE;
GRANT ALL PRIVILEGES            ON ALL   SCHEMAS  IN DATABASE DBT_DEMO TO ROLE DBT_ROLE;
```

If it runs without red error messages, you're done with this part. 🎉

### Write down these seven values

You'll type these into your computer in the next section. Here's what each one
means and its value from the setup above:

| What to note down     | Meaning                                   | Your value                         |
|-----------------------|-------------------------------------------|------------------------------------|
| Account               | Your Snowflake address (from section 1)   | e.g. `acme_corp-xy12345`           |
| User                  | The login dbt uses                        | `DBT_USER`                         |
| Password              | The password you chose above              | `Str0ngPass!` (your own)           |
| Role                  | The permission set                        | `DBT_ROLE`                         |
| Warehouse             | The engine                                | `DBT_WH`                           |
| Database              | Where tables live                         | `DBT_DEMO`                         |
| Schema                | Your **personal folder** for your tables  | `DBT_DEV` (pick your own)          |

> **Pick your own schema name** so it doesn't clash with classmates. For
> example `DBT_DEV_ALICE`, or `DBT_DEV_01`. A "schema" is just a folder inside
> the database where your results are kept separate from everyone else's.

---

## 3. Connect your computer to Snowflake (run this once)

Now you'll download the project and tell it how to reach your Snowflake. Follow
the section for **your** operating system.

### 3A. On a Mac

Paste these lines into Terminal, **one block at a time**. Replace the example
values with your own from section 2.

```bash
# Download the project and go into its folder
git clone <github-project-link> dbt_demo
cd dbt_demo

# Create a private workspace and install dbt into it
python3 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install "dbt-snowflake~=1.8"

# Check dbt installed correctly
dbt --version

# Copy the sample settings file into place
mkdir -p ~/.dbt
cp profiles.sample.yml ~/.dbt/profiles.yml

# Tell dbt your Snowflake details (use YOUR values here)
export SNOWFLAKE_ACCOUNT="acme_corp-xy12345"
export SNOWFLAKE_USER="DBT_USER"
export SNOWFLAKE_PASSWORD="Str0ngPass!"
export SNOWFLAKE_ROLE="DBT_ROLE"
export SNOWFLAKE_WAREHOUSE="DBT_WH"
export SNOWFLAKE_DATABASE="DBT_DEMO"
export SNOWFLAKE_SCHEMA="DBT_DEV"

# Test the connection
dbt debug
```

✅ You want to see the message **"All checks passed!"** at the end.

> **Good to know:** the `.venv` step creates a private, self-contained
> workspace just for this project, so it won't affect anything else on your
> computer. The `export` lines are just how you hand your Snowflake details to
> dbt.

### 3B. On Windows (using Git Bash)

On Windows, use **Git Bash** — it comes bundled with Git. Open the Start menu,
type **Git Bash**, and press Enter. (Please don't use PowerShell or Command
Prompt for this project — the commands below are written for Git Bash.)

Paste these lines into Git Bash, **one block at a time**. Replace the example
values with your own from section 2.

```bash
# Download the project and go into its folder
git clone <github-project-link> dbt_demo
cd dbt_demo

# Create a private workspace and install dbt into it
python -m venv .venv
source .venv/Scripts/activate
pip install --upgrade pip
pip install "dbt-snowflake~=1.8"

# Check dbt installed correctly
dbt --version

# Copy the sample settings file into place
mkdir -p ~/.dbt
cp profiles.sample.yml ~/.dbt/profiles.yml

# Tell dbt your Snowflake details (use YOUR values here)
export SNOWFLAKE_ACCOUNT="acme_corp-xy12345"
export SNOWFLAKE_USER="DBT_USER"
export SNOWFLAKE_PASSWORD="Str0ngPass!"
export SNOWFLAKE_ROLE="DBT_ROLE"
export SNOWFLAKE_WAREHOUSE="DBT_WH"
export SNOWFLAKE_DATABASE="DBT_DEMO"
export SNOWFLAKE_SCHEMA="DBT_DEV"

# Test the connection
dbt debug
```

✅ You want to see the message **"All checks passed!"** at the end.

> **Note for Windows:** the only difference from the Mac steps is turning on the
> private workspace — on Windows/Git Bash it's `source .venv/Scripts/activate`
> (note `Scripts`, not `bin`).

---

# ✅ Setup is complete!

If `dbt debug` said **"All checks passed!"**, your computer is talking to
Snowflake and you're ready.

**Everything above was one-time setup. Everything below is the practice you'll
do in the bootcamp** — and you can repeat it as often as you like.

> **Coming back later?** Each time you open a new terminal to work on this
> project, you need to do two quick things again: (1) activate the workspace
> (`source .venv/bin/activate` on Mac, or `source .venv/Scripts/activate` on
> Windows/Git Bash), and (2) re-enter the `export` lines from section 3.

---

## 4. The workflow — build the data step by step

Remember the kitchen: raw ingredients → prepped → mixed → finished dish. You'll
run each stage and then peek at Snowflake to see what appeared.

```
seeds  →  sources  →  staging  →  intermediate  →  marts
```

### Step 1 — Seeds: load the raw data

```bash
dbt seed
```

- **What it does:** loads the example spreadsheets (CSV files) into Snowflake.
- **Where it lands:** a folder (schema) called `DBT_DEV_raw` (your schema name
  plus `_raw`).
- **See it for yourself** — in Snowflake, open a Worksheet and run:
  ```sql
  SELECT * FROM DBT_DEMO.DBT_DEV_RAW.RAW_CUSTOMERS LIMIT 5;
  ```
  You should see five customers.

### Step 2 — Sources: just a label (nothing to build)

Sources are only a **note** telling dbt where the raw data lives — there's
nothing to run. If you're curious, open the file
`models/staging/_sources.yml` in your editor to see how it's written.

To check the project is healthy, run:

```bash
dbt parse
```

- **What it does:** quickly checks that all the project files make sense. No
  data is changed.

### Step 3 — Staging: wash & chop (tidy each table)

```bash
dbt run --select staging
```

- **What it does:** creates cleaned-up versions of each raw table (better names,
  correct formats).
- **Where it lands:** the `DBT_DEV_staging` folder.
- **Check it worked** (this runs the built-in quality checks):
  ```bash
  dbt test --select staging
  ```

### Step 4 — Intermediate: mix the ingredients

```bash
dbt run --select intermediate
```

- **What it does:** combines the tidied tables into a useful in-between table.
- **Where it lands:** the `DBT_DEV_intermediate` folder.
- This one isn't shown to end users — it's a building block for the final step.

### Step 5 — Marts: the finished dish

```bash
dbt run --select marts
```

- **What it does:** creates the final, report-ready tables (customers, orders,
  daily sales).
- **Where it lands:** the `DBT_DEV_marts` folder.
- **Run all the quality checks** across the whole project:
  ```bash
  dbt test
  ```

### Step 6 — See the picture (documentation & data map)

```bash
dbt docs generate
dbt docs serve
```

- **What it does:** opens a web page in your browser with a **map** showing how
  the data flows from raw all the way to the finished tables. Press `Ctrl + C`
  in the terminal when you're done to close it.

---

### Recap: where each step puts its results

(Assuming your schema is `DBT_DEV`.)

| Step | Command                         | Lands in folder        | What you get                    |
|------|---------------------------------|------------------------|---------------------------------|
| 1    | `dbt seed`                      | `DBT_DEV_raw`          | the raw example tables          |
| 2    | (just a label — nothing runs)   | —                      | a note pointing at the raw data |
| 3    | `dbt run --select staging`      | `DBT_DEV_staging`      | tidied tables                   |
| 4    | `dbt run --select intermediate` | `DBT_DEV_intermediate` | a combined building block       |
| 5    | `dbt run --select marts`        | `DBT_DEV_marts`        | the final report-ready tables   |

### The one-command shortcut (once you're comfortable)

Instead of running each step, this does the whole thing at once:

```bash
dbt build
```

---

## 5. If something goes wrong

| What you see                              | What to do                                                                 |
|-------------------------------------------|----------------------------------------------------------------------------|
| `dbt debug` says connection failed        | Double-check your account value from section 1 (e.g. `acme_corp-xy12345`). |
| A message about "insufficient privileges" | Re-run the setup block in section 2.                                        |
| Your tables aren't showing in Snowflake   | Make sure you're looking in the right folder, e.g. `DBT_DEV_marts`.        |
| Mac: `command not found: dbt`             | Turn the workspace back on: `source .venv/bin/activate`                     |
| Windows: `dbt` is not recognized          | Turn the workspace back on: `source .venv/Scripts/activate`                |