module Rubee
  module Support
    module Hash
      def self.included(base)
        base.extend(ClassMethods)
        base.prepend(InstanceMethods)
      end

      module ClassMethods
      end

      module InstanceMethods
        def [](key)
          return wrap(super(key)) if key?(key)

          alt_key =
            case key
            when ::Symbol then key.to_s
            when ::String then key.to_sym
            else key
            end

          wrap(super(alt_key))
        end

        def deep_dig(key)
          return self[key] if self[key]

          each do |_, v|
            if v.is_a?(Hash)
              return v.deep_dig(key)
            end
          end

          nil
        end

        private

        def wrap(value)
          value.is_a?(::Hash) ? value.extend(Rubee::Support::Hash::InstanceMethods) : value
        end

        def keys_to_string!
          keys_to(:string, self)
        end

        def keys_to_sym!
          keys_to(:symbol, self)
        end

        def keys_to(type, obj)
          case obj
          when ::Hash
            obj.each_with_object({}) do |(k, v), result|
              key =
                case type
                when :string then k.to_s
                when :symbol then k.to_sym
                else k
                end

              result[key] = keys_to(type, v)
            end
          when ::Array
            obj.map { |v| keys_to(type, v) }
          else
            obj
          end
        end
      end
    end
  end
end
