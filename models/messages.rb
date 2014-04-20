class Messages
  include DataMapper::Resource

  property :id, Serial
  property :type, String, :length => 2
  property :text, Text
  property :created_at, DateTime
end
