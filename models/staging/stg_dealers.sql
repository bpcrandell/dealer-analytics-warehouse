with source as (
    select * from {{ ref('raw_dealers') }}
)

select
    cast(dealer_id as integer)        as dealer_id,
    dealer_name,
    dealer_group,
    region,
    state,
    fulfillment_carrier,
    lower(status)                     as status,
    cast(implementation_date as date) as implementation_date,
    cast(updated_at as timestamp)     as updated_at
from source
