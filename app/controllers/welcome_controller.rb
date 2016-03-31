class WelcomeController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def index
    conn = OCI8.new('njiang/password@oracle.cise.ufl.edu:1521/orcl')
    
    @rows = []
    cursor = conn.exec("select pid from player") do |row|
      @rows << row.first

      break if @rows.count == 10
    end

    # cursor.close
    # conn.logoff
  end

  def search
    byebug
  end

end
