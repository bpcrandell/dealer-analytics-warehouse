"""
Generate a synthetic auto-insurance dealer-channel dataset for the warehouse.

The shape mirrors an embedded-insurance dealer funnel:
    calls  ->  leads  ->  quotes  ->  policies
with a dealer master that carries the kind of attributes (group, region,
fulfillment carrier, go-live date, status) you actually model in this domain.

Everything here is fabricated with a fixed random seed, so the data is
reproducible and contains no real customer, dealer, or company information.

Run:  python scripts/generate_seed_data.py
Output: CSV files in ../seeds/
"""
import csv
import os
import random
from datetime import date, datetime, timedelta

random.seed(42)

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SEEDS = os.path.join(ROOT, "seeds")
os.makedirs(SEEDS, exist_ok=True)

# ---------------------------------------------------------------- dealers ----
GROUPS = ["Great Lakes Auto Group", "Sunbelt Motors", "Pacific Crest Dealers",
          "Heartland Automotive", "Independent"]
REGIONS = {"Midwest": ["MI", "OH", "IL", "IN", "WI"],
           "South": ["TX", "FL", "GA", "NC", "TN"],
           "West": ["CA", "WA", "AZ", "CO", "NV"],
           "Northeast": ["NY", "PA", "NJ", "MA", "CT"]}
CARRIERS = ["Carrier A", "Carrier B", "In-House Agency"]
BRANDS = ["Ford", "Chevrolet", "Toyota", "Honda", "Kia", "Hyundai", "Nissan",
          "Subaru", "Jeep", "Mazda", "GMC", "Volkswagen"]
CITIES = ["Detroit", "Austin", "Sacramento", "Cleveland", "Tampa", "Denver",
          "Albany", "Charlotte", "Phoenix", "Madison", "Newark", "Nashville",
          "Seattle", "Columbus", "Dallas", "Atlanta", "Reno", "Hartford"]

def rand_date(start, end):
    delta = (end - start).days
    return start + timedelta(days=random.randint(0, delta))

dealers = []
for i in range(1, 61):
    region = random.choice(list(REGIONS))
    state = random.choice(REGIONS[region])
    impl = rand_date(date(2023, 1, 1), date(2024, 10, 1))
    status = random.choices(["active", "paused", "churned"], weights=[80, 12, 8])[0]
    dealers.append({
        "dealer_id": i,
        "dealer_name": f"{random.choice(CITIES)} {random.choice(BRANDS)}",
        "dealer_group": random.choice(GROUPS),
        "region": region,
        "state": state,
        "fulfillment_carrier": random.choice(CARRIERS),
        "status": status,
        "implementation_date": impl.isoformat(),
        "updated_at": datetime(2025, 12, 31, 12, 0, 0).isoformat(sep=" "),
    })

# ------------------------------------------------------------------ leads ----
SOURCES = ["Call Center", "Web", "QR Code"]
DEPARTMENTS = ["Sales", "Service", "F&I"]
LEAD_STATUS = ["new", "working", "closed"]

leads, quotes, policies = [], [], []
lead_id = quote_id = policy_id = 0

for _ in range(6000):
    d = random.choice(dealers)
    impl = date.fromisoformat(d["implementation_date"])
    earliest = max(impl, date(2025, 1, 1))
    if earliest > date(2025, 12, 20):
        continue
    created = rand_date(earliest, date(2025, 12, 20))
    lead_id += 1
    leads.append({
        "lead_id": lead_id,
        "dealer_id": d["dealer_id"],
        "lead_source": random.choice(SOURCES),
        "department": random.choices(DEPARTMENTS, weights=[60, 25, 15])[0],
        "status": random.choice(LEAD_STATUS),
        "created_at": datetime.combine(created, datetime.min.time())
                      .replace(hour=random.randint(8, 19), minute=random.randint(0, 59))
                      .isoformat(sep=" "),
    })
    # ~55% of leads get a quote
    if random.random() < 0.55:
        quoted = created + timedelta(days=random.randint(0, 5))
        carrier = random.choice(CARRIERS)
        monthly = round(random.uniform(95, 310), 2)
        quote_id += 1
        quotes.append({
            "quote_id": quote_id,
            "lead_id": lead_id,
            "dealer_id": d["dealer_id"],
            "carrier": carrier,
            "monthly_premium": monthly,
            "quoted_at": datetime.combine(quoted, datetime.min.time())
                          .replace(hour=random.randint(8, 19), minute=random.randint(0, 59))
                          .isoformat(sep=" "),
        })
        # ~40% of quotes convert to a bound policy
        if random.random() < 0.40:
            bound = quoted + timedelta(days=random.randint(0, 10))
            term = random.choice([6, 12])
            policy_id += 1
            policies.append({
                "policy_id": policy_id,
                "quote_id": quote_id,
                "lead_id": lead_id,
                "dealer_id": d["dealer_id"],
                "carrier": carrier,
                "monthly_premium": monthly,
                "term_months": term,
                "bound_at": datetime.combine(bound, datetime.min.time())
                             .replace(hour=random.randint(8, 19), minute=random.randint(0, 59))
                             .isoformat(sep=" "),
            })

# ------------------------------------------------------------------ calls ----
OUTCOMES = ["connected", "voicemail", "missed"]
calls = []
for cid in range(1, 10001):
    d = random.choice(dealers)
    call_day = rand_date(date(2025, 1, 1), date(2025, 12, 20))
    calls.append({
        "call_id": cid,
        "dealer_id": d["dealer_id"],
        "outcome": random.choices(OUTCOMES, weights=[55, 25, 20])[0],
        "duration_seconds": random.randint(15, 900),
        "call_at": datetime.combine(call_day, datetime.min.time())
                    .replace(hour=random.randint(8, 19), minute=random.randint(0, 59))
                    .isoformat(sep=" "),
    })

# ------------------------------------------------------------------ write ----
def write_csv(name, rows):
    path = os.path.join(SEEDS, name)
    with open(path, "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=list(rows[0].keys()))
        w.writeheader()
        w.writerows(rows)
    print(f"  {name:24} {len(rows):>6} rows")

print("Writing seeds:")
write_csv("raw_dealers.csv", dealers)
write_csv("raw_leads.csv", leads)
write_csv("raw_quotes.csv", quotes)
write_csv("raw_policies.csv", policies)
write_csv("raw_calls.csv", calls)
print("Done.")
