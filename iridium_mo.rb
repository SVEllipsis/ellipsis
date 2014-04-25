#Load all the resources we need
Dir[File.join(File.dirname(__FILE__), "initializers/*.rb")].each do |file|
  require file
end

nmea = Nmea.last()
weather = Weather.last()

values = Array.new

values << nmea['lat']
values << nmea['long']
values << nmea['bearing']
values << nmea['speed']
values << nmea['waterspeed']
values << weather['temp_out']
values << nmea['windspeed']
values << nmea['winddir']
values << nmea['rel_pressure']

message = values.join(',')

Messages.send_message(message)
