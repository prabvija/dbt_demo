-- Mart: daily sales totals by product category. Consumed by BI.

with orders as (
    select * from {{ ref('int_orders_enriched') }}
    where status = 'completed'
)

select
    order_date,
    category,
    count(distinct order_id) as orders,
    sum(amount_usd)          as revenue_usd
from orders
group by order_date, category
order by order_date, category
