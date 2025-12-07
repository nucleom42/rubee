module Rubee
  module DatabaseObjectable
    using ChargedString
    def self.included(base)
      base.extend(ClassMethods)
      base.include(InstanceMethods)
      base.prepend(Initializer)

      base.include(Rubee::Hookable)
      base.include(Rubee::Serializable)
      base.include(Rubee::Validatable)
    end

    module ClassMethods
      def pluralize_class_name
        name.pluralize.snakeize
      end

      def accessor_names
        instance_methods(false)
          .select { |m| method_defined?("#{m}=") } # Check if setter exists
      end
    end

    module InstanceMethods
    end

    module Initializer
    end
  end
end
