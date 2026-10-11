SELECT
    us_state,
    tupleElement(maxMerge(max_transaction), 2) AS category,
    tupleElement(maxMerge(max_transaction), 1) AS max_amount
FROM hw2.state_max
GROUP BY us_state
ORDER BY us_state;