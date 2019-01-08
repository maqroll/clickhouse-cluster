/* se resuelve en local */
/* shard shard */ SELECT * FROM test_db.events_shard ALL INNER JOIN test_db.companies_shard USING (company_id);