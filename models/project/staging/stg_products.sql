-- Staging: one row per product. Clean casts and column names.
with source as (
    select * from {{ source('raw', 'raw_products') }}
)

select
    product_id,
    product_name,
    category,
    cast(unit_price as double) as unit_price
from source
