class PlayerController < ApplicationController
  before_filter :authenticate_user

  def player_impact
    query = %{
      SELECT DISTINCT name FROM Team
    }

    @teams = exec(query).results
    @teams.map!(&:first).sort!
  end

  def player_impact_results
    query = %{
      
      select (bat_play / bat_tot) as bat_stat, (field_play / field_tot) as field_stat, (pitch_play / pitch_tot) as pitch_stat, :1
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

  def player_value
    query = %{
      SELECT DISTINCT season_year
      FROM StatYear
      WHERE salary IS NOT NULL
    }

    @years = exec(query).results
    @years.map!(&:first).sort!
  end

  def player_value_results
    query = %{
      

    }


    @results = exec(query, params[:year])
  end

end