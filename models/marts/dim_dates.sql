{#
    Date dimension built with a DuckDB date spine (no external packages).
#}
with spine as (
    select cast(g as date) as date_day
    from generate_series(
        timestamp '2024-01-01',
        timestamp '2026-01-01',
        interval '1 day'
    ) as s(g)
)

select
    date_day,
    cast(strftime(date_day, '%Y%m%d') as integer) as date_key,
    extract(year from date_day)                   as year,
    extract(month from date_day)                  as month,
    strftime(date_day, '%Y-%m')                   as year_month,
    extract(quarter from date_day)                as quarter,
    extract(dow from date_day)                    as day_of_week,
    dayname(date_day)                             as day_name,
    (extract(dow from date_day) in (0, 6))        as is_weekend
from spine
