namespace :db do
  def load_team_files
    $teams = read_and_parse("csv/teams.csv").map{|row| [row[2], row.to_h]}.to_h
    puts "\tTeams parsed"
    $franchises = read_and_parse("csv/teamsfranchises.csv").map{|row| [row[0], row.to_h]}.to_h
    puts "\tFranchises parsed"
  end

  def insert_teams
    teams_added = 0
    $teams.each do |arr|
      team = arr[1]
      query = %{
        INSERT INTO Team
        (name, season_year, wins, losses, rank)
        VALUES
        (
          #{str_or_null $franchises[team["franchID"]]["franchName"]},
          #{int_or_null team["yearID"]},
          #{int_or_null team["W"]},
          #{int_or_null team["L"]},
          #{int_or_null team["Rank"]}
        )
      }

      begin
        $conn.exec query
      rescue
        puts "\tFailed to insert team #{team["yearID"]} #{$franchises[team["franchID"]]["franchName"]}"
        next
      end

      puts "\tInserted team #{team["yearID"]} #{$franchises[team["franchID"]]["franchName"]}"
      teams_added += 1
    end

    commit
    puts "Added #{teams_added} teams"
  end


  def load_master_files
    $master = read_and_parse("csv/master.csv").map{|row| [row[0], row.to_h]}.to_h
    puts "\tMaster parsed"

    $bat_year = read_and_parse("csv/batting.csv").map{|row| [row[0], row.to_h]}.to_h
    puts "\tBatting parsed"

    $field_year = read_and_parse("csv/fielding.csv").map{|row| [row[0], row.to_h]}.to_h
    puts "\tFielding parsed"

    $pitch_year = read_and_parse("csv/pitching.csv").map{|row| [row[0], row.to_h]}.to_h
    puts "\tPitching parsed"

    $manager_year = read_and_parse("csv/managers.csv").map{|row| [row[0], row.to_h]}.to_h
    puts "\tManagers parsed"
  end

  def insert_players_and_managers
    players_added = 0
    managers_added = 0

    $master.each do |arr|
      row = arr[1]
      # only add entries from master to player table if they have a stat year
      if ($bat_year[row["playerID"]] || $field_year[row["playerID"]] || $pitch_year[row["playerID"]])
        query = %{
          INSERT INTO Player
          (pid, dob, height, weight, fname, lname, bat, throw)
          VALUES
          (
            #{str_or_null row["playerID"]},
            #{date_or_null(row["birthYear"], row["birthMonth"], row["birthDay"])},
            #{int_or_null row["height"]},
            #{int_or_null row["weight"]},
            #{str_or_null row["nameFirst"]},
            #{str_or_null row["nameLast"]},
            #{str_or_null row["bats"]},
            #{str_or_null row["throws"]}
          )
        }

        players_added += $conn.exec query
        puts "\tInserted player #{row["nameGiven"]}"
      end

      if ($manager_year[row["playerID"]])        
        query = %{
          INSERT INTO Manager
          (mid, dob, fname, lname)
          VALUES
          (
            #{str_or_null row["playerID"]},
            #{date_or_null(row["birthYear"], row["birthMonth"], row["birthDay"])},
            #{str_or_null row["nameFirst"]},
            #{str_or_null row["nameLast"]}
          )
        }

        managers_added += $conn.exec query
        puts "\tInserted manager #{row["nameGiven"]}"
      end
    end

    commit
    puts "Added #{players_added} players"
    puts "Added #{managers_added} managers"
  end


  def insert_manager_years
    manager_years_added = 0

    $manager_year.each do |row|
      pid = row[0]
      m_year = row[1]
      team_name = team_name(m_year["teamID"])
      query = %{
        INSERT INTO ManagerYear
        (name, season_year, mid, inseason, games, wins, losses, rank) 
        VALUES
        (
          #{str_or_null team_name},
          #{int_or_null m_year["yearID"]},
          #{str_or_null pid},
          #{str_or_null m_year["inseason"]},
          #{int_or_null m_year["G"]},
          #{int_or_null m_year["W"]},
          #{int_or_null m_year["L"]}
          #{int_or_null m_year["rank"]}
        )
      }

      begin
        $conn.exec query
      rescue
        byebug
      end

      manager_years_added += 1
      puts "\tInserted manager_year #{m_year["yearID"]} #{pid}"
    end

    commit
    puts "Added #{manager_years_added} manager years"
  end
end