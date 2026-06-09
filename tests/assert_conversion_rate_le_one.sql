-- Sanity check on the headline metric: a conversion rate can never exceed 1.
-- Returns offending rows; the test passes when zero rows come back.
select
    dealer_id,
    year_month,
    lead_to_policy_rate
from {{ ref('mart_dealer_performance') }}
where lead_to_policy_rate > 1
