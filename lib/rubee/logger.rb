module Rubee
  class Logger
    include Singleton

    def warn(message, options = {}, &block)
      log(:warn, message, options, &block)
    end

    def error(message, options = {}, &block)
      log(:error, message, options, &block)
    end

    def info(message, options = {}, &block)
      log(:info, message, options, &block)
    end

    def log(severity, message, options = {}, &block)
      @out.send(severity, message, options)

      block&.call(message, options) if block_given?
    end

    def out
      @out ||= Rubee::Configuration.get_logger || Stdout
    end
  end

  class Stdout
    class << self
      def error(message, options = {})
        color_puts(message, color: :red)
      end

      def info(message, options = {})
        color_puts(message, color: :blue)
      end

      def warn(message, options = {})
        color_puts(message, color: :yellow)
      end
    end
  end
end
