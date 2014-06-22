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

def self.clean(val)
  return nil unless val.match("[0-9].")
  return nil if val.empty?
  val
end

values = Array.new

values << clean(data[0])
values << clean(data[1])
values << clean(data[6])
values << clean(data[4])
values << clean(data[8])
values << ''
values << ''
values << ''
values << ''

message = values.join(',')

REDIS.publish("mo", msg)
