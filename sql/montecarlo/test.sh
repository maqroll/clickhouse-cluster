for f in `ls *.q`; do 
	echo $f; 
	echo '-------------'; 
	time docker run -it --rm yandex/clickhouse-client:19.9.2.4 --host `ipconfig getifaddr en0` --port 30011 --multiline --multiquery --query "`cat $f`"; 
done
