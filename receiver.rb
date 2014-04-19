require "rubygems"
require "serialport"

#Load all the resources we need
Dir[File.join(File.dirname(__FILE__), "initializers/*.rb")].each do |file|
  require file
end


#params for serial port
port_str = "/dev/tty.usbmodemfd121"  #may be different for you
baud_rate = 115200
data_bits = 8
stop_bits = 1
parity = SerialPort::NONE

if File.exist?(port_str)

  sp = SerialPort.new(port_str, baud_rate, data_bits, stop_bits, parity)

  while(true) do
    message = sp.gets
    message.chomp!

    split = message.split('=')

    puts message

    Nmea.set(split[0],split[1])
  end

  sp.close

else

  while(true) do
    puts "No Arduino Connected"
    sleep(1000)
  end

end
