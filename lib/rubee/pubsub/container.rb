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

      # Custom method that is called when a message is published
      def on_publish(*)
        raise NotImplementedError
      end
    end
  end
end
