# class Subscriber
#   include Rubee::PubSub::Subscriber

#   def self.on_pub(channel, message)
#     puts "channel=#{channel} message=#{message}"
#   end
# end

# class SubscriberOne
#   include Rubee::PubSub::Subscriber

#   def self.on_pub(channel, message)
#     puts "channel=#{channel} message=#{message}"
#   end
# end

# class Publisher
#   include Rubee::PubSub::Publisher
# end

# Subscriber.sub("ok")

# SubscriberOne.sub("ok")

# Publisher.pub("ok", {message: "hello"})

# SubscriberOne.unsub("ok")

# Publisher.pub("ok", {message: "hello"})

