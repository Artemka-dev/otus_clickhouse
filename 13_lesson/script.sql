CREATE TABLE sales (
    id UInt32,
    product_id UInt32,
    quantity UInt32,
    price Float32,
    sale_date DateTime
) ENGINE = MergeTree()
PARTITION BY toYYYYMM(sale_date)
ORDER BY (sale_date, product_id, id);


INSERT INTO sales 
SELECT 
    number AS id,
    floor(rand() % 100) + 1 AS product_id,
    floor(rand() % 10) + 1 AS quantity, 
    (rand() % 1000) / 10 + 10 AS price,
    toDateTime('2024-01-01 00:00:00') + rand() % (360 * 24 * 3600) AS sale_date
FROM system.numbers 
LIMIT 10000;


ALTER TABLE sales ADD PROJECTION sales_projection (
    SELECT 
        product_id,
        sum(quantity) AS total_quantity,
        sum(quantity * price) AS total_sales
    GROUP BY product_id
);

ALTER TABLE sales MATERIALIZE PROJECTION sales_projection;



CREATE TABLE sales_aggregated (
    product_id UInt32,
    total_quantity UInt64,
    total_sales Float64
) ENGINE = SummingMergeTree()
ORDER BY product_id;

CREATE MATERIALIZED VIEW sales_mv TO sales_aggregated AS
SELECT 
    product_id,
    sum(quantity) AS total_quantity,
    sum(quantity * price) AS total_sales
FROM sales
GROUP BY product_id;


