module ChargedHash
  refine Hash do
    def [](key)
      return wrap(super(key)) if key?(key)

      alt_key = key.is_a?(Symbol) ? key.to_s : key.to_sym
      wrap(super(alt_key))
    end

    private

    def wrap(value)
      value.is_a?(Hash) ? value.extend(ChargedHash) : value
    end

    def keys_to_string!
      keys_to(:string, self)
    end

    def keys_to_sym!
      keys_to(:symbol, self)
    end

    def keys_to(type, obj)
      case obj
      when Hash
        obj.each_with_object({}) do |(k, v), result|
          key = k.to_s
          result[key] = keys_to(type, v)
        end
      when Array
        obj.map { |v| keys_to(type, v) }
      else
        obj
      end
    end
  end
end
