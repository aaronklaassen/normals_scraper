require "rubygems"
require "httparty"
require "nokogiri"

include HTTParty

WINNIPEG_URL = "http://weather.gc.ca/city/pages/mb-38_metric_e.html"

page = Nokogiri::HTML(self.class.get(WINNIPEG_URL))

normals_html = page.css("#data .middleCol dd")
normals_html.shift # get rid of the "nodata" placeholder

# lol
max = normals_html.shift.inner_text.split("°").first
min = normals_html.shift.inner_text.split("°").first

File.open("normals.csv", "a") do |f|
  f.write [Date.today,max,min].join(",")
  f.write "\n"
end