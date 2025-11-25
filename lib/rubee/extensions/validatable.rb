module Rubee
  module Validatable
    class State
      attr_accessor :errors, :valid

      def initialize
        @valid = true
        @errors = {}
      end

      def add_error(attribute, message)
        @valid = false
        @errors[attribute] ||= []
        @errors[attribute] << message
      end

      def has_errors_for?(attribute)
        @errors.key?(attribute)
      end
    end

    class RuleChain
      attr_reader :instance, :attribute

      def initialize(instance, attribute, state)
        @instance = instance
        @attribute = attribute
        @state = state
      end

      def required(error_message)
        value = @instance.send(@attribute)
        if value.nil? || (value.respond_to?(:empty?) && value.empty?)
          @state.add_error(@attribute, error_message)
        end
        self
      end

      def optional(*)
        self
      end

      def type(expected_class, error_message)
        return self if @state.has_errors_for?(@attribute)

        value = @instance.send(@attribute)
        unless value.is_a?(expected_class)
          @state.add_error(@attribute, error_message)
        end
        self
      end

      def condition(predicate_block, error_message)
        return self if @state.has_errors_for?(@attribute)

        unless predicate_block.call
          @state.add_error(@attribute, error_message)
        end
        self
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
      base.prepend(Initializer)
      base.include(InstanceMethods)
    end

    module Initializer
      def initialize(*)
        @state = State.new
        super
        run_validations
      end
    end

    module InstanceMethods
      def valid?
        run_validations
        @state.valid
      end

      def errors
        run_validations
        @state.errors
      end

      def run_validations
        @state = State.new
        self.class&.validation_block&.call(self)
      end

      def required(attribute, options)
        error_message = options[:required]
        RuleChain.new(self, attribute, @state).required(error_message)
      end

      def optional(attribute)
        RuleChain.new(self, attribute, @state).optional
      end

      def add_error(attribute, message)
        @state.add_error(attribute, message)
      end
    end

    module ClassMethods
      attr_reader :validation_block

      def validate(&block)
        @validation_block = block
      end
    end
  end
end
