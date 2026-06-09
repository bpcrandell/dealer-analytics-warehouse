-- Data integrity: every bound policy must trace back to a quote.
-- Returns offending rows; the test passes when zero rows come back.
select
    p.policy_id
from {{ ref('stg_policies') }} p
left join {{ ref('stg_quotes') }} q on p.quote_id = q.quote_id
where q.quote_id is null
