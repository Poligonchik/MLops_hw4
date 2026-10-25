-- Этот я из условий оставила тоже
SELECT * FROM {{ ref('stg_transactions') }} WHERE amount < 0