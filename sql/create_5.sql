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