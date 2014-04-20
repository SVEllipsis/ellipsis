#Load all the resources we need
Dir[File.join(File.dirname(__FILE__), "initializers/*.rb")].each do |file|
  require file
end

begin
  REDIS.subscribe('mt') do |on|
    on.subscribe do |channel, subscriptions|
      puts "Subscribed to ##{channel} (#{subscriptions} subscriptions)"
    end

    on.message do |channel, message|
      puts "Recieved message from Iridium"
      Messages.create(
        :type => 'mt',
        :text => message,
        :created_at => Time.now()
      )
    end

    on.unsubscribe do |channel, subscriptions|
      puts "Unsubscribed from ##{channel} (#{subscriptions} subscriptions)"
    end
  end
rescue Redis::BaseConnectionError => error
  puts "#{error}, retrying in 1s"
  sleep 1
  retry
end
