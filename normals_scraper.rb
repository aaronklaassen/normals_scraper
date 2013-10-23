require "rubygems"
require "httparty"
require "nokogiri"
require "sqlite3"

include HTTParty

WINNIPEG_URL = "http://weather.gc.ca/city/pages/mb-38_metric_e.html"

page = Nokogiri::HTML(self.class.get(WINNIPEG_URL))

# This is yesterday's data.
actual_html = page.css("#data .leftCol dd")
actual_html.shift
high_actual = actual_html.shift.inner_text.split("°").first
low_actual  = actual_html.shift.inner_text.split("°").first

# Today
normals_html = page.css("#data .middleCol dd")
normals_html.shift # get rid of the "nodata" placeholder
high_normal = normals_html.shift.inner_text.split("°").first
low_normal  = normals_html.shift.inner_text.split("°").first

begin
    
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
                VALUES ('#{Date.today}', #{low_normal}, #{high_normal})"

  db.execute "UPDATE temperatures
                SET low_actual = #{low_actual}, high_actual = #{high_actual}
              WHERE date='#{Date.today - 1}'"

rescue SQLite3::Exception => e 
  puts "DB error"
  puts e
ensure
  db.close if db
end