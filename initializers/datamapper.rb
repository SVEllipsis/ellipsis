require 'data_mapper'

DataMapper.setup(:default, ENV['CLEARDB_DATABASE_URL'] || 'mysql://root@localhost/ellipsis')

Dir[File.join(File.dirname(__FILE__), "../models/*.rb")].each do |file|
  require file
end

DataMapper.finalize.auto_upgrade!
