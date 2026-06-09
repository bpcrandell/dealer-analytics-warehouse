with source as (
    select * from {{ ref('raw_calls') }}
)

select
    cast(call_id as integer)          as call_id,
    cast(dealer_id as integer)        as dealer_id,
    outcome,
    cast(duration_seconds as integer) as duration_seconds,
    cast(call_at as timestamp)        as call_at
from source
