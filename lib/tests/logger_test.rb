require_relative 'test_helper'

describe 'Rubee::Logger' do
  describe 'logger' do
    it 'exists' do
      _(Rubee::Logger).wont_be_nil
    end
  end

  describe '.warn' do
    it 'output message' do
      output = capture_stdout { Rubee::Logger.warn(message: 'test') }

      assert_includes(output, "WARN test")
    end
  end

  describe '.info' do
    it 'output message' do
      output = capture_stdout { Rubee::Logger.info(message: 'test') }

      assert_includes(output, "INFO test")
    end
  end

  describe '.error' do
    it 'output message' do
      output = capture_stdout { Rubee::Logger.error(message: 'test') }

      assert_includes(output, "ERROR test")
    end
  end

  describe '.critical' do
    it 'output message' do
      output = capture_stdout { Rubee::Logger.critical(message: 'test') }

      assert_includes(output, "CRITICAL test")
    end
  end

  describe '.debug' do
    it 'output message' do
      output = capture_stdout { Rubee::Logger.debug(object: User.new(email: 'ok@ok.com', password: 123)) }

      assert_includes(output, "DEBUG #<User:")
    end
  end
end
