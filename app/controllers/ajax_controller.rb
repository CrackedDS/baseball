# for all utility queries (ajax requests that return json)

class AjaxController < ApplicationController
  before_filter :authenticate_user

  def player_list
    query = %{
      SELECT * from player 
      WHERE CONCAT(lower(fname), CONCAT(' ', lower(lname))) like :1 
    }
    @players = exec(query, "%#{params[:term].downcase}%")
    @players.map! do |player|
      {
        label: "#{player[4]} #{player[5]}",
        value: player[0]
      }
    end

    respond_to do |format|
      format.json { render json: {players: @players } }
    end
  end


  def player_list_team
    query = %{
      SELECT DISTINCT player.fname, player.lname, player.pid from player 
      INNER JOIN StatYear on player.pid = StatYear.pid
      WHERE StatYear.team_name = :1
    }
    @players = exec(query, params[:term]).results
    @players.map! do |player|
      {
        label: "#{player[0]} #{player[1]}",
        value: player[2]
      }
    end

    respond_to do |format|
      format.json { render json: {players: @players } }
    end
  end

  def manager_list_team
    query = %{
      SELECT DISTINCT manager.fname, manager.lname, manager.mid from manager 
      INNER JOIN ManagerYear on manager.mid = ManagerYear.mid
      WHERE ManagerYear.team_name = :1
    }
    @managers = exec(query, params[:term]).results
    @managers.map! do |manager|
      {
        label: "#{manager[0]} #{manager[1]}",
        value: manager[2]
      }
    end

    respond_to do |format|
      format.json { render json: {managers: @managers } }
    end
  end

end
