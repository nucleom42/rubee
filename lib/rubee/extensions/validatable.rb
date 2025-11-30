module Rubee
  module Validatable
    class Error < StandardError; end

    class State
      attr_accessor :errors, :valid

      def initialize
        @valid = true
        @errors = {}
      end

      def add_error(attribute, hash)
        @valid = false
        @errors[attribute] ||= {}
        @errors[attribute].merge!(hash)
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
        @optional = false
      end

      def required(error_message = nil)
        value = @instance.send(@attribute)

        error_hash = assemble_error_hash(error_message, :required)
        if value.nil? || (value.respond_to?(:empty?) && value.empty?)
          @state.add_error(@attribute, error_hash)
        end

        self
      end

      def optional(*)
        @optional = true

        self
      end

      def attribute
        self
      end

      def type(expected_class, error_message = nil)
        return self if @state.has_errors_for?(@attribute)
        value = @instance.send(@attribute)
        return self if @optional && value.nil?

        error_hash = assemble_error_hash(error_message, :type, class: expected_class)
        unless value.is_a?(expected_class)
          @state.add_error(@attribute, error_hash)
        end

        self
      end

      def condition(handler, error_message = nil)
        return self if @state.has_errors_for?(@attribute)
        value = @instance.send(@attribute)
        return self if @optional && value.nil?

        error_hash = assemble_error_hash(error_message, :condition)
        if handler.respond_to?(:call)
          @state.add_error(@attribute, error_hash) unless handler.call
        else
          @instance.send(handler)
        end

        self
      end

      private

      def assemble_error_hash(error_message, error_type, **options)
        error_message ||= default_message(error_type, **options)
        if error_message.is_a?(String)
          error_message = { message: error_message }
        end

        error_message
      end

      def default_message(type, **options)
        {
          condition: "condition is not met",
          required: "attribute is required",
          type: "attribute must be #{options[:class]}",
        }[type]
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
      base.prepend(Initializer)
      base.include(InstanceMethods)
    end

    module Initializer
      def initialize(*)
        @__validation_state = State.new
        super
        run_validations
      end
    end

    module InstanceMethods
      def valid?
        run_validations
        @__validation_state.valid
      end

      def invalid?
        !valid?
      end

      def errors
        run_validations
        @__validation_state.errors
      end

      def run_validations
        @__validation_state = State.new
        self.class&.validation_block&.call(self)
      end

      def attribute(name)
        RuleChain.new(self, name, @__validation_state).attribute
      end

      def required(attribute, options)
        error_message = options
        RuleChain.new(self, attribute, @__validation_state).required(error_message)
      end

      def optional(attribute)
        RuleChain.new(self, attribute, @__validation_state).optional
      end

      def add_error(attribute, hash)
        @__validation_state.add_error(attribute, hash)
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
