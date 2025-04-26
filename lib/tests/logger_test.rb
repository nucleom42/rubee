require_relative 'test_helper'
require 'stringio'

describe 'Rubee::Logger' do
  describe 'logger' do
    it 'exists' do
      _(Rubee::Logger.logger).wont_be_nil
    end
  end

  describe '.warn' do
    it 'output message' do
      output = capture_stdout { Rubee::Logger.warn(message: 'test') }

      _(output).must_equal("test\n")
    end
  end

  describe '.info' do
    it 'output message' do
      output = capture_stdout { Rubee::Logger.info(message: 'test') }

      _(output).must_equal("test\n")
    end
  end

  describe '.error' do
    it 'output message' do
      output = capture_stdout { Rubee::Logger.error(message: 'test') }

      _(output).must_equal("test\n")
    end
  end

  describe '.critical' do
    it 'output message' do
      output = capture_stdout { Rubee::Logger.critical(message: 'test') }

      _(output).must_equal("test\n")
    end
  end

  describe '.debug' do
    it 'output message' do
      output = capture_stdout { Rubee::Logger.debug(object: User.new) }

      _(output).must_equal("test\n")
    end
  end
end
