-- When we increase the number of flips to one million, the percentage of heads is very close to 50%.

with
	groupArray(rand()%2) as c,
	['We got ' || toString(countEqual(c,0)) || ' heads', 'That is ' || toString(countEqual(c,0)/10000) || '%'] as r
select
	arrayJoin(r) 
from numbers(1000000) 
format TSVRaw;