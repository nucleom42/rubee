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
                handler.respond_to?(:call) ? safe_call(handler, [self, args]) : send(handler)
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
                handler.respond_to?(:call) ? safe_call(handler, [self, args]) : send(handler)
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
                  safe_call(handler, [self, args]) do
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
            safe_call(if_condition, [instance])
          elsif instance.respond_to?(if_condition)
            instance.send(if_condition)
          end
        unless_condition_result =
          if unless_condition.nil?
            false
          elsif unless_condition.respond_to?(:call)
            safe_call(unless_condition, [instance])
          elsif instance.respond_to?(unless_condition)
            instance.send(unless_condition)
          end

        if_condition_result && !unless_condition_result
      end

      def safe_call(handler, call_args = [], &block)
        if handler.is_a?(Proc)
          wrapped = safe_lambda(handler, &block)

          # Forward block to the handler lambda if present
          if block
            wrapped.call(*call_args, &block)
          else
            wrapped.call(*call_args)
          end
        else
          handler.call
          block&.call
        end
      end

      def safe_lambda(strict_lambda, &block)
        return strict_lambda unless strict_lambda.is_a?(Proc)
        return strict_lambda unless strict_lambda.lambda?
        return strict_lambda unless strict_lambda.arity >= 0

        proc do |*call_args|
          lambda_arity = strict_lambda.arity

          # Take only what lambda can handle, pad missing ones with nil
          args_for_lambda = call_args.first(lambda_arity)
          if args_for_lambda.length < lambda_arity
            args_for_lambda += Array.new(lambda_arity - args_for_lambda.length, nil)
          end

          strict_lambda.call(*args_for_lambda, &block)
        end
      end
    end

    module InstanceMethods
      def conditions_met?(if_condition = nil, unless_condition = nil)
        self.class.conditions_met?(if_condition, unless_condition, self)
      end

      def safe_lambda(strict_lambda)
        self.class.safe_lambda(strict_lambda)
      end

      def safe_call(handler, call_args = [], &block)
        self.class.safe_call(handler, call_args, &block)
      end
    end
  end
end
