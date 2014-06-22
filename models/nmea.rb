class Nmea
  include DataMapper::Resource

  property :id, Serial
  property :lat, Float
  property :long, Float
  property :speed, Float
  property :bearing, Float
  property :winddir, Float
  property :windspeed, Float
  property :waterspeed, Float
  property :watertemp, Float
  property :created_at, DateTime

  def lat_as_str
    ord = lat >= 0 ? "N" : "S"
    geo_format(lat, ord)
  end

  def long_as_str
    ord = long >= 0 ? "E" : "W"
    geo_format(long, ord)
  end

  def geo_format(geo_float, ord)
    units = degreesminutesseconds(geo_float)
    "#{units[:degrees]}\xc2\xb0 #{units[:minutes]}\xe2\x80\xb2 #{units[:seconds]}\xe2\x80\xb3 #{ord}"
  end

  def degreesminutesseconds(fl)
    fl.to_s.match /(?<degrees>\d{0,3})\.(?<minutes>\d\d)(?<seconds>\d{0,3})/
  end

  def self.set(key, value)
    REDIS.hset 'nmea', key, value
  end

  def self.get(key)
    REDIS.hget 'nmea', key
  end

  def self.parse(data)
    self.create(
      :lat => clean(data[0]),
      :long => clean(data[1]),
      :speed => clean(data[4]),
      :bearing => clean(data[5]),
      :winddir => clean(data[8]),
      :windspeed => clean(data[9]),
      :waterspeed => clean(data[7]),
      :watertemp => clean(data[6]),
      :created_at => Time.now()
    )
  end


  def self.clean(val)
    return nil unless val.match("[0-9].")
    return nil if val.empty?
    val
  end

end
