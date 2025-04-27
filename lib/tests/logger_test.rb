require_relative 'test_helper'

class CustomLogger
  class << self
    def warn(message:, **options, &block); end

    def info(message:, **options, &block)
      puts "CUSTOM INFO #{message}"
    end

    def error(message:, **options, &block); end

    def critical(message:, **options, &block); end

    def debug(object:, **options, &block); end
  end
end

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

  describe 'when custom logger defined in the configuration' do
    it 'uses custom logger' do
      Rubee::Configuration.setup(env = :test) { _1.logger = { logger: CustomLogger, env: } }

      output = capture_stdout { Rubee::Logger.info(message: 'test') }
      assert_includes(output, "CUSTOM INFO test")

      Rubee::Configuration.setup(env = :test) { _1.logger = { env: } }
    end
  end
end
