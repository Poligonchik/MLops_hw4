-- Соответствие группе проверка
select * from {{ ref('stg_transactions') }}
where 
    (amount < 50 and amount_bucket != 'SMALL')
    or (amount >= 50 and amount < 200 and amount_bucket != 'MEDIUM')
    or (amount >= 200 and amount_bucket != 'LARGE')
