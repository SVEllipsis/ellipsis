require 'data_mapper'

DataMapper.setup(:default, {
  adapter: 'mysql',
  database: 'ellipsis',
  username: 'root',
  password: '',
  host: 'localhost',
  port: 3306,
  socket: '/opt/boxen/data/mysql/socket'
})

Dir[File.join(File.dirname(__FILE__), "../models/*.rb")].each do |file|
  require file
end

DataMapper.finalize.auto_upgrade!
