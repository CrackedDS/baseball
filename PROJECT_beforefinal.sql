--Insure that the user can only select season year greater than 1984 since we have null values on the table for the salary field;
-- Here the sal gives the ratio of the players salary and the median salary for that season;
-- Get the Impact for each of the player who played that season; 
-- replace 2002 by the season selected by the user;
-- formula can be the ratio 
-- 
-- (player's bating and pitching impact ) & SAL 


select PID,FNAME, LNAME ,(SALARY/MEDIAN) SAL,TEAM_NAME,SEASON_YEAR
from(
select  p.pid,
        p.fname,
        p.lname,
        season_year,
        team_name, 
        salary, 
        percentile_disc(0.5) within group (order by salary desc)  
        over (partition by season_year) median  
from   statyear syear, player p where syear.pid= p.pid and season_year > 1984) where  SEASON_YEAR ='2002' order by sal;





 --select m.MID,(sum(m.WINS)/sum(m.GAMES)) WR from manageryear m inner join pitchyear p on m.team_name= p.team_name and m.season_year = p.season_year where m.MID in(select mid from MANAGERYEAR) group by m.MID order by m.MID;

 --select m.MID,(avg(p.wins))/(avg(p.wins)+avg(p.losses)) WR1 from manageryear m inner join pitchyear p on m.team_name= p.team_name and m.season_year = p.season_year where m.MID in(select mid from MANAGERYEAR) group by m.mid order by m.MID; 
 
 -- this query gives us the ratio but some of the (avg(p.wins)/(avg(p.wins)+ avg(p.losses) yields zero so couldnt order by RATIO;
 select m.fname, m.lname, ratio from manager m natural join 
(select MID, ratio from (
 select m.MID,((sum(m.WINS)/sum(m.GAMES))/(avg(p.wins)+1)/(1+avg(p.wins)+ avg(p.losses))) RATIO from manageryear m inner join pitchyear p on m.team_name= p.team_name and m.season_year = p.season_year where m.MID in(select mid from MANAGERYEAR) group by m.mid order by ratio desc) where rownum <=10
 ) order by ratio desc;  
 -- take the top 10 tuples 
 
 --and sum(m.GAMES)<>0 and avg(p.wins)+ avg(p.losses)<>0
 
 ------------
 --HEAD TO HEAD FOR USER TEAM 
 -- please change the static values accordingly and create one more user team
 -- let me know if do not work 
 -- currently it is dummy
 
 select (team_bat - team_field1 - team_pitch1), (team_bat1 - team_field - team_pitch)
 from
 (select avg(bat_stat) team_bat, avg(field_stat) team_field ,avg(pitch_stat) team_pitch from
  (select ((singles + (2 * doubles) + (3 * triples) + (4 * rbi) + (2 * stolen_bases) + (0.5 * hits) - (3 * strikeouts) + (4 * home_runs)) / games) as bat_stat
    from BATYEAR natural join statyear
    WHERE PID IN (select PID from PLAYERUSERTEAM PL where PL.name = 'Team 1' and PL.user_email='test@test.com')),    
    (select ((putouts + (1.5 * assists) - (2 * errors) + (3 * double_plays)) / games) as field_stat
    from FIELDYEAR natural join statyear
    WHERE PID IN (select PID from PLAYERUSERTEAM PL where PL.name = 'Team 1' and PL.user_email='test@test.com')),
    (select ((outs + (5 * shutouts) - (2 * homeruns) - walks + strikeouts) / games) as pitch_stat
    from PITCHYEAR natural join statyear
    WHERE PID IN (select PID from PLAYERUSERTEAM PL where PL.name = 'Team 1' and PL.user_email='test@test.com'))),
   (select avg(bat_stat1) team_bat1, avg(field_stat1) team_field1,avg(pitch_stat1) team_pitch1 from
  (select ((singles + (2 * doubles) + (3 * triples) + (4 * rbi) + (2 * stolen_bases) + (0.5 * hits) - (3 * strikeouts) + (4 * home_runs)) / games) as bat_stat1
    from BATYEAR natural join statyear
    WHERE PID IN (select PID from PLAYERUSERTEAM PL where PL.name = 'Team 2' and PL.user_email='test@test.com')),    
    (select ((putouts + (1.5 * assists) - (2 * errors) + (3 * double_plays)) / games) as field_stat1
    from FIELDYEAR natural join statyear
    WHERE PID IN (select PID from PLAYERUSERTEAM PL where PL.name = 'Team 2' and PL.user_email='test@test.com')),
    (select ((outs + (5 * shutouts) - (2 * homeruns) - walks + strikeouts) / games) as pitch_stat1
    from PITCHYEAR natural join statyear
    WHERE PID IN (select PID from PLAYERUSERTEAM PL where PL.name = 'Team 2' and PL.user_email='test@test.com')));
 
 
 
 ------------------------------ENDS--------------------
 ------------
 ---ROUGH WORK
 -------------
 select avg(bat_stat), avg(field_stat), avg(pitch_stat) from
  (select ((singles + (2 * doubles) + (3 * triples) + (4 * rbi) + (2 * stolen_bases) + (0.5 * hits) - (3 * strikeouts) + (4 * home_runs)) / games) as bat_stat
    from BATYEAR natural join statyear
    WHERE PID='aceveju01'),    
    (select ((putouts + (1.5 * assists) - (2 * errors) + (3 * double_plays)) / games) as field_stat
    from FIELDYEAR natural join statyear
    WHERE PID='aceveju01'),
    (select ((outs + (5 * shutouts) - (2 * homeruns) - walks + strikeouts) / games) as pitch_stat
    from PITCHYEAR natural join statyear
    WHERE PID='aceveju01');

----------------------------
select (team_bat - team_field1 - team_pitch1), (team_bat1 - team_field - team_pitch)
from
  (select avg(bat_stat) as team_bat
  from
    (select ((singles + (2 * doubles) + (3 * triples) + (4 * rbi) + (2 * stolen_bases) + (0.5 * hits) - (3 * strikeouts) + (4 * home_runs)) / games) as bat_stat
    from BATYEAR natural join statyear
    WHERE TEAM_NAME='Texas Rangers' and SEASON_YEAR='2002')),
  (select avg(field_stat) as team_field
  from
    (select ((putouts + (1.5 * assists) - (2 * errors) + (3 * double_plays)) / games) as field_stat
    from FIELDYEAR natural join statyear
    WHERE TEAM_NAME='Texas Rangers' and SEASON_YEAR='2002')),
  (select avg(pitch_stat) as team_pitch
  from
    (select ((outs + (5 * shutouts) - (2 * homeruns) - walks + strikeouts) / games) as pitch_stat
    from PITCHYEAR natural join statyear
    WHERE TEAM_NAME='Texas Rangers' and SEASON_YEAR='2002')),
  (select avg(bat_stat) as team_bat1
  from
    (select ((singles + (2 * doubles) + (3 * triples) + (4 * rbi) + (2 * stolen_bases) + (0.5 * hits) - (3 * strikeouts) + (4 * home_runs)) / games) as bat_stat
    from BATYEAR natural join statyear
    WHERE TEAM_NAME='Houston Astros' and SEASON_YEAR='2002')),
  (select avg(field_stat) as team_field1
  from
    (select ((putouts + (1.5 * assists) - (2 * errors) + (3 * double_plays)) / games) as field_stat
    from FIELDYEAR natural join statyear
    WHERE TEAM_NAME='Houston Astros' and SEASON_YEAR='2002')),
  (select avg(pitch_stat) as team_pitch1
  from
    (select ((outs + (5 * shutouts) - (2 * homeruns) - walks + strikeouts) / games) as pitch_stat
    from PITCHYEAR natural join statyear
    WHERE TEAM_NAME='Houston Astros' and SEASON_YEAR='2002'));
-------------------
select * from BATYEAR where rownum <= 12;
 select * from PLAYERUSERTEAM;
 
select * from PITCHYEAR;
--select mt, pitchtable from (

 select * from manageryear where mid ='bensove01';
 select * from manageryear, pitchyear where manageryear.team_name = pitchyear.team_name and manageryear.season_year = pitchyear.season_year and manageryear.mid='bensove01';
 --(select MID, (wins/games) WR, manageryear.WINS, manageryear.LOSSES from manageryear order by MID ASC);--where manager.fname='Davey' and manager.LNAME='Johnson'; 
select  p.pid,
        p.fname,
        p.lname,
        season_year,
        team_name, 
        salary, 
        percentile_disc(0.5) within group (order by salary desc)  
        over (partition by season_year) median  
from   statyear syear, player p where syear.pid= p.pid and season_year > 1984;
