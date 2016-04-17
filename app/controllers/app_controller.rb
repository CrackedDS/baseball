class AppController < ApplicationController
  before_filter :authenticate_user

  def home; end
  def test
    @res = exec(%{
select avg(sing) singles, avg(doub) doubles, avg(tri) triples,avg(rbi) rbi , avg(stol) stolenbases, avg(hit) hits , avg(strike) strikeouts, avg(hmruns) homeruns from(
select PID,sum(singles) sing, sum(doubles) doub, sum(triples) tri, sum (rbi) rbi, sum (stolen_bases) stol , sum(hits) hit, sum(home_runs) hmruns,sum(strikeouts) strike  from BATYEAR 
group by PID) union

select avg(sing) singles, avg(doub) doubles, avg(tri) triples,avg(rbi) rbi , avg(stol) stolenbases, avg(hit) hits , avg(strike) strikeouts, avg(hmruns) homeruns from(
select PID,sum(singles) sing, sum(doubles) doub, sum(triples) tri, sum (rbi) rbi, sum (stolen_bases) stol , sum(hits) hit, sum(home_runs) hmruns,sum(strikeouts) strike  from BATYEAR
group by PID having PID='adamsgl01') 
      })

  end

  def player_impact
    query = %{
      SELECT DISTINCT name FROM Team
    }

    @teams = exec(query).results
    @teams.map!(&:first).sort!
  end

  def player_impact_results
    query = %{
      
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
          having PID=:1),
          (select sum(games) as tot
          from statyear
          group by PID
          having PID=:1)),
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
          having PID=:1),
          (select sum(games) as tot
          from statyear
          group by PID
          having PID=:1)),
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
          having PID=:1),
          (select sum(games) as tot
          from statyear
          group by PID
          having PID=:1))

    }

    @impact1 = exec(query, params[:player1])
    @name1 = get_name(params[:player1])
    @impact2 = exec(query, params[:player2])
    @name2 = get_name(params[:player2])
  end


  def h2h_score
    query = %{
      SELECT DISTINCT name FROM Team
    }

    @teams = exec(query).results
    @teams.map!(&:first).sort!
  end

  def h2h_score_results
    query = %{
      select (team_bat - team_field1 - team_pitch1), (team_bat1 - team_field - team_pitch)
      from
        (select avg(bat_stat) as team_bat
        from
          (select ((singles + (2 * doubles) + (3 * triples) + (4 * rbi) + (2 * stolen_bases) + (0.5 * hits) - (3 * strikeouts) + (4 * home_runs)) / games) as bat_stat
          from BATYEAR natural join statyear
          WHERE TEAM_NAME='#{params[:team1]}' and SEASON_YEAR='#{params[:year1]}')),
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
        (select avg(bat_stat) as team_bat1
        from
          (select ((singles + (2 * doubles) + (3 * triples) + (4 * rbi) + (2 * stolen_bases) + (0.5 * hits) - (3 * strikeouts) + (4 * home_runs)) / games) as bat_stat
          from BATYEAR natural join statyear
          WHERE TEAM_NAME='#{params[:team2]}' and SEASON_YEAR='#{params[:year2]}')),
        (select avg(field_stat) as team_field1
        from
          (select ((putouts + (1.5 * assists) - (2 * errors) + (3 * double_plays)) / games) as field_stat
          from FIELDYEAR natural join statyear
          WHERE TEAM_NAME='#{params[:team2]}' and SEASON_YEAR='#{params[:year2]}')),
        (select avg(pitch_stat) as team_pitch1
        from
          (select ((outs + (5 * shutouts) - (2 * homeruns) - walks + strikeouts) / games) as pitch_stat
          from PITCHYEAR natural join statyear
          WHERE TEAM_NAME='#{params[:team2]}' and SEASON_YEAR='#{params[:year2]}'))
    }

    @teams = ["#{params[:year1]} #{params[:team1]}", "#{params[:year2]} #{params[:team2]}"]
    @result = exec(query)


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

  def season_sim

  end

  def player_value
    query = %{
      SELECT DISTINCT name FROM Team
    }

    @teams = exec(query).results
    @teams.map!(&:first).sort!
  end

  def historical_player

  end

  def historical_team

  end

  def manager_evaluation
    query = %{
      SELECT DISTINCT name FROM Team
    }

    @teams = exec(query).results
    @teams.map!(&:first).sort!

  end

end
