{{
    config(
        materialized='view',
        tags=['staging', 'users']
    )
}}

/*
    Staging model for users table.

    Data Quality Considerations:
    - Soft deletes: Use deleted_at IS NULL for active users
    - NULL country_code: Some users have missing country data
    - seller_tier: NULL for pure buyers (user_type = 'buyer')

    This is a STARTER MODEL - candidates should enhance with:
    - Additional data quality checks
    - Proper type casting
    - Handling of edge cases
*/

with source as (
    select * from {{ source('raw_marketplace', 'users') }}
),

renamed as (
    select
        -- Primary key
        id as user_id,

        -- User identifiers
        email,
        username,

        -- User classification
        user_type,

        -- Personal info
        first_name,
        last_name,
        coalesce(country_code, 'XX') as country_code,  -- Default for unknown

        -- Seller attributes (NULL for buyers)
        seller_tier,
        seller_rating,

        -- Status flags
        is_active,
        deleted_at is not null as is_deleted,

        -- Timestamps
        created_at,
        updated_at,
        deleted_at

    from source
)

select * from renamed
