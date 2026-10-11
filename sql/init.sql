CREATE DATABASE IF NOT EXISTS hw2;
CREATE TABLE IF NOT EXISTS hw2.transactions
(
    row_id UInt64,
    transaction_time DateTime('UTC') CODEC(Delta, ZSTD(1)),
    merch String CODEC(ZSTD(1)),
    cat_id LowCardinality(String),
    amount Decimal(18, 2) CODEC(ZSTD(1)),
    name_1 String CODEC(ZSTD(1)),
    name_2 String CODEC(ZSTD(1)),
    gender LowCardinality(String),
    street String CODEC(ZSTD(1)),
    one_city LowCardinality(String),
    us_state LowCardinality(String),
    post_code String,
    lat Float64,
    lon Float64,
    population_city UInt64,
    jobs LowCardinality(String),
    merchant_lat Float64,
    merchant_lon Float64,
    target UInt8
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(transaction_time)
ORDER BY (us_state, cat_id, transaction_time);

CREATE TABLE IF NOT EXISTS hw2.state_max(
    us_state LowCardinality(String),
    max_transaction AggregateFunction(max, Tuple(Decimal(18, 2), String))
    )
ENGINE = AggregatingMergeTree
ORDER BY us_state;

CREATE MATERIALIZED VIEW IF NOT EXISTS hw2.to_state_max
TO hw2.state_max
AS
SELECT
    us_state,
    maxState(tuple(amount, toString(cat_id))) AS max_transaction
FROM hw2.transactions
GROUP BY us_state;

-- Чтение сообщений из Kafka
CREATE TABLE IF NOT EXISTS hw2.kafka_transactions
(
    row_id UInt64,
    transaction_time String,
    merch String,
    cat_id String,
    amount String,
    name_1 String,
    name_2 String,
    gender String,
    street String,
    one_city String,
    us_state String,
    post_code String,
    lat String,
    lon String,
    population_city String,
    jobs String,
    merchant_lat String,
    merchant_lon String,
    target String
)
ENGINE = Kafka
SETTINGS
    kafka_broker_list = 'kafka:9092',
    kafka_topic_list = 'transactions',
    kafka_group_name = 'clickhouse_hw2',
    kafka_format = 'JSONEachRow',
    kafka_num_consumers = 1,
    kafka_max_block_size = 65536;

-- Перенос
CREATE MATERIALIZED VIEW IF NOT EXISTS hw2.kafka_to_transactions
TO hw2.transactions
AS
SELECT
    row_id,
    toDateTime(transaction_time, 'UTC') AS transaction_time,
    merch,
    cat_id,
    toDecimal64(amount, 2) AS amount,
    name_1,
    name_2,
    gender,
    street,
    one_city,
    us_state,
    post_code,
    toFloat64(lat) AS lat,
    toFloat64(lon) AS lon,
    toUInt64(population_city) AS population_city,
    jobs,
    toFloat64(merchant_lat) AS merchant_lat,
    toFloat64(merchant_lon) AS merchant_lon,
    toUInt8(target) AS target
FROM hw2.kafka_transactions;