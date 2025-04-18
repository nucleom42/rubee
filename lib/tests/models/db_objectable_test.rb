require_relative '../test_helper'

class MergBerg
  include Rubee::DatabaseObjectable
  attr_accessor :id, :foo, :bar
end

describe 'Database Objectable' do
  describe 'class methods' do
    it 'pluralizes class names' do
      _(MergBerg.pluralize_class_name).must_equal('mergbergs')
    end

    it 'pluralizes words' do
      _(MergBerg.pluralize('pony')).must_equal('ponies')
      _(MergBerg.pluralize('hand')).must_equal('hands')
      _(MergBerg.pluralize('fox')).must_equal('foxes')
    end

    it 'singularizes words' do
      _(MergBerg.singularize('ponies')).must_equal('pony')
      _(MergBerg.singularize('hands')).must_equal('hand')
      _(MergBerg.singularize('foxes')).must_equal('fox')
      _(MergBerg.singularize('moon')).must_equal('moon')
    end

    it 'retrieves accessor names' do
      accessors = MergBerg.accessor_names
      _(accessors).must_include(:id)
      _(accessors).must_include(:foo)
      _(accessors).must_include(:bar)
    end
  end
end
