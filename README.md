# Clickhouse cluster on k8s
	
    kubectl create namespace ch
    make zk ch1 ch2 ch3 ch4 ch5
    docker run -it --rm yandex/clickhouse-client --host `ipconfig getifaddr en0` --port 30012 --multiline
    make stop

# Clickhouse cluster on docker (before)
    See docker tag.
    
Be aware of [ClickHouse operator for kubernetes](https://www.altinity.com/blog/2019/4/9/altinity-clickhouse-operator-for-kubernetes).
