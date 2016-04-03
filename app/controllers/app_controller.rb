class AppController < ApplicationController
  before_filter :authenticate_user
  def home

  end

  def user_management
    conn = OCI8.new('njiang/password@oracle.cise.ufl.edu:1521/orcl')

    @teams = []

    query = %{
      SELECT Player.fname, Player.lname, UserTeam.name
      FROM UserTeam
      INNER JOIN PlayerUserTeam p1 ON p1.user_email = UserTeam.user_email
      INNER JOIN PlayerUserTeam p2 ON p2.name = UserTeam.name
      INNER JOIN Player ON Player.pid = p1.pid
      WHERE UserTeam.user_email = :1
    }

    cursor = conn.exec(query, session[:user_id]) do |row|
      @teams << row
    end
    conn.logoff

  end

  def player_list
    
    conn = OCI8.new('njiang/password@oracle.cise.ufl.edu:1521/orcl')
    @players = []
    cursor = conn.exec("select * from player where lower(lname) ilike :1", params[:term].downcase + "%") do |row|
      @players << {
        label: "#{row[4]} #{row[5]}",
        value: row[0]
      }
    end
    byebug

    conn.logoff

    respond_to do |format|
      format.json { render json: {players: @players } }
    end
  end


  def add_team; end

  def player_impact

  end


  def h2h_score

  end

  def season_sim

  end

  def player_value

  end

  def historical_player

  end

  def historical_team

  end

  def manager_evaluation

  end

end
