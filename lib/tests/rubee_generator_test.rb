require_relative 'test_helper'

describe 'Rubee::Generator' do
  describe 'generates Sequel schema lines' do
    it 'for string with just name' do
      generator = Rubee::Generator.new('', '', '', {})

      attribute = { name: 'something', type: :string }

      text = generator.send(:generate_sequel_schema, attribute)

      _(text).must_equal('String :something')
    end
  end
end