namespace :db do
  def sy_key(hash)
    "#{hash["playerID"]}#{hash["yearID"]}#{hash["stint"]}"
  end

  def load_stat_files
    $fielding = read_and_parse("csv/fielding.csv")
      .group_by{|x| [x["playerID"], x["yearID"], x["stint"]]}
      .map do |x|
        res = x.second.first.to_h
        x.second.each_with_index do |stat, index|
          next if (index == 0) 
          res["G"] = [stat["G"].to_i, res["G"].to_i].max
          res["GS"] = [stat["GS"].to_i, res["GS"].to_i].max
          ["InnOuts","PO","A","E","DP","PB","WP","SB","CS","ZR"].each do |key|
            res[key] = res[key].to_i
            res[key] += stat[key].to_i
          end
        end
        res
      end
    $pitching = read_and_parse("csv/pitching.csv").map(&:to_h)
    $batting = read_and_parse("csv/batting.csv").map(&:to_h)
    $salaries = read_and_parse("csv/salaries.csv").map{|row| ["#{row[0]}#{row[1]}#{row[3]}", row.to_h["salary"]]}.to_h
    $set = Set.new
    puts "\tStats parsed"
  end

  def insert_fielding
    fielding_added = 0
    sy_added = 0

    $fielding.each do |hash|
      if !$set.include?(sy_key(hash))
        sal_key = "#{hash["yearID"]}#{hash["teamID"]}#{hash["playerID"]}"
        query = %{
          INSERT INTO StatYear
          (season_year, pid, team_name, stint, games, salary)
          VALUES
          (
            #{int_or_null hash["yearID"]},
            #{str_or_null hash["playerID"]},
            #{str_or_null team_name(hash["yearID"] + hash["teamID"])},
            #{int_or_null hash["stint"]},
            #{int_or_null hash["G"]},
            #{int_or_null $salaries[sal_key]}
          )
        }
        begin
          $conn.exec query
        rescue
          puts "\tFailed to insert stat year #{sy_key(hash)}"
          next
        end
        puts ($salaries[hash["yearID"] + hash["teamID"] + hash["playerID"]])
        puts "\tInserted stat year #{sy_key(hash)}"
        sy_added += 1
      end


      query = %{
        INSERT INTO FieldYear
        (season_year, pid, stint, team_name, putouts, assists, errors, double_plays, zone_rating)
        VALUES
        (
          #{int_or_null hash["yearID"]},
          #{str_or_null hash["playerID"]},
          #{int_or_null hash["stint"]},
          #{str_or_null team_name(hash["yearID"] + hash["teamID"])},
          #{int_or_null hash["PO"]},
          #{int_or_null hash["A"]},
          #{int_or_null hash["E"]},
          #{int_or_null hash["DP"]},
          #{int_or_null hash["ZR"]}
        )
      }

      begin
        $conn.exec query
      rescue
        puts "\tFailed to insert field year #{sy_key(hash)}"
        next
      end

      puts "\tInserted field year #{sy_key(hash)}"
      fielding_added += 1
    end

    commit
    puts "Added #{sy_added} stat years"
    puts "Added #{fielding_added} field years"
  end

  def insert_pitching
    pitching_added = 0
    sy_added = 0

    $pitching.each do |hash|
      if !$set.include?(sy_key(hash))
        sal_key = "#{hash["yearID"]}#{hash["teamID"]}#{hash["playerID"]}"
        query = %{
          INSERT INTO StatYear
          (season_year, pid, team_name, stint, games, salary)
          VALUES
          (
            #{int_or_null hash["yearID"]},
            #{str_or_null hash["playerID"]},
            #{str_or_null team_name(hash["yearID"] + hash["teamID"])},
            #{int_or_null hash["stint"]},
            #{int_or_null hash["G"]},
            #{int_or_null $salaries[sal_key]}
          )
        }

        begin
          $conn.exec query
        rescue
          byebug
          puts "\tFailed to insert stat year #{sy_key(hash)}"
          next
        end
        puts "\tInserted stat year #{sy_key(hash)}"
        sy_added += 1
      end


      query = %{
        INSERT INTO PitchYear
        (season_year, pid, stint, team_name, wins, losses, saves, outs, shutouts, homeruns, walks, strikeouts)
        VALUES
        (
          #{int_or_null hash["yearID"]},
          #{str_or_null hash["playerID"]},
          #{int_or_null hash["stint"]},
          #{str_or_null team_name(hash["yearID"] + hash["teamID"])},
          #{int_or_null hash["W"]},
          #{int_or_null hash["L"]},
          #{int_or_null hash["SV"]},
          #{int_or_null hash["IPOuts"]},
          #{int_or_null hash["SHO"]},
          #{int_or_null hash["HR"]},
          #{int_or_null hash["BB"]},
          #{int_or_null hash["SO"]}
        )
      }

      begin
        $conn.exec query
      rescue
        byebug
        puts "\tFailed to insert pitch year #{sy_key(hash)}"
        next
      end
      puts "\tInserted pitch year #{sy_key(hash)}"
      pitching_added += 1

    end
    byebug
    commit
    puts "Added #{sy_added} stat years"
    puts "Added #{pitching_added} field years"
  end


  def insert_batting
    batting_added = 0
    sy_added = 0

    $batting.each do |hash|
      if !$set.include?(sy_key(hash))
        sal_key = "#{hash["yearID"]}#{hash["teamID"]}#{hash["playerID"]}"
        query = %{
          INSERT INTO StatYear
          (season_year, pid, team_name, stint, games, salary)
          VALUES
          (
            #{int_or_null hash["yearID"]},
            #{str_or_null hash["playerID"]},
            #{str_or_null team_name(hash["yearID"] + hash["teamID"])},
            #{int_or_null hash["stint"]},
            #{int_or_null hash["G"]},
            #{int_or_null $salaries[sal_key]}
          )
        }

        begin
          $conn.exec query
        rescue
          byebug
          puts "\tFailed to insert stat year #{sy_key(hash)}"
          next
        end
        puts "\tInserted stat year #{sy_key(hash)}"
        sy_added += 1
      end


      query = %{
        INSERT INTO BatYear
        (season_year, pid, stint, team_name, singles, doubles, triples, home_runs, hits, rbi, stolen_bases, strikeouts)  
        VALUES
        (
          #{int_or_null hash["yearID"]},
          #{str_or_null hash["playerID"]},
          #{int_or_null hash["stint"]},
          #{str_or_null team_name(hash["yearID"] + hash["teamID"])},
          #{int_or_null hash["H"]},
          #{int_or_null hash["2B"]},
          #{int_or_null hash["3B"]},
          #{int_or_null hash["HR"]},
          #{int_or_null hash["RBI"]},
          #{int_or_null hash["HR"]},
          #{int_or_null hash["SB"]},
          #{int_or_null hash["SO"]}
        )
      }

      begin
        $conn.exec query
      rescue
        byebug
        puts "\tFailed to insert bat year #{sy_key(hash)}"
        next
      end
      puts "\tInserted bat year #{sy_key(hash)}"
      batting_added += 1
    end
    byebug
    commit
    puts "Added #{sy_added} stat years"
    puts "Added #{batting_added} bat years"
  end
end