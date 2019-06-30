-- HISTORICAL DATA TO TRAIN THE MODELS
drop table if exists tasks_train;
CREATE TABLE tasks_train (
	task_id UInt64, 
	project_id UInt64, 
	user_id UInt64, 
	technology_id UInt64, 
	estimated_hours UInt64, 
	real_hours Float64
) ENGINE = MergeTree() 
PARTITION BY project_id 
ORDER BY (project_id, user_id) 
SETTINGS index_granularity = 8192

-- SAMPLE DATA
-- seq 4000 |LC_NUMERIC=en_US  awk '{print $0","$0%3","$0%4","$0%5","$0%19","$0%19+((rand()-0.5)*3)}' | docker run -i --rm yandex/clickhouse-client:19.9.2.4 --host `ipconfig getifaddr en0` --port 30011 --query "insert into tasks_train FORMAT CSV"

-- MODELS: user & technology
drop table if exists tasks_model;
CREATE TABLE tasks_model 
ENGINE = MergeTree() 
PARTITION BY model 
ORDER BY tuple() AS 
SELECT
    1 as priority,
    user_id as user_id,
    technology_id as technology_id, 
    toFloat64(-1) as project_id,
    stochasticLinearRegressionState(0.001,.1,5,'SGD')(estimated_hours,real_hours) as model,
    now() as ts
FROM tasks_train
GROUP BY user_id,technology_id;

-- MODELS: user
INSERT INTO tasks_model 
SELECT
    2 as priority,
    user_id,
    -1 as technology_id, 
    -1 as project_id,
    stochasticLinearRegressionState(0.001,.1,5,'SGD')(estimated_hours,real_hours) as model, 
    now() as ts
FROM tasks_train
GROUP BY user_id;

-- MODELS: technology & project
INSERT INTO tasks_model 
SELECT
    3 as priority, 
    -1 as user_id,
    technology_id,
    project_id,
    stochasticLinearRegressionState(0.001,.1,5,'SGD')(estimated_hours,real_hours) as model, 
    now() as ts
FROM tasks_train
GROUP BY project_id,technology_id;

-- MODELS: technology
INSERT INTO tasks_model 
SELECT
    4 as priority,
    -1 as user_id,
    technology_id,
    -1 as project_id,
    stochasticLinearRegressionState(0.001,.1,5,'SGD')(estimated_hours,real_hours) as model, 
    now() as ts
FROM tasks_train
GROUP BY technology_id;

-- MODELS: overall
INSERT INTO tasks_model 
SELECT
    5 as priority,
    -1 as user_id,
    -1 as technology_id,
    -1 as project_id,
    stochasticLinearRegressionState(0.001,.1,5,'SGD')(estimated_hours,real_hours) as model, 
    now() as ts
FROM tasks_train;

drop table if exists tasks;
CREATE TABLE tasks (
	task_id UInt64, 
	project_id UInt64, 
	user_id UInt64, 
	technology_id UInt64, 
	estimated_hours Float64, 
	predicted_hours Float64
) ENGINE = MergeTree() 
PARTITION BY project_id 
ORDER BY (project_id, user_id) 
SETTINGS index_granularity = 8192;

-- new tasks
CREATE TEMPORARY TABLE temp_tasks as tasks;

-- predicted_hours is ignored
insert into temp_tasks values(1,1,1,1,30,40);

-- insert new tasks using the most appropiate and recent model
INSERT INTO tasks 
WITH (
	SELECT model
	FROM tasks_model m
	WHERE 
	(m.user_id=user_id AND m.technology_id=technology_id) 
	OR (m.user_id=user_id AND m.technology_id ==-1) 
	OR (m.user_id ==-1 AND m.project_id=project_id AND m.technology_id=technology_id) 
	OR (m.user_id ==-1 AND m.project_id ==-1 AND m.technology_id==-1) 
	ORDER BY priority ASC, ts DESC
	LIMIT 1
) AS model 
SELECT
	task_id,
	project_id,
	user_id,
	technology_id,
	estimated_hours,
	evalMLMethod(model,estimated_hours) 
FROM temp_tasks;

drop table temp_tasks;