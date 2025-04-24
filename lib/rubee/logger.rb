module Rubee
  include Singleton

  class Logger
    def log(message, options={}, &block)
      out.send(:color_puts, message, color: :gray)

      block&.call if block_given?
    end

    def warn(message, options={}, &block)

    end

    def error(message, options={}, &block)

    end

    def info(message, options={}, &block)

    end

    def out
      @out ||= (Rubee::Configuration.get_logger || $stdout)
    end
  end
end
