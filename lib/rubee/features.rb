module Rubee
  class Features
    class << self
      def redis_available?
        require "redis"
        redis_url = Rubee::Configuration.get_redis_url
        redis = redis_url&.empty? ? Redis.new : Redis.new(url: redis_url)
        redis.ping
        true
      rescue LoadError, Redis::CannotConnectError
        false
      end

      def websocket_available?
        require "websocket"
        true
      rescue LoadError
        false
      end
    end
  end
end
