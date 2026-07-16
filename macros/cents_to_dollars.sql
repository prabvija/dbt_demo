{#
    A tiny reusable macro. Call it in SQL like:
        select {{ cents_to_dollars('amount_cents') }} as amount_usd
    dbt compiles it to:
        select (amount_cents / 100.0)::numeric(16,2) as amount_usd

    Why macros?
      • DRY — write the logic once
      • Consistent rounding/casting across the whole project
      • Show attendees the compiled SQL in target/compiled/ — the "aha" moment
#}

{% macro cents_to_dollars(column_name, precision=2) %}
    ({{ column_name }} / 100.0)::numeric(16, {{ precision }})
{% endmacro %}
