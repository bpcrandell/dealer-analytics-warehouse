with source as (
    select * from {{ ref('raw_leads') }}
)

select
    cast(lead_id as integer)      as lead_id,
    cast(dealer_id as integer)    as dealer_id,
    lead_source,
    department,
    status,
    cast(created_at as timestamp) as created_at
from source
