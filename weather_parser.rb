require 'json'

#Load all the resources we need
Dir[File.join(File.dirname(__FILE__), "initializers/*.rb")].each do |file|
  require file
end

data = JSON.parse(File.read("/home/pi/weather/output/latest.json"))

Weather.create(
  'temp_out' => data['temp_out'],
  'temp_in' => data['temp_in'],
  'temp_appr' => data['temp_appr'],
  'wind_avg' => data['wind_avg'],
  'wind_gust' => data['wind_gust'],
  'wind_dir' => data['wind_dir'],
  'hum_out' => data['hum_out'],
  'hum_in' => data['hum_in'],
  'rain' => data['rain'],
  'rel_pressure' => data['rel_pressure'],
  :created_at => Time.now()
)
