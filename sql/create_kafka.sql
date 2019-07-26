drop table if exists atopic;
CREATE TABLE if not exists atopic (
    timestamp UInt64,
    level String,
    message String
  ) ENGINE = Kafka SETTINGS kafka_broker_list = 'cfkafka.ch.svc.cluster.local:29092',
                            kafka_topic_list = 'atopic',
                            kafka_group_name = 'group1',
                            kafka_format = 'JSONEachRow',
                            kafka_max_block_size = 100000,
                            kafka_num_consumers = 1;

drop table if exists persist;
CREATE TABLE IF NOT EXISTS persist
as atopic ENGINE = MergeTree()
PARTITION BY toYYYYMM(toDate(timestamp))
ORDER BY (timestamp)
SETTINGS index_granularity=8192;     

drop table if exists toPersist;
CREATE MATERIALIZED VIEW if not exists toPersist TO persist
    AS SELECT timestamp,level,message
    FROM atopic;                       