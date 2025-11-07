module Rubee
  module PubSub
    class Container
      def pub(*)
        raise NotImplementedError
      end

      # Container Implementation of sub
      def sub(*)
        raise NotImplementedError
      end

      # Container Implementation of unsub
      def unsub(*)
        raise NotImplementedError
      end

      protected

      def retrieve_klasses(iterable)
        iterable.map { |clazz| turn_to_class(clazz) }
      end

      def turn_to_class(string)
        string.split('::').inject(Object) { |o, c| o.const_get(c) }
      end

      def fan_out(clazzes, args, &block)
        mutex = Mutex.new

        mutex.synchronize do
          clazzes.each do |clazz|
            if block
              block.call(clazz.name, args)
            else
              clazz.on_pub(clazz.name, args)
            end
          end
          true
        end
      end
    end
  end
end
