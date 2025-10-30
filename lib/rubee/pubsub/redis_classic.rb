module Rubee
  module PubSub
    class RedisClassic
      include Singleton

      REDIS_KEY_PREFIX = "rubee:subscriptions"

      def initialize
        @redis_pool = ConnectionPool::Wrapper.new(size: 5, timeout: 5) { ::Redis.new }
      end

      # --- Publish a message ---
      def publish(channel, message)
        @redis_pool.publish(channel, message.to_json)
      end

      # --- Subscribe connection to a channel ---
      def subscribe(connection_id, channel, &block)
        key = redis_key_for(connection_id)

        # Check if already subscribed
        if subscribed?(connection_id, channel)
          return { status: :already_subscribed }
        end

        # Register subscription in Redis
        @redis_pool.sadd(key, channel)

        # Start background listener thread
        Thread.new do
          @redis_pool.with do |redis|
            redis.subscribe(channel) do |on|
              on.message do |ch, msg|
                block.call(ch, msg)
              end
            end
          end
        end

        { status: :subscribed }
      end

      # --- Unsubscribe a specific channel ---
      def unsubscribe(connection_id, channel)
        key = redis_key_for(connection_id)

        unless subscribed?(connection_id, channel)
          return { status: :not_found }
        end

        @redis_pool.with do |redis|
          redis.unsubscribe(channel) rescue nil
          redis.srem(key, channel)
        end

        { status: :unsubscribed }
      end

      # --- Unsubscribe all channels for a connection ---
      def unsubscribe_all(connection_id)
        key = redis_key_for(connection_id)
        channels = subscriptions_for(connection_id)

        return if channels.empty?

        @redis_pool.with do |redis|
          channels.each { |ch| redis.unsubscribe(ch) rescue nil }
          redis.del(key)
        end

        { status: :unsubscribed_all, channels: channels }
      end

      # --- Check if already subscribed ---
      def subscribed?(connection_id, channel)
        key = redis_key_for(connection_id)
        @redis_pool.sismember(key, channel)
      end

      # --- Get all subscriptions for a connection ---
      def subscriptions_for(connection_id)
        key = redis_key_for(connection_id)
        @redis_pool.smembers(key)
      end

      private

      def redis_key_for(connection_id)
        "#{REDIS_KEY_PREFIX}:#{connection_id}"
      end
    end
  end
end
