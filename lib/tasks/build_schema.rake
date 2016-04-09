namespace :db do
  def build_schema
    begin
      $conn.exec %{
        DROP INDEX statyear_teamname
      }
    rescue
    end

    tables = []
    cursor = $conn.exec %{
      SELECT 'DROP TABLE ' || table_name || ' CASCADE CONSTRAINTS' FROM user_tables 
      WHERE table_name IN ('PLAYER', 'APPUSER', 'MANAGER', 'SEASON', 'TEAM', 
        'MANAGERYEAR', 'SALARY', 'USERTEAM', 'PLAYERUSERTEAM', 'STATYEAR',
        'PITCHYEAR', 'FIELDYEAR', 'BATYEAR') 
    } do |row|
      tables << row.first
    end

    tables.each do |del_query|
      $conn.exec del_query
    end

    $conn.exec %{
      CREATE TABLE Player (
        pid varchar(255) PRIMARY KEY,
        dob date,
        height int,
        weight int,
        fname varchar(100),
        lname varchar(100),
        bat char,
        throw char
      )
    }

    $conn.exec %{
      CREATE TABLE AppUser (
        email varchar(255) PRIMARY KEY,
        password varchar(255)
      )
    }

    $conn.exec %{
      CREATE TABLE Manager (
        mid varchar(255) PRIMARY KEY,
        dob date,
        fname varchar(100),
        lname varchar(100)
      )
    }

    $conn.exec %{
      CREATE TABLE Season (
        year int PRIMARY KEY
      )
    }

    (1871..2013).each do |year|
        $conn.exec %{
            INSERT INTO Season
            (year) VALUES (#{year})
        }
    end

    $conn.exec %{
      CREATE TABLE Team (
        name varchar(255),
        season_year int,
        wins int,
        losses int,
        rank int,
        constraint PK_TEAM PRIMARY KEY (name, season_year),
        constraint FK_TEAM_1 FOREIGN KEY (season_year) REFERENCES Season(year)
      )
    }

    $conn.exec %{
      CREATE TABLE ManagerYear (
        team_name varchar(255),
        season_year int,
        mid varchar(255),
        inseason int,
        games int,
        wins int,
        losses int,
        rank int,
        constraint PK_MANAGER_YEAR PRIMARY KEY (team_name, season_year, mid),
        constraint FK_MANAGER_YEAR_1 FOREIGN KEY (team_name, season_year) REFERENCES Team(name, season_year),
        constraint FK_MANAGER_YEAR_2 FOREIGN KEY (season_year) REFERENCES Season(year),
        constraint FK_MANAGER_YEAR_3 FOREIGN KEY (mid) REFERENCES Manager(mid)
      )
    }

    $conn.exec %{
      CREATE TABLE UserTeam (
        user_email varchar(255),
        name varchar(255),
        constraint PK_USER_TEAM PRIMARY KEY (user_email, name),
        constraint FK_USER_TEAM_1 FOREIGN KEY (user_email) REFERENCES AppUser(email)
      )
    }

    $conn.exec %{
      CREATE TABLE PlayerUserTeam (
        user_email varchar(255),
        name varchar(255),
        pid varchar(255),
        constraint PK_PLAYER_USER_TEAM PRIMARY KEY (user_email, pid, name),
        constraint FK_PLAYER_USER_TEAM_1 FOREIGN KEY (user_email, name) REFERENCES UserTeam(user_email, name),
        constraint FK_PLAYER_USER_TEAM_2 FOREIGN KEY (pid) REFERENCES Player(pid)
      )
    }

    $conn.exec %{
      CREATE TABLE StatYear (
        season_year int,
        pid varchar(255),
        team_name varchar(255),
        stint int,
        games int,
        salary int,
        constraint PK_STAT_YEAR PRIMARY KEY (season_year, pid, stint),
        constraint FK_STAT_YEAR_1 FOREIGN KEY (season_year) REFERENCES Season(year),
        constraint FK_STAT_YEAR_2 FOREIGN KEY (pid) REFERENCES Player(pid),
        constraint FK_STAT_YEAR_3 FOREIGN KEY (team_name, season_year) REFERENCES Team(name, season_year)
      )
    }

    $conn.exec %{
      CREATE TABLE PitchYear (
        season_year int,
        pid varchar(255),
        stint int,
        team_name varchar(255),
        wins int,
        losses int,
        saves int,
        outs int,
        shutouts int,
        homeruns int,
        walks int,
        strikeouts int,
        constraint PK_PITCH_YEAR PRIMARY KEY (season_year, pid, stint),
        constraint FK_PITCH_YEAR_1 FOREIGN KEY (season_year) REFERENCES Season(year),
        constraint FK_PITCH_YEAR_2 FOREIGN KEY (pid) REFERENCES Player(pid),
        constraint FK_PITCH_YEAR_3 FOREIGN KEY (team_name, season_year) REFERENCES Team(name, season_year)
      )
    }

    $conn.exec %{
      CREATE TABLE FieldYear (
        season_year int,
        pid varchar(255),
        stint int,
        team_name varchar(255),
        putouts int,
        assists int,
        errors int,
        double_plays int,
        zone_rating int,
        constraint PK_FIELD_YEAR PRIMARY KEY (season_year, pid, stint),
        constraint FK_FIELD_YEAR_1 FOREIGN KEY (season_year) REFERENCES Season(year),
        constraint FK_FIELD_YEAR_2 FOREIGN KEY (pid) REFERENCES Player(pid),
        constraint FK_FIELD_YEAR_3 FOREIGN KEY (team_name, season_year) REFERENCES Team(name, season_year)
      )
    }

    $conn.exec %{
      CREATE TABLE BatYear (
        season_year int,
        pid varchar(255),
        stint int,
        team_name varchar(255),
        singles int,
        doubles int,
        triples int,
        home_runs int,
        hits int,
        rbi int,
        stolen_bases int,
        strikeouts int,
        constraint PK_BAT_YEAR PRIMARY KEY (season_year, pid, stint),
        constraint FK_BAT_YEAR_1 FOREIGN KEY (season_year) REFERENCES Season(year),
        constraint FK_BAT_YEAR_2 FOREIGN KEY (pid) REFERENCES Player(pid),
        constraint FK_BAT_YEAR_3 FOREIGN KEY (team_name, season_year) REFERENCES Team(name, season_year)
      )
    }

    $conn.exec %{
      "CREATE INDEX statyear_teamname ON StatYear(team_name)"
    %}

  end


end