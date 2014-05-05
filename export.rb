#Load all the resources we need
Dir[File.join(File.dirname(__FILE__), "initializers/*.rb")].each do |file|
  require file
end

##Get all of todays data
##Write todays data as a json file to disk
