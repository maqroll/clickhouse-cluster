DROP TABLE IF EXISTS test_db.companies_dist
ON CLUSTER test_cluster;

DROP TABLE IF EXISTS test_db.companies_shard 
ON CLUSTER test_cluster;

drop table if exists system.query_log_all 
on cluster all_cluster;

DROP TABLE IF EXISTS test_db.events_dist
ON CLUSTER test_cluster;

DROP TABLE IF EXISTS test_db.events_shard 
ON CLUSTER test_cluster;

DROP TABLE IF EXISTS view_db.events_one_shard
ON CLUSTER test_cluster;

DROP TABLE IF EXISTS test_db.dict
ON CLUSTER test_cluster;

DROP TABLE IF EXISTS test_db.units_sold_shard
on CLUSTER all_cluster;

DROP TABLE IF EXISTS test_db.impacts_shard
on CLUSTER all_cluster;

drop database if exists view_db;
drop database if exists test_db;