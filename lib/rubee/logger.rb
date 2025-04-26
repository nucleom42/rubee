module Rubee
  class Logger
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

      def log(severity, message, options = {}, &block)
        time = Time.now.strftime('%Y-%m-%d %H:%M:%S')
        if options.any?
          message = options.map { |k, v| "[#{k}: #{v}]" }.join << " #{message}"
        end
        out.send(severity, "[#{time}] #{severity.upcase} #{message}")

        block&.call(message, options) if block_given?
      end

      def out
        @out ||= Rubee::Configuration.get_logger || Stdout
      end
    end
  end

  class Stdout
    class << self
      def error(message)
        color_puts(message, color: :red)
      end

      def info(message)
        color_puts(message, color: :gray)
      end

      def warn(message)
        color_puts(message, color: :yellow)
      end

      def debug(message)
        color_puts(message)
      end

      def critical(message)
        color_puts(message, color: :red, style: :blink)
      end
    end
  end
end
