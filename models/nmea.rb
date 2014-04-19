class Nmea

  def self.set(key, value)
    REDIS.hset 'nmea', key, value
  end

  def self.get(key)
    REDIS.hget 'nmea', key
  end

  def self.sync
    keys = REDIS.hgetall 'nmea'

    keys.each do |k,v|
      Event.set(k, v)
    end

  end

end
