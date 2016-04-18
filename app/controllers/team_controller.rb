class TeamController < ApplicationController
  before_filter :authenticate_user

  def h2h_score
    query = %{
      SELECT DISTINCT name FROM Team
    }

    @teams = exec(query).results
    @teams.map!(&:first).sort!
  end

  def h2h_score_results
    query = %{
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
              WHERE TEAM_NAME='#{params[:team1]}' and SEASON_YEAR='#{params[:year1]}')
            group by team_name),
            (select avg(field_stat) as team_field
            from
              (select ((putouts + (1.5 * assists) - (2 * errors) + (3 * double_plays)) / games) as field_stat
              from FIELDYEAR natural join statyear
              WHERE TEAM_NAME='#{params[:team1]}' and SEASON_YEAR='#{params[:year1]}')),
            (select avg(pitch_stat) as team_pitch
            from
              (select ((outs + (5 * shutouts) - (2 * homeruns) - walks + strikeouts) / games) as pitch_stat
              from PITCHYEAR natural join statyear
              WHERE TEAM_NAME='#{params[:team1]}' and SEASON_YEAR='#{params[:year1]}')),
            (select team_name as team2, avg(bat_stat) as team_bat1
            from
              (select team_name, ((singles + (2 * doubles) + (3 * triples) + (4 * rbi) + (2 * stolen_bases) + (0.5 * hits) - (3 * strikeouts) + (4 * home_runs)) / games) as bat_stat
              from BATYEAR natural join statyear
              WHERE TEAM_NAME='#{params[:team2]}' and SEASON_YEAR='#{params[:year2]}')
            group by team_name),
            (select avg(field_stat) as team_field1
            from
              (select ((putouts + (1.5 * assists) - (2 * errors) + (3 * double_plays)) / games) as field_stat
              from FIELDYEAR natural join statyear
              WHERE TEAM_NAME='#{params[:team2]}' and SEASON_YEAR='#{params[:year2]}')),
            (select avg(pitch_stat) as team_pitch1
            from
              (select ((outs + (5 * shutouts) - (2 * homeruns) - walks + strikeouts) / games) as pitch_stat
              from PITCHYEAR natural join statyear
              WHERE TEAM_NAME='#{params[:team2]}' and SEASON_YEAR='#{params[:year2]}'))))

    }

    @teams = ["#{params[:year1]} #{params[:team1]}", "#{params[:year2]} #{params[:team2]}"]
    @result = exec(query)

    if @result.results.first[4] == @result.results.first[0]
      @result.results.first[2], @result.results.first[3] = @result.results.first[3], @result.results.first[2]
    end

    query = %{
      SELECT SUM(PitchYear.homeruns), SUM(PitchYear.strikeouts), SUM(PitchYear.shutouts), SUM(PitchYear.walks),
             SUM(FieldYear.putouts), SUM(FieldYear.assists), SUM(FieldYear.errors), SUM(FieldYear.double_plays),
             SUM(BatYear.home_runs), SUM(BatYear.hits), SUM(BatYear.rbi), SUM(BatYear.strikeouts)
      FROM statyear
      LEFT JOIN PitchYear ON 
        StatYear.pid = PitchYear.pid AND
        StatYear.season_year = PitchYear.season_year AND
        StatYear.stint = PitchYear.stint
      LEFT JOIN BatYear ON
        StatYear.pid = BatYear.pid AND
        StatYear.season_year = BatYear.season_year AND
        StatYear.stint = BatYear.stint
      LEFT JOIN FieldYear ON
        StatYear.pid = FieldYear.pid AND
        StatYear.season_year = FieldYear.season_year AND
        StatYear.stint = FieldYear.stint

      WHERE StatYear.team_name = :1 AND StatYear.season_year = :2
    }

    @stats1 = exec(query, params[:team1], params[:year1])
    @stats2 = exec(query, params[:team2], params[:year2])
  end

  def h2h_user
    query = %{
      SELECT user_email, name FROM UserTeam
    }

    @teams = exec(query).results
    @teams.map!{|x| "#{x.second} (#{x.first})"}.sort!
  end  

  def h2h_user_results
    email1 = params[:team1].scan(/\(\S+\)/)[0][1..-2]
    email2 = params[:team2].scan(/\(\S+\)/)[0][1..-2]
    team1 = params[:team1].scan(/\A.+\(/)[0][0..-3]
    team2 = params[:team2].scan(/\A.+\(/)[0][0..-3]

    query = %{
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
              WHERE PID IN (select PID from PLAYERUSERTEAM PL where PL.name = '#{team1}' and PL.user_email='#{email1}')
              group by pid),
              (select name from playeruserteam where name = '#{team1}' and user_email='#{email1}')
            group by name),
            (select avg(field_stat) as team_field
            from
              (select ((putouts + (1.5 * assists) - (2 * errors) + (3 * double_plays)) / games) as field_stat
              from FIELDYEAR natural join statyear
              WHERE PID IN (select PID from PLAYERUSERTEAM PL where PL.name = '#{team1}' and PL.user_email='#{email1}'))),
            (select avg(pitch_stat) as team_pitch
            from
              (select ((outs + (5 * shutouts) - (2 * homeruns) - walks + strikeouts) / games) as pitch_stat
              from PITCHYEAR natural join statyear
              WHERE PID IN (select PID from PLAYERUSERTEAM PL where PL.name = '#{team1}' and PL.user_email='#{email1}'))),
            (select name as team2, avg(bat_stat) as team_bat1
            from
              (select pid, avg((singles + (2 * doubles) + (3 * triples) + (4 * rbi) + (2 * stolen_bases) + (0.5 * hits) - (3 * strikeouts) + (4 * home_runs)) / games) as bat_stat
              from BATYEAR natural join statyear
              WHERE PID IN (select PID from PLAYERUSERTEAM PL where PL.name = '#{team2}' and PL.user_email='#{email2}')
              group by pid),
              (select name from playeruserteam where name = '#{team2}' and user_email='#{email2}')
            group by name),
            (select avg(field_stat) as team_field1
            from
              (select ((putouts + (1.5 * assists) - (2 * errors) + (3 * double_plays)) / games) as field_stat
              from FIELDYEAR natural join statyear
              WHERE PID IN (select PID from PLAYERUSERTEAM PL where PL.name = '#{team2}' and PL.user_email='#{email2}'))),
            (select avg(pitch_stat) as team_pitch1
            from
              (select ((outs + (5 * shutouts) - (2 * homeruns) - walks + strikeouts) / games) as pitch_stat
              from PITCHYEAR natural join statyear
              WHERE PID IN (select PID from PLAYERUSERTEAM PL where PL.name = '#{team2}' and PL.user_email='#{email2}')))))
    }

    @teams = ["#{params[:team1]}", "#{params[:team2]}"]
    @result = exec(query)

    if @result.results.first[4] == @result.results.first[0]
      @result.results.first[2], @result.results.first[3] = @result.results.first[3], @result.results.first[2]
    end

    query = %{
      SELECT SUM(PitchYear.homeruns), SUM(PitchYear.strikeouts), SUM(PitchYear.shutouts), SUM(PitchYear.walks),
             SUM(FieldYear.putouts), SUM(FieldYear.assists), SUM(FieldYear.errors), SUM(FieldYear.double_plays),
             SUM(BatYear.home_runs), SUM(BatYear.hits), SUM(BatYear.rbi), SUM(BatYear.strikeouts)
      FROM PlayerUserTeam
      JOIN StatYear ON PlayerUserTeam.pid = StatYear.pid
      LEFT JOIN PitchYear ON 
        StatYear.pid = PitchYear.pid AND
        StatYear.season_year = PitchYear.season_year AND
        StatYear.stint = PitchYear.stint
      LEFT JOIN BatYear ON
        StatYear.pid = BatYear.pid AND
        StatYear.season_year = BatYear.season_year AND
        StatYear.stint = BatYear.stint
      LEFT JOIN FieldYear ON
        StatYear.pid = FieldYear.pid AND
        StatYear.season_year = FieldYear.season_year AND
        StatYear.stint = FieldYear.stint

      WHERE PlayerUserTeam.user_email = :1 AND PlayerUserTeam.name = :2
    }
    
    @stats1 = exec(query, email1, team1)
    @stats2 = exec(query, email2, team2)
  end

end