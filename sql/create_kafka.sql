-- Kafka table
drop table if exists atopic;
CREATE TABLE if not exists atopic (
    timestamp UInt64,
    app String,
    level String,
    message String
  ) ENGINE = Kafka SETTINGS kafka_broker_list = 'cfkafka.ch.svc.cluster.local:29092',
                            kafka_topic_list = 'atopic',
                            kafka_group_name = 'group1',
                            kafka_format = 'JSONEachRow',
                            kafka_max_block_size = 100,
                            kafka_num_consumers = 1;

-- Last 5 minutes errors persistent store
drop table if exists errors_last_5_minutes;
CREATE TABLE IF NOT EXISTS errors_last_5_minutes (
    timestamp DateTime,
    app String,
    level String,
    message String
) ENGINE = MergeTree()
PARTITION BY app
ORDER BY (timestamp)
TTL timestamp + INTERVAL 5 MINUTE
SETTINGS index_granularity=8192;     

-- Last 5 minutes errors group by app
drop table if exists errors_last_5_minutes_by_app;
CREATE TABLE IF NOT EXISTS errors_last_5_minutes_by_app (
    timestamp DateTime,
    app String,
    errors AggregateFunction(count,UInt64,String,String,String)
) ENGINE = AggregatingMergeTree()
PARTITION BY app
ORDER BY (timestamp)
TTL timestamp + INTERVAL 5 MINUTE
SETTINGS index_granularity=8192;

-- View to errors_last_5_minutes
drop table if exists toPersist;
CREATE MATERIALIZED VIEW if not exists toPersist 
TO errors_last_5_minutes
AS SELECT toDateTime(timestamp) as timestamp,app,level,message
FROM atopic where level=='ERROR';                       

-- View to errors_last_5_minutes_by_app
drop table if exists toPersistGroup;
CREATE MATERIALIZED VIEW if not exists toPersistGroup 
TO errors_last_5_minutes_by_app
AS SELECT
    toDateTime(timestamp) as timestamp,
    app,
    countState(*)    AS errors
FROM atopic
where level=='ERROR'
GROUP BY timestamp,app;

-- Sample query
select app,countMerge(errors) 
from errors_last_5_minutes_by_app 
where timestamp>subtractMinutes(now(),5) 
group by app;