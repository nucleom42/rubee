module ChargedString
  refine String do
    def pluralize
      if end_with?('y') && !%w[a e i o u].include?(self[-2])
        "#{self[0..-2]}ies" # Replace "y" with "ies"
      elsif end_with?('s', 'x', 'z', 'ch', 'sh')
        "#{self}es" # Add "es" for certain endings
      else
        "#{self}s" # Default to adding "s"
      end
    end

    def plural?
      return true if end_with?('s') && !end_with?('ss')

      false
    end

    def singular?
      !plural?
    end

    def singularize
      if end_with?('ies') && length > 3
        "#{self[0..-4]}y" # Convert "ies" to "y"
      elsif end_with?('es') && %w[s x z ch sh].any? { |ending| self[-(ending.length + 2)..-3] == ending }
        self[0..-3] # Remove "es" for selfs like "foxes", "buses"
      elsif end_with?('s') && length > 1
        self[0..-2] # Remove "s" for regular plurals
      else
        self # Return as-is if no plural form is detected
      end
    end
  end
end
