-- We flip a coin 1000 times and count how often heads come

with
	groupArray(rand()%2) as c,
	['We got ' || toString(countEqual(c,0)) || ' heads', 'That is ' || toString(countEqual(c,0)/10) || '%'] as r
select
	arrayJoin(r) 
from numbers(1000) 
format TSVRaw;