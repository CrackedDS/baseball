class AppController < ApplicationController
  before_filter :authenticate_user

  def home; end

  def player_impact
    query = %{
      SELECT DISTINCT name FROM Team
    }

    @teams = exec(query)
    @teams.map!(&:first).sort!
  end


  def h2h_score
    query = %{
      SELECT DISTINCT name FROM Team
    }

    @teams = exec(query)
    @teams.map!(&:first).sort!
  end

  def season_sim

  end

  def player_value
    query = %{
      SELECT DISTINCT name FROM Team
    }

    @teams = exec(query)
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

    @teams = exec(query)
    @teams.map!(&:first).sort!
  end

end
