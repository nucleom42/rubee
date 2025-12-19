require_relative 'test_helper'

describe 'Configuration' do
  describe 'rubee_support Hash only' do
    it 'patches Hash only' do
       String.send(:undef_method, :plural?) if "".respond_to?(:plural?)
      Rubee::Configuration.setup(env = :test) do
        _1.rubee_support = { classes: [Rubee::Support::Hash] }
      end
      _({ one: 1 }['one']).must_equal(1)

      _(raise_error { "apples".plural? }.is_a?(NoMethodError)).must_equal(true)
    end
  end

  describe 'rubee_support all' do
    it 'patches Hash and String' do
      Rubee::Configuration.setup(env = :test) { _1.rubee_support = { all: true } }
      _({ one: 1 }['one']).must_equal(1)
      _("apples".plural?).must_equal(true)
    end
  end
end
