require_relative '../test_helper'

class TestSerialized
  include Rubee::Serializable

  attr_accessor :id, :towel_color, :name
end

describe 'Serializable Model' do
  describe 'attributes' do
    it 'exists and settable' do
      cerealed = TestSerialized.new(id: 10, towel_color: 'blue', name: 'Ford Prefect')

      _(cerealed.id).must_equal(10)
      _(cerealed.towel_color).must_equal('blue')
      _(cerealed.name).must_equal('Ford Prefect')
    end

    it 'does not exist not settable' do
      _ { TestSerialized.new(blue: 'hello') }.must_raise(NoMethodError)
    end
  end

  describe 'coverts to' do
    before do
      @cerealed = TestSerialized.new(id: 10, towel_color: 'blue', name: 'Ford Prefect')
    end
    it 'hash' do
      _(@cerealed.to_h).must_be_instance_of(Hash)
    end

    it 'json' do
      _(@cerealed.to_json).must_be_instance_of(String)
    end
  end
end
