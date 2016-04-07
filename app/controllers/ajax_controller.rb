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

end
