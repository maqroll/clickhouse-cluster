-- monte carlo methods
-- https://easylang.online/apps/tutorial_mcarlo.html

-- We flip a coin 1000 times and count how often heads come

with
	groupArray(rand()%2) as c,
	['We got ' || toString(countEqual(c,0)) || ' heads', 'That is ' || toString(countEqual(c,0)/10) || '%'] as r
select
	arrayJoin(r) 
from numbers(1000) 
format TSVRaw;

-- When we increase the number of flips to one million, the percentage of heads is very close to 50%.

with
	groupArray(rand()%2) as c,
	['We got ' || toString(countEqual(c,0)) || ' heads', 'That is ' || toString(countEqual(c,0)/10000) || '%'] as r
select
	arrayJoin(r) 
from numbers(1000000) 
format TSVRaw;

-- We play American roulette with a single zero wheel. Double zero wheels are twice as bad for the player. There are 37 numbers, from 0 to 36. We bet on the high numbers, i.e. we win the bet if the ball rolls to a number from 19 to 36, otherwise we lose our money.

select 
	multiIf(rand()%37>=19,'You win 10$','You lose 10$') 
format TSVRaw;

-- Let's play a thousand times

with
	groupArray(rand()%37) as c,
	arraySum(arrayMap(x -> multiIf(x>=19,10,-10),c)) as r
select
	'Cash after playing: $' || toString(r)
from numbers(1000) 
format TSVRaw;

-- Now lets play 10000 times

with
	groupArray(rand()%37) as c,
	arraySum(arrayMap(x -> multiIf(x>=19,10,-10),c)) as r
select
	'Cash after playing: $' || toString(r)
from numbers(10000) 
format TSVRaw;

-- The new strategy: bet on 13 - we win $350 when the ball rolls to 13.

with
	groupArray(rand()%37) as c,
	arraySum(arrayMap(x -> multiIf(x==13,350,-10),c)) as r
select
	'Cash after playing: $' || toString(r)
from numbers(10000) 
format TSVRaw;

-- We got $1000. We always bet $10 on the high numbers. When the $1000 is gone or becomes $2000, we stop playing. When the casino day is over (after 500 games), we go home and continue playing the next day.

with
	groupArray(rand()%37>=19) as r,
	arrayCumSum(arrayMap(x -> multiIf(x==1,10,-10),r)) as c,
	arrayFirstIndex(x->x==-1000,c) as lose,
	arrayFirstIndex(x->x==1000,c) as win,
	if(win==0,lose,win) as i,
	toUInt32(ceiling(i/500)) as days,
	range(days) as j,
	arrayMap(x -> ('Day ' || toString(x+1) || ': $' || ((x+1)*500<=i? toString(1000+c[(x+1)*500]) : toString(1000+c[i]))),j) as res
select
	arrayJoin(res)
from numbers(500*100 /* 100 days should be enough*/)
format TSVRaw;

-- We need a winning strategy. The chance that a high number will come after a low one could be higher. So we bet on the high numbers if there was a low number before, otherwise we bet on the low numbers.

/* TODO */
with
	groupArray(rand()%37>=19) as r,
	arrayCumSum(arrayMap(x -> multiIf(x==1,10,-10),r)) as c,
	arrayFirstIndex(x->x==-1000,c) as lose,
	arrayFirstIndex(x->x==1000,c) as win,
	if(win==0,lose,win) as i,
	toUInt32(ceiling(i/500)) as days,
	range(days) as j,
	arrayMap(x -> ('Day ' || toString(x+1) || ': $' || ((x+1)*500<=i? toString(1000+c[(x+1)*500]) : toString(1000+c[i]))),j) as res
select
	arrayJoin(res)
from numbers(500*100 /* 100 days should be enough*/)
format TSVRaw;