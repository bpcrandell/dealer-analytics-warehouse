{#
    Dealer performance by month: the funnel rolled up with the conversion
    metrics the Dealer Success team would actually track.
#}
with funnel as (
    select * from {{ ref('fct_funnel') }}
),
dealers as (
    select * from {{ ref('dim_dealers') }} where is_current
),
dates as (
    select * from {{ ref('dim_dates') }}
)

select
    f.dealer_id,
    d.dealer_name,
    d.dealer_group,
    d.region,
    d.state,
    d.fulfillment_carrier,
    d.status,
    dd.year_month,
    count(*)                                                          as leads,
    sum(case when f.is_quoted then 1 else 0 end)                      as quotes,
    sum(case when f.is_bound then 1 else 0 end)                       as policies,
    round(sum(case when f.is_quoted then 1 else 0 end) * 1.0
          / count(*), 3)                                              as lead_to_quote_rate,
    round(sum(case when f.is_bound then 1 else 0 end) * 1.0
          / nullif(sum(case when f.is_quoted then 1 else 0 end), 0), 3) as quote_to_policy_rate,
    round(sum(case when f.is_bound then 1 else 0 end) * 1.0
          / count(*), 3)                                              as lead_to_policy_rate,
    sum(case when f.is_bound
             then f.policy_monthly_premium * f.term_months
             else 0 end)                                              as bound_premium_value
from funnel f
join dates dd on f.lead_date = dd.date_day
left join dealers d on f.dealer_id = d.dealer_id
group by 1, 2, 3, 4, 5, 6, 7, 8
