class UsersController < ApplicationController
  
  def register
    conn = OCI8.new('njiang/password@oracle.cise.ufl.edu:1521/orcl')

    cursor = conn.exec("select * from appuser where email = :1", params["email"]) do |row|
      @row = row
    end

    if @row
      flash[:alert] = "E-mail has already been used. Please try another"
      redirect_to root_url
    else
      conn.exec("INSERT INTO AppUser (email, password) VALUES (:1, :2)", params["email"], params["password"])
      conn.exec("commit")
      redirect_to home_url
    end
  end


end
