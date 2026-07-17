-- CONCEPT: Jinja variables & conditionals.
-- Jinja tags run BEFORE the SQL hits Snowflake.

{% set min_amount = 20 %}

select
    'min_amount was set to {{ min_amount }}' as note,
    {{ min_amount }} as min_amount

-- Try:  dbt compile --select 03_jinja_variables
-- Then open target/compiled/... to see the rendered SQL.
