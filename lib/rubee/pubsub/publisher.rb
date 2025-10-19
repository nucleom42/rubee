module Rubee
  module PubSub
    module Publisher
      Error = Class.new(StandardError)

      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def pub(channel, args = {})
          Rubee::Configuration.pubsub_container.pub(channel, args)
          true
        end
      end
    end
  end
end
