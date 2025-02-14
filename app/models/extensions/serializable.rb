module Serializable
  def self.included(base)
    base.send(:extend, ClassMethods)
    base.send(:include, InstanceMethods)
    base.prepend(Initializer)
  end

  module Initializer
    def initialize(attrs)
      attrs.each do |attr, value|
        self.send("#{attr}=", value)
      end
    end
  end

  module ClassMethods
  end

  module InstanceMethods
    def to_json
      to_h.to_json
    end

    def to_h
      instance_variables.each_with_object({}) do |var, hash|
        hash[var.to_s.delete("@")] = instance_variable_get(var)
      end
    end
  end
end
