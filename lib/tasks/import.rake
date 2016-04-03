require 'csv' 

namespace :db do
  desc "Add Courses to Database"
  task :import => :environment do |t, args|
    $conn = OCI8.new('njiang/password@oracle.cise.ufl.edu:1521/orcl')
    load_master_files
    load_team_files
    load_stat_files

    build_schema
    puts "Schema built successfully"

    insert_teams
    puts "Teams inserted successfully"

    insert_players_and_managers
    puts "Master inserted successfully"

    insert_manager_years
    puts "Manager years inserted successfully"

    insert_fielding
    insert_pitching
    insert_batting
    puts "Field years inserted successfully"

    $conn.close
  end

  

end
