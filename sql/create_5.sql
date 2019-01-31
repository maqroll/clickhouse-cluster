create database if not exists view_db;
CREATE TABLE IF NOT EXISTS view_db.events_one (
  event_date           Date DEFAULT toDate(now()),
  company_id           UInt32,
  product_id           UInt32
) ENGINE = Distributed(test_cluster, view_db, events_one_shard);

create database if not exists test_db;

CREATE TABLE IF NOT EXISTS test_db.units_sold (
 event_date          DateTime DEFAULT now(),
  company_id          UInt32,
  product_id          UInt32,
  sold               UInt32	
) ENGINE = Distributed(all_cluster, test_db, units_sold_shard);

create table if not exists test_db.impacts (
  partition_id        UInt32,
  company_id          UInt32,
  product_id          UInt32,
  sold                UInt32	
) ENGINE = Distributed(all_cluster, test_db, impacts_shard);

/* Careful: FINAL aggregation on Distributed is executed after FINAL execution on local nodes */
create table if not exists test_db.user_activity (
  user_id UInt64,
  page_views UInt8,
  duration UInt8,
  sign Int8
) ENGINE = Distributed(all_cluster, test_db, user_activity_shard);

/* ERROR: Distributed on Distributed is not supported */
CREATE TABLE IF NOT EXISTS test_db.level_zero (
  event_date          Date DEFAULT toDate(now()),
  company_id          UInt32,
  product_id          UInt32,
  sold               UInt32
) ENGINE = Distributed(three_four_cluster, test_db, level_zero);

CREATE TABLE IF NOT EXISTS cascade_db.last (
  event_date          Date DEFAULT toDate(now()),
  company_id          UInt32,
  product_id          UInt32,
  sold               UInt32
) ENGINE = MergeTree()
PARTITION BY toYYYYMM(event_date)
ORDER BY (company_id,product_id)
SETTINGS index_granularity=8192;

CREATE TABLE IF NOT EXISTS cascade_db.first AS cascade_db.last ENGINE = MergeTree()
PARTITION BY toYYYYMM(event_date)
ORDER BY (company_id,product_id)
SETTINGS index_granularity=8192;

// Negative values get inserted ok in first but not in last
// last is not aligned with first
// UPDATE: Type mismatch for column company_id....
// Nor updates nor deletes get propagated through views.
CREATE MATERIALIZED VIEW IF NOT EXISTS cascade_db.first_to_last TO cascade_db.last AS select * from cascade_db.first;