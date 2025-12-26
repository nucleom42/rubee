module Rubee
  module Serializable
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.prepend(Initializer)
    end

    module Initializer
      def initialize(attrs)
        attrs.each do |attr, value|
          send("#{attr}=", value)
        end
      end
    end

    module InstanceMethods
      def to_json(*_args)
        to_h.to_json
      end

      def to_h
        instance_variables.each_with_object({}) do |var, hash|
          attr_name = var.to_s.delete('@')
          next if attr_name.start_with?('__')
          instance_var = instance_variable_get(var)
          hash[attr_name] = if instance_var.respond_to?(:to_h)
            instance_var.to_h
          else
            instance_variable_get(var)
          end
        end
      end
    end
  end
end
