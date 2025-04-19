using ChargedString

module Rubee
  class SequelObject
    include Rubee::DatabaseObjectable

    def destroy(cascade: false, **_options)
      if cascade
        # find all tables with foreign key
        tables_with_fk = DB.tables.select do |table|
          DB.foreign_key_list(table).any? { |fk| fk[:table] == self.class.pluralize_class_name.to_sym }
        end
        # destroy related records
        tables_with_fk.each do |table|
          fk_name ||= "#{self.class.name.to_s.downcase}_id".to_sym
          target_klass = Object.const_get(table.to_s.singularize.capitalize)
          target_klass.where(fk_name => id).map(&:destroy)
        end
      end
      self.class.dataset.where(id:).delete
    end

    def save
      args = to_h.dup&.transform_keys(&:to_sym)
      if args[:id]
        begin
          udpate(args)
        rescue StandardError => _e
          return false
        end

      else
        begin
          created_object = self.class.create(args)
        rescue StandardError => _e
          return false
        end
        self.id = created_object.id

      end
      true
    end

    def assign_attributes(args = {})
      to_h.each_key do |attr|
        send("#{attr}=", args[attr.to_sym]) if args[attr.to_sym]
      end
    end

    def update(args = {})
      assign_attributes(args)
      found_hash = self.class.dataset.where(id:)
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
        found_hash = dataset.order(:id).last
        return new(**found_hash) if found_hash

        nil
      end

      def first
        found_hash = dataset.order(:id).first
        return new(**found_hash) if found_hash

        nil
      end

      # ## User
      # owns_many :comments
      # > user.comments
      # > [<comment1>, <comment2>]
      def owns_many(assoc, fk_name: nil, over: nil, **_options)
        singularized_assoc_name = assoc.to_s.singularize
        fk_name ||= "#{name.to_s.downcase}_id"

        define_method(assoc) do
          klass = Object.const_get(singularized_assoc_name.capitalize)
          if over
            sequel_dataset = klass
              .join(over.to_sym, "#{singularized_assoc_name}_id".to_sym => :id)
              .where(fk_name.to_sym => id)
            self.class.serialize(sequel_dataset, klass)
          else
            klass.where(fk_name.to_sym => id)
          end
        end
      end

      # ## Comment
      # owns_one :user
      # > comment.user
      # > <user>
      def owns_one(assoc, options = {})
        Sequel::Model.one_to_one(assoc, **options)
        fk_name ||= "#{name.to_s.downcase}_id"
        define_method(assoc) do
          Object.const_get(assoc.capitalize).where(fk_name.to_sym => id)&.first
        end
      end

      # ## Account
      # holds :user
      # > account.user
      # > <user>
      def holds(assoc, fk_name: nil, **_options)
        fk_name ||= "#{assoc.to_s.downcase}_id"
        define_method(assoc) do
          target_klass = Object.const_get(assoc.capitalize)
          target_klass.find(send(fk_name))
        end
      end

      def reconnect!
        return if defined?(DB) && !DB.nil?

        const_set(:DB, Sequel.connect(Rubee::Configuration.get_database_url))
      end

      def dataset
        @dataset ||= DB[pluralize_class_name.to_sym]
      rescue Exception => _e
        reconnect!
        retry
      end

      def all
        dataset.map do |record_hash|
          new(**record_hash)
        end
      end

      def find(id)
        found_hash = dataset.where(id:)&.first
        return new(**found_hash) if found_hash

        nil
      end

      def where(args)
        dataset.where(**args).map do |record_hash|
          new(**record_hash)
        end
      end

      def order(*args)
        dataset.order(*args).map do |record_hash|
          new(**record_hash)
        end
      end

      def join(assoc, args)
        dataset.join(assoc, **args)
      end

      def create(attrs)
        out_id = dataset.insert(**attrs)
        new(**attrs.merge(id: out_id))
      end

      def destroy_all(cascade: false)
        all.each { |record| record.destroy(cascade:) }
      end

      def serialize(suquel_dataset, klass = nil)
        klass ||= self
        suquel_dataset.map do |record_hash|
          target_klass_fields = DB[klass.name.pluralize.downcase.to_sym].columns
          klass_attributes = record_hash.filter { target_klass_fields.include?(_1) }
          klass.new(**klass_attributes)
        end
      end
    end
  end
end
