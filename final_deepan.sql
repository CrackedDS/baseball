--------------------------------------------------
/*Player Impact Analyser*/

select (bat_play / bat_tot) as bat_stat, (field_play / field_tot) as field_stat, (pitch_play / pitch_tot) as pitch_stat
from
  (select avg(stat / tot) as bat_tot
  from
    (select (sum(singles) + (2 * sum(doubles)) + (3 * sum(triples)) + (4 * sum(rbi)) + (2 * sum(stolen_bases)) + (0.5 * sum(hits)) - (3 * sum(strikeouts)) + (4 * sum(home_runs))) as stat
    from BATYEAR A),
    (select sum(games) as tot
    from statyear C)),
  (select avg(stat / tot) as bat_play
  from
    (select (sum(singles) + (2 * sum(doubles)) + (3 * sum(triples)) + (4 * sum(rbi)) + (2 * sum(stolen_bases)) + (0.5 * sum(hits)) - (3 * sum(strikeouts)) + (4 * sum(home_runs))) as stat
    from BATYEAR
    group by PID 
    having PID='adamsgl01'),
    (select sum(games) as tot
    from statyear
    group by PID
    having PID='adamsgl01')),
  (select avg(stat / tot) as field_tot
  from
    (select (sum(putouts) + (1.5 * sum(assists)) - (2 * sum(errors)) + (3 * sum (double_plays))) as stat
    from FIELDYEAR A),
    (select sum(games) as tot
    from statyear C)),
  (select avg(stat / tot) as field_play
  from
    (select (sum(putouts) + (1.5 * sum(assists)) - (2 * sum(errors)) + (3 * sum (double_plays))) as stat
    from FIELDYEAR
    group by PID 
    having PID='adamsgl01'),
    (select sum(games) as tot
    from statyear
    group by PID
    having PID='adamsgl01')),
  (select avg(stat / tot) as pitch_tot
  from
    (select (sum(outs) + (5 * sum(shutouts)) - (2 * sum(homeruns)) - sum(walks) + sum(strikeouts)) as stat
    from PITCHYEAR A),
    (select sum(games) as tot
    from statyear C)),
  (select avg(stat / tot) as pitch_play
  from
    (select (sum(outs) + (5 * sum(shutouts)) - (2 * sum(homeruns)) - sum(walks) + sum(strikeouts)) as stat
    from PITCHYEAR
    group by PID 
    having PID='adamsgl01'),
    (select sum(games) as tot
    from statyear
    group by PID
    having PID='adamsgl01'));

---------------------------------------------------------------

/*H2H Score Prediction*/

select team1, team2, score_low, round(score_low + abs(teamlow_chance - teamhigh_chance)) as score_high, (case when greatest(teamhigh_chance, teamlow_chance) = teamhigh_chance then bigger else smaller end) as winner
from
  (select team1, team2, (least(team1_stat, team2_stat) * dbms_random.value()) as teamlow_chance, (greatest(team1_stat, team2_stat) * dbms_random.value(0,0.5)) as teamhigh_chance,  (round(dbms_random.value() * 8) + 1) as score_low, (case when greatest(team1_stat, team2_stat) = team1_stat then team1 else team2 end) as bigger, (case when least(team1_stat, team2_stat) = team1_stat then team1 else team2 end) as smaller
  from
    (select team1, team2, (team_bat - team_field1 - team_pitch1) as team1_stat, (team_bat1 - team_field - team_pitch) as team2_stat
    from
      (select team_name as team1, avg(bat_stat) as team_bat
      from
        (select team_name, ((singles + (2 * doubles) + (3 * triples) + (4 * rbi) + (2 * stolen_bases) + (0.5 * hits) - (3 * strikeouts) + (4 * home_runs)) / games) as bat_stat
        from BATYEAR natural join statyear
        WHERE TEAM_NAME='Texas Rangers' and SEASON_YEAR='2002')
      group by team_name),
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
      (select team_name as team2, avg(bat_stat) as team_bat1
      from
        (select team_name, ((singles + (2 * doubles) + (3 * triples) + (4 * rbi) + (2 * stolen_bases) + (0.5 * hits) - (3 * strikeouts) + (4 * home_runs)) / games) as bat_stat
        from BATYEAR natural join statyear
        WHERE TEAM_NAME='Houston Astros' and SEASON_YEAR='2002')
      group by team_name),
      (select avg(field_stat) as team_field1
      from
        (select ((putouts + (1.5 * assists) - (2 * errors) + (3 * double_plays)) / games) as field_stat
        from FIELDYEAR natural join statyear
        WHERE TEAM_NAME='Houston Astros' and SEASON_YEAR='2002')),
      (select avg(pitch_stat) as team_pitch1
      from
        (select ((outs + (5 * shutouts) - (2 * homeruns) - walks + strikeouts) / games) as pitch_stat
        from PITCHYEAR natural join statyear
        WHERE TEAM_NAME='Houston Astros' and SEASON_YEAR='2002'))));

-------------------------------------------------------------------------

/*SEASON SIMULATION*/

select team1, team2, score_low, round(score_low + abs(teamlow_chance - teamhigh_chance)) as score_high, (case when greatest(teamhigh_chance, teamlow_chance) = teamhigh_chance then bigger else smaller end) as winner
from
  (select team1, team2, (least(team1_stat, team2_stat) * dbms_random.value()) as teamlow_chance, (greatest(team1_stat, team2_stat) * dbms_random.value(0,0.5)) as teamhigh_chance,  (round(dbms_random.value() * 8) + 1) as score_low, (case when greatest(team1_stat, team2_stat) = team1_stat then team1 else team2 end) as bigger, (case when least(team1_stat, team2_stat) = team1_stat then team1 else team2 end) as smaller
  from
    (select team1, (team_bat - team_field1 - team_pitch1) as team1_stat, team2, (team_bat1 - team_field - team_pitch) as team2_stat
    from
      ((select team_name as team1, avg(bat_stat) as team_bat
      from
        (select team_name, ((singles + (2 * doubles) + (3 * triples) + (4 * rbi) + (2 * stolen_bases) + (0.5 * hits) - (3 * strikeouts) + (4 * home_runs)) / games) as bat_stat
        from BATYEAR natural join statyear
        WHERE SEASON_YEAR='2002')
      group by team_name) natural join
      (select team_name as team1, avg(field_stat) as team_field
      from
        (select team_name, ((putouts + (1.5 * assists) - (2 * errors) + (3 * double_plays)) / games) as field_stat
        from FIELDYEAR natural join statyear
        WHERE SEASON_YEAR='2002')
      group by team_name) natural join
      (select team_name as team1, avg(pitch_stat) as team_pitch
      from
        (select team_name, ((outs + (5 * shutouts) - (2 * homeruns) - walks + strikeouts) / games) as pitch_stat
        from PITCHYEAR natural join statyear
        WHERE SEASON_YEAR='2002')
      group by team_name)),
      ((select team_name as team2, avg(bat_stat) as team_bat1
      from
        (select team_name, ((singles + (2 * doubles) + (3 * triples) + (4 * rbi) + (2 * stolen_bases) + (0.5 * hits) - (3 * strikeouts) + (4 * home_runs)) / games) as bat_stat
        from BATYEAR natural join statyear
        WHERE SEASON_YEAR='2002')
      group by team_name) natural join
      (select team_name as team2, avg(field_stat) as team_field1
      from
        (select team_name, ((putouts + (1.5 * assists) - (2 * errors) + (3 * double_plays)) / games) as field_stat
        from FIELDYEAR natural join statyear
        WHERE SEASON_YEAR='2002')
      group by team_name) natural join
      (select team_name as team2, avg(pitch_stat) as team_pitch1
      from
        (select team_name, ((outs + (5 * shutouts) - (2 * homeruns) - walks + strikeouts) / games) as pitch_stat
        from PITCHYEAR natural join statyear
        WHERE SEASON_YEAR='2002')
      group by team_name))
      where team1 != team2));

-------------------------------------------------------------------

/*H2H score prediction for user team*/

select team1, team2, score_low, round(score_low + abs(teamlow_chance - teamhigh_chance)) as score_high, (case when greatest(teamhigh_chance, teamlow_chance) = teamhigh_chance then bigger else smaller end) as winner
from
  (select team1, team2, (least(team1_stat, team2_stat) * dbms_random.value()) as teamlow_chance, (greatest(team1_stat, team2_stat) * dbms_random.value(0,0.5)) as teamhigh_chance,  (round(dbms_random.value() * 8) + 1) as score_low, (case when greatest(team1_stat, team2_stat) = team1_stat then team1 else team2 end) as bigger, (case when least(team1_stat, team2_stat) = team1_stat then team1 else team2 end) as smaller
  from
    (select team1, team2, (team_bat - team_field1 - team_pitch1) as team1_stat, (team_bat1 - team_field - team_pitch) as team2_stat
    from
      (select name as team1, avg(bat_stat) as team_bat
      from
        (select pid, avg((singles + (2 * doubles) + (3 * triples) + (4 * rbi) + (2 * stolen_bases) + (0.5 * hits) - (3 * strikeouts) + (4 * home_runs)) / games) as bat_stat
        from BATYEAR natural join statyear
        WHERE PID IN (select PID from PLAYERUSERTEAM PL where PL.name = 'Team 1' and PL.user_email='test@test.com')
        group by pid),
        (select name from playeruserteam where name = 'Team 1' and user_email='test@test.com')
      group by name),
      (select avg(field_stat) as team_field
      from
        (select ((putouts + (1.5 * assists) - (2 * errors) + (3 * double_plays)) / games) as field_stat
        from FIELDYEAR natural join statyear
        WHERE PID IN (select PID from PLAYERUSERTEAM PL where PL.name = 'Team 1' and PL.user_email='test@test.com'))),
      (select avg(pitch_stat) as team_pitch
      from
        (select ((outs + (5 * shutouts) - (2 * homeruns) - walks + strikeouts) / games) as pitch_stat
        from PITCHYEAR natural join statyear
        WHERE PID IN (select PID from PLAYERUSERTEAM PL where PL.name = 'Team 1' and PL.user_email='test@test.com'))),
      (select name as team2, avg(bat_stat) as team_bat1
      from
        (select pid, avg((singles + (2 * doubles) + (3 * triples) + (4 * rbi) + (2 * stolen_bases) + (0.5 * hits) - (3 * strikeouts) + (4 * home_runs)) / games) as bat_stat
        from BATYEAR natural join statyear
        WHERE PID IN (select PID from PLAYERUSERTEAM PL where PL.name = 'Team 2' and PL.user_email='test@test.com')
        group by pid),
        (select name from playeruserteam where name = 'Team 2' and user_email='test@test.com')
      group by name),
      (select avg(field_stat) as team_field1
      from
        (select ((putouts + (1.5 * assists) - (2 * errors) + (3 * double_plays)) / games) as field_stat
        from FIELDYEAR natural join statyear
        WHERE PID IN (select PID from PLAYERUSERTEAM PL where PL.name = 'Team 2' and PL.user_email='test@test.com'))),
      (select avg(pitch_stat) as team_pitch1
      from
        (select ((outs + (5 * shutouts) - (2 * homeruns) - walks + strikeouts) / games) as pitch_stat
        from PITCHYEAR natural join statyear
        WHERE PID IN (select PID from PLAYERUSERTEAM PL where PL.name = 'Team 2' and PL.user_email='test@test.com')))));

-----------------------------------------------------------------------

/*Player Impact Analyser modified for player value analyser*/

select pid, (bat_play / bat_tot) as bat_stat, (field_play / field_tot) as field_stat, (pitch_play / pitch_tot) as pitch_stat
from
  (select avg(stat / tot) as bat_tot
  from
    (select (sum(singles) + (2 * sum(doubles)) + (3 * sum(triples)) + (4 * sum(rbi)) + (2 * sum(stolen_bases)) + (0.5 * sum(hits)) - (3 * sum(strikeouts)) + (4 * sum(home_runs))) as stat
    from BATYEAR A),
    (select sum(games) as tot
    from statyear C)),
  (select avg(stat / tot) as field_tot
  from
    (select (sum(putouts) + (1.5 * sum(assists)) - (2 * sum(errors)) + (3 * sum (double_plays))) as stat
    from FIELDYEAR A),
    (select sum(games) as tot
    from statyear C)),
  (select avg(stat / tot) as pitch_tot
  from
    (select (sum(outs) + (5 * sum(shutouts)) - (2 * sum(homeruns)) - sum(walks) + sum(strikeouts)) as stat
    from PITCHYEAR A),
    (select sum(games) as tot
    from statyear C)),
  ((select pid, avg(stat / tot) as bat_play
  from
    (select pid, (sum(singles) + (2 * sum(doubles)) + (3 * sum(triples)) + (4 * sum(rbi)) + (2 * sum(stolen_bases)) + (0.5 * sum(hits)) - (3 * sum(strikeouts)) + (4 * sum(home_runs))) as stat
    from BATYEAR
    group by PID) natural join
    (select pid, sum(games) as tot
    from statyear
    group by PID)
  group by pid) natural join
  (select pid, avg(stat / tot) as field_play
  from
    (select pid, (sum(putouts) + (1.5 * sum(assists)) - (2 * sum(errors)) + (3 * sum (double_plays))) as stat
    from FIELDYEAR
    group by PID) natural join
    (select pid, sum(games) as tot
    from statyear
    group by PID)
  group by pid) natural join
  (select pid, avg(stat / tot) as pitch_play
  from
    (select pid, (sum(outs) + (5 * sum(shutouts)) - (2 * sum(homeruns)) - sum(walks) + sum(strikeouts)) as stat
    from PITCHYEAR
    group by PID) natural join
    (select pid, sum(games) as tot
    from statyear
    group by PID)
  group by pid));
  
-------------------------------------------------------------