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
        iterable.map { |clazz| clazz.split('::').inject(Object) { |o, c| o.const_get(c) } }
      end

      def fan_out(clazzes, args)
        mutex = Mutex.new

        mutex.synchronize do
          clazzes.each { |clazz| clazz.on_pub(clazz.name, args) }
          true
        end
      end
    end
  end
end
