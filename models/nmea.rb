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

  def self.sync
    keys = REDIS.hgetall 'nmea'

    self.create(
      :lat => keys['LATA'],
      :long => keys['LONG'],
      :speed => keys['KNOT'],
      :bearing => keys['BEAR'],
      :winddir => keys['WIND'],
      :windspeed => keys['WINS'],
      :waterspeed => keys['WATS'],
      :watertemp => keys['WATT'],
      :created_at => Time.now()
    )

  end

  def self.parse(msg)
    if valid_message?(msg)
      kv = msg.split("=")
      self.set(kv[0], kv[1])
    end
  end

  private

  def self.valid_message?(msg)
    /[A-Z][A-Z][A-Z][A-Z]=/.match(msg)
  end

  def valid_values
    {
      'LATA' => 'latitude',
      'LONG' => 'longitude',
      'DATE' => 'date',
      'TIME' => 'time',
      'KNOT' => 'speed in knots',
      'BEAR' => 'direction of travel',
      'WIND' => 'wind direction',
      'WINS' => 'wind speed',
      'WATT' => 'water temperature',
      'WATS' => 'water speed'
    }
  end

end
