module Rubee
  module Hookable
    def self.included(base)
      base.extend(ClassMethods)
      base.include(InstanceMethods)
    end

    module ClassMethods
      def before(*methods, handler, **options)
        if options[:class_methods]
          methods.each do |method|
            define_method(method) do |*args, &block|
              self.class.send(method, *args, &block)
            end

            private(method)
          end
        end

        methods.each do |method|
          hook = Module.new do
            define_method(method) do |*args, &block|
              if conditions_met?(options[:if], options[:unless])
                handler.respond_to?(:call) ? handler.call : send(handler)
              end

              super(*args, &block)
            end
          end

          prepend(hook)
        end
      end

      def after(*methods, handler, **options)
        if options[:class_methods]
          methods.each do |method|
            define_method(method) do |*args, &block|
              self.class.send(method, *args, &block)
            end

            private(method)
          end
        end

        methods.each do |method|
          hook = Module.new do
            define_method(method) do |*args, &block|
              result = super(*args, &block)

              if conditions_met?(options[:if], options[:unless])
                handler.respond_to?(:call) ? handler.call : send(handler)
              end

              result
            end
          end

          prepend(hook)
        end
      end

      def around(*methods, handler, **options)
        if options[:class_methods]
          methods.each do |method|
            define_method(method) do |*args, &block|
              self.class.send(method, *args, &block)
            end

            private(method)
          end
        end

        methods.each do |method|
          hook = Module.new do
            define_method(method) do |*args, &block|
              if conditions_met?(options[:if], options[:unless])
                if handler.respond_to?(:call)
                  result = nil
                  handler.call do
                    result = super(*args, &block)
                  end

                  result
                else
                  send(handler) do
                    super(*args, &block)
                  end
                end
              else
                super(*args, &block)
              end
            end
          end

          prepend(hook)
        end
      end
    end

    module InstanceMethods
      private

      def handle_class_method
        self.class.send(name, *args, &block)
      end

      def conditions_met?(if_condition = nil, unless_condition = nil)
        return true if if_condition.nil? && unless_condition.nil?

        if_condition_result =
          if if_condition.nil?
            true
          elsif if_condition.respond_to?(:call)
            if_condition.call
          elsif respond_to?(if_condition)
            send(if_condition)
          end
        unless_condition_result =
          if unless_condition.nil?
            false
          elsif unless_condition.respond_to?(:call)
            unless_condition.call
          elsif respond_to?(unless_condition)
            send(unless_condition)
          end

        if_condition_result && !unless_condition_result
      end
    end
  end
end
