-- The new strategy: bet on 13 - we win $350 when the ball rolls to 13.

with
	groupArray(rand()%37) as c,
	arraySum(arrayMap(x -> multiIf(x==13,350,-10),c)) as r
select
	'Cash after playing: $' || toString(r)
from numbers(10000) 
format TSVRaw;