-- CONCEPT: Jinja loops unroll into SQL.
-- One loop generates N columns — add a status, no SQL edits needed.

{% set statuses = ['completed', 'returned', 'cancelled'] %}

select
    customer_id,
    {% for s in statuses %}
    sum(case when status = '{{ s }}' then 1 else 0 end) as {{ s }}_count
    {%- if not loop.last %},{% endif %}
    {% endfor %}
from {{ ref('stg_orders') }}
group by customer_id
