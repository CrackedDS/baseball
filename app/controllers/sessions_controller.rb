class SessionsController < ApplicationController
  def login
    query = %{
      SELECT * FROM appuser WHERE email = :1 AND password = :2
    }
    
    @row = exec(query, params["email"], params["password"])

    if @row.size > 0
      session[:user_id] = @row.first.first
      flash[:notice] = "Welcome back!"
      redirect_to home_url
    else
      flash[:alert] = "Invalid Username or Password"
      redirect_to root_url
    end
  end

  def logout
    session[:user_id] = nil
    flash[:notice] = "Logged out successfully."
    redirect_to root_url
  end
end
