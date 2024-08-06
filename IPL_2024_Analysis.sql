-- Q1 : Total Run BY Player During Tournament In Descending Order
select 
	Team ,     
	BatsMan ,     
	Sum(Runs) as Total_Runs ,     
	count(*) as inning 
from 2_player 
group by Team , BatsMan 
order by Sum(Runs) desc ; 

-- Q2 : Top Five Player Based on Maximum Run During Tournament In Descending Order
with cte as (
select 	
	dense_rank() over(order by sum(Runs) desc) as rn,
	Team ,     
	BatsMan ,     
	Sum(Runs) as Total_Runs ,     
	count(*) as inning 
from 2_player 
group by Team , BatsMan )
select * from cte having rn <= 5 ;

-- Q3 : Total 4’s By Player(Top 5) During Tournament In Descending Order 

with cte as (
select	
	dense_rank() over(order by sum(Fours) desc) as rn,
	Team ,
	BatsMan,    
	Sum(Runs) as Runss ,        
	count(*) as M ,        
	sum(Fours) as 4s
from 2_player
group by Team , BatsMan )
select * from cte where rn <= 5 ;

-- Q4 : Total 6’s By Player(Top 5) During Tournament In Descending Order 

with cte as (
select	
	dense_rank() over(order by sum(Sixers) desc) as rn,
	Team ,    
	BatsMan,    
	Sum(Runs) as Runs ,       
	count(*) as M ,        
	sum(Sixers) as 6s
from 2_player
group by Team , BatsMan )
select * from cte where rn <= 5;

-- Q5 : Total Boundaries By Player(Top 5) During Tournament In Descending Order 

with cte as (
select	
	dense_rank() over(order by sum(Fours)+sum(Sixers) desc) as rn,	
	Team ,    
	BatsMan,    
	Sum(Runs) as Runss ,        
	count(*) as M ,        
	sum(Fours)+sum(Sixers) as Boundaries
from 2_player
group by Team , BatsMan )
select * from cte where rn <= 5;

-- Q6 : Total 4’s By Player(Top 5) During Inning In Descending Order 

with cte as(
select 	
	dense_rank() over(order by Fours desc) as rn ,	
	Team ,    
	batsman ,   
	runs,    
	balls,    
	round(runs / balls *100 , 2) as SR,    
	fours as 4s
from 2_player )
select * from cte where rn <= 5 ;

-- Q7 : Total 6’s By Player(Top 3) During Inning In Descending Order 

with cte as(
select 	
	dense_rank() over(order by Sixers desc) as rn ,	
	Team ,    
	batsman ,    
	runs,    
	balls,    
	round(runs / balls *100 , 2) as SR,    
	Sixers as 6s
from 2_player )
select * from cte where rn<=3;

-- Q8 : Total 50’s By Player(Top N) During Inning In Descending Order 

with cte as (
select 	
	rank() over(order by count(runs) desc) as rn,	
	team ,    
	batsman,    
	count(Runs) as 50s
from 2_player 
where Runs>=50 and runs<100
group by team , BatsMan )
select * from cte where rn<=5;

-- Q9 : Total 100’s By Player(Top N) During Inning In Descending Order 

with cte as(
select 	
	rank() over(order by count(runs) desc) as rn,	
	team ,    
	batsman,    
	count(Runs) as 100s
from 2_player 
where runs>=100
group by team , BatsMan )
select * from cte where rn <= 5 ;

-- Q10 : Highest Run BY Player(Top n) During Tournament In Descending Order ( * Means Not_out )  
with cte as (
select	
	dense_rank() over(order by runs desc) as rn,	
	team ,    
	batsman,    
	case
		when OUT_NTOUT="0" then concat(runs,"* / ",balls) else concat(runs," / ",balls)
	end as Highest_Runs,    
	round(runs / balls * 100 , 2) as SR
from 2_player)
select * from cte where rn <= 5 ;

-- Q11 : Best Strike Rate During Tournament with 50+ Balls In Descending Order

with cte as (
select 	
	dense_rank() over(order by round(sum(runs) / sum(balls) * 100 , 2 ) desc) as rn,	
	team ,     
	BatsMan,    
	count(*) as M ,    
	Sum(Runs) as Runss ,       
	sum(balls) as Ball ,    
	round(sum(runs) / sum(balls) * 100 , 2 ) as SR,    
	sum(Fours) as 4s,    
	sum(sixers) as 6s
from 2_player
group by team , batsman 
having sum(balls)>=50 )
select * from cte where rn<=5 ;

-- Q12 : Average Run BY Player During Tournament In Descending Order
--				        Avg = Total _ Runs / Inning ( excluding Not_out inning)

with cte as (
select	
	dense_rank() over(order by round(Sum(Runs) / sum(out_ntout),2) desc) as rn,
	Team ,     
	BatsMan ,    
	Sum(Runs) as Total_Runs ,        
	count(*) as inning ,        
	sum(out_ntout) as outt,    
	count(*) - sum(out_ntout) as not_out,   
	round(Sum(Runs) / sum(out_ntout),2) as Avg_run
from 2_player 
group by Team , BatsMan )
select * from cte where rn <= 5;

-- Q13 : Total Wickets BY Bowler(Top N) During Tournament In Descending Order

with cte as(
select 	
	rank() over(order by sum(Wickets) desc) as rn,	
	Team ,    
	Bowler ,    
	count(*) as innings ,    
	sum(Wickets) as Wickets ,    
	round(sum(runs) / sum(balls) * 6.00 , 2) as Econ
from 1_bowlerr
group by team , Bowler)
select * from cte where rn<=5;

-- Q14 : Best Bowling Figures During Tournament In Descending Order

select 	
	Team ,    
	Bowler ,    
	Overs,	
	round(runs / balls * 6.00 , 2) as Econ,    
	concat(wickets,"/",runs) as BB,
	(select count(*) from 1_bowlerr where bowler = b.bowler and wickets>=3 and Wickets<5) as 3w,    
	(select count(*) from 1_bowlerr where bowler = b.bowler and wickets>=5) as 5w 
from 1_bowlerr b
order by Wickets desc , runs asc
limit 5 ;

-- Q15 : Most Economical Bowlers of Tournament In Descending Order

select 	
	Team ,    
	Bowler ,    
	count(*) as innings,    
	sum(Wickets) as W,    
	sum(runs) as Runs,    
	sum(balls) as Balls ,    
	round((sum(Runs) / sum(Balls) * 6.00),2) as Avgg
from 1_bowlerr
group by Team , Bowler
order by round((sum(Runs) / sum(Balls) * 6.00),2)
limit 5 ;

-- Q16 : Purple Cap (Highest Wicket)
with cte1 as (
select	Team,    Bowler,    
	count(*) as innings,    sum(runs) as R,
	concat(floor(sum(balls)/6),".",mod(sum(balls),6)) as O,    
	sum(Wickets) as W,    
	round(sum(Runs) / sum(Balls) * 6 , 2) as Econ,    
	sum(Maiden) as Maidens
from 1_bowlerr
group by Team , bowler 
order by sum(Wickets) desc) ,
cte2 as (
select 	batsman ,	sum(Runs) as R , sum(balls) as Ba,    
	count(balls) as inn_playing ,    
	round(sum(runs)/sum(balls)*100,2) as SR
from 2_player
group by team , batsman )
select 	a.*,    coalesce(b.R,"Not Played") as R,    
	coalesce(b.Ba,"Not Played") as B , coalesce(b.SR,"Not Played") as SR ,    
	coalesce(b.inn_playing,"Not Played") as inning 
from cte1 a 
left join cte2 b 
	on a.bowler = b.batsman  
limit 5;

-- Q17 : Maiden Over

with cte1 as (
select 	
	rank() over(order by sum(Maiden) desc) as rn,	
	Team,    
	Bowler,    
	count(*) as innings,    
	sum(runs) as R,    
	concat(floor(sum(balls)/6),".",mod(sum(balls),6)) as O,    
	sum(Wickets) as W,    
	round(sum(Runs) / sum(Balls) * 6 , 2) as Econ,    
	sum(Maiden) as Maidens
from 1_bowlerr
group by Team , bowler )
select * from cte1 where rn<=5 ;

-- Q18 : Total Dot Balls during Tournament 

select 	
	Team,    
	Bowler,    
	count(*) as innings,    
	sum(runs) as R,    
	concat(floor(sum(balls)/6),".",mod(sum(balls),6)) as O,    
	sum(Wickets) as W,    
	round(sum(Runs) / sum(Balls) * 6 , 2) as Econ,    
	sum(Maiden) as Maidens,    
	Sum(dot_balls) as Dots
from 1_bowlerr
group by Team , bowler 
order by sum(Dot_Balls) desc
limit 5 ;

-- Q19 : Most Runs Conceded in inning 

select 	
	dense_rank() over(order by runs desc ) as rn,	
	Team,    
	Bowler,    
	overs,    
	runs
from 1_bowlerr
Limit 5 ;

-- Q20 : Orange Cap (Highest Runs)

select	
	dense_rank() over(order by sum(runs) desc) as Rn,
	Team ,    batsman ,    count(*) as Inning ,    
	Sum(OUT_NTOUT) as Outt ,    
	count(*) - sum(OUT_NTOUT) as not_out,    
	Sum(Runs) as Runs ,    
	max(Runs) as Highest_score,    
	round( Sum(Runs) / sum(OUT_NTOUT)  , 2) as Avgg,    
	round(Sum(Runs) / sum(Balls) * 100 , 2 ) as SR ,    
	sum(Fours) as 4s ,    sum(Sixers) as 6s ,    
	(select count(*) from 2_player where BatsMan = a.BatsMan and runs>=50 and runs<100) as 50s,   
	(select count(*) from 2_player where BatsMan = a.BatsMan and runs>=100) as 100s
from 2_player a 
group by Team , Batsman 
limit 5 ;








 


