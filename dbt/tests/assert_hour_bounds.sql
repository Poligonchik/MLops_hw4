-- Проверка границ часов
select * from {{ ref('stg_transactions') }}
where t_hour < 0 or t_hour > 23