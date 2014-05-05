require "rubygems"
require "net/http"


#Load all the resources we need
Dir[File.join(File.dirname(__FILE__), "initializers/*.rb")].each do |file|
  require file
end

uri = URI('http://192.168.1.73/')
response = Net::HTTP.get_response(uri)
puts response.body if response.is_a?(Net::HTTPSuccess)

data = response.body.split("|")

Nmea.parse(data)
