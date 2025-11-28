module Rubee
  module Hookable
    def self.included(base)
      base.extend(ClassMethods)
      base.include(InstanceMethods)
    end

    module ClassMethods
      def before(*methods, handler, **options)
        methods.each do |method|
          hook = Module.new do
            define_method(method) do |*args, &block|
              if conditions_met?(options[:if], options[:unless])
                handler.respond_to?(:call) ? handler.to_proc.call(self) : send(handler)
              end

              super(*args, &block)
            end
          end

          options[:class_methods] ? singleton_class.prepend(hook) : prepend(hook)
        end
      end

      def after(*methods, handler, **options)
        methods.each do |method|
          hook = Module.new do
            define_method(method) do |*args, &block|
              result = super(*args, &block)

              if conditions_met?(options[:if], options[:unless])
                handler.respond_to?(:call) ? handler.to_proc.call(self) : send(handler)
              end

              result
            end
          end

          options[:class_methods] ? singleton_class.prepend(hook) : prepend(hook)
        end
      end

      def around(*methods, handler, **options)
        methods.each do |method|
          hook = Module.new do
            define_method(method) do |*args, &block|
              if conditions_met?(options[:if], options[:unless])
                if handler.respond_to?(:call)
                  result = nil
                  handler.to_proc.call(self) do
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

          options[:class_methods] ? singleton_class.prepend(hook) : prepend(hook)
        end
      end

      def conditions_met?(if_condition = nil, unless_condition = nil, instance = nil)
        return true if if_condition.nil? && unless_condition.nil?
        if_condition_result =
          if if_condition.nil?
            true
          elsif if_condition.respond_to?(:call)
            if_condition.to_proc.call(instance)
          elsif instance.respond_to?(if_condition)
            instance.send(if_condition)
          end
        unless_condition_result =
          if unless_condition.nil?
            false
          elsif unless_condition.respond_to?(:call)
            unless_condition.to_proc.call(instance)
          elsif instance.respond_to?(unless_condition)
            instance.send(unless_condition)
          end

        if_condition_result && !unless_condition_result
      end
    end

    module InstanceMethods
      def conditions_met?(if_condition = nil, unless_condition = nil)
        self.class.conditions_met?(if_condition, unless_condition, self)
      end
    end
  end
end
