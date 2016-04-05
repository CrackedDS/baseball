class UserManagementController < ApplicationController
  before_filter :authenticate_user

  def user_management
    conn = OCI8.new('njiang/password@oracle.cise.ufl.edu:1521/orcl')

    @teams = []

    query = %{
      SELECT Player.fname, Player.lname, UserTeam.name, SUM(StatYear.games)
      FROM UserTeam
      INNER JOIN PlayerUserTeam p1 ON 
        p1.user_email = UserTeam.user_email
        AND p1.name = UserTeam.name
      INNER JOIN Player ON Player.pid = p1.pid
      INNER JOIN StatYear ON Player.pid = StatYear.pid
      WHERE UserTeam.user_email = :1
      GROUP BY Player.fname, Player.lname, UserTeam.name
    }

    cursor = conn.exec(query, session[:user_id]) do |row|
      @teams << row
    end
    @teams = @teams.group_by{|row| row[2]}
    
    conn.logoff
  end

  def player_list
    conn = OCI8.new('njiang/password@oracle.cise.ufl.edu:1521/orcl')
    @players = []
    query = %{
      SELECT * from player 
      WHERE CONCAT(lower(fname), CONCAT(' ', lower(lname))) like :1 
    }
    cursor = conn.exec(query, "%" + params[:term].downcase + "%") do |row|
      @players << {
        label: "#{row[4]} #{row[5]}",
        value: row[0]
      }
    end

    conn.logoff

    respond_to do |format|
      format.json { render json: {players: @players } }
    end
  end


  def add_team; end

  def create_team
    conn = OCI8.new('njiang/password@oracle.cise.ufl.edu:1521/orcl')

    query = %{
      INSERT INTO UserTeam
      (user_email, name)
      VALUES
      (:1, :2)
    }
    conn.exec(query, session[:user_id], params[:team_name])

    params["selected_players"].uniq.each do |player|
      next if player == ""

      query = %{
        INSERT INTO PlayerUserTeam
        (user_email, name, pid)
        VALUES
        (:1, :2, :3)
      }

      conn.exec(query, session[:user_id], params[:team_name], player)
    end

    conn.exec("commit")
    conn.logoff
    redirect_to user_management_url
  end
end
