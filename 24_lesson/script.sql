CREATE TABLE kafka_table
(
    message String
)
ENGINE = MergeTree 
ORDER BY message;


CREATE TABLE kafka_table_queue
(
    message String
)
ENGINE = Kafka
SETTINGS 
    kafka_broker_list = 'kafka:9092', 
    kafka_group_name = 'kafka_group_name',
    kafka_topic_list = 'message-topic', 
    kafka_format = 'CSV',
    kafka_num_consumers = 1, 
    kafka_skip_broken_messages = 10,
    kafka_row_delimiter = '\n',
    kafka_thread_per_consumer = 0;


CREATE MATERIALIZED VIEW kafka_table_queue_mv TO kafka_table
( 
    message String 
) AS SELECT message FROM kafka_table_queue;
