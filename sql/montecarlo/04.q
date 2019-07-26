-- Let's play a thousand times

with
	groupArray(rand()%37) as c,
	arraySum(arrayMap(x -> multiIf(x>=19,10,-10),c)) as r
select
	'Cash after playing: $' || toString(r)
from numbers(1000) 
format TSVRaw;