namespace :db do

  def str_or_null(value)
    value ? "'#{value.gsub("'", "''")}'" : "NULL"
  end

  def int_or_null(value)
    value ? "#{value}" : "NULL"
  end

  def date_or_null(year, month, day)
    if (year && month && day)
      dob = "TO_DATE('#{year}-#{month}-#{day}', 'yyyy-mm-dd')"
    else
      dob = 'NULL'
    end
  end

  def read_and_parse(filename)
    CSV.parse(File.read(filename), headers: true)
  end

  def team_name(teamid)
    return $franchises[$teams[teamid]["franchID"]]["franchName"]
  end

  def commit
    $conn.exec "COMMIT"
  end
end