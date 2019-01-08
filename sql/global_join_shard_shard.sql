/* se resuelve en local */
/* global shard shard */ SELECT * FROM test_db.events_shard GLOBAL ALL INNER JOIN test_db.companies_shard USING (company_id);