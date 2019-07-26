-- We got $1000. We always bet $10 on the high numbers. When the $1000 is gone or becomes $2000, we stop playing. When the casino day is over (after 500 games), we go home and continue playing the next day.

with
	groupArray(rand()%37>=19) as r,
	arrayCumSum(arrayMap(x -> multiIf(x==1,10,-10),r)) as c,
	arrayFirstIndex(x->x==-1000,c) as lose,
	arrayFirstIndex(x->x==1000,c) as win,
	least(if(lose==0,500*100,lose),if(win==0,500*100,win)) as i,
	toUInt32(ceiling(i/500)) as days,
	range(days) as j,
	arrayMap(x -> ('Day ' || toString(x+1) || ': $' || ((x+1)*500<=i? toString(1000+c[(x+1)*500]) : toString(1000+c[i]))),j) as res
select
	arrayJoin(res)
from numbers(500*100 /* 100 days should be enough*/)
format TSVRaw;