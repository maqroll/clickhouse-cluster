SELECT 
    argMin(toDate(date),unemploy) as min, 
    argMax(toDate(date),unemploy) as max
FROM file('file.csv', 'CSV', 'date String, pce Float64, pop UInt64, psavert Float64, unempmed Float64, unemploy UInt64') FORMAT JSONEachRow;