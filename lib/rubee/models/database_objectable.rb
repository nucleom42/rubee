module Rubee
  module DatabaseObjectable
    def self.included(base)
      base.extend ClassMethods
      base.include InstanceMethods
      base.prepend Initializer

      base.include Rubee::Hookable
      base.include Rubee::Serializable
    end

    module ClassMethods
      def pluralize_class_name
        pluralize(name.downcase)
      end

      def pluralize(word)
        if word.end_with?('y') && !%w[a e i o u].include?(word[-2])
          "#{word[0..-2]}ies" # Replace "y" with "ies"
        elsif word.end_with?('s', 'x', 'z', 'ch', 'sh')
          "#{word}es" # Add "es" for certain endings
        else
          "#{word}s" # Default to adding "s"
        end
      end

      def singularize(word)
        if word.end_with?('ies') && word.length > 3
          "#{word[0..-4]}y" # Convert "ies" to "y"
        elsif word.end_with?('es') && %w[s x z ch sh].any? { |ending| word[-(ending.length + 2)..-3] == ending }
          word[0..-3] # Remove "es" for words like "foxes", "buses"
        elsif word.end_with?('s') && word.length > 1
          word[0..-2] # Remove "s" for regular plurals
        else
          word # Return as-is if no plural form is detected
        end
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
