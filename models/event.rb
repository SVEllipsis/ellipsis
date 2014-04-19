class Event
  include DataMapper::Resource

  property :id, Serial
  property :metric, String, :length => 8, :key => true
  property :value, String
  property :created_at, DateTime

  #Quick Set
  def self.set(metric = nil, value = nil)
    self.create(:metric => metric, :value => value, created_at: Time.now)
  end

  #Get the latest metric
  def self.get(metric = nil)
    self.last(:metric => metric).value
  end

end
