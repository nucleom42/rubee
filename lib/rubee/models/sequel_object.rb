module Rubee
  class SequelObject
    include Rubee::DatabaseObjectable
    using ChargedString
    using ChargedHash

    before :update, :save, :set_timestamps

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
          update(args)
        rescue StandardError => _e
          add_error(:base, sequel_error: e.message)
          return false
        end

      else
        begin
          created_id = self.class.dataset.insert(args)
        rescue StandardError => e
          add_error(:base, sequel_error: e.message)
          return false
        end
        self.id = created_id
      end
      true
    end

    def assign_attributes(args = {})
      self.class.dataset.columns.each do |attr|
        if args[attr.to_sym]
          send("#{attr}=", args[attr.to_sym])
        end
      end
    end

    def update(args = {})
      assign_attributes(args)
      args.merge!(updated:)
      found_hash = self.class.dataset.where(id:)
      return self.class.find(id) if Rubee::DBTools.with_retry { found_hash&.update(**args) }

      false
    end

    def persisted?
      !!id
    end

    def reload
      self.class.find(id)
    end

    private

    def set_timestamps
      return unless respond_to?(:created) && respond_to?(:updated)

      self.created ||= Time.now
      self.updated = Time.now
    end

    class << self
      def last
        found_hash = dataset.order(:id).last
        return new(**found_hash) if found_hash

        nil
      end

      def count
        dataset.count
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
      def owns_many(assoc, fk_name: nil, over: nil, **options)
        singularized_assoc_name = assoc.to_s.singularize
        fk_name ||= "#{name.to_s.downcase}_id"
        namespace = options[:namespace]

        define_method(assoc) do
          assoc = if namespace
            "::#{namespace.to_s.camelize}::#{singularized_assoc_name.camelize}"
          else
            singularized_assoc_name.camelize
          end
          klass = Object.const_get(assoc)
          if over
            sequel_dataset = klass
              .join(over.to_sym, "#{singularized_assoc_name.snakeize}_id".to_sym => :id)
              .where(Sequel[over][fk_name.to_sym] => id)
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
      def owns_one(assoc, fk_name: nil, **options)
        fk_name ||= "#{name.to_s.downcase}_id"
        namespace = options[:namespace]
        define_method(assoc) do
          assoc = if namespace
            "::#{namespace.to_s.camelize}::#{assoc.to_s.camelize}"
          else
            assoc.to_s.camelize
          end
          Object.const_get(assoc).where(fk_name.to_sym => id)&.first
        end
      end

      # ## Account
      # holds :user
      # > account.user
      # > <user>
      def holds(assoc, fk_name: nil, **options)
        namespace = options[:namespace]
        fk_name ||= "#{assoc.to_s.downcase}_id"
        define_method(assoc) do
          klass_string = if namespace
            "::#{namespace.to_s.camelize}::#{assoc.to_s.camelize}"
          else
            assoc.to_s.camelize
          end
          target_klass = Object.const_get(klass_string)
          target_klass.find(send(fk_name))
        end
      end

      def reconnect!
        return if defined?(DB) && !DB.nil?

        db_url = Rubee::Configuration.get_database_url
        uri = URI.parse(db_url)

        if uri.scheme == 'sqlite' || uri.scheme == 'sqlite3'
          db_path = db_url.sub(%r{^sqlite://}, '')
          if Rubee::DBTools.valid_sqlite_database_exists?(db_path)
            const_set(:DB, Sequel.connect(db_url))
          else
            # Set DB to nil to avoid infinite loops, but allow future retries
            const_set(:DB, nil) unless defined?(DB)
            return false
          end
        else
          const_set(:DB, Sequel.connect(db_url))
        end

        Rubee::DBTools.set_prerequisites!
        true
      end

      def dataset
        @dataset ||= DB[pluralize_class_name.to_sym]
      rescue Exception => e
        reconnect!
        @__reconnect_count ||= 0
        @__reconnect_count += 1
        if @__reconnect_count > 3
          raise e
        end
        sleep(0.1)
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
        if dataset.columns.include?(:created) && dataset.columns.include?(:updated)
          attrs.merge!(created: Time.now, updated: Time.now)
        end
        instance = new(**attrs)
        Rubee::DBTools.with_retry { instance.save }
        instance
      end

      def destroy_all(cascade: false)
        all.each { |record| record.destroy(cascade:) }
      end

      def serialize(suquel_dataset, klass = nil)
        klass ||= self
        target_klass_fields = DB[klass.name.snakeize.pluralize.downcase.to_sym].columns
        suquel_dataset.map do |record_hash|
          klass_attributes = record_hash.filter { target_klass_fields.include?(_1) }
          klass.new(**klass_attributes)
        end
      end

      def validate_before_persist!
        before(:save, proc { |model| raise Rubee::Validatable::Error, model.errors.to_s }, if: :invalid?)
        before(:update, proc do |model, args|
          if (instance = model.class.new(*args)) && instance.invalid?
            raise Rubee::Validatable::Error, instance.errors.to_s
          end
        end)
      end

    end
  end
end
