DB = Sequel.connect(Rubee::Configuration.get_database_url)

class SequelObject < DatabaseObject
  def destroy
    self.class.connection.where(id:).delete
  end

  def save
    args = to_h.dup&.transform_keys(&:to_sym)
    if args[:id]
      udpate(args) rescue false
      true
    else
      self.class.create(args) rescue false
      true
    end
  end

  def assign_attributes(args={})
    to_h.each do |attr, value|
      self.send("#{attr}=", args[attr.to_sym]) if args[attr.to_sym]
    end
  end

  def update(args = {})
    assign_attributes(args)
    found_hash = self.class.connection.where(id:)
    return self.class.find(id) if found_hash&.update(**args)

    false
  end

  def persisted?
    !!id
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

    def destroy_all
      all.each(&:destroy)
    end
  end
end
