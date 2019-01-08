# Clickhouse cluster on Docker

    docker-compose up
    
    docker run -it --rm yandex/clickhouse-client --host $ip --port 9012 --multiline

    with
        arrayMap(i -> concat(ProfileEvents.Names[i],'='),arrayEnumerate(ProfileEvents.Names)) as p,
        arrayMap(i -> concat(p[i],toString(ProfileEvents.Values[i])), arrayEnumerate(ProfileEvents.Values)) as profile
    select 
        hostName(),
        type,
        query,
        is_initial_query,
        thread_numbers,
        profile
    from system.query_log_all 
    where 
        initial_query_id in (select query_id from system.query_log where query like '% shard dist %' and is_initial_query=1 and type in (2) order by query_start_time desc limit 1)
        and type in (2,3,4)
    order by query_start_time asc;