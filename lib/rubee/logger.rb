module Rubee
  class Logger
    class << self
      def warn(message:, **options, &block)
        out.warn(message:, **options, &block)
      end

      def error(message:, **options, &block)
        out.error(message:, **options, &block)
      end

      def critical(message:, **options, &block)
        out.critical(message:, **options, &block)
      end

      def info(message:, **options, &block)
        out.info(message:, **options, &block)
      end

      def debug(object:, **options, &block)
        out.debug(object:, **options, &block)
      end

      def out
        Rubee::Configuration.get_logger || Stdout
      end
    end
  end

  class Stdout
    class << self
      def warn(message:, **options, &block)
        log(:warn, message, options, &block)
      end

      def error(message:, **options, &block)
        log(:error, message, options, &block)
      end

      def critical(message:, **options, &block)
        log(:critical, message, options, &block)
      end

      def info(message:, **options, &block)
        log(:info, message, options, &block)
      end

      def debug(object:, **options, &block)
        log(:debug, object.inspect, options, &block)
      end

      def print_error(message)
        color_puts(message, color: :red)
      end

      def print_info(message)
        color_puts(message, color: :gray)
      end

      def print_warn(message)
        color_puts(message, color: :yellow)
      end

      def print_debug(message)
        color_puts(message)
      end

      def print_critical(message)
        color_puts(message, color: :red, style: :blink)
      end

      def log(severity, message, options = {}, &block)
        time = Time.now.strftime('%Y-%m-%d %H:%M:%S')
        if options.any?
          message = options.map { |k, v| "[#{k}: #{v}]" }.join << " #{message}"
        end
        send("print_#{severity}", "[#{time}] #{severity.upcase} #{message}")

        block&.call(message, options) if block_given?
      end
    end
  end
end
