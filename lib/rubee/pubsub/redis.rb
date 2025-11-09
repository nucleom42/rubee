require "connection_pool"
require "redis"
require "singleton"
require "json"

module Rubee
  module PubSub
    class Redis < Container
      include Singleton

      DEFAULT_POOL_SIZE = 5
      DEFAULT_TIMEOUT = 5

      def initialize
        @pool = ConnectionPool.new(size: DEFAULT_POOL_SIZE, timeout: DEFAULT_TIMEOUT) { ::Redis.new }
        @mutex = Mutex.new
      end

      # Example: pub("ok", message: "hello")
      def pub(channel, args = {}, &block)
        keys = with_redis { |r| r.scan_each(match: "#{channel}:*").to_a }
        return false if keys.empty?

        values = with_redis { |r| r.mget(*keys) }

        iterable = values.each_with_index.each_with_object({}) do |(val, i), hash|
          key = keys[i]
          hash[key] = val
        end

        clazzes = retrieve_klasses(iterable)
        fan_out(clazzes, args, &block)
      end

      # Example: sub("ok", "User", ["123"])
      def sub(channel, klass_name, args = [], &block)
        @mutex.synchronize do
          id = args.first
          id_string = id ? ":#{id}" : ""
          key = "#{channel}:#{klass_name}#{id_string}"
          existing = with_redis { |r| r.get(key) }
          io = args.last.respond_to?(:call) ? args.pop : nil

          with_redis { |r| r.set(key, args.join(",")) } unless existing
          block&.call(key, io: io)
        end
        true
      end

      def unsub(channel, klass_name, args = [], &block)
        @mutex.synchronize do
          id = args.first
          id_string = id ? ":#{id}" : ""
          key = "#{channel}:#{klass_name}#{id_string}"
          value = with_redis { |r| r.get(key) }
          return false unless value

          io = args.pop if args.last.respond_to?(:call)
          with_redis { |r| r.del(key) }
          block&.call(key, io: io)
        end
        true
      end

      protected

      def with_redis(&block)
        @pool.with(&block)
      end

      def retrieve_klasses(iterable)
        iterable.each_with_object({}) do |(key, args), hash|
          channel, clazz, id = key.split(":")
          arg_list = args.to_s.split(",")
          hash[key] = { channel:, clazz:, args: arg_list, id: }
        end
      end

      def fan_out(clazzes, method_args = {}, &block)
        clazzes.each do |_key, opts|
          clazz = turn_to_class(opts[:clazz])
          clazz_args = opts[:args]

          clazz.on_pub(opts[:channel], *clazz_args, **method_args)
          id_string = opts[:id] ? ":#{opts[:id]}" : ""
          block&.call("#{opts[:channel]}:#{opts[:clazz]}#{id_string}", **method_args)
        end
        true
      end
    end
  end
end
