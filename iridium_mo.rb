#Load all the resources we need
Dir[File.join(File.dirname(__FILE__), "initializers/*.rb")].each do |file|
  require file
end

@nmea = Nmea.last()
@weather = Weather.last()

def windspeed
  return @nmea['windspeed'] unless @nmea['windspeed'].nil?
  @weather['wind_avg']
end

def winddir
  return @nmea['winddir'] unless @nmea['winddir'].nil?
  @weather['wind_dir']
end

values = Array.new

values << @nmea['lat']
values << @nmea['long']
values << @nmea['bearing']
values << @nmea['speed']
values << @nmea['waterspeed']
values << @weather['temp_out']
values << windspeed
values << winddir
values << @weather['rel_pressure']

message = values.join(',')

puts message.inspect

Messages.send_message(message)
