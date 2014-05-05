class Weather
  include DataMapper::Resource

  property :id, Serial
  property :temp_out, Float
  property :temp_in, Float
  property :temp_appr, Float
  property :wind_avg, Float
  property :wind_gust, Float
  property :wind_dir, String
  property :hum_out, Float
  property :hum_in, Float
  property :rain, Float
  property :rel_pressure, Float
  property :created_at, DateTime

end
