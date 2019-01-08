attach table if not exists default.file_engine_table(
	name String, 
	value UInt64
) ENGINE=File(JSONEachRow);