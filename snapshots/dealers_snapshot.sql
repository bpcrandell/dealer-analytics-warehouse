{#
    SCD2 history for the dealer master.

    dbt's timestamp snapshot strategy watches `updated_at`. Each time a dealer's
    attributes change and the snapshot is re-run, dbt closes the old version
    (sets dbt_valid_to) and opens a new one, so we keep full history of group,
    region, carrier, and status changes over time.
#}
{% snapshot dealers_snapshot %}
{{
    config(
        target_schema='snapshots',
        unique_key='dealer_id',
        strategy='timestamp',
        updated_at='updated_at'
    )
}}
select * from {{ ref('stg_dealers') }}
{% endsnapshot %}
