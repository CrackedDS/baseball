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

  def season_sim
    query = %{
      SELECT DISTINCT year FROM season
      ORDER BY year DESC
    }

    @years = exec(query).results
  end

  def season_sim_results
    query = %{
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
              WHERE SEASON_YEAR=:1)
            group by team_name) natural join
            (select team_name as team1, avg(field_stat) as team_field
            from
              (select team_name, ((putouts + (1.5 * assists) - (2 * errors) + (3 * double_plays)) / games) as field_stat
              from FIELDYEAR natural join statyear
              WHERE SEASON_YEAR=:1)
            group by team_name) natural join
            (select team_name as team1, avg(pitch_stat) as team_pitch
            from
              (select team_name, ((outs + (5 * shutouts) - (2 * homeruns) - walks + strikeouts) / games) as pitch_stat
              from PITCHYEAR natural join statyear
              WHERE SEASON_YEAR=:1)
            group by team_name)),
            ((select team_name as team2, avg(bat_stat) as team_bat1
            from
              (select team_name, ((singles + (2 * doubles) + (3 * triples) + (4 * rbi) + (2 * stolen_bases) + (0.5 * hits) - (3 * strikeouts) + (4 * home_runs)) / games) as bat_stat
              from BATYEAR natural join statyear
              WHERE SEASON_YEAR=:1)
            group by team_name) natural join
            (select team_name as team2, avg(field_stat) as team_field1
            from
              (select team_name, ((putouts + (1.5 * assists) - (2 * errors) + (3 * double_plays)) / games) as field_stat
              from FIELDYEAR natural join statyear
              WHERE SEASON_YEAR=:1)
            group by team_name) natural join
            (select team_name as team2, avg(pitch_stat) as team_pitch1
            from
              (select team_name, ((outs + (5 * shutouts) - (2 * homeruns) - walks + strikeouts) / games) as pitch_stat
              from PITCHYEAR natural join statyear
              WHERE SEASON_YEAR=:1)
            group by team_name))
            where team1 != team2))
    }

    @res = exec(query, params[:season])

    @res.results.each do |x|
      if x[4] == x[0]
        x[2], x[3] = x[3], x[2]
      end
    end

    @standings = {}

    @res.results.each do |x|
      @standings[x[0]] = [0, 0] if !@standings[x[0]]
      @standings[x[1]] = [0, 0] if !@standings[x[1]]

      if x[2] > x[3]
        @standings[x[0]][0] += 1
        @standings[x[1]][1] += 1
      else
        @standings[x[0]][1] += 1
        @standings[x[1]][0] += 1
      end
    end
  end


  def manager_evaluation
    query = %{
      SELECT DISTINCT name FROM Team
    }

    @teams = exec(query).results
    @teams.map!(&:first).sort!

  end

  def manager_evaluation_results
    query = %{
      SELECT (fname || ' ' || lname), pitcher_winrate, manager_winrate, manager_winrate / pitcher_winrate, avgw, avgl
      FROM
      (SELECT 
        CASE WHEN (SUM(wins) + SUM(losses)) = 0 THEN 0 
        ELSE SUM(wins) / (SUM(wins) + SUM(losses)) END pitcher_winrate
      FROM PitchYear p
      WHERE pid IN 
        (SELECT DISTINCT p.pid FROM ManagerYear m 
        INNER JOIN PitchYear p ON m.team_name= p.team_name and m.season_year = p.season_year
        WHERE m.mid = :1))
      ,
      (
        SELECT fname, lname, (SUM(wins) / (SUM(wins) + SUM(losses))) manager_winrate, AVG(wins) avgw, AVG(losses) avgl
        FROM ManagerYear
        INNER JOIN Manager on ManagerYear.mid = Manager.mid
        WHERE ManagerYear.mid = :1
        GROUP BY fname, lname
      )
    }

    @results1 = exec(query, params[:manager1]).results.first
    @results2 = exec(query, params[:manager2]).results.first  
  end

end
