select fname,lname from PLAYER
where PID IN(
Select distinct PID from STATYEAR
where SALARY = (select MAX(SALARY) from STATYEAR where STATYEAR.SEASON_YEAR= '1991')) and rownum <=10;

select salary from statyear where SEASON_YEAR > 1985;

select avg(sum) from (
select distinct PID, sum(games) sum from STATYEAR
group by PID);

--select p.singles / d.singles from (

select avg(sing) singles, avg(doub) doubles, avg(tri) triples,avg(rbi) rbi , avg(stol) stolenbases, avg(hit) hits , avg(strike) strikeouts, avg(hmruns) homeruns from(
select PID,sum(singles) sing, sum(doubles) doub, sum(triples) tri, sum (rbi) rbi, sum (stolen_bases) stol , sum(hits) hit, sum(home_runs) hmruns,sum(strikeouts) strike  from BATYEAR 
group by PID) union

select avg(sing) singles, avg(doub) doubles, avg(tri) triples,avg(rbi) rbi , avg(stol) stolenbases, avg(hit) hits , avg(strike) strikeouts, avg(hmruns) homeruns from(
select PID,sum(singles) sing, sum(doubles) doub, sum(triples) tri, sum (rbi) rbi, sum (stolen_bases) stol , sum(hits) hit, sum(home_runs) hmruns,sum(strikeouts) strike  from BATYEAR
group by PID having PID='adamsgl01') ;

select avg(put) putouts, avg(assist) assists, avg(error) errors,avg(doubleplay) double_plays  from(
select PID,sum(putouts) put, sum(assists) assist, sum(errors) error, sum (double_plays) doubleplay from FIELDYEAR
group by PID having PID='adamsgl01') union

select avg(put) putouts, avg(assist) assists, avg(error) errors,avg(doubleplay) double_plays  from(
select PID,sum(putouts) put, sum(assists) assist, sum(errors) error, sum (double_plays) doubleplay from FIELDYEAR
group by PID);

select avg(win) wins, avg(loss) losses, avg(save) saves ,avg(out) outs , avg(homerun) homeruns , avg(walk) walks ,avg(strikeout) strikeouts from(
select PID,sum(wins) win, sum(losses) loss, sum(saves) save, sum(outs) out, sum(homeruns) homerun, sum(walks) walk , sum(strikeouts) strikeout from PITCHYEAR
group by PID having PID='adamsgl01')union

select avg(win) wins, avg(loss) losses, avg(save) saves ,avg(out) outs , avg(homerun) homeruns , avg(walk) walks ,avg(strikeout) strikeouts from(
select PID,sum(wins) win, sum(losses) loss, sum(saves) save, sum(outs) out, sum(homeruns) homerun, sum(walks) walk , sum(strikeouts) strikeout from PITCHYEAR
group by PID );

select avg(salary) avgsalary from 
(select PID , sum(salary) salary from STATYEAR group by PID);
--);

select max(salary) from statyear where season_year = '2013';
select min(salary) from statyear ;

select max(rank) from MANAGERYEAR;

--get the median salary of the player over the whole database
select  pid,
        season_year,
        team_name, 
        salary, 
        percentile_disc(0.5) within group (order by salary desc) 
        over () median 
from   statyear;

--- median salary for a particular season 
select  p.pid,
        p.fname,
        p.lname,
        season_year,
        team_name, 
        salary, 
        percentile_disc(0.5) within group (order by salary desc)  
        over (partition by season_year) median  
from   statyear syear, player p where syear.pid= p.pid and season_year > 1984;




