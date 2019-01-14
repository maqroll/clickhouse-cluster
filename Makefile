q = docker run -it --rm yandex/clickhouse-client --host `ipconfig getifaddr en0` --port $1 --multiline --multiquery --query "`cat $2`"

clean:
	rm -rf ./ch*_volume/data/*
	rm -rf ./ch*_volume/flags/*
	rm -rf ./ch*_volume/format_schemas/*
	rm -rf ./ch*_volume/metadata/*
	rm -rf ./ch*_volume/status/*
	rm -rf ./ch*_volume/tmp/*
	rm -rf ./data/*
	rm -rf ./datalog/*

create: sql/create.sql
	$(call q, 9011, sql/create.sql)
	$(call q, 9015, sql/create_5.sql)

drop: sql/drop.sql
	$(call q, 9012, sql/drop.sql)
	$(call q, 9015, sql/drop_5.sql)

# Can't use remote(..) to insert on remote tables
# Nodes (1,2) & (1,3) get the same data (ReplicatedMergeTree)
populate: sql/populate_1.sql sql/populate_2.sql sql/populate_3.sql sql/populate_4.sql
	$(call q, 9011, sql/populate_1.sql)
	$(call q, 9012, sql/populate_2.sql)
	$(call q, 9013, sql/populate_3.sql)
	$(call q, 9014, sql/populate_4.sql)

# LEFT TABLE DISTRIBUTED -> DISTRIBUTED
# LEFT TABLE LOCAL -> LOCAL
# GLOBAL -> PUSH RIGHT TABLE
join: sql/join_dist_dist.sql sql/join_shard_shard.sql sql/join_dist_shard.sql sql/join_shard_dist.sql
	# merge(shard x dist) for all the nodes
	$(call q, 9011, sql/join_dist_dist.sql)

	# shard x shard in local -> empty
	$(call q, 9011, sql/join_shard_shard.sql)

	# merge(shard x shard) for all the nodes -> empty
	$(call q, 9011, sql/join_dist_shard.sql)
	
	# shard x dist in local
	$(call q, 9011, sql/join_shard_dist.sql)

global_join: 
	# dist -> push; merge(shard x push) for all the nodes
	$(call q, 9011, sql/global_join_dist_dist.sql)

	# shard x shard in local -> empty
	$(call q, 9011, sql/global_join_shard_shard.sql)

	# shard -> push; merge(shard x push) for all the nodes
	$(call q, 9011, sql/global_join_dist_shard.sql)
	
	# shard x dist in local
	$(call q, 9011, sql/global_join_shard_dist.sql)	

dict:
	$(call q, 9011, sql/dictionary.sql)

attach:
	$(call q, 9015, sql/attach_5.sql)

detach:
	$(call q, 9015, sql/detach_5.sql)

unemploy:
	$(call q, 9011, sql/unemploy.sql)

optimize:
	$(call q, 9011, sql/optimize.sql)

insert:
	$(call q, 9011, sql/insert.sql)
	$(call q, 9015, sql/insert_5.sql)

# ReplacingMergeTree doesn't return last inserted row (for the same version)
# Optimize change the result
last:
	$(call q, 9015, sql/last.sql)

impacts:
	$(call q, 9015, sql/impacts.sql)

# mutations
# https://www.altinity.com/blog/2018/10/16/updates-in-clickhouse
update:
	$(call q, 9011, sql/update.sql)


# AggregateFunctions
# Not that interesting!!
