select
    row_id,
    transaction_time,
    toDate(transaction_time) as t_date,
    toHour(transaction_time) as t_hour,
    -- Это я чтобы пакет использовать
    {{ dbt_date.day_of_week('transaction_time', isoweek=true) }} as day_of_week,
    trimBoth(merch) as merch,
    lowerUTF8(trimBoth(cat_id)) as cat_id,

    cast(amount as Decimal(18, 2)) as amount,
    {{ amount_bucket('amount') }} as amount_bucket,

    trimBoth(name_1) as name_1,
    trimBoth(name_2) as name_2,
    upperUTF8(trimBoth(gender)) as gender,
    upperUTF8(trimBoth(us_state)) as us_state,
    toUInt8(target) as target

from {{ source('raw', 'transactions') }}