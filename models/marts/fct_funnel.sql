{#
    Funnel fact at lead grain: one row per lead, enriched with whether it was
    quoted and bound. This is the spine for conversion analytics.
#}
with leads as (
    select * from {{ ref('stg_leads') }}
),
quotes as (
    select * from {{ ref('stg_quotes') }}
),
policies as (
    select * from {{ ref('stg_policies') }}
)

select
    l.lead_id,
    l.dealer_id,
    l.lead_source,
    l.department,
    cast(l.created_at as date)        as lead_date,
    q.quote_id,
    q.monthly_premium                 as quote_monthly_premium,
    cast(q.quoted_at as date)         as quote_date,
    p.policy_id,
    p.term_months,
    p.monthly_premium                 as policy_monthly_premium,
    cast(p.bound_at as date)          as bound_date,
    (q.quote_id is not null)          as is_quoted,
    (p.policy_id is not null)         as is_bound
from leads l
left join quotes   q on l.lead_id = q.lead_id
left join policies p on l.lead_id = p.lead_id
