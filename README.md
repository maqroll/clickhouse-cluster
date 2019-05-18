# Clickhouse cluster on k8s
	
    kubectl create namespace ch
    make k8s
    docker run -it --rm yandex/clickhouse-client --host `ipconfig getifaddr en0` --port 30012 --multiline
    make stop

# Clickhouse cluster on docker (before)
    See docker tag.