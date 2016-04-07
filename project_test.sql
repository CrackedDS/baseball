
 --manager evaluation 
 
select mid,SEASON_YEAR,sum(games),sum( wins), sum(losses) from MANAGERYEAR group by mid, season_year order by season_year asc; 

select mid,sum(games),sum( wins), sum(losses) from MANAGERYEAR group by mid; 

select M.mid , M.fname, M.lname from MANAGERYEAR MY, MANAGER M where M.MID = MY.MID and MY.rank =1 and MY.SEASON_YEAR = 2011;

SELECT COUNT(*) from player ;

SELECT * FROM team;

Select distinct NAME from TEAM
where season_year = '2013';

Select * FROM PLAYER P, STATYEAR S where
P.pid = S.pid;

Select * FROM BATYEAR where rownum <=100;

Select p.pid, p.fname, p.lname from PLAYER P, STATYEAR S
where P.pid = S.pid  
and S.team_name = 'Atlanta Braves'
and S.season_year = '1991';

Select * from PITCHYEAR;
Select * from FIELDYEAR;
Select * from BATYEAR;
Select SALARY,PID,SEASON_YEAR from STATYEAR
where SALARY > 100;
Select * from MANAGER;

select * from STATYEAR where pid = 'traynpi01';

select avg(singles),avg(doubles),avg(home_runs), avg(doubles), avg(triples), avg(hits), avg(RBI), avg(stolen_bases), avg(strikeouts)
from BATYEAR;

select count(*) from FIELDYEAR;
select count(*) from BATYEAR;

-- average number of games per player;
select avg(sum) from (
select distinct PID, sum(games) sum from STATYEAR
group by PID);

--total number of singles by a PID;
select avg(sing) from(
select PID,sum(singles) sing from BATYEAR 
group by PID);

--total number of dobles by a PID;
select avg(sing) from(
select PID,sum(doubles) sing from BATYEAR 
group by PID);

--total number of triples by a PID;
select avg(sing) from(
select PID,sum(triples) sing from BATYEAR 
group by PID);

--total number of triples by a PID;
select avg(sing) from(
select PID,sum(BATYEAR.HOME_RUNS) sing from BATYEAR 
group by PID);

--total number of triples by a PID;
select avg(sing) from(
select PID,sum(BATYEAR.STRIKEOUTS) sing from BATYEAR 
group by PID);

--total number of triples by a PID;
select avg(sing) from(
select PID,sum(hits) sing from BATYEAR 
group by PID);

--total number of triples by a PID;
select avg(sing) from(
select PID,sum(rbi) sing from BATYEAR 
group by PID);

--total number of triples by a PID;
select avg(sing) from(
select PID,sum(stolen_bases) sing from BATYEAR 
group by PID);

select fname,lname from PLAYER
where PID IN(
Select distinct PID from STATYEAR
where SALARY = (select MAX(SALARY) from STATYEAR where STATYEAR.SEASON_YEAR= '1991'));



--WHERE P.pid = 'averyst01'
Select P1.WINS-P2.WINS W, P1.LOSSES-P2.LOSSES L, P1.SAVES-P2.SAVES S,P1.OUTS-P2.OUTS O,P1.SHUTOUTS-P2.SHUTOUTS S,P1.HOMERUNS-P2.HOMERUNS H, P1.WALKS - P2.WALKS W, P1.STRIKEOUTS - P2.STRIKEOUTS SOUT from PITCHYEAR P1, PITCHYEAR P2
WHERE P1.pid = 'leibrch01'
and P1.team_name = 'Atlanta Braves'
and P1.season_year = '1991'
and P2.pid = 'averyst01'
and P2.team_name = 'Atlanta Braves'
and P2.season_year = '1991';

-- fielding table 
select avg(sing) from(
select PID,sum(Fieldyear.zone_rating) sing from Fieldyear
group by PID);

select avg(errors) from Fieldyear;

--Select SID from V$SESSION;
select outs from PITCHYEAR where 
rownum <= 10;

--Pitching table
select avg(sing) from(
select PID,sum(PITCHYEAR.outs) sing from PITCHYEAR
group by PID);

select count(distinct player.PID) from statyear, player where  statyear.PID = player.PID
 and season_year = '1991' and statyear.TEAM_NAME ='Cincinnati Reds' ;