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
  end
end
