{#
    Generate a date spine (one row per day between two dates).
    Useful for time-series reports where you need "zero" rows for empty days.

    Demonstrates Jinja loops + variables.

    Usage:
        {{ generate_date_spine('2024-01-01', '2024-01-07') }}
#}

{% macro generate_date_spine(start_date, end_date) %}
    with dates as (
        {# Jinja variables + a loop that unrolls into UNION ALL statements #}
        {% for i in range(31) %}
            {% if loop.first %}
                select dateadd(day, {{ i }}, cast('{{ start_date }}' as date)) as day
            {% else %}
                union all
                select dateadd(day, {{ i }}, cast('{{ start_date }}' as date))
            {% endif %}
        {% endfor %}
    )
    select day from dates
    where day <= cast('{{ end_date }}' as date)
{% endmacro %}
