insert into test_db.units_sold_shard(company_id,product_id,sold) values (2,2,2),(2,2,5),(2,2,8);

# the second case never will get compacted.... you always with need the extra sum
insert into test_db.impacts_shard(partition_id,company_id,product_id,sold) values (1,1,1,1),(1,1,1,1);
insert into test_db.impacts_shard(partition_id,company_id,product_id,sold) values (1,2,2,1),(2,2,2,1);