class SessionsController < ApplicationController
  def login
    conn = OCI8.new('njiang/password@oracle.cise.ufl.edu:1521/orcl')

    cursor = conn.exec("select * from appuser where email = :1 and password = :2", params["email"], params["password"]) do |row|
      @row = row
    end

    if @row
      session[:user_id] = @row.first
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
