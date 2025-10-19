module Rubee
  module PubSub
    module Subscriber
      Error = Class.new(StandardError)

      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def sub(channel)
          Rubee::Configuration.pubsub_container.sub(channel)
          true
        end

        def unsub(channel)
          Rubee::Configuration.pubsub_container.unsub(channel)
          true
        end
      end
    end
  end
end
