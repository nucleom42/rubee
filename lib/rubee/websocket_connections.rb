module Rubee
  class WebsocketConnections
    include Singleton
    def initialize
      @subscribers ||= Hash.new { |h, k| h[k] = [] }
    end

    def register(channel, io)
      @subscribers[channel] << io unless @subscribers[channel].include?(io)
    end

    def remove(channel, io)
      @subscribers[channel].delete(io)
    end

    def stream(channel, args = {})
      ios = @subscribers[channel]
      if !ios&.empty? && ios.all? { _1.respond_to?(:call) }
        ios.each { _1.call(args) }
      end
    end

    def clear
      @subscribers = Hash.new { |h, k| h[k] = [] }
    end
  end
end
