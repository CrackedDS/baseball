class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception


  protected 
  def authenticate_user
    if session[:user_id]
      return true 
    else
      flash[:alert] = "You must be logged in to view this page!"
      redirect_to root_url
      return false
    end
  end


  def exec(query, *args)
    conn = OCI8.new('njiang/password@oracle.cise.ufl.edu:1521/orcl')
    result = Result.new
    result.results = []

    begin
      cursor = conn.exec(query, *args)
      result.columns = cursor.get_col_names

      while r = cursor.fetch()
        result.results << r
      end

    rescue => e
      puts "QUERY ERROR: #{t.to_s}"
    ensure
      conn.logoff
    end
    return result
  end

  def exec_commit(query, *args)
    conn = OCI8.new('njiang/password@oracle.cise.ufl.edu:1521/orcl')
    begin
      conn.exec(query, *args)
      conn.exec("COMMIT")
    rescue => e
      puts "QUERY ERROR: #{t.to_s}"
    ensure
      conn.logoff
    end
  end
end


