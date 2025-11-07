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

      # ie. pub("ok", { message: "hello" })
      def pub(channel, args = {}, &block)
        keys = redis_connection.scan_each(match: "#{channel}:*").to_a
        return false if keys&.empty?

        values = redis_connection.mget(*keys)
        iterable_subscriber_hash = values.each_with_object({}).with_index do |(val, hash), index|
          key = keys[index] # getting key as "ok:User"
          hash[key] = val
        end

        clazzes = retrieve_klasses(iterable_subscriber_hash)
        fan_out(clazzes, args, &block)

        true
      end

      # ie sub("ok", "User", ["123"])
      def sub(channel, klazz_name, args = [], &block)
        @mutex.synchronize do
          channel = "#{channel}:#{klazz_name}"
          value = redis_connection.get(channel)

          io = args.pop if args.count > 1 && args.last.respond_to?(:call)
          unless value
            redis_connection.set(channel, args.join(','))
          end
          block&.call(channel, { io: })
        end

        true
      end

      def unsub(channel, klazz_name, args = [], &block)
        @mutex.synchronize do
          channel = "#{channel}:#{klazz_name}"
          return false unless redis_connection.get(channel)

          io = args.pop if args.count > 1 && args.last.respond_to?(:call)
          redis_connection.del(channel)
          block&.call(channel, { io: })
        end

        true
      end

      protected

      def retrieve_klasses(iterable)
        iterable.each_with_object({}) do |(channel_n_klass_string, args), hash|
          channel, clazz = channel_n_klass_string.split(':')
          args = args.split(',') || []
          hash["#{channel_n_klass_string}-#{args}"] = { channel:, args:, clazz: }
        end
      end

      def fan_out(clazzes, method_args = {}, &block)
        mutex = Mutex.new

        mutex.synchronize do
          clazzes.each do |_k, options|
            clazz = turn_to_class(options[:clazz])
            clazz_args = options[:args]

            clazz.on_pub(clazz.name, *clazz_args, **method_args)
            block&.call("#{options[:channel]}:#{options[:clazz]}", **method_args)
          end
          true
        end
      end
    end
  end
end
