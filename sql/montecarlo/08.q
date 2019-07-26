-- We need a winning strategy. The chance that a high number will come after a low one could be higher. So we bet on the high numbers if there was a low number before, otherwise we bet on the low numbers.

with
	groupArray(toUInt8(rand()%37)) as r
	,arrayMap(i->toUInt8(multiIf(i==0,0,i>0 and i<19,1,2)),r) as kkkk /* lo que salió */
    ,arrayMap(i->toUInt8(multiIf(i==0,1,r[i]>0 and r[i]<19,2,1)),range(length(r))) as hhhh /* lo que apostaría */
    ,arrayMap(i->toInt8(multiIf(kkkk[i+1]!=0 and hhhh[i+1]==kkkk[i+1],10,-10)),range(length(r))) as k
	,arrayCumSum(k) as c
	,arrayFirstIndex(x -> x==-1000,c) as lose
	,arrayFirstIndex(x -> x==1000,c) as win
	,least(if(lose==0,500*100,lose),if(win==0,500*100,win)) as ik
	,toUInt32(ceiling(ik/500)) as days
	,range(days) as j
	,arrayMap(x -> ('Day ' || toString(x+1) || ': $' || ( ((x+1)*500<=ik) ? toString(1000+c[(x+1)*500]) : toString(1000+c[ik]) ) ),j) as res
select
	arrayJoin(res)
from numbers(500*30)
format TSVRaw;