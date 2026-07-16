-- MART: a dimension table (one row per customer) for BI consumption.
-- Materialized as a table (see dbt_project.yml) for query speed.

with customers as (
    select * from {{ ref('stg_customers') }}
),

orders as (
    select * from {{ ref('stg_orders') }}
),

customer_orders as (
    select
        customer_id,
        count(*)                                     as total_orders,
        sum(case when status = 'completed'
                 then amount_usd else 0 end)         as lifetime_value_usd,
        min(order_date)                              as first_order_date,
        max(order_date)                              as most_recent_order_date
    from orders
    group by customer_id
)

select
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    c.country,
    c.signup_date,
    coalesce(co.total_orders, 0)          as total_orders,
    coalesce(co.lifetime_value_usd, 0)    as lifetime_value_usd,
    co.first_order_date,
    co.most_recent_order_date
from customers c
left join customer_orders co using (customer_id)
