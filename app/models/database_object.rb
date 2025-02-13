DB = Sequel.sqlite(Rubee::Configuration.get_database_url)

class DatabaseObject
  def initialize(attrs)
    attrs.each do |attr, value|
      self.send("#{attr}=", value)
    end
  end

  def to_json
    to_h.to_json
  end

  def to_h
    instance_variables.each_with_object({}) do |var, hash|
      hash[var.to_s.delete("@")] = instance_variable_get(var)
    end
  end

  def destroy
    self.class.connection.where(id:).delete
  end

  def save
    args = to_h.dup
    args.delete(:id)
    update(args)
  end

  def update(args = {})
    to_h.each do |attr, value|
      self.send("#{attr}=", args[attr.to_sym]) if args[attr.to_sym]
    end
    found_hash = self.class.connection.where(id:)
    return true if found_hash&.update(**args)

    false
  end

  def reload
    self.class.find(id)
  end

  class << self
    def last
      found_hash = connection.order(:id).last
      return self.new(**found_hash) if found_hash

      nil
    end

    def connection
      @connection ||= DB[pluralize_class_name.to_sym]
    end

    def all
      connection.map do |record_hash|
        self.new(**record_hash)
      end
    end

    def find(id)
      found_hash = connection.where(id:)&.first
      return self.new(**found_hash) if found_hash

      nil
    end

    def where(args)
      connection.where(**args).map do |record_hash|
        self.new(**record_hash)
      end
    end

    def create(attrs)
      out_id = connection.insert(**attrs)
      self.new(**(attrs.merge(id: out_id)))
    end

    def pluralize_class_name
      word = self.name.downcase
        # Basic pluralization rules
      if word.end_with?('y') && !%w[a e i o u].include?(word[-2])
        word[0..-2] + 'ies' # Replace "y" with "ies"
      elsif word.end_with?('s', 'x', 'z', 'ch', 'sh')
        word + 'es' # Add "es" for certain endings
      else
        word + 's' # Default to adding "s"
      end
    end
  end
end
