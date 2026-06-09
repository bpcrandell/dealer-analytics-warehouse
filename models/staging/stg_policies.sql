with source as (
    select * from {{ ref('raw_policies') }}
)

select
    cast(policy_id as integer)             as policy_id,
    cast(quote_id as integer)              as quote_id,
    cast(lead_id as integer)               as lead_id,
    cast(dealer_id as integer)             as dealer_id,
    carrier,
    cast(monthly_premium as decimal(10,2)) as monthly_premium,
    cast(term_months as integer)           as term_months,
    cast(bound_at as timestamp)            as bound_at
from source
