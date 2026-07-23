-- Intermediate: join staging models. Not exposed to BI directly.
-- ref() everywhere so dbt builds the DAG.

with orders as (
    select * from {{ ref('stg_orders') }}
),

customers as (
    select * from {{ ref('stg_customers') }}
),

products as (
    select * from {{ ref('stg_products') }}
)

select
    o.order_id,
    o.order_date,
    o.status,
    o.amount_usd,
    c.customer_id,
    c.first_name || ' ' || c.last_name as customer_name,
    c.country,
    p.product_id,
    p.product_name,
    p.category
from orders o
left join customers c using (customer_id)
left join products  p using (product_id)
