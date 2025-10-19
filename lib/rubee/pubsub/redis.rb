module Rubee
  module PubSub
    class Redis < Container
      include Singleton

      def initialize
        @con = ::Redis.new
      end

      def redis_connection
        @con ||= ::Redis.new
      end

      def pub(channel, args = {})
        message = args[:message]
        return false if message.nil? || message.empty? || redis_connection.nil?

        redis_connection.publish(channel, message)

        true
      end

      def sub(channel)
        return false if redis_connection.nil?

        Thread.new do
          redis_connection.subscribe(channel) do |on|
            on.message do |_ch, msg|
              on_pub(channel, msg)
            end
          end

          true
        rescue => e
          ::Rubee.logger.error(message: e.message, class_name: 'Rubee::PubSub::Redis')

          false
        end
      end

      def unsub(channel, _args = {})
        return false if redis_connection.nil?

        redis_connection.unsubscribe(channel)

        true
      end
    end
  end
end
