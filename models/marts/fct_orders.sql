-- MART: fact table of orders, one row per order, enriched with customer info.
-- Override materialization to "incremental" to demo the concept.
-- On first run: builds full table.
-- On subsequent runs: only inserts new orders (where order_date > max in table).

{{ config(
    materialized = 'incremental',
    unique_key   = 'order_id'
) }}

with enriched as (
    select * from {{ ref('int_orders_enriched') }}
)

select * from enriched

{% if is_incremental() %}
    -- This filter is only applied on incremental runs.
    -- {{ this }} refers to the existing table in the warehouse.
    where order_date > (select coalesce(max(order_date), '1900-01-01') from {{ this }})
{% endif %}
