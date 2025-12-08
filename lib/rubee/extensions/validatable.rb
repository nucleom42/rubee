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

        error_hash = assemble_error_hash(error_message, :required, attribute: @attribute)
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
          required: "attribute '#{options[:attribute]}' is required",
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
        @__validation_state.errors
      end

      def run_validations
        @__validation_state = State.new
        if (block = self.class.validation_block)
          instance_exec(&block)
        end
      end

      def subject
        @__validation_state.instance
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

      def validate_after_setters
        unless respond_to?(:after)
          raise "Can't use validate_after_setters without after hook, please include Rubee::Hookable"
        end
        after(*accessor_names.filter { |name| !name.start_with?("__") }.map { |name| "#{name}=" }, :run_validations)
      end
    end
  end
end
