{#
    SCD2 dealer dimension, built from the snapshot.
    One row per dealer *version*; `is_current` flags the live record.
#}
with snap as (
    select * from {{ ref('dealers_snapshot') }}
)

select
    md5(cast(dealer_id as varchar) || '|' || cast(dbt_valid_from as varchar)) as dealer_key,
    dealer_id,
    dealer_name,
    dealer_group,
    region,
    state,
    fulfillment_carrier,
    status,
    implementation_date,
    dbt_valid_from                                          as valid_from,
    coalesce(dbt_valid_to, cast('9999-12-31' as timestamp)) as valid_to,
    (dbt_valid_to is null)                                  as is_current
from snap
