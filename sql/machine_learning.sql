-- Auto Machine Learning (functions available on 19.9 branch)
-- https://medium.com/coinmonks/what-is-entropy-and-why-information-gain-is-matter-4e85d46d2f01
-- https://www.saedsayad.com/decision_tree.htm
CREATE DATABASE IF NOT EXISTS test_db;

/* MODEL TRAINING */
DROP TABLE IF EXISTS test_db.tasks_train;
CREATE TABLE IF NOT EXISTS test_db.tasks_train (
	task_id Float64,
	project_id Float64,
	user_id Float64,
	technology_id Float64,
	estimated_hours Float64,
	real_hours Float64
) ENGINE = MergeTree()
PARTITION BY project_id
ORDER BY (project_id,user_id)
SETTINGS index_granularity=8192;

/* PREDICTED */
DROP TABLE IF EXISTS test_db.tasks;
CREATE TABLE IF NOT EXISTS test_db.tasks (
	task_id Float64,
	project_id Float64,
	user_id Float64,
	technology_id Float64,
	estimated_hours Float64,
	predicted_hours Float64
) ENGINE = MergeTree()
PARTITION BY project_id
ORDER BY (project_id,user_id)
SETTINGS index_granularity=8192;

DROP TABLE IF EXISTS test_db.tasks_model;
CREATE TABLE test_db.tasks_model ENGINE = MergeTree() PARTITION BY state ORDER BY tuple() AS 
SELECT stochasticLinearRegressionState(0.00000001,1,30,'SGD')(real_hours, project_id, user_id, technology_id,estimated_hours)
AS state, now() AS version FROM test_db.tasks_train;


-- TODO: re-train the model

DROP TABLE IF EXISTS temp_tasks;
CREATE TEMPORARY TABLE temp_tasks AS test_db.tasks;
insert into temp_tasks values(....);
insert into test_db.tasks 
	WITH (SELECT state FROM test_db.tasks_model) AS model 
	select task_id,project_id,user_id,technology_id,estimated_hours,evalMLMethod(model, project_id,user_id,technology_id,estimated_hours) from test_tasks;


--SELECT  stochasticLinearRegression(0.00000001,1,30,'SGD')(real_hours, estimated_hours) AS state FROM test_db.tasks_train;

-- TODO fake data for training the model
-- seq 4000 | awk '{print $0",1,"($0%2)+1","($0%3)+1","$0","$0+rand()}' | clickhouse client -q "insert into test_db.tasks_train format CSV"