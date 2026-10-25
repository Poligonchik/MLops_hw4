select
    t_date,
    us_state,
    count() as transaction_count,
    sum(amount) as total_amount,
    round(avg(amount), 2) as avg_amount,
    quantileExact(0.95)(toFloat64(amount)) as amount_95,

    round(100 * countIf(amount_bucket = 'LARGE') / count(), 2) as large_transaction

from {{ ref('stg_transactions') }}

group by
    t_date,
    us_state