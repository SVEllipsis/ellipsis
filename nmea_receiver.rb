require "rubygems"
require "serialport"

#Load all the resources we need
Dir[File.join(File.dirname(__FILE__), "initializers/*.rb")].each do |file|
  require file
end

#params for serial port
port_str = "/dev/ttyACM0"  #may be different for you
baud_rate = 115200
data_bits = 8
stop_bits = 1
parity = SerialPort::NONE

if !File.exist?(port_str)

  puts "No Arduino Connected"

  while(!File.exist?(port_str)) do
    sleep(30)
    true
  end

end

sp = SerialPort.new(port_str, baud_rate, data_bits, stop_bits, parity)
puts "Opening serial to NMEA bus"

sync_timer = Time.now()

while(true) do
  message = sp.gets
  message.chomp!

  Nmea.parse(message)

  if ((Time.now() - sync_timer) > 300)
    Nmea.sync
    t1 = Time.now()
  end

end

sp.close
