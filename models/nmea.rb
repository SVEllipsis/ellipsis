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

  def self.set(key, value)
    REDIS.hset 'nmea', key, value
  end

  def self.get(key)
    REDIS.hget 'nmea', key
  end

  def self.parse(data)
    puts self.create(
      :lat => clean(data[0]),
      :long => clean(data[1]),
      :speed => clean(data[4]),
      :bearing => clean(data[5]),
      :winddir => clean(data[8]),
      :windspeed => clean(data[9]),
      :waterspeed => clean(data[7]),
      :watertemp => clean(data[6]),
      :created_at => Time.now()
    ).inspect
  end


  def self.clean(val)
    return nil unless val.match("[0-9].")
    return nil if val.empty?
    val
  end

end
