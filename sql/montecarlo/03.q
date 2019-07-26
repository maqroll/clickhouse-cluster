-- We play American roulette with a single zero wheel. Double zero wheels are twice as bad for the player. There are 37 numbers, from 0 to 36. We bet on the high numbers, i.e. we win the bet if the ball rolls to a number from 19 to 36, otherwise we lose our money.

select 
	multiIf(rand()%37>=19,'You win 10$','You lose 10$') 
format TSVRaw;