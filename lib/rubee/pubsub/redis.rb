module Rubee
  module PubSub
    class Redis < Container
      include Singleton

      def initialize
        @con ||= ConnectionPool::Wrapper.new { ::Redis.new }
        @mutex ||= Mutex.new
      end

      def redis_connection
        @con ||= ConnectionPool::Wrapper.new { ::Redis.new }
      end

      def pub(channel, args = {})
        iterable_subscriber_list = redis_connection.get(channel)
        iterable_subscriber_list = JSON.parse(iterable_subscriber_list)
        return false unless iterable_subscriber_list

        clazzes = retrieve_klasses(iterable_subscriber_list)
        fan_out(clazzes, args)

        true
      end

      def sub(channel, klazz_name)
        @mutex.synchronize do
          payload = redis_connection.get(channel)
          unless payload
            redis_connection.set(channel, '[]')
          end
          payload = JSON.parse(redis_connection.get(channel))
          redis_connection.set(channel, payload | [klazz_name]) unless payload.include?(klazz_name)
        end

        true
      end

      def unsub(channel, klazz_name)
        @mutex.synchronize do
          return false unless redis_connection.get(channel)

          payload = JSON.parse(redis_connection.get(channel))
          redis_connection.set(channel, payload - [klazz_name])
        end

        true
      end
    end
  end
end
