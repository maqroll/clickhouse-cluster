-- load parquet file into temporary table
clickhouse client --external --structure "sku_art String, fecha_hora_desde DateTime, fecha_hora_hasta Nullable(DateTime), precio Float" --file=000000_0 --name=prices --format=Parquet -q "select count(*) from prices"
