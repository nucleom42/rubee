module Rubee
  module PubSub
    module Subscriber
      Error = Class.new(StandardError)

      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def sub(channel, args = [], &block)
          Rubee::Configuration.pubsub_container.sub(channel, name, args, &block)

          true
        end

        def unsub(channel, args = [], &block)
          Rubee::Configuration.pubsub_container.unsub(channel, name, args, &block)

          true
        end

        def on_pub(channel, message, options = {})
          raise NotImplementedError
        end
      end
    end
  end
end
