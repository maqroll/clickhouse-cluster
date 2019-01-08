/* ejecuta events_shard x companies_dist en cada nodo y agrega en local */
/* global dist dist */ SELECT * FROM test_db.events_dist GLOBAL ALL INNER JOIN test_db.companies_dist USING (company_id);