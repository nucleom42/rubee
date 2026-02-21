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
        rescue StandardError => e
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
        original_assoc = assoc
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
              .dataset
              .join(over.to_sym, "#{singularized_assoc_name.snakeize}_id".to_sym => :id)
              .where(Sequel[over][fk_name.to_sym] => id).select_all(original_assoc)

            ::Rubee::AssocArray.new([], klass, sequel_dataset)
          else
            ::Rubee::AssocArray.new([], klass, klass.dataset.where(fk_name.to_sym => id))
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
        return if db_set?

        const_set(:DB, Sequel.connect(Rubee::Configuration.get_database_url))

        Rubee::DBTools.set_prerequisites!

        true
      rescue Exception => e
        false
      end

      def db_set?
        defined?(DB) && !DB.nil?
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
        ::Rubee::AssocArray.new([], self, dataset)
      end

      def find(id)
        found_hash = dataset.where(id:)&.first
        return new(**found_hash) if found_hash

        nil
      end

      def where(args, options = {})
        query_dataset = options[:__query_dataset] || dataset

        ::Rubee::AssocArray.new([], self, query_dataset.where(**args))
      end

      def order(args, options = {})
        query_dataset = options[:__query_dataset] || dataset

        order_arg = if args.is_a? Hash
          args.values[0] == :desc ? Sequel.desc(args.keys[0]) : Sequel.asc(args.keys[0])
        else
          args
        end
        ::Rubee::AssocArray.new([], self, query_dataset.order(order_arg))
      end

      def join(assoc, args, options = {})
        query_dataset = options[:__query_dataset] || dataset

        ::Rubee::AssocArray.new([], self, query_dataset.join(assoc, **args))
      end

      def limit(args, options = {})
        query_dataset = options[:__query_dataset] || dataset

        ::Rubee::AssocArray.new([], self, query_dataset.limit(*args))
      end

      def offset(args, options = {})
        query_dataset = options[:__query_dataset] || dataset

        ::Rubee::AssocArray.new([], self, query_dataset.offset(*args))
      end

      def paginate(page = 1, per_page = 10, options = {})
        query_dataset = options[:__query_dataset] || dataset
        offset = (page - 1) * per_page

        ::Rubee::AssocArray.new([], self, query_dataset.offset(offset).limit(per_page),
                       pagination_meta: options[:__pagination_meta])
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
          dup__instance = model.dup
          dup__instance.assign_attributes(**args[0])
          if dup__instance.invalid?
            raise Rubee::Validatable::Error, dup__instance.errors.to_s
          end
        end)
      end

      def find_or_new(attrs = {})
        where(attrs).first || new(**attrs)
      end
    end
  end
end
