class Messages
  include DataMapper::Resource

  property :id, Serial
  property :type, String, :length => 2
  property :text, Text
  property :created_at, DateTime

  def self.send_message(msg = '')
    self.create(
      :type => 'mo',
      :text => msg,
      :created_at => Time.now()
    )

    REDIS.publish("mo", msg)
  end

end
