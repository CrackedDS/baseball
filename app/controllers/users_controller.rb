class UsersController < ApplicationController
  
  def register
    query = %{
      SELECT * FROM AppUser WHERE email = :1 
    }
    
    @row = exec(query, params["email"])

    if @row.length > 0
      flash[:alert] = "E-mail has already been used. Please try another"
      redirect_to root_url
    else
      query = %{
        INSERT INTO AppUser (email, password) VALUES (:1, :2)
      }
      exec_commit(query, params["email"], params["password"])

      session[:user_id] = params["email"]
      redirect_to home_url
    end
  end


end
