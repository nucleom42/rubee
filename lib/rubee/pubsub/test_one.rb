# class Subscriber
#   include Rubee::PubSub::Subscriber

#   def self.on_pub(channel, message, options = {})
#     puts "channel=#{channel} message=#{message} options=#{options}"
#   end
# end

# class SubscriberOne
#   include Rubee::PubSub::Subscriber

#   def self.on_pub(channel, message, options = {})
#     puts "channel=#{channel} message=#{message} options=#{options}"
#   end
# end

# class Publisher
#   include Rubee::PubSub::Publisher
# end

# Subscriber.sub("ok", ["123456"])

# SubscriberOne.sub("ok", ["123"])

# Publisher.pub("ok", { message: "hello" })

# SubscriberOne.unsub("ok", ["123"])

# Publisher.pub("ok", { message: "hello" })
