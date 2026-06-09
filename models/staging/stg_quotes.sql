with source as (
    select * from {{ ref('raw_quotes') }}
)

select
    cast(quote_id as integer)              as quote_id,
    cast(lead_id as integer)               as lead_id,
    cast(dealer_id as integer)             as dealer_id,
    carrier,
    cast(monthly_premium as decimal(10,2)) as monthly_premium,
    cast(quoted_at as timestamp)           as quoted_at
from source
