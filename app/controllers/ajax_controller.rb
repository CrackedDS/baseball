# for all utility queries (ajax requests that return json)

class AjaxController < ApplicationController
  before_filter :authenticate_user

  def player_list
    query = %{
      SELECT * from player 
      WHERE CONCAT(lower(fname), CONCAT(' ', lower(lname))) like :1 
    }
    @players = exec(query, "%#{params[:term].downcase}%")
    @players.results.map! do |player|
      {
        label: "#{player[4]} #{player[5]}",
        value: player[0]
      }
    end

    respond_to do |format|
      format.json { render json: {players: @players.results } }
    end
  end


  def player_list_team
    filter_team = "PitchYear" if params[:filter] == "0"
    filter_team = "BatYear" if params[:filter] == "1"
    filter_team = "FieldYear" if params[:filter] == "2"

    query = %{
      SELECT DISTINCT player.fname, player.lname, player.pid from player 
      INNER JOIN StatYear on player.pid = StatYear.pid
      INNER JOIN #{filter_team} on StatYear.pid = #{filter_team}.pid AND
        StatYear.season_year = #{filter_team}.season_year AND
        StatYear.stint = #{filter_team}.stint
      WHERE StatYear.team_name = :1
      ORDER BY player.lname ASC
    }

    @players = exec(query, params[:term])
    @players.results.map! do |player|
      {
        label: "#{player[0]} #{player[1]}",
        value: player[2]
      }
    end

    respond_to do |format|
      format.json { render json: {players: @players.results } }
    end
  end

  def player_list_team_salary
    filter_team = "PitchYear" if params[:filter] == "0"
    filter_team = "BatYear" if params[:filter] == "1"
    filter_team = "FieldYear" if params[:filter] == "2"

    query = %{
      SELECT DISTINCT player.fname, player.lname, player.pid from player 
      INNER JOIN StatYear on player.pid = StatYear.pid
      INNER JOIN #{filter_team} on StatYear.pid = #{filter_team}.pid AND
        StatYear.season_year = #{filter_team}.season_year AND
        StatYear.stint = #{filter_team}.stint
      WHERE StatYear.team_name = :1 AND
      StatYear.salary IS NOT NULL
      ORDER BY player.lname ASC
    }

    @players = exec(query, params[:term])
    @players.results.map! do |player|
      {
        label: "#{player[0]} #{player[1]}",
        value: player[2]
      }
    end

    respond_to do |format|
      format.json { render json: {players: @players.results } }
    end
  end

  def manager_list_team
    query = %{
      SELECT DISTINCT manager.fname, manager.lname, manager.mid from manager 
      INNER JOIN ManagerYear on manager.mid = ManagerYear.mid
      WHERE ManagerYear.team_name = :1
    }
    @managers = exec(query, params[:term])
    @managers.results.map! do |manager|
      {
        label: "#{manager[0]} #{manager[1]}",
        value: manager[2]
      }
    end

    respond_to do |format|
      format.json { render json: {managers: @managers.results } }
    end
  end

  def year_list_team
    query = %{
      SELECT DISTINCT season_year
      FROM Team
      WHERE name = :1
      ORDER BY season_year DESC
    }
    @years = exec(query, params[:term])
    @years.results.map! do |year|
      {
        label: year[0],
        value: year[0]
      }
    end

    respond_to do |format|
      format.json { render json: {years: @years.results } }
    end


  end

end
