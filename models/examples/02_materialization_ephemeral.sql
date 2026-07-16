-- CONCEPT: Ephemeral — dbt does NOT create anything in the warehouse.
-- The SQL is inlined as a CTE inside any model that ref()s it.
-- Useful for tiny helpers you don't want cluttering the schema.

{{ config(materialized='ephemeral') }}

select
    'US' as country_code, 'United States' as country_name
union all
select 'UK', 'United Kingdom'
union all
select 'IN', 'India'
