#Load all the resources we need
Dir[File.join(File.dirname(__FILE__), "initializers/*.rb")].each do |file|
  require file
end

nmea = Nmea.last()




# 5133.82N,00042.24W,173.8,99.8,30,99.8N,1,ABC
# LAT,LONG,SPEED,COURSE,TEMP,WIND,POWER,DEST
