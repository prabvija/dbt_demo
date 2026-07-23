-- Staging: one row per order. Rename and cast only — no joins.
with source as (
    select * from {{ source('raw', 'raw_orders') }}
)

select
    order_id,
    customer_id,
    product_id,
    cast(order_date as date) as order_date,
    status,
    cast(amount as double)   as amount_usd
from source
