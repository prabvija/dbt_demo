-- Singular test: fails if any completed order has a non-positive amount.
-- Any SELECT that returns rows = test failure.

select
    order_id,
    amount_usd
from {{ ref('stg_orders') }}
where status = 'completed'
  and amount_usd <= 0
