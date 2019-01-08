create database if not exists test_db on cluster all_with_query_cluster;
create database if not exists view_db on cluster test_cluster;

CREATE TABLE IF NOT EXISTS test_db.events_shard ON CLUSTER test_cluster(
  event_date           Date DEFAULT toDate(now()),
  company_id           UInt32,
  product_id           UInt32
) ENGINE=ReplicatedMergeTree(
    '/clickhouse/tables/{shard}/events_shard', '{replica}',
    event_date,
    (company_id),
    8192
);

/* Can't use AS because we are creating  this table in query nodes */
CREATE TABLE IF NOT EXISTS test_db.events_dist
ON CLUSTER all_with_query_cluster (
  event_date           Date DEFAULT toDate(now()),
  company_id           UInt32,
  product_id           UInt32
) ENGINE = Distributed(test_cluster, test_db, events_shard, rand());

CREATE TABLE IF NOT EXISTS test_db.units_sold_shard
ON CLUSTER all_cluster (
  event_date          DateTime DEFAULT now(),
  company_id          UInt32,
  product_id          UInt32,
  sold               UInt32
) ENGINE = ReplacingMergeTree(event_date)
PARTITION BY toDate(event_date)
ORDER BY (company_id,product_id)
SETTINGS index_granularity=8192;

CREATE TABLE IF NOT EXISTS test_db.impacts_shard
ON CLUSTER all_cluster (
  partition_id        UInt32,
  company_id          UInt32,
  product_id          UInt32,
  sold                UInt32
) ENGINE = SummingMergeTree((sold))
PARTITION BY partition_id
ORDER BY (company_id,product_id)
SETTINGS index_granularity=8192;

CREATE TABLE IF NOT EXISTS test_db.user_activity_shard
ON CLUSTER all_cluster (
  user_id UInt64,
  page_views UInt8,
  duration UInt8,
  sign Int8
)
ENGINE CollapsingMergeTree(sign)
ORDER BY user_id;

create table if not exists system.query_log_all 
on cluster all_with_query_cluster as system.query_log 
ENGINE = Distributed(all_cluster,system,query_log);

/* Can't use AS because we are creating  this table in query nodes */
CREATE TABLE IF NOT EXISTS test_db.companies_shard 
ON CLUSTER test_cluster(
  company_id           UInt32,
  description          String
) ENGINE=ReplicatedMergeTree(
    '/clickhouse/tables/{shard}/companies_shard', '{replica}')
PARTITION BY company_id%10
ORDER BY (company_id);

CREATE TABLE IF NOT EXISTS test_db.companies_dist
ON CLUSTER all_with_query_cluster (
  company_id           UInt32,
  description          String
) ENGINE = Distributed(test_cluster, test_db, companies_shard, rand());

CREATE VIEW IF NOT EXISTS view_db.events_one_shard on cluster test_cluster as select * from test_db.events_shard where company_id=1;

CREATE TABLE IF NOT EXISTS test_db.dict
ON CLUSTER test_cluster (
    Key UInt64,
    Value UInt64
)
ENGINE = Dictionary(dict_name);

/* a part a row: totally ineffective */
CREATE TABLE IF NOT EXISTS test_db.economics
ENGINE = MergeTree()
PARTITION BY toYYYYMM(toDate(date))
ORDER BY date AS
SELECT *
FROM file('file.csv', 'CSV', 'date String, pce Float64, pop UInt64, psavert Float64, unempmed Float64, unemploy UInt64');

CREATE TABLE IF NOT EXISTS test_db.level_zero_shard
ON CLUSTER one_two_cluster (
  event_date          Date DEFAULT toDate(now()),
  company_id          UInt32,
  product_id          UInt32,
  sold               UInt32
) ENGINE = MergeTree()
PARTITION BY toYYYYMM(event_date)
ORDER BY (company_id,product_id)
SETTINGS index_granularity=8192;

CREATE TABLE IF NOT EXISTS test_db.level_one_shard
ON CLUSTER one_two_cluster (
  event_date          Date DEFAULT toDate(now()),
  company_id          UInt32,
  product_id          UInt32,
  sold               UInt32
) ENGINE = MergeTree()
PARTITION BY toYYYYMM(event_date)
ORDER BY (company_id,product_id)
SETTINGS index_granularity=8192;

CREATE TABLE IF NOT EXISTS test_db.level_zero
ON CLUSTER three_cluster (
  event_date          Date DEFAULT toDate(now()),
  company_id          UInt32,
  product_id          UInt32,
  sold               UInt32
) ENGINE = Distributed(one_two_cluster, test_db, level_zero_shard);

/* Name intentional */
CREATE TABLE IF NOT EXISTS test_db.level_zero
ON CLUSTER four_cluster (
  event_date          Date DEFAULT toDate(now()),
  company_id          UInt32,
  product_id          UInt32,
  sold               UInt32
) ENGINE = Distributed(one_two_cluster, test_db, level_one_shard);
