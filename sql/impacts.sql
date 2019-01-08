SELECT 
    company_id, 
    product_id, 
    sum(sold) as sold
FROM test_db.impacts 
GROUP BY (company_id, product_id) FORMAT JSONEachRow;