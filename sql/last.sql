SELECT 
    company_id, 
    product_id, 
    argMax(sold, event_date), 
    argMax(event_date, event_date)
FROM test_db.units_sold 
GROUP BY (company_id, product_id)
