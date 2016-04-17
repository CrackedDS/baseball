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


  def h2h_score
    query = %{
      SELECT DISTINCT name FROM Team
    }

    @teams = exec(query).results
    @teams.map!(&:first).sort!
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
