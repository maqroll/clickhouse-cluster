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