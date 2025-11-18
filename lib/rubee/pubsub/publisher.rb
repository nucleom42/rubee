module Rubee
  module PubSub
    module Publisher
      Error = Class.new(StandardError)

      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def pub(channel, args = {}, &block)
          Rubee::Configuration.pubsub_container.pub(channel, args, &block)
          true
        end
      end
    end
  end
end
