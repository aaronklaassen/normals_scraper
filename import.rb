require 'csv'
require 'sqlite3'

CSV.foreach("normals.csv") do |row|
  begin
    today = Date.parse(row[0])
    high = row[1]
    low = row[2]

    db = SQLite3::Database.open "normals.db"

    db.execute  "CREATE TABLE IF NOT EXISTS temperatures
                  (
                    id          INTEGER PRIMARY KEY,
                    date        DATE,
                    low_normal  DECIMAL,
                    high_normal DECIMAL,
                    low_actual  DECIMAL,
                    high_actual DECIMAL
                  )"

    db.execute "INSERT INTO temperatures (date, low_normal, high_normal)
                  VALUES ('#{today}', #{low}, #{high})"

  rescue SQLite3::Exception => e 
    puts "DB error"
    puts e
  ensure
    db.close if db
  end
end