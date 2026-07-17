-- CONCEPT: Call a macro from your SQL. Macros = reusable Jinja functions.
-- See macros/cents_to_dollars.sql for the definition.

select
    order_id,
    amount_usd                                       as amount_original,
    {{ cents_to_dollars('(amount_usd * 100)') }}    as amount_via_macro
from {{ ref('stg_orders') }}
limit 5