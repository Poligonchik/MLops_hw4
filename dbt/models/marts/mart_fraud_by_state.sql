select
    us_state,
    count() as transaction_count,
    countIf(target = 1) as fraud_count,

    round(100 * countIf(target = 1) / count(), 2) as fraud_rate,
    uniqExact(tuple(name_1, name_2)) as customer_count,
    uniqExact(merch) as merch_count,
    sum(amount) as total_amount,
    sumIf(amount, target = 1) as fraud_amount

from {{ ref('stg_transactions') }}

group by us_state