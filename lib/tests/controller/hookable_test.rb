require_relative '../test_helper'

class TestResponder
  def call
    true
  end
end

class TestFailResponder
  def call
    false
  end
end

class TestHookable
  include Rubee::Hookable

  attr_accessor :value, :glue, :varty

  before :before_around_after, :set_value
  around :before_around_after, :set_around
  after :before_around_after, :set_glue

  before :before_after_around, :set_value
  after :before_after_around, :set_glue
  around :before_after_around, :set_around

  around :around_before_after, :set_around
  before :around_before_after, :set_value
  after :around_before_after, :set_glue

  around :around_after_before, :set_around
  after :around_after_before, :set_glue
  before :around_after_before, :set_value
  
  after :after_around_before, :set_glue
  around :after_around_before, :set_around
  before :after_around_before, :set_value

  after :after_before_around, :set_glue
  before :after_before_around, :set_value
  around :after_before_around, :set_around



  # With responder conditions
  after :set_if_condition, :set_glue, if: TestResponder.new
  after :set_unless_condition, :set_glue, unless: TestResponder.new

  around :failed_around, :set_value, if: TestFailResponder.new
  around :success_around, TestResponder.new

  # With local conditional
  before :prep_if_condition, :set_value
  after :set_if_condition, :set_glue, if: :value_red
  before :prep_unless_condition, :set_value
  after :set_unless_condition, :set_glue, unless: :value_red

  
  def after_around_before; end
  def before_around_after; end
  def around_before_after; end
  def after_before_around; end
  def before_after_around; end
  def around_after_before; end

  def prep_if_condition; end
  def set_if_condition; end

  def prep_unless_condition; end
  def set_unless_condition; end

  def failed_around; end
  def success_around; end

  def value_red
    value == 'red'
  end

  private

  def set_value
    @value = 'red'
  end

  def set_glue
    @glue = 'white'
  end

  def set_around
    @varty = 'something'
  end
end

describe 'Hookable Controller' do
  describe 'combinations of order' do
    it 'does not have anything called' do
      hookable = TestHookable.new

      _(hookable.value).must_be_nil
      _(hookable.glue).must_be_nil
      _(hookable.varty).must_be_nil
    end

    it 'before_around_after' do
      hookable = TestHookable.new
      hookable.before_around_after

      _(hookable.value).must_equal('red')
      _(hookable.glue).must_equal('white')
      _(hookable.varty).must_equal('something')
    end

    it 'before_after_around' do
      hookable = TestHookable.new
      hookable.before_after_around

      _(hookable.value).must_equal('red')
      _(hookable.glue).must_equal('white')
      _(hookable.varty).must_equal('something')
    end

    it 'around_before_after' do
      hookable = TestHookable.new
      hookable.around_before_after

      _(hookable.value).must_equal('red')
      _(hookable.glue).must_equal('white')
      _(hookable.varty).must_equal('something')
    end

    it 'around_after_before' do
      hookable = TestHookable.new
      hookable.around_after_before

      _(hookable.value).must_equal('red')
      _(hookable.glue).must_equal('white')
      _(hookable.varty).must_equal('something')
    end

    it 'after_around_before' do
      hookable = TestHookable.new
      hookable.after_around_before

      _(hookable.value).must_equal('red')
      _(hookable.glue).must_equal('white')
      _(hookable.varty).must_equal('something')
    end

    it 'after_before_around' do
      hookable = TestHookable.new
      hookable.after_before_around

      _(hookable.value).must_equal('red')
      _(hookable.glue).must_equal('white')
      _(hookable.varty).must_equal('something')
    end

  end

  describe 'conditions' do
    it 'does not set glue if condition' do
      hookable = TestHookable.new

      hookable.set_if_condition

      _(hookable.value).must_be_nil
    end

    it 'does set glue if condition' do
      hookable = TestHookable.new

      hookable.prep_if_condition
      hookable.set_if_condition

      _(hookable.value).must_equal('red')
    end

    it 'does not set glue if condition' do
      hookable = TestHookable.new

      hookable.set_unless_condition

      _(hookable.value).must_be_nil
    end

    it 'does set glue if condition' do
      hookable = TestHookable.new

      hookable.prep_unless_condition
      hookable.set_unless_condition

      _(hookable.value).must_equal('red')
    end


    it 'checks around for failure' do
      hookable = TestHookable.new

      hookable.failed_around

      _(hookable.glue).must_be_nil
    end

    it 'checks around success' do
      hookable = TestHookable.new

      hookable.success_around

      _(hookable.glue).must_be_nil
    end
  end
end
