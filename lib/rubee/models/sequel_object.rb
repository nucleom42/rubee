module Rubee
  class SequelObject < DatabaseObject
    DB = Sequel.connect(Rubee::Configuration.get_database_url) rescue nil

    def destroy
      self.class.connection.where(id:).delete
    end

    def save
      args = to_h.dup&.transform_keys(&:to_sym)
      if args[:id]
        udpate(args) rescue return false

        true
      else
        created_object = self.class.create(args) rescue return false
        self.id = created_object.id

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

      def first
        found_hash = connection.order(:id).first
        return self.new(**found_hash) if found_hash

        nil
      end

      # ## User
      # owns_many :comments
      # > user.comments
      # > [<comment1>, <comment2>]
      def owns_many(assoc, fk_name: nil, over: nil)
        singularized_assoc_name = singularize(assoc.to_s)
        fk_name ||= "#{self.name.to_s.downcase}_id"
        define_method(assoc) do
          klass = Object.const_get(singularized_assoc_name.capitalize)
          if over
            sequel_dataset = klass
              .join(over.to_sym, "#{singularized_assoc_name}_id".to_sym => :id)
              .where(fk_name.to_sym => id)
            self.class.sequel_to_obj(sequel_dataset, klass)
          else
            klass.where(fk_name.to_sym => id)
          end
        end
      end

      # ## Comment
      # owns_one :user
      # > comment.user
      # > <user>
      def owns_one(assoc, fk_name: nil)
        fk_name ||= "#{self.name.to_s.downcase}_id"
        define_method(assoc) do
          Object.const_get(assoc.capitalize).where(fk_name.to_sym => id)&.first
        end
      end

      # ## Account
      # holds_one :user
      # > account.user
      # > <user>
      def holds_one(assoc, fk_name: nil)
        fk_name ||= "#{assoc.to_s.downcase}_id"
        define_method(assoc) do
          target_klass = Object.const_get(assoc.capitalize)
          target_klass.find(self.send(fk_name))
        end
      end

      # ## Post
      # holds_many :comments
      # > post.comments
      # > [<comment1>, <comment2>]
      def holds_many(assoc, fk_name: nil)
        singularized_assoc_name = singularize(assoc.to_s)
        fk_name ||= "#{singularized_assoc_name.to_s.downcase}_id"
        define_method(assoc) do
          Object.const_get(singularized_assoc_name.capitalize).where(id: self.send(fk_name))
        end
      end

      def reconnect!
        const_set(:DB, Sequel.connect(Rubee::Configuration.get_database_url))
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

      def join(assoc, args)
        connection.join(assoc, **args)
      end

      def create(attrs)
        out_id = connection.insert(**attrs)
        self.new(**(attrs.merge(id: out_id)))
      end

      def destroy_all
        all.each(&:destroy)
      end

      def sequel_to_obj(suquel_dataset, klass)
        suquel_dataset.map do |record_hash|
          klass.new(**record_hash)
        end
      end
    end
  end
end
